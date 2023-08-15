# frozen_string_literal: true

# Opens a Yomichan JSON frequency table file and saves it to
# FrequencyTable / FrequencyTableEntry records.
class FrequencyTableImporter
  attr_accessor :frequency_table, :file

  def initialize(table_name, filepath)
    @frequency_table = FrequencyTable.find_or_create_by(name: table_name)
    @file = File.new(filepath, 'r')
  end

  def call
    json_data.each do |term|
      entry = FrequencyTableEntry.find_or_create_by!(
        frequency_table:,
        content: term[0]
      )
      entry.update(frequency: term[2])
    end
  ensure
    file.close
  end

  private

  def json_data
    @json_data ||= build_json_data
  end

  def build_json_data
    parser = Yajl::Parser.new
    parser.parse(file)
  end
end
