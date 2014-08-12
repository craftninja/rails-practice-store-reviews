class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :user
      t.belongs_to :product
      t.string :description
      t.integer :stars
      t.timestamps
    end
  end
end
