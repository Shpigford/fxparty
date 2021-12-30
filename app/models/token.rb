class Token < ApplicationRecord
  has_many :items
  has_many :stats
end
