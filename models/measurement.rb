class Measurement < ActiveRecord::Base

  scope :last_five_minutes, -> {
    where("created_at  > ?", 5.minutes.ago)
  }

  scope :electricity, -> { where(:kind => 'e') }
  scope :gas, -> { where(:kind => 'g') }
  scope :water, -> { where(:kind => 'w') }
end
