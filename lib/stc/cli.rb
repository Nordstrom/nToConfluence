require 'executable'
require 'lib/stc.rb'

class N2Confluence
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

    # N2Confluence is a simple application that takes markdown from various sources and uploads it into Confluence.
    def call
      help!
    end

    class Stash < self
      # The Stash Project to read from
      attr_accessor :project

      # The Stash Repository to read from
      attr_accessor :repository

      # The URL to your Stash server - "https://git.nordstrom.net"
      attr_accessor :stash_url

      # Convert markdown structure from Stash into Confluence
      def call
        do_stuff(Sources::Stash, @username, @password, @project, @repository, @stash_url)
      end
    end

    class Knife < self
      # The full path to the knife.rb file to use
      attr_accessor :config

      # The name of the Chef Org (becomes page title prefix)
      attr_accessor :org_name

      # Generate a report based on a knife query.
      def call
        do_stuff(Sources::Knife, @config, @org_name)
      end
    end

    class Disk < self
      # Path to the directory with .md files
      attr_accessor :path

      # Name of the .md file to use as the parent page
      attr_accessor :start_file

      # Upload contents of a directory into Confluence
      def call
        do_stuff(Sources::Disk, @path, @start_file)
      end
    end

    private

    def do_stuff(type, *params)
      source = type.new(*params)
      app = Application.new(@username, @password, @space, @confluence_url, source)
      app.go
    end
  end
end
