#!/usr/bin/env ruby -w

require 'fileutils'

[
  ['Thursday', ['10am', '12pm', '2pm', '4pm', '6pm']],
  ['Friday', ['10am', '12pm', '2pm', '4pm', '6pm', '8pm', '10pm']],
  ['Saturday', ['10am', '12pm', '2pm', '4pm', '6pm', '8pm', '10pm']],
  ['Sunday', ['10am', '12pm', '2pm', '4pm']],
].each do |day, times|
  dirname = File.expand_path("../../#{day.downcase}", __FILE__)
  FileUtils.rm_rf(dirname)
  FileUtils.mkdir_p(dirname)
  File.open(File.join(dirname, 'index.html'), 'w+') do |file|
    text = []
    text << '---'
    text << 'layout: default'
    text << "title: #{day} GamesOnDemand at GenCon"
    text << '---'
    text << "{% assign day = site.data.#{day.downcase} %}"
    text << '{% include day.html day=day %}'
    file.puts text.join("\n")
  end
  times.each_with_index do |time, index|
    FileUtils.mkdir_p(File.join(dirname, time))
    File.open(File.join(dirname, time, 'index.html'), 'w+') do |file|
      text = []
      text << '---'
      text << 'layout: default'
      text << "title: #{time} #{day} GamesOnDemand at GenCon"
      text << '---'
      text << "{% assign time = site.data.#{day.downcase}.times.#{time} %}"
      text << '{% include time.html time = time %}'
      file.puts text.join("\n")
    end
  end
end
