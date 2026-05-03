class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :value, inclusion: { in: [1, -1] }
  validates :user_id, uniqueness: { scope: :post_id }

  after_create :add_vote_to_count
  after_destroy :remove_vote_from_count
  after_update :sync_votes_count, if: :saved_change_to_value?

  private

  def add_vote_to_count
    Post.increment_counter(:votes_count, post_id, by: value)
  end

  def remove_vote_from_count
    Post.increment_counter(:votes_count, post_id, by: -value)
  end

  def sync_votes_count
    delta = value - value_previously_was
    Post.increment_counter(:votes_count, post_id, by: delta)
  end
end