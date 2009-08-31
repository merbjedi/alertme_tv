ids = [
  74845,
  73244,
  74543,
  72173,
  75299,
  78107,
  80337,
  82283,
  71663,
  72108,
  79126,
  71663,
  75340,
  73739,
  73762,
  80348,
  80547,
  72218,
  79501,
  72158,
  78901,
  75760,
  75682,
  79349,
  73255,
  72129,
  70851,
  76321
]

result = ""

ids.each do |id|
  result << "Series #{id}: \n"
  result << "Series Art: #{TvDb.download_series_art(id)}\n"
  result << "Thumbnail Art: #{TvDb.download_fan_art(id, :thumbnail => true)}\n" 
  result << "Fan Art: #{TvDb.download_fan_art(id)}\n" 
  result << "Poster Art: #{TvDb.download_poster_art(id)}\n"
  result << "\n\n"
end


puts "DONE!"
puts result