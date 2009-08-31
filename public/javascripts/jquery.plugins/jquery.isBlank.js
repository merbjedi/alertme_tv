(function($) {  
  // Returns whether a string is not blank
  $.isPresent = function(obj) { 
    if(obj && $.trim(obj) != "")
    {
      return true;
    }
    else
    {
      return false;
    }
  };   

  // Returns whether a string is blank
  $.isBlank = function(obj) { 
    return !$.isPresent(obj);
  };   

})(jQuery);
