#!/usr/bin/env ruby -w

require 'fileutils'
require 'psych'
require 'csv'
gem 'byebug'

source_filename = File.expand_path('../../_data/god_gencon_gameimport.csv', __FILE__)
collector = {}
exceptions = []
CSV.foreach(source_filename, headers: :first_row) do |row|
  # Header ["Name", "Game1", "G1Type", "G1Pitch", "G1Hours", "G1PMin", "G1PMax", "G1Kids"]
  row['Game1'] = '3:16' if row['Game1'].to_s =~ /1361+/
  row['Game1'] = row['Game1'].sub(/^An? /i, '')
  row['Game1'] = row['Game1'].sub(/^The /i, '')

  slugified_game_name = row['Game1'].split('(').first.gsub(/\W+/, '-').downcase.sub(/-$/, '')
  slugified_person_name = row['Name'].gsub(/\W+/, '-').downcase
  collector[slugified_game_name] ||= {
    'facilitators' => {},
    'type' => row['G1Type'],
    'name' => row['Game1']
  }

  # Data integrity error
  if collector[slugified_game_name]['name'].downcase != row['Game1'].downcase
    exceptions << "Mismatch game name: #{slugified_game_name}\n\tExpected: #{collector[slugified_game_name]['name']}\n\tGot: #{row['Game1']}"
  end

  # Date integrity error check
  if collector[slugified_game_name]['type'] != row['G1Type']
    exceptions << "Mismatch game type: #{slugified_game_name}\n\tExpected: #{collector[slugified_game_name]['type']}\n\tGot: #{row['G1Type']}"
  end

  collector[slugified_game_name]['facilitators'][slugified_person_name] = {
    'type' => row['G1Type'],
    'facilitator_name' => row['Name'],
    'name' => row['Game1'],
    'pitch' => row['G1Pitch'],
    'duration' => row['G1Hours'],
    'minimum_players' => row['G1PMin'],
    'maximum_players' => row['G1PMax'],
    'kid_friendly' => (row['G1Kids'] == 'Yes' ? true : false)
  }
end

# Alphabetizing the hash
collector = collector.sort {|a,b| a[0] <=> b[0] }.each_with_object({}) {|game, mem| mem[game[0]] = game[1]; mem}

$stderr.puts exceptions

File.open(File.expand_path('../../_data/games.yml', __FILE__), 'w+') do |file|
  file.puts Psych.dump(collector)
end
