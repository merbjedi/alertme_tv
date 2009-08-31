module Merb
  module ShowHelpers
    # SHOW THUMBNAIL
    def show_thumb_image(show, opts = {})
      if show_thumb_url(show)
        image_tag(show_thumb_url(show), :alt => show.title)
      else
        image_tag AppConfig.default_thumb_url, :alt => "", :class => "asset_placeholder"
      end
    end
    
    def show_thumb_url(show)
      AppConfig.tv_assets_url / show.tvdb_thumb_url if show.tvdb_thumb_url.present?
    end
    
    # SHOW POSTER
    def show_poster_image(show, opts = {})
      if show_poster_url(show)
        image_tag(show_poster_url(show), :alt => show.title)
      else
        image_tag AppConfig.default_poster_url, :alt => "", :class => "asset_placeholder"
      end
    end

    def show_poster_url(show)
      AppConfig.tv_assets_url / show.tvdb_poster_url if show.tvdb_poster_url.present?
    end
    
    # SHOW BANNER
    def show_banner_image(show, opts = {})
      if show_banner_url(show)
        image_tag(show_banner_url(show), :alt => show.title)
      else
        image_tag AppConfig.default_banner_url, :alt => "", :class => "asset_placeholder"
      end
    end
    
    def show_banner_url(show)
      AppConfig.tv_assets_url / show.tvdb_banner_url if show.tvdb_banner_url.present?
    end
    
    # SHOW FANART
    def show_fanart_image(show, opts = {})
      if show_fanart_url(show)
        image_tag(show_fanart_url(show), :alt => show.title)
      else
        image_tag AppConfig.default_fanart_url, :alt => "", :class => "asset_placeholder"
      end
    end
    
    def show_fanart_url(show)
      AppConfig.tv_assets_url / show.tvdb_fanart_url if show.tvdb_fanart_url.present?
    end
    
  end
end
