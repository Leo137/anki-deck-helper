# frozen_string_literal: true

# Opens a Yomichan JSON frequency table file and saves it to
# FrequencyTable / FrequencyTableEntry records.
class FrequencyTableImporter
  attr_accessor :frequency_table, :file, :frequency_table_entries

  def initialize(table_name, filepath)
    @frequency_table = FrequencyTable.find_or_create_by(name: table_name)
    @file = File.new(filepath, 'r')
    @frequency_table_entries = []
  end

  def call
    json_data.each do |term|
      frequency_table_entries << build_frequency_table_entry(term)

      import_frequency_table_entries if frequency_table_entries.length > 50_000
    end
    import_frequency_table_entries
  ensure
    file.close
  end

  private

  def build_frequency_table_entry(term)
    raise "Term #{term} has frequency nil" unless get_term_frequency(term[2])

    FrequencyTableEntry.new(
      frequency_table:,
      content: term[0],
      frequency: get_term_frequency(term[2])
    )
  end

  def get_term_frequency(field)
    return field if field.is_a? Numeric

    return field['value'] if field['value'].is_a? Numeric

    field['frequency']['value']
  end

  def import_frequency_table_entries
    return unless frequency_table_entries.any?

    FrequencyTableEntry.import(
      frequency_table_entries.uniq(&:content),
      on_duplicate_key_update: { conflict_target: [:content, :frequency_table_id], columns: [:frequency] },
      recursive: true
    )
    @frequency_table_entries = []
  end

  def json_data
    @json_data ||= build_json_data
  end

  def build_json_data
    parser = Yajl::Parser.new
    parser.parse(file)
  end
end
