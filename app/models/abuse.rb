class Abuse < ActiveRecord::Base

  belongs_to :abusable, polymorphic: true, counter_cache: :abused_count
  belongs_to :user

  attr_readonly :abused_count

end
