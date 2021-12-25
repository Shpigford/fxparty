class Item < ApplicationRecord
  # belongs_to :token, primary_key: 'fxid', foreign_key: 'token_fxid', class_name: 'Token'
  belongs_to :token
  belongs_to :wallet
end
