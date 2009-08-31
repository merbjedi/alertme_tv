class AlertMe
  include DataMapper::Resource
  storage_names[:default] = "alert_me"
  property :id, Serial

  property :key, String, :nullable => false
  property :val, String  
  
  def self.[](k)
    result = first(:key => k)
    result ? result.val : nil
  end
    
  def self.[]=(k, v)
    all(:key => k).destroy!
    create(:key => k, :val => v.to_s)
  end
  
  
  def self.tvdb_mirror_updated_at
    if self["tvdb_mirror_updated_at"]
      Time.parse(self["tvdb_mirror_updated_at"])
    else
      nil
    end
  end
  
  def self.tvdb_mirror_updated_at=(new_val)
    self["tvdb_mirror_updated_at"] = new_val
  end
  
  # see if a particular cache date property needs updating
  def self.needs_update?(last_updated, cache_time = 1.day)
    return true unless last_updated
    cache_time ||= 1.day
    last_updated < (Time.now - cache_time)
  end  
  
end