class Product < ApplicationRecord
  belongs_to :category
  has_many_attached :images

  validates :name, presence: true, length: {minimum: 5, maximum: 60}
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, length: {maximum: 500}, allow_blank: true

  scope :on_sale, -> { where(on_sale: true) }
  scope :newly_added, -> { where("created_at > ?", 3.days.ago) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
end
