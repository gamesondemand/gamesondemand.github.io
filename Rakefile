namespace :build do
  task :google_session do
    require "rubygems"
    require "google_drive"
    @session = GoogleDrive.login(ENV['GOOGLE_USERNAME'], ENV['GOOGLE_PASSWORD'])
  end
  task :functions do
    def keyify_time(time)
      time.gmtime.strftime('%a %l%p').sub(/ +/, ' ')
    end
    def slugify_text(input)
      input.gsub(/\W+/, '-').downcase.sub(/-$/, '')
    end
    def alpha_group_for(word)
      case word.to_s[0,1]
      when /\d/ then '0-9'
      when /[abcdef]/ then 'A-F'
      when /[ghijkl]/ then 'G-L'
      when /[mnopqr]/ then 'M-R'
      when /[stuvwxyz]/ then 'S-Z'
      end
    end
  end

  namespace :pages do
    desc 'Build game pages'
    task :games => ['build:data:games'] do
      require 'fileutils'
      require 'psych'

      FileUtils.rm_rf(File.expand_path("../available-games", __FILE__))
      games = Psych.load_file(File.expand_path('../_data/games.yml', __FILE__)).collect.sort {|a,b| a[0] <=> b[0] }

      dirname = File.expand_path("../available-games", __FILE__)
      FileUtils.mkdir_p(dirname)
      File.open(File.join(dirname, 'index.html'), 'w+') do |file|
        text = []
        text << '---'
        text << 'layout: game'
        text << "title: Available Games for Games on Demand at GenCon"
        text << "description: Available Games for Games on Demand at GenCon"
        text << '---'
        text << '<article class="available-games">'
        text << '  <header class="available-games-header header">'
        text << '    <h2 class="name">{{ page.title }}</h2>'
        text << '  </header>'
        text << ''
        text << '  <nav>'
        text << '    <ul class="inline-list">'
        text << '      {% assign previous_alpha_group = "" %}'
        text << '      {% for game in site.data.games %}'
        text << '        {% if game[1].alpha_group != previous_alpha_group %}{% assign previous_alpha_group = game[1].alpha_group %}<li><a class="button tiny round" href="#{{ previous_alpha_group }}">{{ previous_alpha_group }}</a></li>{% endif %}'
        text << '      {% endfor %}'
        text << '    </ul>'
        text << '  </nav>'
        text << ''
        text << '  <table>'
        text << '    <caption>{{ page.title }}</caption>'
        text << '    <thead>'
        text << '      <tr>'
        text << '        <th width="80%">Game</th>'
        text << '        <th width="20%">Type</th>'
        text << '      </tr>'
        text << '    </thead>'
        text << '    <tbody>'
        text << '  {% assign previous_alpha_group = "" %}'
        text << '  {% for game in site.data.games %}'
        text << '    <tr>'
        text << '      <td><a href="/available-games/{{game[0]}}/"{% if game[1].alpha_group != previous_alpha_group %}{% assign previous_alpha_group = game[1].alpha_group %} name="{{ previous_alpha_group}}"{% endif %}>'
        text << '        {{ game[1].name }}'
        text << '      </a></td>'
        text << '      <td>{{ game[1].type }}</td>'
        text << '    </tr>'
        text << '  {% endfor %}'
        text << '    </tbody>'
        text << '  </table>'
        text << ''
        text << '</article>'
        file.puts text.join("\n")
      end


      games.each do |game_id, game_config|
        dirname = File.expand_path("../available-games/#{game_id}", __FILE__)
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
          text << "{% assign game_id = '#{game_id}' %}"
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
        ['Sunday', ['10am', '12pm', '2pm']],
      ].each do |day, times|
        dirname = File.expand_path("../#{day.downcase}", __FILE__)
        FileUtils.rm_rf(dirname)
        FileUtils.mkdir_p(dirname)
        File.open(File.join(dirname, 'index.html'), 'w+') do |file|
          text = []
          text << '---'
          text << 'layout: day'
          text << "title: #{day} Games on Demand at GenCon"
          text << "description: List of games for #{day} at Games on Demand GenCon"
          text << '---'
          text << "{% assign day = site.data.times.#{day.downcase} %}"
          text << '{% include day.html day=day %}'
          file.puts text.join("\n")
        end
        times.each_with_index do |time, index|
          FileUtils.mkdir_p(File.join(dirname, time))
          File.open(File.join(dirname, time, 'index.html'), 'w+') do |file|
            text = []
            text << '---'
            text << 'layout: time'
            text << "title: #{time} #{day} Games on Demand at GenCon"
            text << "description: List of games for #{time} #{day} at Games on Demand GenCon"
            text << '---'
            text << "{% assign time = site.data.times.#{day.downcase}.times.#{time} %}"
            text << '{% include time.html time = time %}'
            file.puts text.join("\n")
          end
        end
      end
    end
  end

  namespace :data do
    desc 'Download the schedule'
    task :schedule_download => ['build:google_session'] do
      require 'csv'
      temp_filename = File.expand_path('../_data/schedule-tmp.csv', __FILE__)
      filename = File.expand_path('../_data/schedule.csv', __FILE__)
      sheet = @session.spreadsheet_by_key('1eXGyt8ttJNqzEnSOq5frSeOZ0nV1zEm41SCs60rtn1I')
      sheet.export_as_file(temp_filename)
      contents = File.read(temp_filename).split("\n")
      contents.shift # Junk row
      days = contents.shift.split(",").collect(&:strip)
      slots = contents.shift.split(",").collect {|obj| obj.sub(/ +/, '').strip.upcase }
      contents.shift # Final hours
      merged_days = []
      days.each_with_index do |col, i|
        merged_days << "#{col} #{slots[i]}".gsub(/ +/, ' ')
      end
      merged_days[1] = "name"
      contents.unshift(merged_days.join(','))
      CSV.open(filename, 'w+') do |csv|
        contents.each do |content|
          row = CSV.parse(content).pop[1..-1]
          csv << row # Silly leading space
        end
      end
      File.unlink(temp_filename)
    end

    desc 'Build necessary game data'
    task :games => ['build:functions'] do
      require 'fileutils'
      require 'psych'
      require 'csv'
      require 'nokogiri'

      collector = {}
      exceptions = []
      ['Tabletop', 'LARP'].each do |type|
        document = Nokogiri::XML.parse(File.read(File.expand_path("../_data/gencon_god_#{type.downcase}.xml", __FILE__)))
        document.css('games gm').each do |gm|
          gm.css('game').each do |game|
            game_name = game.xpath('title').first.text
            game_name = game_name.
              gsub(/:(\w)/, ': \1').
              sub(/^(An?) (.*)$/i, '\2').
              sub(/^(The) (.*)$/i, '\2')
            game_type = type
            gm_name = (gm.xpath('schedule_name').first || gm.xpath('name').first).text
            slugified_game_name = slugify_text(game_name.split('(').first)
            slugified_person_name = slugify_text(gm_name)

            collector[slugified_game_name] ||= {
              'facilitators' => {},
              'type' => game_type,
              'name' => game_name,
              'alpha_group' => alpha_group_for(slugified_game_name)
            }
            if collector[slugified_game_name]['name'].downcase != game_name.downcase
              exceptions << "Mismatch game name: #{slugified_game_name}\n\tExpected: #{collector[slugified_game_name]['name']}\n\tGot: #{game_name}"
            end
            if collector[slugified_game_name]['type'] != game_type
              exceptions << "Mismatch game type: #{slugified_game_name}\n\tExpected: #{collector[slugified_game_name]['type']}\n\tGot: #{game_type}"
            end
            pitch = game.xpath('pitch').inner_html.strip
            duration = game.css('scheduling duration').first.text
            minimum_players = game.css('scheduling min').first.text
            maximum_players = game.css('scheduling max').first.text
            audience_node = game.css('audience').first
            if audience_node
              audience = audience_node.text
            else
              audience = ''
            end
            collector[slugified_game_name]['facilitators'][slugified_person_name] = {
              'type' => game_type,
              'facilitator_name' => gm_name,
              'name' => game_name,
              'pitch' => pitch,
              'duration' => duration,
              'minimum_players' => minimum_players,
              'maximum_players' => maximum_players,
              'audience' => audience
            }
          end
        end
      end

      # Alphabetizing the hash
      collector = collector.sort {|a,b| a[0] <=> b[0] }.each_with_object({}) {|game, mem| mem[game[0]] = game[1]; mem}

      $stderr.puts exceptions

      File.open(File.expand_path('../_data/games.yml', __FILE__), 'w+') do |file|
        file.puts Psych.dump(collector)
      end
    end

    desc 'Responsible for parsing the schedule CSV and generating a hosts and facilitators file'
    task :volunteers => ['build:functions', 'build:functions'] do #, 'build:data:schedule_download'] do
      Day = Struct.new(:day, :times)
      require 'csv'
      require 'psych'
      times = Psych.load_file(File.expand_path('../_data/times.yml', __FILE__))
      days = []
      facilitating = {}
      hosting = {}
      times.each_with_object(days) {|time, mem| 
        mem << Day.new(time[1].fetch('day'), time[1]['times'].values.collect{|v| v['time'] })
      }

      def peak_ahead(row, times, index, role_pattern)
        duration = 2
        times[index+1..-1].each do |time|
          if row[keyify_time(time)] =~ role_pattern
            duration += 2
          else
            break
          end
        end
        duration
      end

      source_filename = File.expand_path('../_data/schedule.csv', __FILE__)
      CSV.foreach(source_filename, headers: :first_row) do |row|
        # Because some rows don't have people
        if row['name']
          slugified_person_name = slugify_text(row['name'])
          days.each do |day|
            day.times.each_with_index do |time, index|
              time_key = keyify_time(time)
              case row[time_key]
              when /host/i
                hosting[slugified_person_name] ||= []
                hosting[slugified_person_name] << {
                  day: time.gmtime.strftime('%A').downcase.strip,
                  slot: time.gmtime.strftime('%l%p').strip,
                  max_duration: peak_ahead(row, day.times, index, /host/i),
                  role: row[time_key].downcase
                }
              when /gm/i
                facilitating[slugified_person_name] ||= []
                facilitating[slugified_person_name] << {
                  day: time.gmtime.strftime('%A').downcase.strip,
                  slot: time.gmtime.strftime('%l%p').strip,
                  max_duration: peak_ahead(row, day.times, index, /gm/i),
                  role: row[time_key].downcase
                }
              when /larp/i
                facilitating[slugified_person_name] ||= []
                facilitating[slugified_person_name] << {
                  day: time.gmtime.strftime('%A').downcase.strip,
                  slot: time.gmtime.strftime('%l%p').strip,
                  max_duration: peak_ahead(row, day.times, index, /larp/i),
                  role: row[time_key].downcase
                }
              when /^ *$/
              else
              end
            end
          end
        end
      end

      File.open(File.expand_path('../_data/hosts.yml', __FILE__), 'w+') do |file|
        hosts = []
        hosting.each_with_object(hosts) do |h, mem|
          mem << { name: h[0], times: h[1] }
        end
        file.puts Psych.dump(hosts)
      end
      File.open(File.expand_path('../_data/facilitator.yml', __FILE__), 'w+') do |file|
        facilitators = []
        facilitating.each_with_object(facilitators) do |h, mem|
          h[1].each do |data|
            mem << data.merge(name: h[0])
          end
          mem
        end
        file.puts Psych.dump(facilitators)
      end
    end

    desc 'Responsible for building thetime'
    task :times => ['build:functions', 'build:data:games','build:data:volunteers'] do
      require 'psych'
      require 'set'
      times = Psych.load_file(File.expand_path('../_data/times.yml', __FILE__))
      facilitators = Psych.load_file(File.expand_path('../_data/facilitator.yml', __FILE__))
      games = Psych.load_file(File.expand_path('../_data/games.yml', __FILE__))
      time_registry = {}
      game_offerings = {}
      times.each do |day_name, time_structure|
        time_registry[day_name] = time_structure
        time_structure.fetch('times').each do |abbreviation, slot_data|
          time_registry.fetch(day_name).fetch('times')[abbreviation]['two_hour_games'] = []
          time_registry.fetch(day_name).fetch('times')[abbreviation]['four_hour_games'] = []
          the_time = time_registry.fetch(day_name).fetch('times')[abbreviation]['time']
          time_registry.fetch(day_name).fetch('times')[abbreviation]['label'] = the_time.gmtime.strftime("%A %l%p")
          slot_facilitators = facilitators.select do |facilitator|
            facilitator.fetch(:day).upcase == day_name.upcase &&
            facilitator.fetch(:slot).upcase == abbreviation.upcase
          end

          games.each do |game_id, game_data|
            game_offerings[game_id] ||= Set.new
            slot_facilitators.each do |facilitator|
              offering = game_data.fetch('facilitators')[facilitator.fetch(:name)]
              next unless offering
              next unless (facilitator.fetch(:role) =~ /gm/i && offering.fetch('type') =~ /tabletop/i) ||
                  (facilitator.fetch(:role) =~ /larp/i && offering.fetch('type') =~ /larp/i)
              offering_duration = offering.fetch('duration').to_i
              next unless offering_duration <= facilitator.fetch(:max_duration).to_i
              entry = { 'game_id' => game_id, 'facilitator_id' => facilitator.fetch(:name) }
              game_offerings[game_id] << { 'slug' => File.join(day_name, abbreviation), 'label' => keyify_time(slot_data.fetch('time')), 'facilitator_id' => entry['facilitator_id'] }
              case offering_duration
              when 2 then slot_data['two_hour_games'] << entry
              when 4 then slot_data['four_hour_games'] << entry
              else
                raise "Unexpected duration"
              end
            end
            game_offerings[game_id] = game_offerings[game_id].to_a
          end
        end
      end

      File.open(File.expand_path('../_data/times.yml', __FILE__), 'w+') do |file|
        file.puts Psych.dump(time_registry)
      end

      File.open(File.expand_path('../_data/game_offerings.yml', __FILE__), 'w+') do |file|
        file.puts Psych.dump(game_offerings)
      end
    end
  end
  task :pages => ['build:pages:schedule', 'build:pages:games']
  task :data => ['build:data:games', 'build:data:schedule_download', 'build:data:volunteers', 'build:data:times']
end

desc 'Build the sites'
task :build => ['build:data', 'build:pages']

task :default => :build

# Uncomment for later
# task :parse_xml do
#   require 'nokogiri'
#   gem 'byebug'
#   xml_doc = File.expand_path('../_data/god_menu_tabletop.xml', __FILE__)
#   doc = Nokogiri::XML.parse(File.read(xml_doc))
#   doc.css('[key=autokey30]').each do |obj|
#     ::Kernel.require 'byebug'; ::Kernel.byebug; true;
#   end
# end
