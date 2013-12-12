module Thredded
  class TopicDecorator < SimpleDelegator
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    attr_reader :topic

    def initialize(topic)
      super
      @topic = topic
    end

    def slug
      topic.slug.nil? ? topic.id : topic.slug
    end

    def css_class
      classes = []
      classes << 'locked' if locked?
      classes << 'sticky' if sticky?
      classes << 'private' if private?
      classes += ['category'] + categories.map(&:name) if categories.present?
      classes.join(' ')
    end

    def last_user_link
      if last_user && last_user.to_s != 'Anonymous User'
        last_user_path = Thredded.user_path(last_user)

        "<a href='#{last_user_path}'>#{last_user}</a>".html_safe
      else
        last_user.to_s
      end
    end
    
    def user_link
      if topic.user && topic.user.to_s != 'Anonymous User'
        user_path = Thredded.user_path(topic.user)
        "<a href='#{user_path}'>#{topic.user}</a>".html_safe
      else
        '<a href="#">?</a>'.html_safe
      end
    end

    def farthest_page
      if topic.user.id > 0
        @read_status ||= topic.user_topic_reads.select do |reads|
          reads.user_id == topic.user.id
        end
      end

      if @read_status.blank?
        Thredded::NullTopicRead.new.page
      else
        @read_status.first.page
      end
    end

    def original
      topic
    end

    def updated_at_timeago
      if updated_at.nil?
        <<-eohtml.html_safe
          <abbr>
            a little while ago
          </abbr>
        eohtml
      else
        <<-eohtml.html_safe
          <abbr class="timeago" title="#{updated_at_utc}">
            #{updated_at_str}
          </abbr>
        eohtml
      end
    end

    def created_at_timeago
      if created_at.nil?
        <<-eohtml.html_safe
          <abbr class="started_at">
            a little while ago
          </abbr>
        eohtml
      else
        <<-eohtml.html_safe
          <abbr class="started_at timeago" title="#{created_at_utc}">
            #{created_at_str}
          </abbr>
        eohtml
      end
    end

    def gravatar_url
      super.gsub /http:/, ''
    end

    private

    def updated_at_str
      updated_at.to_s
    end

    def updated_at_utc
      updated_at.getutc.iso8601
    end

    def created_at_str
      created_at.to_s
    end

    def created_at_utc
      created_at.getutc.iso8601
    end
  end
end
