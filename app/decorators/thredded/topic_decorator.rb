require 'thredded/base_topic_decorator'

module Thredded
  class TopicDecorator < SimpleDelegator
    include Thredded::HtmlDecorator
    def initialize(private_topic)
      super(Thredded::BaseTopicDecorator.new(private_topic))
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Topic')
    end

    def css_class
      classes = []
      classes << 'locked' if locked?
      classes << 'sticky' if sticky?
      classes += ['category'] + categories.map(&:name) if categories.present?
      classes.join(' ')
    end

    def category_options
      messageboard.decorate.category_options
    end
  end
end
