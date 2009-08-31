require 'merb-auth-more/mixins/salted_user'

# This is a default user class used to activate merb-auth.  Feel free to change from a User to 
# Some other class, or to remove it altogether.  If removed, merb-auth may not work by default.
#
# Don't forget that by default the salted_user mixin is used from merb-more
# You'll need to setup your db as per the salted_user mixin, and you'll need
# To use :password, and :password_confirmation when creating a user
#
# see merb/merb-auth/setup.rb to see how to disable the salted_user mixin
# 
# You will need to setup your database and create a user.
class User
  include DataMapper::Resource
  include Merb::Authentication::Mixins::AuthenticatedUser
  include Merb::Authentication::Mixins::SaltedUser

  
  property :id,     Serial
  property :username, String, :size => 40
  
  property :crypted_password, String, :size => 40
  property :salt, String, :size => 40

  property :ip_address, String
  
  property :auth_token, String, :nullable => true

  property :activation_code, String, :size => 40
  property :activated_at, DateTime
  
  # alert data
  property :email, String, :size => 255, :nullable => true
  property :gtalk_id, String, :size => 255, :nullable => true
  property :sms_carrier, String, :nullable => true
  property :sms_number, String, :nullable => true
  
  has n, :favorites
  has n, :alerts
  
  # validations
  validates_present :username, :when => [:signup]
  validates_is_unique :username, :when => [:default, :signup, :change_password]
  validates_format :username, :with => /^(\w|\.)+$/i, :when => [:signup], :message => "can only contain letters and numbers"
  
  # signup validations
  validates_present :password, :when => [:signup, :change_password]
  validates_is_confirmed :password, :when => [:signup, :change_password]
  
  validates_format :email, :as => :email_address, :allow_nil => true, :when => [:update_contact]
  validates_format :gtalk_id, :as => :email_address, :allow_nil => true, :when => [:update_contact]
  
  # nillify blank attributes
  before :valid?, :nillify
  
  timestamps :at  
  
  attr_accessor :totally_new
  
  # user states
  is :state_machine, :initial => :anonymous, :column => :state do
    state :anonymous
    state :pending, :enter => :on_pending
    state :active, :enter => :on_active

    event :register do
      transition :from => :anonymous, :to => :pending
    end

    event :activate do
      transition :from => :pending, :to => :active
    end
  end
  
  def url
    "#{AppConfig.site_url}/u/#{username}"
  end

  def self.create_anonymous!(attributes = {})
    u = create!(attributes)
    u.totally_new = true
    u
  end

  def self.authenticate(login, password)
    @u = first(:username => login)
    @u ||= first(:email => login) if login.present?
    @u && @u.authenticated?(password) ? @u : nil
  end
  
  def self.make_token
    seed = [Time.now, (1..10).map{ rand.to_s }]
    Digest::SHA1.hexdigest(seed.flatten.join('--'))
  end 
  
  def password_required?
    return false if anonymous?
    crypted_password.blank? || !password.blank?
  end
  
  def favorites_count
    @_favorites_count ||= favorites.count
    @_favorites_count
  end
  
  def alerts_count
    @_alerts_count ||= alerts.count
    @_alerts_count
  end
  
  def favorite_show?(show)
    favorites.first(:show_id => show.id) ? true : false
  end
  
  # sets a user up (login, password, etc)
  def setup(attributes = {})
    self.attributes = attributes
    
    # on successful user setup, we should remove the old activation code
    self.activation_code = nil
    
    if save(:signup)
      
      # mark user as registered
      if anonymous?
        register!
        save!
      end

      # activate user if not already active
      if pending?
        activate!
        save!
      end
      
      return true
    else
      return false
    end
  end
  
  # generate a random password
  def self.random_password(size = 8)
    charset = %w{2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join.downcase
  end
  
  # add active check to authentication
  def self.authenticate(username, password)
    u = super(username, password)
    if u && u.active?
      u
    else
      nil
    end
  end
  
  # helper methods for states
  def active?
    state == "active"
  end

  def pending?
    state == "pending"
  end

  def anonymous?
    state == "anonymous"
  end

  protected
  
  # fired when going from anonymous to pending
  def on_pending
    # generate activation code
    self.activation_code = self.class.make_token[0...8]
    
    # send confirmation email
    send_confirmation

    return true
  end
  
  # overwrite me to handle sending registration confirmation emails
  def send_confirmation
  end
  
  # fired when going from pending to active
  def on_active
    # set activation time
    self.activated_at = Time.now

    # send success email
    send_success

    return true
  end
  
  # overwrite me to handle sending success emails
  def send_success
  end
  
  
  def nillify
    self.email = nil if email.blank?
    self.password = nil if password.blank?
    self.password_confirmation = nil if password_confirmation.blank?
  end
  
end
