require 'xmlrpc/client'
require 'redcarpet'

class StashToConfluence
  class Confluence
    def initialize(url, user, password)
      server = XMLRPC::Client.new2("https://confluence.nordstrom.net/rpc/xmlrpc")
      server.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
      @confluence = server.proxy('confluence2')
      @token = @confluence.login(user, password)
    end

    def get_page(id)
      @confluence.getPage(@token, id.to_s)
    end

    def save_page(page)
      @confluence.storePage(@token, page)
    end
  end


  class MarkdownToHtml
    def initialize()
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    end

    def render(markdown)
      @markdown.render(markdown)
    end
  end


  class Application
    def initialize(user, password)
      @confluence = Confluence.new("", user, password)
      @markdown = MarkdownToHtml.new()
      @header = @markdown.render(File.read('header.md'))


    end

    def go
      page = @confluence.get_page(42726778)
      page['content'] = "#{@header}<hr/>#{@markdown.render(File.read('README.md'))}"
      page['title'] = 'README'

      @confluence.save_page(page)
    end
  end
end
