(function($j) {  
  $j.fn.post_delete = function(opts) { 

    // defaults
    var opts = $j.extend({
      confirm: function(el) {
        // get confirmation message from attribute "confirm"
        var confirmMessage = $j(el).attr("data-confirm");
        if(confirmMessage != undefined && confirmMessage != "")
        {
          return confirm(confirmMessage);
        }
        else
        {
          return true;
        }
      }
    }, opts);
    
    this.unbind("click");
    this.click(function() {
      
      // check confirmation before submitting
      var confirmed = true;
      if(typeof(opts.confirm) == "function")
      {
        confirmed = opts.confirm(this);
      }
      
      if(confirmed)
      {
        $j("<form method='POST'><input type='hidden' name='_method' value='delete' /><form>")
          .attr("action", $j(this).attr("href"))
          .insertAfter($j(this))
          .submit();
      }

      return false;
    });
    
    return this;
  }; 
})(jQuery);