require 'executable'
require 'lib/stc.rb'

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
        source = Sources::Stash.new(@username, @password, @project, @repository, @stash_url)
        do_stuff(source)
      end
    end

    class Knife < self
      # The full path to the knife.rb file to use
      attr_accessor :config

      def call
        source = Sources::Knife.new(@config)
        do_stuff(source)
      end
    end

    private

    def do_stuff(source)
      app = Application.new(@username, @password, @space, @confluence_url, source)
      app.go
    end
  end
end
