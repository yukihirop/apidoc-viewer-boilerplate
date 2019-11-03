class User < ApplicationRecord
  validates :uid,            presence: true, uniqueness: true
  validates :provider,       presence: true
  validates :name,           presence: true
  validates :email,          presence: true
  validates :first_name,     presence: true
  validates :last_name,      presence: true
  validates :token,          presence: true, uniqueness: true
  validates :refresh_token,  presence: true, uniqueness: true
end
