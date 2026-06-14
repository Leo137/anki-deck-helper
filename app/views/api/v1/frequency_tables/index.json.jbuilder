# frozen_string_literal: true

json.array! @frequency_tables do |frequency_table|
  json.extract! frequency_table, :id, :name, :created_at, :updated_at
end
