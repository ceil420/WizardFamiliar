## Known Issues
###### Blogatog

### Occasional missed embed
Sometimes, instead of an embed, a message will be sent to the channel with a
link to the blog entry, followed by a simple bolded message for the question.
The bold message is actually a workaround for a *400 Bad Request* error occa-
sionally received from Discordrb, the library used to interface with Discord.
I have been unable to identify the cause of the error.

Logs from a good (embedded) posting:
```
2019-10-21 06:53:19 > 3. Inside RSS item https://markrosewater.tumblr.com/post/188493682073.
2019-10-21 06:53:19 > 4. Processing 188493682073.
2019-10-21 06:53:19 > 6. Posting new post.
2019-10-21 06:53:19 >>>> Are there any plans for a 3-type land?
2019-10-21 06:53:19 >>>> https://markrosewater.tumblr.com/post/188493682073
2019-10-21 06:53:19 >>>> <p>I never say never. </p>
2019-10-21 06:53:19 >>>> Mon, 21 Oct 2019 09:46:51 -0400
2019-10-21 06:53:19 > 7. Post posted.
2019-10-21 06:53:19 > 9. Sleeping five...
```

Logs from a bad (bolded) posting:
```
2019-10-21 06:53:29 > 3. Inside RSS item https://markrosewater.tumblr.com/post/188493661338.
2019-10-21 06:53:29 > 4. Processing 188493661338.
2019-10-21 06:53:29 > 6. Posting new post.
2019-10-21 06:53:29 >>>> Do you think there is any chance that we see something like a "Magic: The Gathering 2" or new TCG by WOTC? I'm always hearing about "If we were starting the game today X would be different" and I think as great as the game is, it is held back by some old notions that other card games have modernized, especially things like the Land System. I really think that a MTG2, with you guys hving the chance to redo some old concepts about the game, keeping what is great, would result in something AMAZING.
2019-10-21 06:53:29 >>>> https://markrosewater.tumblr.com/post/188493661338
2019-10-21 06:53:29 >>>> <p>When Magic is as successful as it’s ever been, it’s a big risk to “start over”.</p>
2019-10-21 06:53:29 >>>> Mon, 21 Oct 2019 09:45:38 -0400
2019-10-21 06:53:30 > 7. Post failed.
2019-10-21 06:53:30 >>>> 400 Bad Request
2019-10-21 06:53:30 >>>> ["/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/abstract_response.rb:249:in `exception_with_response'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/abstract_response.rb:129:in `return!'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/request.rb:836:in `process_result'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/request.rb:743:in `block in transmit'", "/home/ceil/.rvm/rubies/ruby-2.6.3/lib/ruby/2.6.0/net/http.rb:920:in `start'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/request.rb:727:in `transmit'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/request.rb:163:in `execute'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient/request.rb:63:in `execute'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/rest-client-2.1.0/lib/restclient.rb:70:in `post'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/discordrb-3.3.0/lib/discordrb/api.rb:81:in `raw_request'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/discordrb-3.3.0/lib/discordrb/api.rb:112:in `request'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/discordrb-3.3.0/lib/discordrb/api/channel.rb:76:in `create_message'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/discordrb-3.3.0/lib/discordrb/bot.rb:367:in `send_message'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/discordrb-3.3.0/lib/discordrb/data.rb:1617:in `send_message'", "/home/ceil/.rvm/gems/ruby-2.6.3/gems/discordrb-3.3.0/lib/discordrb/data.rb:1645:in `send_embed'", "tracker-blogatog.rb:47:in `block (3 levels) in <main>'", "tracker-blogatog.rb:29:in `each'", "tracker-blogatog.rb:29:in `block (2 levels) in <main>'", "/home/ceil/.rvm/rubies/ruby-2.6.3/lib/ruby/2.6.0/open-uri.rb:169:in `open_uri'", "/home/ceil/.rvm/rubies/ruby-2.6.3/lib/ruby/2.6.0/open-uri.rb:736:in `open'", "/home/ceil/.rvm/rubies/ruby-2.6.3/lib/ruby/2.6.0/open-uri.rb:35:in `open'", "tracker-blogatog.rb:25:in `block in <main>'"]
2019-10-21 06:53:30 > 9. Sleeping five...
```

The same code processed both posts. See the source in **tracker-blogatog.rb**,
but the relevant code is below:
```ruby
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
          puts "#{Time.now.strftime("%F %T")} >>>> #{item.title.to_s}"
          puts "#{Time.now.strftime("%F %T")} >>>> #{item.link.to_s}"
          puts "#{Time.now.strftime("%F %T")} >>>> #{item.description.to_s}"
          puts "#{Time.now.strftime("%F %T")} >>>> #{item.pubDate.to_s}"

          begin
            bot.channel(chan).send_embed("New **Blogatog** post!") do |embed|
              embed.title = "Blogatog"
              embed.description = item.pubDate.to_s
              embed.colour = 0x687FC7
              embed.url = item.link.to_s
              embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url:"https://66.media.tumblr.com/avatar_7c8d4585b098_64.pnj")
              embed.add_field(name: item.title.to_s, value: "#{item.description.gsub!(/<("[^"]*"|'[^']*'|[^'">])*>/, '')}")
            end
            puts "#{Time.now.strftime("%F %T")} > 7. Post posted."
          rescue StandardError => err
            bot.send_message(chan, "New **Blogatog** post at <#{item.link.to_s}>\n**#{item.title.to_s}**\n#{item.description.gsub!(/<("[^"]*"|'[^']*'|[^'">])*>/, '')}")
            puts "#{Time.now.strftime("%F %T")} > 7. Post failed."
            puts "#{Time.now.strftime("%F %T")} >>>> #{err.message}"
            puts "#{Time.now.strftime("%F %T")} >>>> #{err.backtrace.inspect}"
          end

        else
          puts "#{Time.now.strftime("%F %T")} > 8. No more new posts, breaking out."
          break
        end

        puts "#{Time.now.strftime("%F %T")} > 9. Sleeping five..."
        sleep 5
      end
```

(Very important to note that the current goal is *functional* code, not necess-
arily *pretty* code. This will be refactored once I understand how everything
is fundamentally supposed to work. I *do*, however, need to write up a better
logging system...)

-c
