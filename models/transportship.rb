class Transportship
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account
  belongs_to :transport 
  belongs_to :group
  
  validates_presence_of :account, :transport, :group
  
  has_many :notifications, as: :notifiable, dependent: :destroy
  after_create do
    notifications.create! :group => group, :type => 'joined_transport'
  end      
           
  def self.admin_fields
    {
      :account_id => :lookup,
      :transport_id => :lookup,
      :group_id => :lookup
    }
  end
  
  before_validation do
    errors.add(:transport, 'is full') if transport and transport.capacity and transport.transportships.count == transport.capacity
  end  
      
end
