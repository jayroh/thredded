require 'spec_helper'


module Thredded
  describe PrivateTopic do
    before(:each) do
      @user1 = create(:user, name: 'privateuser1')
      @user2 = create(:user, name: 'privateuser2')
      @messageboard = create(:messageboard)
      @topic = create(:private_topic, messageboard: @messageboard, users: [@user1, @user2])
    end

    it 'is private when it has users' do
      @topic.private?.should be_true
    end

    context 'when it is private' do
      it 'does not allow someone not involved to read the topic' do
        @user3 = create(:user)
        ability = Ability.new(@user3)

        ability.can?(:read, @topic).should be_false
      end

      it 'allows someone included in the topic to read it' do
        ability = Ability.new(@user2)

        ability.can?(:read, @topic).should be_true
      end
    end

    describe '.add_user' do
      before(:each) do
        @joel  = create(:user, name: 'joel')
      end

      it 'should add a user by their username' do
        @topic.add_user('joel')
        @topic.users.should include(@joel)
      end

      it 'should add a user with a User object' do
        @topic.add_user(@joel)
        @topic.users.should include(@joel)
      end
    end

    describe '.users_to_sentence' do
      it 'should list out the users in a topic in a human readable format' do
        @topic.users_to_sentence.should eq 'Privateuser1 and Privateuser2'
      end
    end

    describe '.unread_privates?' do
      context 'when a user sends another user a PM' do
        it 'the user should have unread private topics' do
          expect(PrivateTopic.unread_privates?(@user2)).to be_true
        end
      end

      context 'when a user reads a private thread' do
        it 'the user should not have unread private topics' do
          create(:user_topic_read, user: @user2, topic: @topic)
          expect(PrivateTopic.unread_privates?(@user2)).to be_false
        end
      end

      context 'when a user reads a PM and gets another PM' do
        it 'the user should have unread private topics' do
          create(:user_topic_read, user: @user2, topic: @topic)
          create(:private_topic, messageboard: @messageboard, users: [@user1, @user2])
          expect(PrivateTopic.unread_privates?(@user2)).to be_true
        end
      end
    end
  end
end
