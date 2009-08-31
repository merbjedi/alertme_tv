require 'tv_db'
require 'tv_rage'
module ShowDataImporter
  # refresh all the shows
  def refresh
    [
      refresh_tvrage,
      refresh_tvrage_episodes,
      refresh_tvdb,
      refresh_tvdb_assets
    ].any?{|result| result }
  end
  alias :refresh_all :refresh 

  # force refresh of the show data (SLOW!)
  def refresh!
    [
      refresh_tvrage!,
      refresh_tvrage_episodes!,
      refresh_tvdb!,
      refresh_tvdb_assets!
    ].any?{|result| result }
  end
  alias :refresh_all! :refresh!
  
  # refresh show details from tvrage
  def refresh_tvrage(data = nil)
    return unless data || AlertMe.needs_update?(tvrage_processed_at, AppConfig.tvrage.cache)
    
    # fetch show data
    data ||= TvRage.get_info(tvrage_id)
    
    # set tvrage data
    self.cancelled = data["ended"] ? true : false
    self.tvrage_status = data["status"]
    self.tvrage_data = data.reject{|k,v| k == "Episodelist"}
    self.tvrage_processed_at = Time.now
    self.save
  end
  
  def refresh_tvrage!
    refresh_tvrage TvRage.get_info(tvrage_id)
  end  
  
  # refresh show episodes from tvrage
  def refresh_tvrage_episodes(data = nil)
    return unless data || AlertMe.needs_update?(tvrage_episodes_processed_at, AppConfig.tvrage.episode_cache)
    
    # fetch episode data    
    data ||= TvRage.get_latest_episodes(tvrage_id)
    
    self.tvrage_episodes_data = data
    self.tvrage_episodes_processed_at = Time.now
    self.save
  end
  
  def refresh_tvrage_episodes!
    refresh_tvrage_episodes TvRage.get_latest_episodes(tvrage_id)
  end
      
  # refresh show details from tvdb
  def refresh_tvdb(data = nil)
    return unless data || AlertMe.needs_update?(tvdb_processed_at, AppConfig.tvdb.cache)
    
    data ||= TvDb.get_series(self.title)
    self.tvdb_id = data["seriesid"]
    self.tvdb_description = data["Overview"]
    self.tvdb_data = data
    self.tvdb_processed_at = Time.now

    self.save
  end
  
  def refresh_tvdb!
    refresh_tvdb(TvDb.get_series(self.title))
  end
  
  # refresh tvdb assets (images, etc)
  def refresh_tvdb_assets(force = false)
    return unless force || AlertMe.needs_update?(tvdb_assets_processed_at, AppConfig.tvdb.assets_cache)
    
    # make sure we refresh tvdb first
    refresh_tvdb
    return unless tvdb_id
    
    self.tvdb_thumb_url  = TvDb.download_fan_art(tvdb_id, :thumbnail => true)
    self.tvdb_fanart_url = TvDb.download_fan_art(tvdb_id)
    self.tvdb_banner_url = TvDb.download_series_art(tvdb_id)
    self.tvdb_poster_url = TvDb.download_poster_art(tvdb_id)

    # on success
    self.tvdb_assets_processed_at = Time.now
    self.save
  end
  
  def refresh_tvdb_assets!
    refresh_tvdb_assets(true)
  end
end