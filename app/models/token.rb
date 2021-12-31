class Token < ApplicationRecord
  has_many :items
  has_many :stats

  scope :active, -> {where(delisted:false)}
end
