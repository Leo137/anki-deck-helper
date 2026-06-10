# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        before_action :authenticate_user!, only: :show

        def show
          if current_user
            render json: user_payload(current_user)
          else
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end

        private

        def respond_with(resource, _opts = {})
          render json: user_payload(resource)
        end

        def respond_to_on_destroy
          if current_user
            render json: { message: 'Logged out successfully' }
          else
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        def user_payload(user)
          {
            id: user.id,
            email: user.email,
            username: user.username,
            preferred_language: user.preferred_language
          }
        end
      end
    end
  end
end
