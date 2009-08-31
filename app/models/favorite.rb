class Favorite
  include DataMapper::Resource
  
  property :id, Serial

  belongs_to :user
  belongs_to :show
  
  timestamps :at
  
  # fetch an alert
  def self.from_pair(user, show)
    fav = first(:user_id => user.id, :show_id => show.id)
    unless fav
      fav = new(:user_id => user.id, :show_id => show.id)
    end
    fav
  end
  
end