require 'fileutils'
class TvDb
  include HTTParty
  base_uri AppConfig.tvdb.service_url
  http_proxy AppConfig.proxy_addr, AppConfig.proxy_port
  format :xml
  
  # http://www.thetvdb.com/api/GetSeries.php?seriesname=
  def self.get_series(name)
    result = get("/api/GetSeries.php", :query => {:seriesname => name})
    
    if result && result["Data"]
      [result["Data"]["Series"]].flatten.first
    else
      nil
    end
  end
  
  def self.get_mirrors
    results = get("/api/#{AppConfig.tvdb.api_key}/mirrors.xml")
    [results["Mirrors"]["Mirror"]].flatten.compact if results
  end
  
  # download series data
  def self.download_data(series_id)
    download_url = "#{TvDbMirror.zip_mirror_path}/api/#{AppConfig.tvdb.api_key}/series/#{series_id}/all/#{AppConfig.tvdb.default_lang}.zip"
    
    save_zip_path = "#{AppConfig.tv_assets_path / series_path(series_id)}.zip"
    FileUtils.mkdir_p(File.dirname(save_zip_path))

    # download zipm
    `curl -fo '#{save_zip_path}' '#{download_url}'`
    
    # check if the download worked
    if File.exists?(save_zip_path)
      # unzip it
      extract_path = AppConfig.tv_assets_path / series_path(series_id)
      `rm -Rf #{extract_path}` if File.exists?(extract_path) and extract_path.present?
      `unzip -qu '#{save_zip_path}' -d '#{extract_path}'`
      `rm #{save_zip_path}`
      return true
    else
      return false
    end
  end
  
  def self.download_fan_art(series_id, opts = {})
    download_banner(series_id, 'fanart', opts)
  end

  def self.download_series_art(series_id, opts = {})
    download_banner(series_id, 'series', opts)
  end

  def self.download_poster_art(series_id, opts = {})
    download_banner(series_id, 'poster', opts)
  end
  
  # def self.download_season_art(series_id, opts = {})
  #   download_banner(series_id, 'season', opts)
  # end
  
  
  protected
  # banner_types: fanart, season, poster, series  
  def self.download_banner(series_id, banner_type, opts = {})
    opts[:index] ||= 0
    
    banner_xml = AppConfig.tv_assets_path / series_path(series_id) / "banners.xml"
    download_data(series_id) unless File.exists?(banner_xml)
    
    if File.exists?(banner_xml)
      banner_mirror_path = TvDbMirror.banner_mirror_path
      
      banner_xml = Crack::XML.parse(File.new(banner_xml).read)
      return nil unless banner_xml && banner_xml["Banners"]
      
      # filter the banners
      banners = [banner_xml["Banners"]["Banner"]].flatten.compact.select do |b|
        b["Language"] == "en" && 
        b["BannerType"] == banner_type
      end
    
      # bring the items with SeriesName to the top
      banners = banners.sort_by {|b| b["SeriesName"] || "false" }.reverse
      
      if opts[:thumbnail]
        banners = banners.select do |b|
          b["ThumbnailPath"].present?
        end
      end
      
      # download a banner (attempt 3 times)
      banner_path = nil
      Array(banners.slice(opts[:index], AppConfig.tvdb.download_max_retries)).each do |banner|
        banner_path = series_path(series_id) / banner_type / "#{banner['id']}"
        FileUtils.mkdir_p(File.dirname(AppConfig.tv_assets_path  / banner_path))
        
        if opts[:thumbnail]
          banner_path = "#{banner_path}_thumb"
          banner_url = "#{banner_mirror_path}/banners/#{banner["ThumbnailPath"]}"
        else
          banner_url = "#{banner_mirror_path}/banners/#{banner["BannerPath"]}"
        end

        # download thumbnail
        save_as = "#{AppConfig.tv_assets_path / banner_path}.jpg"
        curl_cmd = "curl -fLo '#{save_as}' '#{banner_url}'"
        `#{curl_cmd}`
        
        return "#{banner_path}.jpg" if File.exists?(save_as)
      end
      
      return nil
    else
      return nil
    end
  end
  
  def self.series_path(series_id)
    "tvdb" / "series" / series_id.to_i.to_s
  end
  
  
end