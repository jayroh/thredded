module Thredded
  class Role < ActiveRecord::Base
    ROLES = %w(superadmin admin moderator member)

    belongs_to :messageboard
    belongs_to :user, class_name: Thredded.user_class

    validates_presence_of :level
    validates_inclusion_of :level, in: ROLES
    validates_presence_of :messageboard_id
    validates_presence_of :user_id

    scope :for, -> (messageboard) { where(messageboard_id: messageboard.id) }
    scope :as,  -> (role) { where(level: role) }
  end
end
