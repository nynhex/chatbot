require 'net/http'
require_relative 'command'

class Meme < Command
    def print_help
        send("Here are the memes I can do:", @is_pm)
        send("/code * I don't always ___ but when I do ___\n" +
             "* Yo dawg ___ so ___\n" +
             "* One does not simply ___\n" +
             "* take my money\n" +
             "* Not sure if ___ or ___\n" +
             "* What if I told you ___\n" +
             "* Am I the only one around here ___\n" +
             "* ___ Ain't nobody got time for that'", @is_pm)
    end

    def respond
        if not @client.config.has_key?('meme')
            send("Sorry, I'm not configured to do meme's. Check my config.", @is_pm)
            return
        end

        # Meme ID's come from https://api.imgflip.com/caption_image
        # This should probably be more robust and stored in the db,
        # but I'm kinda lazy right now...
        @memes = {
            :interesting_man => 61532,
            :yodawg => 101716,
            :takemoney => 176908,
            :notsure => 61520,
            :onedoesnot => 61579,
            :matrix => 100947,
            :onlyone => 259680,
            :notime => 442575
        }

        meme_url = nil
        post_data = {
            :template_id => nil,
            :text0 => nil,
            :text1 => nil,
            :username => nil,
            :password => nil
        }

        if not @params[1]
            print_help
            return
        end

        case @params[1].downcase
        when /i don't always (.*) but when i do (.*)/
            post_data[:template_id] = @memes[:interesting_man]
            post_data[:text0] = "I don't always #{$1}"
            post_data[:text1] = "but when I do, #{$2}"
        when /yo dawg (.*) so (.*)/
            post_data[:template_id] = @memes[:yodawg]
            post_data[:text0] = "Yo Dawg, #{$1}"
            post_data[:text1] = "so #{$2}"
        when /one does not simply (.*)/
            post_data[:template_id] = @memes[:onedoesnot]
            post_data[:text0] = 'One does not simply'
            post_data[:text1] = $1
        when /take my money/
            post_data[:template_id] = @memes[:takemoney]
            post_data[:text0] = 'Shut up and'
            post_data[:text1] = 'take my money!'
        when /not sure if (.*) or (.*)/
            post_data[:template_id] = @memes[:notsure]
            post_data[:text0] = "Not sure if #{$1}"
            post_data[:text1] = "or #{$2}"
        when /what if i told you (.*)/
            post_data[:template_id] = @memes[:matrix]
            post_data[:text0] = "What if I told you"
            post_data[:text1] = $1
        when /am i the only one around here (.*)/
            post_data[:template_id] = @memes[:onlyone]
            post_data[:text0] = 'Am I the only one around here'
            post_data[:text1] = $1
        when /(.*) ain't nobody got time for that/
            post_data[:template_id] = @memes[:notime]
            post_data[:text0] = $1
            post_data[:text1] = "Ain't nobody got time for that!"
        when 'help'
            print_help
            return
        else
            print_help
            return
        end

        url = @client.config['meme']['post_url']
        post_data[:username] = @client.config['meme']['username']
        post_data[:password] = @client.config['meme']['password']

        @client.log.debug("Going to generate a meme:")
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(post_data)
        response = http.request(request)
        if response.code == '200'
            data = JSON.parse(response.body)
            if data['success']
                meme_url = data['data']['url']
            else
                @client.log.error("Tried to make meme, but got error: #{data['error_message']}")
            end
        else
            @client.log.error("Tried to make meme, but got response: #{response.code}")
        end

        if meme_url
            send(meme_url)
        else
            send("Sorry, I couldn't generate a meme for that.'", @is_pm)
        end
    end
end
