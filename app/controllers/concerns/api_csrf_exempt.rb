# frozen_string_literal: true

# JSON API endpoints authenticated via JWT do not use session cookies or CSRF tokens.
# Requests proxied from the Vite dev server also send a browser Origin that does not
# match Rails' internal Docker base_url, which would otherwise raise
# ActionController::InvalidAuthenticityToken.
module ApiCsrfExempt
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token
  end
end
