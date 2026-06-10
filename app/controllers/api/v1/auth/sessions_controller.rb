# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        include ApiCsrfExempt

        respond_to :json

        skip_before_action :verify_signed_out_user, only: :destroy

        before_action :authenticate_user!, only: :show

        def show
          if current_user
            render json: user_payload(current_user)
          else
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end

        def destroy
          user = warden.authenticate(scope: :user)
          return render json: { error: 'Unauthorized' }, status: :unauthorized unless user

          sign_out(user)
          render json: { message: 'Logged out successfully' }
        end

        private

        def respond_with(resource, _opts = {})
          render json: user_payload(resource)
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
