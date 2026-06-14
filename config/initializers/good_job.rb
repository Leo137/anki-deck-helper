# frozen_string_literal: true

Rails.application.configure do
  # Jobs are processed by the `worker` Compose service (`bundle exec good_job start`).
  config.good_job.execution_mode = :external
  config.good_job.queues = '*'
end
