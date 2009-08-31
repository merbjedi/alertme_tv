(function($) {  
  // Looks within to see if it has any children with a matching filter
  $.fn.setup_tooltips = function(opts) { 
    opts = opts || {};
    
    if(!opts.default_tooltip_html)
    {
      // fuck you javascript
      opts.default_tooltip_html = "";
      opts.default_tooltip_html += "<div class='tooltip'>";
      opts.default_tooltip_html += "  <div class='tooltip_top'><a class='close'><img src='/images/tooltip/blue_close.png' /></a></div>";
      opts.default_tooltip_html += "  <div class='tooltip_body loading'><img src='/images/tooltip/loading.gif' alt='loading' /></div>";
      opts.default_tooltip_html += "  <div class='tooltip_bottom'></div>"
      opts.default_tooltip_html += "</div>"
    }
    
    this.each(function(index) {
      var self = $(this);
      if(self.data("tooltip_setup"))
      {
        return;
      }

      var slider_item = self;
      var slider_items = slider_item.parents(".slider_items:first");
      var tooltip = slider_item.parents(".slider_items").find(".tooltip_container");
      
      // show id
      var showid = slider_item.attr("showid");
      
      // initialize content on the tooltip
      self.bind("tooltip_init", function() {
        
        // todo: reset tooltip & fill it via ajax (if they clicked on something new)
        var newshow = false;
        if(tooltip.attr("showid") != showid)
        {
          // set showid for the current tooltip
          tooltip.attr("showid", showid);
          tooltip.trigger("tooltip_fetch");
        }

        self.trigger("tooltip_show");
      });
      
      tooltip.bind("tooltip_show_loading", function() {
        tooltip.html(opts.default_tooltip_html);
      });
      
      tooltip.bind("tooltip_fetch", function() {
        // set loading
        tooltip.trigger("tooltip_show_loading");
        
        var sid = showid;
        $.ajax({
          url: "/shows/"+showid+"/tooltip",
          success: function(html) {
            // console.log("Orig: "+sid);
            // console.log("New: "+tooltip.attr("showid"));
            if(sid == tooltip.attr("showid"))
            {
              // console.log("WORKED!");
              tooltip.html(html);
            }
           
          }
        });

      });
      
      self.bind("tooltip_hide_others", function() {
        // hide all other tooltips
        $(".tooltip").not(tooltip).hide();
      });
      
      // 
      self.bind("tooltip_show", function() {
        // choose which side its on
        var relativeOffset = slider_item.offset().left - slider_items.offset().left;
        // console.log("relativeOffset: "+relativeOffset);    
        tooltip.removeClass("left_tip right_tip mid_tip");
        if(relativeOffset < 100)
        {
          tooltip.addClass("left_tip");
        }
        else if(relativeOffset > 500)
        {
          tooltip.addClass("right_tip");
        }
        else
        {
          tooltip.addClass("mid_tip");
        }

        // show tooltip
        if(tooltip.is("visible"))
        {
          tooltip.show();
        }
        else
        {
          var inner = tooltip.find(".tooltip");
          inner.hide();
          tooltip.show();
          inner.fadeIn();
        }
        
        // scroll if necessary
        if(!$.inviewport(tooltip.find(".tooltip_bottom"), {threshold : 20}))
        {
          $.scrollTo(slider_items, {duration: 500, offset: {top: -200, left: 0}});
        }
      });

      self.data("tooltip_setup", true);
    });
    return this;
  }; 
})(jQuery);


$(document).ready(function() {
  // show slider item tooltip
  $(".slider_item.show_tooltip").livequery("click", function() {
    var self = $(this).setup_tooltips();

    self.trigger("tooltip_hide_others");
    self.trigger("tooltip_init");
    
    return false;
  });
  
  // tooltip behaviors
  $(".tooltip .close").livequery("click", function() {
    $(this).parents(".tooltip_container:first").hide();
    return false;
  });
  
  $(".tooltip .toggle_alert").livequery("click", function() {
    var container = $(this).parents(".tooltip_container:first");
    container.find(".tooltip").removeClass("show_info").addClass("show_alert");
    return false;
  });
  
  $(".tooltip .toggle_info").livequery("click", function() {
    var container = $(this).parents(".tooltip_container:first");
    container.find(".tooltip").removeClass("show_alert").addClass("show_info");
    return false;
  });
  
  $(".tooltip .toggle_favorite").livequery("click", function() {
    var container = $(this).parents(".tooltip_container:first");
    
    container.trigger("tooltip_show_loading");
    $.ajax({
      url: "/shows/"+parseInt(container.attr("showid"),10)+"/toggle_favorite",
      success: function(html) {
        container.html(html);
        container.find(".tooltip").show();
      }
    });
    
    return false;
  });
  
});
