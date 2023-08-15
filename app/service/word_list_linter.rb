# frozen_string_literal: true

# Checks if a word list structure doesnt has oddities in format
class WordListLinter
  attr_accessor :file

  def initialize(filepath)
    @file = File.new(filepath, 'r')
  end

  def call
    file.each_line.with_index do |term, index|
      rules.each do |rule|
        send(rule, term, index + 1)
      end
    end
  ensure
    file.close
  end

  private

  def rules
    %i[
      check_line_empty
      check_straneous_characters
    ]
  end

  # Rules
  def check_line_empty(term, index)
    return unless term.empty?

    puts "[#{index}, \"#{term}\"] Line empty"
  end

  def check_straneous_characters(term, index)
    return unless term[/[。\-～~,.]/]

    puts "[#{index}, \"#{term}\"] Straneous character"
  end
end
