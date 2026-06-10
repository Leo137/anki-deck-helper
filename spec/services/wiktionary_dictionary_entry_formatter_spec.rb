# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WiktionaryDictionaryEntryFormatter do
  let(:entry_hash) do
    JSON.parse(File.read(Rails.root.join('spec/fixtures/files/wiktionary_densha.jsonl')).lines.first)
  end

  subject(:formatted) { described_class.new(entry_hash).call }

  it 'maps the word to entry text' do
    expect(formatted.text).to eq('電車')
  end

  it 'maps transliteration forms to kana readings' do
    expect(formatted.readings).to contain_exactly(
      have_attributes(text: 'でんしゃ', is_kana: true)
    )
  end

  it 'creates one meaning per sense' do
    expect(formatted.meanings.length).to eq(4)
  end

  it 'maps glosses to definitions' do
    first_meaning = formatted.meanings.first

    expect(first_meaning.definitions).to contain_exactly(
      have_attributes(text: '外部からの電気を動力として走る列車のうち、1編成中の車両のいくつか又はすべてに動力となる電動機を装備して自走能力をそなえ、機関車の牽引によらずに走行する列車。')
    )
  end

  it 'assigns part of speech to each meaning' do
    formatted.meanings.each do |meaning|
      expect(meaning.parts_of_speech).to contain_exactly(have_attributes(code: 'noun'))
    end
  end

  it 'maps entry and sense categories to misc tags' do
    first_meaning = formatted.meanings.first

    expect(first_meaning.misc_tags.map(&:code)).to include(
      '和製漢語',
      '日本語',
      '日本語 名詞',
      '日本語 車両',
      '日本語 鉄道',
      '車両'
    )
  end

  it 'maps sense tags to misc tags' do
    informal_meaning = formatted.meanings.last

    expect(informal_meaning.misc_tags.map(&:code)).to include('informal', '日本語 口語')
  end

  it 'maps sense topics to fields' do
    first_meaning = formatted.meanings.first

    expect(first_meaning.fields).to contain_exactly(have_attributes(code: 'rail-transport'))
  end
end
