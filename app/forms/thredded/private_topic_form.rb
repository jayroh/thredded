module Thredded
  class PrivateTopicForm
    include ActiveModel::Model

    attr_accessor \
      :title,
      :category_ids,
      :user_ids,
      :locked,
      :sticky,
      :content,
      :private_topic

    attr_reader :user, :messageboard, :params

    validate :validate_children

    def initialize(params = {})
      @params = params
      @title = params[:title]
      @category_ids = params[:category_ids] || []
      @user_ids = params[:user_ids] || []
      @locked = params[:locked] || false
      @sticky = params[:sticky] || false
      @content = params[:content]
      @user = params[:user]
      @messageboard = params[:messageboard]
    end

    def self.model_name
      Thredded::PrivateTopic.model_name
    end

    def categories
      messageboard.categories
    end

    def category_options
      messageboard.decorate.category_options
    end

    def filter
      messageboard.filter
    end

    def users
      messageboard.users
    end

    def save
      if valid?
        ActiveRecord::Base.transaction do
          private_topic.save!
          post.save!
        end
      end
    end

    def private_topic
      @private_topic ||= messageboard.private_topics.build(
        title: title,
        locked: locked,
        sticky: sticky,
        users: private_users,
        user: user,
        last_user: user,
        categories: topic_categories,
      )
    end

    def post
      @post ||= private_topic.posts.build(
        content: content,
        user: user,
        messageboard: messageboard,
        filter: messageboard.filter
      )
    end

    def selected_options
      { selected: private_user_ids }
    end

    def html_options
      {
        multiple: true,
        'data-placeholder' => 'select users to participate in this topic',
      }
    end

    def users_options
      messageboard.decorate.users_options
    end

    private

    def topic_categories
      if category_ids
        ids = category_ids.reject(&:empty?).map(&:to_i)
        Category.where(id: ids)
      else
        []
      end
    end

    def private_user_ids
      private_users.map(&:id)
    end

    def private_users
      if user
        ids = user_ids.reject(&:empty?).map(&:to_i).push(user.id).uniq
        User.where(id: ids)
      else
        []
      end
    end

    def validate_children
      if private_topic.invalid?
        promote_errors(private_topic.errors)
      end

      if post.invalid?
        promote_errors(post.errors)
      end
    end

    def promote_errors(child_errors)
      child_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
