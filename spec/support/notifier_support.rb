# frozen_string_literal: true
class MockNotifier
  mattr_accessor :users_notified_of_new_post, :users_notified_of_new_private_post

  class << self
    def new_post(_post, users)
      self.users_notified_of_new_post = users
    end

    def new_private_post(_post, users)
      self.users_notified_of_new_private_post = users
    end

    def resetted
      self.users_notified_of_new_post = []
      self.users_notified_of_new_private_post = []
      self
    end
  end
end