# frozen_string_literal: true

class Language < ApplicationRecord
  has_many :dictionaries, dependent: :destroy

  validates :code, presence: true, uniqueness: true

  def self.find_or_create_by_code!(code)
    find_or_create_by!(code: code.to_s)
  end
end
