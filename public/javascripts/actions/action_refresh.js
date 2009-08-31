function refresh_counts(){
  $.getJSON("/users/mini_counts", function(result) {
    
    $(".count_alerts").text("("+result.alerts_count+")");
    $(".count_favorites").text("("+result.favorites_count+")");
  });
}

function refresh_account(){
  var self = $("#dropmenu_account");
  $.ajax({
    url: "/users/mini_account",
    data: {visible: self.find(".dropmenu_body").is(":visible")},
    success: function(html) {
      self.replaceWith(html);
    }
  });

}

function refresh_alerts(){
  var self = $("#dropmenu_alerts");
  $.ajax({
    url: "/users/mini_alerts",
    data: {visible: self.find(".dropmenu_body").is(":visible")},
    success: function(html) {
      self.replaceWith(html);
    }
  });

}

function refresh_favorites(){
  var self = $("#dropmenu_favorites");
  $.ajax({
    url: "/users/mini_favorites",
    data: {visible: self.find(".dropmenu_body").is(":visible")},
    success: function(html) {
      self.replaceWith(html);
    }
  });
}

$(document).ready(function() {
  // refresh account
  $(".action_refresh_all").livequery(function() {
    refresh_account();
    refresh_alerts();
    refresh_favorites();
    refresh_counts();
    $(this).remove();
  });
  
  $(".action_refresh_account").livequery(function() {
    refresh_account();
    $(this).remove();
  });
  
  
  $(".action_refresh_alerts").livequery(function() {
    refresh_alerts();
    $(this).remove();
  });
  
  $(".action_refresh_favorites").livequery(function() {
    refresh_favorites();
    $(this).remove();
  });

  $(".action_refresh_counts").livequery(function() {
    refresh_counts();
    $(this).remove();
  });
  
});
