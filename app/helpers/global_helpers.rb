module Merb
  module GlobalHelpers
    include ShowHelpers
    include BodyHelpers
    include ContentHelpers
    
    def mini_submit(opts = {})
      opts = {:type => "image", :src => "/images/mini_submit.png"}.merge(opts)
      tag(:input, opts)
    end
    
    def current_user
      session.user
    end
    
    def add_to_db_url(show)
      if show.is_a?(Hash) and show['showid'].present?
        "/shows/add/?showid=#{show['showid']}"
      else
        "#"
      end
    end
    
    def logged_in?
      session.user and session.user.activated_at
    end
    
    def pluralize(count, singular, plural = nil)
      "#{count || 0} " + ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
    end

    
    def full_url(path = nil)
      request.protocol + "://" + request.host + path.to_s
    end
    
    
    def redirect_back
      if request.referer.present?
        redirect request.referer
      else
        redirect "/"
      end
    end
    
    def sms_carrier_options
      AppConfig.sms_carriers.marshal_dump.values.map do |pair|
        carrier = pair.marshal_dump
        [carrier[:value], carrier[:name]]
      end
    end
    
    
    # Returns +text+ transformed into HTML using simple formatting rules.
    # Two or more consecutive newlines(<tt>\n\n</tt>) are considered as a
    # paragraph and wrapped in <tt><p></tt> tags. One newline (<tt>\n</tt>) is
    # considered as a linebreak and a <tt><br /></tt> tag is appended. This
    # method does not remove the newlines from the +text+.
    #
    # You can pass any HTML attributes into <tt>html_options</tt>.  These
    # will be added to all created paragraphs.
    # ==== Examples
    #   my_text = "Here is some basic text...\n...with a line break."
    #
    #   simple_format(my_text)
    #   # => "<p>Here is some basic text...\n<br />...with a line break.</p>"
    #
    #   more_text = "We want to put a paragraph...\n\n...right there."
    #
    #   simple_format(more_text)
    #   # => "<p>We want to put a paragraph...</p>\n\n<p>...right there.</p>"
    #
    #   simple_format("Look ma! A class!", :class => 'description')
    #   # => "<p class='description'>Look ma! A class!</p>"
    def simple_format(text, html_options={})
      start_tag = open_tag('p', html_options)
      text = text.to_s.dup
      text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
      text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
      text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
      text.insert 0, start_tag
      text << "</p>"
    end
    
  end
end
