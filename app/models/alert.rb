class Alert
  include DataMapper::Resource
  property :id,     Serial
  
  belongs_to :user
  belongs_to :show

  # how long before/after a show airs to send notification
  property :time_delay, Integer, :default => -1.day
  
  property :email_enabled, Boolean, :default => false
  property :im_enabled, Boolean, :default => false
  property :sms_enabled, Boolean, :default => false
  
  property :before_or_after, Integer, :default => -1

  timestamps :at  
  
  # fetch an alert
  def self.from_pair(user, show)
    alert = first(:user_id => user.id, :show_id => show.id)
    unless alert
      alert = new(:user_id => user.id, :show_id => show.id)
    end
    alert
  end
  
  def self.set_alert(user, show, attributes = {})
    a = Alert.from_pair(user, show)
    before_or_after = attributes[:before_or_after].to_i
    a.attributes = attributes.slice(:time_delay, :email_enabled, :im_enabled, :sms_enabled, :before_or_after)
    a.save
    
    a
  end  
  
  def schedule_description
    result = "will alert "
    if time_delay == 1.week
      result << "1 week "
    elsif time_delay == 1.day
      result << "1 day "
    end
    
    if before_or_after > 1
      result << " after"
    else
      result << " before"
    end
    
    result
  end
  
  def types_description
    types = []
    types << "email" if email_enabled?
    types << "sms" if sms_enabled?
    types << "instant messager" if im_enabled?

    
    if types.size > 0
      "via #{types.join(', ')}"
    else
      ""
    end
  end
end