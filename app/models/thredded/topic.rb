# frozen_string_literal: true
require_dependency 'thredded/topics_search'
module Thredded
  class Topic < ActiveRecord::Base
    include TopicCommon

    scope :for_messageboard, -> messageboard { where(messageboard_id: messageboard.id) }

    scope :stuck, -> { where(sticky: true) }
    scope :unstuck, -> { where(sticky: false) }

    # Using `search_query` instead of `search` to avoid conflict with Ransack.
    scope :search_query, -> query { ::Thredded::TopicsSearch.new(query, self).search }

    scope :order_sticky_first, -> { order(sticky: :desc) }

    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:history, :reserved, :scoped],
                scope:          :messageboard,
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w(topics))

    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_topics

    belongs_to :messageboard,
               counter_cache: true,
               touch: true,
               inverse_of: :topics
    validates :messageboard_id, presence: true

    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :topics,
               counter_cache: :topics_count

    has_many :posts,
             class_name:  'Thredded::Post',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_one :first_post, -> { order_oldest_first },
            class_name:  'Thredded::Post',
            foreign_key: :postable_id

    has_many :topic_categories, dependent: :destroy
    has_many :categories, through: :topic_categories
    has_many :user_read_states,
             class_name: 'Thredded::UserTopicReadState',
             foreign_key: :postable_id,
             inverse_of: :postable,
             dependent: :destroy
    has_many :user_follows,
             class_name: 'Thredded::UserTopicFollow',
             inverse_of: :topic,
             dependent: :destroy
    has_many :following_users,
             class_name: Thredded.user_class,
             source: :user,
             through: :user_follows

    def self.find_by_slug!(slug)
      friendly.find(slug)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::TopicNotFound
    end

    def self.follows_by_topics_lookup(user)
      follows_by_topic_id =
        UserTopicFollow
          .where(user_id: user.id, topic_id: current_scope.map(&:id))
          .group_by(&:topic_id)

      def follows_by_topic_id.get(topic, null_value = nil)
        follow = self[topic.id]
        return null_value unless follow
        follow = follow[0]
        follow.topic = topic
        follow
      end
      follows_by_topic_id
    end

    # @param user [Thredded.user_class]
    # @return [Array<[TopicCommon, UserTopicReadStateCommon, UserTopicFollow]>]
    def self.with_read_and_follow_states(user)
      null_read_state = Thredded::NullUserTopicReadState.new
      return current_scope.zip([null_read_state, nil]) if user.thredded_anonymous?
      read_states_by_topics = read_states_by_topics_lookup(user)
      follows_by_topics = follows_by_topics_lookup(user)
      current_scope.map do |topic|
        [topic, read_states_by_topics.get(topic, null_read_state), follows_by_topics.get(topic)]
      end
    end

    def public?
      true
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    private

    def slug_candidates
      [
        :title,
        [:title, '-topic'],
      ]
    end
  end
end
