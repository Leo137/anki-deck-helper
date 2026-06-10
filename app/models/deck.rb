# frozen_string_literal: true

class Deck < ApplicationRecord
  belongs_to :user

  has_many :deck_words, -> { order(:position) }, dependent: :destroy, inverse_of: :deck
  has_many :words, through: :deck_words

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
