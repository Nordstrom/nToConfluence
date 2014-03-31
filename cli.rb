require 'executable'
require './stc.rb'

class StashToConfluence
  # comment on overall class
  class CLI
    include Executable

    # The url to the XML RPC Confluence interface - "https://confluence.zzzz.com/rpc/xmlrpc".
    attr_accessor :confluence_url
    alias :c :confluence_url

    # The username/login of the user for interactions with Confluence and Stash.
    attr_accessor :username
    alias :u :username

    # The password of the user for interactions with Confluence and Stash.
    attr_accessor :password

    # The name of the Confluence Space to use.
    attr_accessor :space
    alias :s :space

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
  end
end
