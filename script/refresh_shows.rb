result = ""
Show.all.each do |show|
  begin
    result << "Refreshing #{show.title}\n"
    show.refresh
    result << "complete!\n\n"
  rescue Exception => e
    result << "error for #{show.id}!\n"
    result << e.inspect
    result < "\n\n"
  end
end

puts result