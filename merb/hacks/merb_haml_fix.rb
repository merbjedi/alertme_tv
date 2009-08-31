# hack to allow merb-haml to keep working
class File
  class << self
    alias :orig_directory? :directory?
  end
  def self.directory?(args)
    if args.is_a?(Hash)
      orig_directory?(args.keys.first)
    else
      orig_directory?(args)
    end
  end
end