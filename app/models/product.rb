class Product < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  validates :name, presence: true
  validates :price, presence: true
  scope :on_sale, -> { where(on_sale: true) }
  scope :newly_added, -> { where("created_at > ?", 3.days.ago) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
end
