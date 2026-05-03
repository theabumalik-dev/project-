class Vote < ApplicationRecord
  # === СВЯЗИ (ASSOCIATIONS) ===
  # Голос принадлежит пользователю и посту.
  # dependent: :destroy гарантирует, что если удалят пост или юзера, то и голоса удалятся (целостность).
  belongs_to :user
  belongs_to :post

  # === ВАЛИДАЦИИ (VALIDATIONS) ===
  # 1. Значение должно быть строго 1 (лайк) или -1 (дизлайк).
  validates :value, inclusion: { in: [-1, 1] }
  
  # 2. Уникальность: один юзер может голосовать за пост только один раз.
  # scope: :post_id означает уникальность пары [user_id + post_id].
  validates :user_id, uniqueness: { scope: :post_id, message: "уже проголосовал за этот пост" }

  # === КОЛБЭКИ (CALLBACKS) - ЛОГИКА "ТОЛСТОЙ МОДЕЛИ" ===
  # Эти методы срабатывают автоматически при событиях жизненного цикла.
  # Контроллер даже не знает, что счетчик обновляется. Он просто создает/удаляет Vote.
  
  after_create :update_post_counter
  after_destroy :update_post_counter
  after_update :update_post_counter_on_change

  private

  # Обновление счетчика при создании или удалении
  def update_post_counter
    # Если запись только что создана (после create) — добавляем значение (+1 или -1).
    # Если запись удалена (после destroy) — вычитаем значение.
    # destroyed? возвращает true, если объект был удален из БД.
    change = destroyed? ? -value : value
    
    # update_counters — это атомарная операция SQL (UPDATE ... SET count = count + X).
    # Она безопасна при конкурентном доступе (Race Condition).
    post.update_counters(votes_count: change)
  end

  # Обновление счетчика при изменении значения (например, сменил лайк на дизлайк)
  def update_post_counter_on_change
    # saved_change_to_value? возвращает true, если поле value изменилось.
    if saved_change_to_value?
      old_value, new_value = saved_change_to_value
      difference = new_value - old_value
      
      # Атомарно обновляем разницу
      post.update_counters(votes_count: difference)
    end
  end
end
