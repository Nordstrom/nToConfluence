require 'executable'
require './stc.rb'

class StashToConfluence
  # comment on overall class
  class CLI
    include Executable

    # The url to the XML RPC Confluence interface - "https://confluence.zzzz.com/rpc/xmlrpc".
    attr_accessor :confluence_url

    # The username/login of the user for interactions with Confluence and Stash.
    attr_accessor :username
    alias :u :username

    # The password of the user for interactions with Confluence and Stash.
    attr_accessor :password

    # The name of the Confluence Space to use.
    attr_accessor :space

    # Show this message.
    def help!
      cli.show_help
      exit
    end
    alias :h! :help!

    class Stash < self
      # The Stash Project to read from
      attr_accessor :project

      # The Stash Repository to read from
      attr_accessor :repository

      # TODO use repository name?
      attr_accessor :app_name

      # The URL to your Stash server - "https://git.nordstrom.net"
      attr_accessor :stash_url

      # Convert markdown structure from Stash into Confluence
      def call
        app = Application.new(@username, @password, @space, @app_name, @project, @repository, @confluence_url, @stash_url)
        app.go
      end
    end

    class Knife < self
      # The full path to the knife.rb file to use
      attr_accessor :config

      def call 
        title = "Servers"
        knife = Sources::Knife.new(@config)
        markdown = knife.get_file
        converter = MarkdownToHtml.new
        html = converter.render(markdown)
        confluence = Confluence.new(@confluence_url, @username, @password)
        start_page_id = confluence.get_home_id(@space)

        begin
          page = confluence.get_page_by_space(@space, title)
        rescue
          page = { "content" => "", "title" => "", "space" => @space, "parentId" => start_page_id }
        end

        page['content'] = html 
        page['title'] = title

        confluence.save_page(page)
      end
    end
  end
end
