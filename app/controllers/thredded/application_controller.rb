module Thredded
  class ApplicationController < ::ApplicationController
    helper Thredded::Engine.helpers
    helper_method :messageboard, :topic, :preferences
    before_filter :update_user_activity

    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = exception.message
      redirect_to root_path
    end

    private

    def update_user_activity
      if messageboard && current_user
        messageboard.update_activity_for!(current_user)
      end
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def messageboard
      if params.key? :messageboard_id
        @messageboard ||= Messageboard.where(slug: params[:messageboard_id]).first
      end
    end

    def preferences
      if current_user
        @preferences ||= UserPreference.where(user_id: current_user.id).first
      end
    end
   
    def default_home
      root_path
    end
   
    def topic
      if messageboard
        @topic ||= messageboard.topics.find(params[:topic_id])
      end
    end

    def ensure_messageboard_exists
      logger.debug("Thredded::ApplicationController.ensure_messageboard_exists messageboard: #{messageboard.to_s}")
      if messageboard.blank?
        redirect_to thredded.root_path,
          flash: { error: 'This messageboard does not exist.' }
      end
    end

    def user_messageboard_preferences
      @user_messageboard_preferences ||=
        current_user
          .thredded_messageboard_preferences
          .where(messageboard_id: messageboard)
          .first
    end
  end
end
