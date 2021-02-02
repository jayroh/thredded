# frozen_string_literal: true

require 'spec_helper'

module Thredded

  describe UserDetail do
    it 'not raises Thredded::Errors::UserDetailNotFound error' do
      user = create(:user)
      user_details = create(:user_detail, user: user)
      expect { UserDetail.find!(user_details.id) }
          .to_not raise_error(Thredded::Errors::UserDetailsNotFound)
    end
  end

  describe UserDetail, 'active storage' do
    it 'attaches the uploaded file' do
      file = fixture_file_upload(Rails.root.join('public', 'apple-touch-icon.png'), 'image/png')
      user = create(:user)
      user_details = create(:user_detail, user: user)
      user_details.profile_banner.attach(file)

      #puts user_details.profile_banner
      #puts ActiveStorage::Blob.order(created_at: :desc).first.attachments.inspect
      expect(user_details.profile_banner).to be_attached
    end
  end

  describe UserDetail, 'counter caching' do
    it 'bumps the posts count when a new post is created' do
      user = create(:user)
      user_details = create(:user_detail, user: user)
      create(:post, user: user)
      expect(user_details.reload.posts_count).to eq(1)
    end

    it 'bumps the topics count when a new topic is created' do
      user = create(:user)
      user_details = create(:user_detail, user: user)
      create(:topic, user: user)

      expect(user_details.reload.topics_count).to eq(1)
    end
  end
end
