class Promotership
  include Mongoid::Document
  include Mongoid::Timestamps

  field :stripe_connect_json, type: String

  belongs_to :account, index: true
  belongs_to :promoter, index: true

  def stripe_user_id
      JSON.parse(stripe_connect_json)['stripe_user_id']
    end

  validates_uniqueness_of :account, scope: :promoter

  def self.admin_fields
    {
      stripe_connect_json: :text_area,
      account_id: :lookup,
      promoter_id: :lookup
    }
  end
end
