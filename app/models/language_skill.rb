class LanguageSkill < ActiveRecord::Base
  extend Enumerize
  enumerize :level,
            in: [:just_hello, :beginner, :intermediate, :expert, :native]

  attr_accessible :level, :user_id, :language_id

  validates :level, presence: true

  belongs_to :user
  belongs_to :language
end
