# frozen_string_literal: true

class Deck < ApplicationRecord
  belongs_to :user

  has_many :cards, -> { order(:position) }, class_name: 'Deck::Card', dependent: :destroy, inverse_of: :deck,
                                            autosave: false

  enum :status, { pending: 0, processing: 1, ready: 2, failed: 3 }

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :generation_progress, numericality: { only_integer: true, in: 0..100 }
end
