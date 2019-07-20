class Room
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
 
  field :name, :type => String
  field :location, :type => String
  field :coordinates, :type => Array  
  field :description, :type => String
  
  belongs_to :account, index: true  
  has_many :room_attachments, :dependent => :destroy
  has_many :room_periods, :dependent => :destroy
  
  validates_presence_of :name
  
  def image
    room_attachments.order('created_at asc').first.try(:image)
  end
  
  def self.marker_color
    'red'
  end   
  
  # Geocoder
  geocoded_by :location  
  def lat; coordinates[1] if coordinates; end  
  def lng; coordinates[0] if coordinates; end  
  after_validation do
    self.geocode || (self.coordinates = nil)
  end   
          
  def self.admin_fields
    {
      :name => :text,
      :location => :text,
      :description => :text_area,
      :account_id => :lookup
    }
  end
    
end
