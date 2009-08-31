result = ""
Show.all.each do |show|
  begin
    result << "Refreshing Count for #{show.title}\n"
    
    show.favorite_count = Favorite.all(:show_id => show.id).count
    show.alert_count = Alert.all(:show_id => show.id).count
    show.save
    
    
    result << "Favorites: #{show.favorite_count}\n"
    result << "Alerts: #{show.alert_count}\n"
    
    result << "\n\n"
  rescue Exception => e
    result << "error for #{show.id}!\n"
    result << e.inspect
    result < "\n\n"
  end
end

puts result