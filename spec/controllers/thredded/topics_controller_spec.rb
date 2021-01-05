# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe TopicsController do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }

    before do
      @messageboard = create(:messageboard)
      @topic = create(:topic, messageboard: @messageboard, title: 'hi')
      @post = create(:post, postable: @topic, content: 'hi')
      allow(controller).to receive_messages(
        topics: [@topic],
        cannot?: false,
        the_current_user: user,
        messageboard: @messageboard
      )
    end

    describe 'GET index' do
      it 'renders' do
        get :index, params: { messageboard_id: @messageboard.slug }
        expect(response).to match_schema(TopicViewSchema)
        expect(response).to have_http_status(200)
      end

      it 'performs canonical redirect' do
        get :index, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :index, messageboard_id: @messageboard.slug)
      end
    end

    describe 'GET search' do
      it 'renders search' do
        allow(Topic).to receive_messages(search_query: Topic.where(id: @topic.id))
        get :search, params: { messageboard_id: @messageboard.slug, q: 'hi' }

        expect(response).to have_http_status(200)
      end

      it 'is successful with spaces around search term(s)' do
        allow(Topic).to receive_messages(search_query: Topic.where(id: @topic.id))
        get :search, params: { messageboard_id: @messageboard.slug, q: '  hi  ' }

        expect(response).to have_http_status(200)
      end

      it 'performs canonical redirect' do
        get :search, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :search, messageboard_id: @messageboard.slug)
      end

      context 'renders' do
        render_views
        it 'a No Results message' do
          allow(Topic).to receive_messages(search_query: Topic.none)
          get :search, params: { messageboard_id: @messageboard.slug, q: 'hi' }

          expect(JSON.parse(response.body)['data']['attributes']['topic_views'].size).to eq(0)
        end
      end
    end

    describe 'GET new' do
      it 'works with no extra parameters' do
        get :new, params: { messageboard_id: @messageboard.slug }
        expect(response).to be_successful
        expect(response).to render_template('new')
        expect(assigns(:new_topic).title).to be_blank
        expect(assigns(:new_topic).content).to be_blank
      end

      it 'assigns extra parameters' do
        get :new, params: {
          messageboard_id: @messageboard.slug, topic: { title: 'given title', content: 'preset content' }
        }
        expect(response).to be_successful
        expect(response).to render_template('new')
        expect(assigns(:new_topic).title).to eq 'given title'
        expect(assigns(:new_topic).content).to eq 'preset content'
      end

      it 'performs canonical redirect' do
        get :new, params: { messageboard_id: @messageboard.id }
        expect(response).to redirect_to(action: :new, messageboard_id: @messageboard.slug)
      end
    end

    describe 'POST create' do
      let(:topic_params) { { title: 'one', content: 'something' } }

      it 'creates' do
        expect do
          post :create, params: { messageboard_id: @messageboard.slug, topic: topic_params }
        end.to change(Topic, :count).by(1)
      end

      it 'returns status code 201 when created' do
        post :create, params: { messageboard_id: @messageboard.slug, topic: topic_params }
        expect(response).to have_http_status(201)
      end
    end

    describe 'POST follow' do
      subject(:do_follow) { post :follow, params: { messageboard_id: @messageboard.id, id: @topic.id } }

      it 'follows' do
        expect { do_follow }.to change { @topic.reload.followers.reload.count }.by(1)
      end
      context 'json format' do
        subject(:do_follow) do
          post :follow, params: { messageboard_id: @messageboard.id, id: @topic.id, format: :json }
        end

        it 'returns changed status' do
          do_follow
          expect(response).to have_http_status(204)
        end
      end
    end

    describe 'POST unfollow' do
      subject(:do_unfollow) do
        post :unfollow, params: { messageboard_id: @messageboard.id, id: @topic.id }
      end

      before { UserTopicFollow.create_unless_exists(user.id, @topic.id) }

      it 'unfollows' do
        expect { do_unfollow }.to change { @topic.reload.followers.reload.count }.by(-1)
      end

      context 'json format' do
        subject(:do_unfollow) do
          post :unfollow, params: { messageboard_id: @messageboard.id, id: @topic.id, format: :json }
        end

        it 'returns changed status' do
          do_unfollow
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
