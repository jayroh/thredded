module Thredded
  class Post < ActiveRecord::Base
    include Gravtastic

    gravtastic :user_email, default: Thredded.avatar_default
    paginates_per 50

    belongs_to :messageboard, counter_cache: true
    belongs_to :postable, polymorphic: true, counter_cache: true

    # Postable types to enable joins, e.g. Thredded::Post.joins(:private_topic)
    belongs_to :private_topic, -> _p { where(thredded_posts: {postable_type: 'Thredded::PrivateTopic'}) },
               foreign_key: :postable_id, inverse_of: :posts
    belongs_to :topic, -> _p { where(thredded_posts: {postable_type: 'Thredded::Topic'}) },
               foreign_key: :postable_id, inverse_of: :posts

    belongs_to :user, class_name: Thredded.user_class
    delegate :email, to: :user, prefix: true
    has_many :attachments, dependent: :destroy
    has_many :post_notifications, dependent: :destroy
    has_one :user_detail, through: :user, source: :thredded_user_detail

    validates :content, presence: true
    validates :messageboard_id, presence: true

    before_validation :set_filter
    after_save :notify_at_users
    after_create :modify_parent_posts_counts

    def created_date
      created_at.strftime('%b %d, %Y %I:%M:%S %Z') if created_at
    end

    def created_timestamp
      created_at.strftime('%Y-%m-%dT%H:%M:%S') if created_at
    end

    def gravatar_url
      super.gsub(/http:/, '')
    end

    def self.filters
      %w(bbcode markdown)
    end

    def filtered_content
      pipeline = HTML::Pipeline.new [
        html_filter_for_pipeline,
        HTML::Pipeline::SanitizationFilter,
        HTML::Pipeline::AtMentionFilter,
        HTML::Pipeline::EmojiFilter,
        HTML::Pipeline::AutolinkFilter,
      ], context_options

      result = pipeline.call(content)
      result[:output].to_s
    end

    private

    def context_options
      {
        asset_root: Thredded.asset_root,
        post: self,
        whitelist: sanitize_whitelist
      }
    end

    def sanitize_whitelist
      HTML::Pipeline::SanitizationFilter::WHITELIST.deep_merge(
        attributes: {
          'code' => ['class'],
          'img' => %w(src class width height),
          'blockquote' => ['class'],
        },
        transformers: [
          lambda do |env|
            node      = env[:node]
            node_name = env[:node_name]

            return if env[:is_whitelisted] || !node.element?
            return if node_name != 'iframe'
            return if (node['src'] =~ %r{\A(https?:)?//(?:www\.)?youtube(?:-nocookie)?\.com/}).nil?

            Sanitize.clean_node!(node,
              elements: %w(iframe),
              attributes: {
                'iframe' => %w(allowfullscreen frameborder height src width)
              }
            )

            { node_whitelist: [node] }
          end
        ]
      )
    end

    def html_filter_for_pipeline
      if filter == 'bbcode'
        HTML::Pipeline::BbcodeFilter
      else
        HTML::Pipeline::MarkdownFilter
      end
    end

    def modify_parent_posts_counts
      user_detail.increment!(:posts_count) if user_detail
      postable.last_user = user
      postable.touch
      postable.save
    end

    def set_filter
      self.filter = messageboard.filter if messageboard
    end

    def notify_at_users
      AtNotifierJob.queue.send_at_notifications(id)
    end
  end
end
