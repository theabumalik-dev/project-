class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :post_id }
end
