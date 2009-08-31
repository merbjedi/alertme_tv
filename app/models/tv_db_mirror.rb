class TvDbMirror
  include DataMapper::Resource
  
  # these are defined at http://thetvdb.com/wiki/index.php/API:mirrors.xml
  TYPES = {1 => :xml, 2 => :banner, 4 => :zip}
  
  property :id, Serial
  property :tvdb_id, Integer, :nullable => false
  property :path, String, :size => 512, :nullable => false
  property :type, Enum[:xml, :banner, :zip]
  
  timestamps :at
  
  # pick an xml mirror for tvdb
  def self.xml_mirror_path
    refresh_all
    mirror = all(:type => :xml).to_a.pick
    mirror ? mirror.path : nil
  end
  
  # pick an banner mirror for tvdb
  def self.banner_mirror_path
    refresh_all
    mirror = all(:type => :banner).to_a.pick
    mirror ? mirror.path : nil
  end
  
  # pick an zip mirror for tvdb
  def self.zip_mirror_path
    refresh_all
    mirror = all(:type => :xml).to_a.pick
    mirror ? mirror.path : nil
  end
  
  # refresh mirrors
  def self.refresh_all!
    refresh_all(true)
  end

  def self.refresh_all(force = false)
    return unless force || AlertMe.needs_update?(AlertMe.tvdb_mirror_updated_at, AppConfig.tvdb.mirror_cache)
    
    mirrors = TvDb.get_mirrors
    return false unless mirrors.present?
    
    all.destroy!
    mirrors.each do |mirror_data|
      create_mirrors_from_typemask(mirror_data, mirror_data["typemask"].to_i)
    end
    
    AlertMe.tvdb_mirror_updated_at = Time.now

    true
  end
  
  protected
  def self.create_mirrors_from_typemask(mirror_data, typemask)
    # first we need to convert the typemask into types
    types = self.translate_typemask(typemask).map{|i| TYPES[i]}.compact
    # create a mirror for each type found
    types.each do |type|
      create_mirror_from_xml(mirror_data, type)
    end
  end
  
  def self.create_mirror_from_xml(mirror_data, type)
    create(:tvdb_id => mirror_data["id"], :path => mirror_data["mirrorpath"], :type => type)
  end
  
  # retarded way to do bit operations
  def self.translate_typemask(typemask)
    case typemask
    when 1
      [1]
    when 2
      [2]
    when 3
      [1,2]
    when 4
      [4]
    when 5
      [1,4]
    when 6
      [2,4]
    when 7
      [1,2,4]
    else
      []
    end
  end

end