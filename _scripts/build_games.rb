#!/usr/bin/env ruby -w

require 'fileutils'
require 'psych'

FileUtils.rm_rf(File.expand_path("../../available-games", __FILE__))
games = Psych.load_file(File.expand_path('../../_data/games.yml', __FILE__)).collect.sort {|a,b| a[0] <=> b[0] }

dirname = File.expand_path("../../available-games", __FILE__)
FileUtils.mkdir_p(dirname)
File.open(File.join(dirname, 'index.html'), 'w+') do |file|
  text = []
  text << '---'
  text << 'layout: default'
  text << "title: Games on Offer at Games on Demand at GenCon"
  text << "description: Games on Offer at Games on Demand at GenCon"
  text << '---'
  text << '<h2>Games on Offer</h2>'
  text << '<ul>'
  text << "{% for game in site.data.games %}"
  text << '  <li><a href="/available-games/{{game[0]}}/">{{ game[1].name }}</a></li>'
  text << '{% endfor %}'
  text << '</ul>'
  text << ''
  file.puts text.join("\n")
end


games.each do |game_id, game_config|
  dirname = File.expand_path("../../available-games/#{game_id}", __FILE__)
  FileUtils.mkdir_p(dirname)
  File.open(File.join(dirname, 'index.html'), 'w+') do |file|
    text = []
    text << '---'
    text << 'layout: game'
    text << "title: #{game_config['name']} at Games on Demand at GenCon"
    text << "description: #{game_config['name']} at Games on Demand at GenCon"
    text << '---'
    text << "{% assign game = site.data.games['#{game_id}'] %}"
    text << '{% include game.html game = game %}'
    text << ''
    file.puts text.join("\n")
  end
end

