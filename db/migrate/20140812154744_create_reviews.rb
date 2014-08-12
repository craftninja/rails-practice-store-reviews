class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :user, null: false
      t.belongs_to :product, null: false
      t.string :description, null: false
      t.integer :stars, null: false
      t.timestamps
    end
  end
end
