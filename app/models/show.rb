require 'show_data_importer'

class Show
  include DataMapper::Resource
  property :id,     Serial
  
  property :title, String, :nullable => false
  
  # tvrage data
  property :tvrage_id, String
  property :tvrage_processed_at, Time
  property :tvrage_data, Json
  property :tvrage_status, String
  
  # tvrage episode data
  property :tvrage_episodes_processed_at, Time, :nullable => true
  property :tvrage_episodes_data, Json
  
  # tvdb data
  property :tvdb_id, String
  property :tvdb_processed_at, Time
  property :tvdb_data, Json
  property :tvdb_description, Text
  property :tvdb_thumb_url, String, :size => 512
  property :tvdb_fanart_url, String, :size => 512
  property :tvdb_poster_url, String, :size => 512
  property :tvdb_banner_url, String, :size => 512
  
  property :favorite_count, Integer, :default => 0
  property :alert_count, Integer, :default => 0
  property :sort_key, Integer, :default => 0
  
  property :cancelled, Boolean, :default => :false
  
  # tvdb assets
  property :tvdb_assets_processed_at, Time, :nullable => true

  timestamps :at  
  
  # includes methods that populate show data from external sources
  include ShowDataImporter
  
  def self.from_tvrage(id)
    show = first(:tvrage_id => id)
    
    # create show if not already exists
    if show
      show.refresh_tvrage
    else
      data = TvRage.get_info(id)
      return nil unless data && data["showname"]    
      show = new(:tvrage_id => id)
      show.title = data["showname"]
      show.refresh_tvrage(data)
    end

    show
  end
  
  def self.top_shows(opts = {})
    opts = {:limit => 12}.merge(opts)
    Show.all(:limit => opts[:limit], :order => [:favorite_count.desc])
  end
end