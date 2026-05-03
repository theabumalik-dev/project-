class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # Валидация: значение может быть только 1 (лайк) или -1 (дизлайк)
  validates :value, inclusion: { in: [-1, 1] }

  # Валидация: один пользователь может проголосовать за пост только один раз
  validates :user_id, uniqueness: { scope: :post_id, message: "уже проголосовал за этот пост" }

  # КОЛБЭКИ (Callbacks) - Автоматические действия
  # После создания голоса -> обновляем счетчик в посте
  after_create_commit :update_post_counter
  
  # После удаления голоса (отмена лайка) -> обновляем счетчик в посте
  after_destroy_commit :update_post_counter

  private

  # Метод обновления счетчика
  def update_post_counter
    # post.increment!(:count_field, step)
    # Это атомарная операция: берет текущее значение в БД и прибавляет value (+1 или -1)
    # Решает проблему Race Condition (гонки потоков)
    post.increment!(:votes_count, value)
  end
end
