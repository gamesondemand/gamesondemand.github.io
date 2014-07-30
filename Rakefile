namespace :build do
  namespace :pages do
    desc 'Build game pages'
    task :games => ['build:data:games'] do
      require 'fileutils'
      require 'psych'

      FileUtils.rm_rf(File.expand_path("../../available-games", __FILE__))
      games = Psych.load_file(File.expand_path('../_data/games.yml', __FILE__)).collect.sort {|a,b| a[0] <=> b[0] }

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
          text << "title: >"
          text << "  #{game_config['name']} at Games on Demand at GenCon"
          text << "description: >"
          text << "  #{game_config['name']} at Games on Demand at GenCon"
          text << '---'
          text << "{% assign game = site.data.games['#{game_id}'] %}"
          text << '{% include game.html game = game %}'
          text << ''
          file.puts text.join("\n")
        end
      end
    end
    desc 'Build day schedule pages'
    task :schedule do
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
          text << "title: #{day} Games on Demand at GenCon"
          text << "description: List of games for #{day} at Games on Demand GenCon"
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
            text << "title: #{time} #{day} Games on Demand at GenCon"
            text << "description: List of games for #{time} #{day} at Games on Demand GenCon"
            text << '---'
            text << "{% assign time = site.data.#{day.downcase}.times.#{time} %}"
            text << '{% include time.html time = time %}'
            file.puts text.join("\n")
          end
        end
      end
    end
  end

  namespace :data do
    desc 'Build necessary game data'
    task :games do
      require 'fileutils'
      require 'psych'
      require 'csv'

      source_filename = File.expand_path('../_data/god_gencon_gameimport.csv', __FILE__)
      collector = {}
      exceptions = []
      CSV.foreach(source_filename, headers: :first_row) do |row|
        # Header ["Name", "Game1", "G1Type", "G1Pitch", "G1Hours", "G1PMin", "G1PMax", "G1Kids"]
        row['Game1'] = '3:16' if row['Game1'].to_s =~ /1361+/
        row['Game1'] = row['Game1'].sub(/^(An?) (.*)$/i, '\2')
        row['Game1'] = row['Game1'].sub(/^(The) (.*)$/i, '\2')

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

      File.open(File.expand_path('../_data/games.yml', __FILE__), 'w+') do |file|
        file.puts Psych.dump(collector)
      end
    end
  end
  task :pages => ['build:pages:schedule', 'build:pages:games']
  task :data => ['build:data:games']
end

desc 'Build the sites'
task :build => ['build:data', 'build:pages']

task :default => :build
