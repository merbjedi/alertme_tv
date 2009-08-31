class TvRage
  include HTTParty
  base_uri AppConfig.tvrage.service_url
  http_proxy AppConfig.proxy_addr, AppConfig.proxy_port
  format :xml
  
  # find shows by name (short dataset)
  def self.search(name, opts = {})
    if opts[:detailed]
      url = "/feeds/full_search.php"
    else
      url = "/feeds/search.php"
    end

    results = get(url, :query => {:show => name})
    if results and results["Results"]
      [results["Results"]["show"]].compact.flatten
    else
      nil
    end
  end  
  
  def self.get_info(show_id, opts = {})
    results = get("/feeds/showinfo.php", :query => {:sid => show_id})
    results["Showinfo"] if results
  end
  
  def self.get_latest_episodes(show_id, opts = {})
    results = get("/feeds/episode_list.php", :query => {:sid => show_id})
    return unless results and results["Show"]
    seasons = [results["Show"]["Episodelist"]["Season"]].flatten
    seasons.last(AppConfig.tvrage.seasons_count.to_i)
  end
  
  def self.get_info_and_episodes(show_id, opts = {})
    results = get("/feeds/full_show_info.php", :query => {:sid => show_id})
    results["Show"] if results
  end
  
end