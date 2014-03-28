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

    def get_page_by_id(id)
      @confluence.getPage(@token, id.to_s)
    end

    def get_page_by_space(space, title)
      @confluence.getPage(@token, space, title)
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
    def initialize(user, password, space, app_name)
      @confluence = Confluence.new("", user, password)
      @markdown = MarkdownToHtml.new()
      @header = @markdown.render(File.read('header.md'))

      @space = space
      @app_name = app_name

    end

    def go
      docs_dir = 'docs'
      files = Dir.entries(docs_dir).reject{ |d| d == '.' || d == '..' }.map{ |f| f.sub('.md', '') }

      start_page = files.first{ |f| f.upcase == 'README' }

      page = @confluence.get_page_by_space(@space, @app_name)
#      page = @confluence.get_page_by_id(42726778)
      page['content'] = "#{@header}<hr/>#{@markdown.render(File.read("#{docs_dir}/#{start_page}.md"))}"
      page['title'] = @app_name

      @confluence.save_page(page)

      start_page_id = page['id']


      files.reject { |f| f == start_page }.each do |f|
        begin
          page = @confluence.get_page_by_space(@space, f)
        rescue
          page = { "content" => "", "title" => "", "space" => @space, "parentId" => start_page_id }
        end

        rendered = @markdown.render(File.read("#{docs_dir}/#{f}.md"))
        page['content'] = "#{@header}<hr/>#{rendered}"
        page['title'] = f

        @confluence.save_page(page)
      end
    end
  end
end
