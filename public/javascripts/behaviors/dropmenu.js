$(document).ready(function() {
  
  
  $("ul.dropmenu_body").livequery(function() {
    $(this).find("li:even").addClass("alt");
  });
  
  $(".dropmenu_trigger").click(function() {
    var body = $($(this).attr("rel")).find(".dropmenu_body")
    $(".dropmenu_body").not(body).hide();
    
    body.slideToggle('normal');

    return false;
  });
  
  // $('img.dropmenu_head').click(function () {
  //   $('ul.dropmenu_body').slideToggle('normal');
  // });
  
  $(".toggle_change_password").livequery("click", function() {
    $(".change_password_form").slideToggle();
  });
  
});
