# frozen_string_literal: true

class WordSet < ApplicationRecord
  enum :origin, { normal: 0, takoboto: 1 }

  has_and_belongs_to_many :words

  validates :name, uniqueness: { scope: :origin }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name origin]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
