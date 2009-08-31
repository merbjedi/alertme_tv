Show.all.each do |show|
  if show.tvrage_data["ended"]
    show.sort_key = "9999999"
    show.save
    puts "#{show.title} HAS ENDED!"
  end
end