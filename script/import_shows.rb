result = ""
[
  6554 ,
  6061 ,
  3449 ,
  2649 ,
  6206 ,
  6060 ,
  16356,
  12662,
  6190 ,
  4628 ,
  6296 ,
  3506 ,
  4895 ,
  4284 ,
  3741 ,
  15614,
  15619,
  5227 ,
  8172 ,
  4724 ,
  5410 ,
  3918 ,
  2870 ,
  7926 ,
  3908 ,
  3261 ,
  5324 ,
  3601 ,  
].each do |tvrage_id|
  show = Show.from_tvrage(tvrage_id)
  if show
    result << "Imported #{show.title}\n"
  else
    result << "Error importing tvrageid: #{tvrage_id}"
  end
end

puts result


