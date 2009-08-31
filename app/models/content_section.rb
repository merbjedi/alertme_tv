class ContentSection
  include DataMapper::Resource

  # properties
  property :id, Serial
  property :path, Text
  property :has_content, Boolean, :default => false

  # html body
  property :body, Text

  # metadata (for admin purposes)
  property :title, String, :size => 255
  property :description, Text

  timestamps :on

  def to_html(options = {})
    body
  end

  def self.from_path(path)
    section = first(:path => path)
    section ||= create!(:path => path, :has_content => false)
  
    section
  end
end