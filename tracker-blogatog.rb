require 'discordrb'
require 'rss'
require 'json'

puts "#{Time.now.strftime("%F %T")} Loading config..."
config   = File.open("keys.json", "r")     { |f| JSON.parse(f.read) }
blogatog = File.open("blogatog.json", "r") { |f| JSON.parse(f.read) }

puts "#{Time.now.strftime("%F %T")} Bringing bot online..."
bot = Discordrb::Commands::CommandBot.new token: config["discord_token"], client_id: config["discord_client_id"], prefix: config["discord_prefix"]

# The meat of the script keeps an eye on Blogatog - the name of
# Mark Rosewater's blog. For now, we're just trying to check in
# every ten minutes, and whenever there's new posts, send them
# to our hard-coded channel.

Thread.new {

  puts "#{Time.now.strftime("%F %T")} > 1. Inside RSS thread."
  chan = '567037361117200384'
  lastpost = blogatog["lastpost"].to_i
  newlast = lastpost

  while (true) do
    open(blogatog["url"]) do |rss|
      puts "#{Time.now.strftime("%F %T")} > 2. Inside RSS loop."
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        puts "#{Time.now.strftime("%F %T")} > 3. Inside RSS item #{item.link.to_s}."
        thispost = item.link.gsub(/.*\/\/.*\/.*\//, '').to_i
        puts "#{Time.now.strftime("%F %T")} > 4. Processing #{thispost}."
        if thispost > newlast
          puts "#{Time.now.strftime("%F %T")} > 5. Marking new post."
          newlast = thispost
        end
        if thispost > lastpost
          puts "#{Time.now.strftime("%F %T")} > 6. Posting new post."
          begin
            bot.channel(chan).send_embed("New **Blogatog** post!") do |embed|
              embed.title = "Blogatog"
              embed.description = item.pubDate.to_s
              embed.colour = 0x687FC7
              embed.url = item.link.to_s
              embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url:"https://66.media.tumblr.com/avatar_7c8d4585b098_64.pnj")
              embed.add_field(name: item.title.to_s, value: "#{item.description.gsub!(/<("[^"]*"|'[^']*'|[^'">])*/, '')}")
            end
            puts "#{Time.now.strftime("%F %T")} > 7. Post posted."
          rescue
            bot.send_message(chan, "New **Blogatog** post at <#{item.link.to_s}>\n**#{item.title.to_s}**\n#{item.description.gsub!(/<("[^"]*"|'[^']*'|[^'">])*/, '')}")
            puts "#{Time.now.strftime("%F %T")} > 7. Post failed."
          end
        else
          puts "#{Time.now.strftime("%F %T")} > 8. No more new posts, breaking out."
          break
        end
        puts "#{Time.now.strftime("%F %T")} > 9. Sleeping five..."
        sleep 5
      end
      puts "#{Time.now.strftime("%F %T")} > 10. Saving lastpost #{newlast} to file."
      blogatog["lastpost"] = lastpost = newlast
      File.open("blogatog.json", "w") { |f| f.puts JSON.generate(blogatog) }
    end
    puts "#{Time.now.strftime("%F %T")} > 11. Sleeping for ten minutes."
    sleep 600
  end
}

bot.run
