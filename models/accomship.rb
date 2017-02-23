class Accomship
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :account
  belongs_to :accom
  belongs_to :group
  
  validates_presence_of :account, :accom, :group
  validates_uniqueness_of :account, :scope => :group
  
  has_many :notifications, as: :notifiable, dependent: :destroy
  after_create do
    notifications.create! :group => group, :type => 'joined_accom'
  end      
        
  def self.admin_fields
    {
      :account_id => :lookup,
      :accom_id => :lookup,
      :group_id => :lookup
    }
  end
  
  before_validation do
    errors.add(:accom, 'is full') if accom and accom.capacity and accom.accomships.count == accom.capacity
  end
    
end
