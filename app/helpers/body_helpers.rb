module Merb
  module BodyHelpers
    
    def body_style(new_style = nil)
      @__body_style = new_style if new_style
      
      # TODO: initialize from user preferences (if set)
      
      @__body_style || "blue"
    end
    
    def body_id(new_id = nil)
      @__body_id = new_id if new_id
      @__body_id
    end
  
  end
end