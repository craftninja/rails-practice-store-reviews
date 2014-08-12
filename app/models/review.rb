class Review < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_presence_of :product_id
  validates_presence_of :description
  validates_presence_of :stars

end
