class Measurement < ActiveRecord::Base

  scope :last_five_minutes, -> {
    in_last(5.minutes.ago)
  }

  scope :in_last, ->(time) {
    where("created_at  > ?", time)
  }

  scope :electricity, -> { where(:kind => 'e') }
  scope :gas, -> { where(:kind => 'g') }
  scope :water, -> { where(:kind => 'w') }
end
