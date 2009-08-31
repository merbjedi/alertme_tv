module Merb
  module ContentHelpers
    def content_section(path, content_type = nil)
      content_section_html(path)
    end
  
    # returns the html content for a particular content section
    def content_section_html(path)
      section = ContentSection.from_path(path)

      # render section with content
      if section.has_content?
        section.to_html
      else
        begin
          # render default (from partial)
          partial("content_sections/#{path}")
        rescue Exception => e
          # display a message (on dev mode) if unable to find content section
          if Merb.env?(:development)
            "Unable to find default content section partial at content_sections/#{path}"
          else
            ""
          end
        end
      end
    end
  end
end