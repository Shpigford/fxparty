class Wallet < ApplicationRecord
  has_many :items

  scope :active, -> {where.not(status:'not_found')}
  scope :tracked, -> {where(tracked: true)}
end
