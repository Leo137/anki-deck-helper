# frozen_string_literal: true

module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        include ApiCsrfExempt

        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: user_payload(resource), status: :created
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :username, :password, :password_confirmation)
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
