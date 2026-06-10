# frozen_string_literal: true

module Api
  module V1
    module Users
      class PreferencesController < BaseController
        include JwtAuthenticatable

        def show
          render json: {
            preferred_language: current_user.preferred_language,
            available_languages: User::PREFERRED_LANGUAGES
          }
        end

        def update
          if current_user.update(preferences_params)
            render json: {
              preferred_language: current_user.preferred_language,
              available_languages: User::PREFERRED_LANGUAGES
            }
          else
            render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def preferences_params
          params.require(:preferences).permit(:preferred_language)
        end
      end
    end
  end
end
