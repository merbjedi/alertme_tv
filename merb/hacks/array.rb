class Array
  def chunk(number_of_chunks)
    chunks = (1..number_of_chunks).collect { [] }
    while self.any?
      chunks.each do |a_chunk|
        a_chunk << self.shift if self.any?
      end
    end
    chunks
  end
  
  def into_pages(page_size)
    a = []
    each_with_index do |x,i|
      a << [] if i % page_size == 0
      a.last << x
    end
    a
  end
end