class Abuse < ActiveRecord::Base

  belongs_to :abusable, polymorphic: true
  belongs_to :user

  attr_readonly :abused_count

  after_save :increment_cache_count
  after_destroy :decrement_cache_count

  protected
    def increment_cache_count
      abusable.update(abused_count: abusable.abused_count + 1)
    end

    def decrement_cache_count
      abusable.update(abused_count: abusable.abused_count - 1)
    end

end
