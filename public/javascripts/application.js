$(document).ready(function() {
  
  $(document).click(function(e) {
    if($(e.target).parents(".slider_items:first").size() == 0)
    {
      $(".tooltip").hide();
    }

    if($(e.target).parents(".dropmenu_body:first").size() == 0)
    {
      $(".dropmenu_body:visible").hide();
    }

  });
  
  $("a.fancybox").livequery(function() {
    $(this).fancybox();
  });
  
  $("#welcomeinline").fancybox({'hideOnContentClick': true});
  
  // initialize scrollable 
  $("div.scrollable").each(function(index) {
    var el = $(this);
    el.scrollable({
      size: 3,
      interval: 0,      
      keyboard: false,
      clickable: false,
      speed: 1000,  
      easing: 'easeInOutBack',
      items: '.thumbs',  
      hoverClass: 'hover',
      onBeforeSeek: function() {
        el.parents(".slider_items").find(".tooltip").hide();
      }
    });
  });
  
  $("a.post_delete").post_delete();
  
  // wire up ajax forms (TODO)
  $("form.ajax").livequery(function() {
    var $this = $(this);
    $this.append("<input type='hidden' name='type' value='ajax' />");
    
    $this.ajaxForm({
      beforeSubmit: function() {
        $this.find(".progress,.loading").show();
      },
      success: function(html) {
        $this.find(".progress,.loading").hide();

        $this.trigger("ajax_form:success", [html]);
        
        if($.isPresent($this.attr("parents")))
        {
          $this.parents($this.attr("parents")).replaceWith(html);
        }
        else if($.isPresent($this.attr("rel")))
        {
          $($this.attr("rel")).replaceWith(html);
        }
        else
        {
          $this.replaceWith(html);
        }
      }
    });
  });
  
  $(".intro").click(function() {
    $("#welcomeinline").click();
  });
});
