class Accom
  include Mongoid::Document
  include Mongoid::Timestamps
 
  field :name, :type => String  
  field :description, :type => String
  field :capacity, :type => Integer
  field :cost, :type => Integer
  
  belongs_to :gathering, index: true
  belongs_to :account, index: true
  validates_presence_of :name, :cost, :capacity
  
  has_many :accomships, :dependent => :destroy
  
  has_many :notifications, as: :notifiable, dependent: :destroy
  after_create do
    notifications.create! :circle => circle, :type => 'created_accom'
  end      
  
  def circle
    gathering
  end
  
  def members
    Account.where(:id.in => accomship.pluck(:account_id))
  end  
        
  def self.admin_fields
    {
      :name => :text,
      :description => :text_area,
      :capacity => :number,
      :cost => :number,
      :gathering_id => :lookup,
      :account_id => :lookup
    }
  end
  
  def cost_per_person
    if accomships.count > 0
      (cost.to_f / accomships.count).round
    end
  end
  
  def full?
    accomships.count == capacity
  end
  
  after_save do
    accomships.each { |accomship| accomship.membership.update_requested_contribution }
  end    
  
  def self.human_attribute_name(attr, options={})  
    {
      :cost => 'Cost for the room'
    }[attr.to_sym] || super  
  end   
    
end
