class Hash
  def to_hash
    return self
  end
end

class NilClass
  def <=>(other)
    return 0
  end
  
  def to_hash
    return {}
  end
end

class Object  
  
  # Rails 2.3 feature
  # tries to run a method, returns nil if it doesn exist
  def try(method, *args, &block)
    send(method, *args, &block) if respond_to?(method, true)
  end
  
  # check if an attribute responds and is present
  def responds_and_present?(sym)
    if respond_to? sym
      return send(sym).present?
    else
      return false
    end
  end  
end

class String
  def to_bool
    if self == "1" or self.downcase == "true" or self.downcase == "yes"
      return true
    else
      return false
    end
  end
  
  # Does the string start with the specified +prefix+?
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end
  alias_method :start_with?, :starts_with?

  # Does the string end with the specified +suffix+?
  def ends_with?(suffix)
    suffix = suffix.to_s
    self[-suffix.length, suffix.length] == suffix      
  end
  alias_method :end_with?, :ends_with?
end

# allow easier checking of new vs existing
module DataMapper::Resource
  def existing_record?
    !new_record?
  end
end