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

    def get_home_id(space)
      @confluence.getSpace(@token, space)['homePage']
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
      home_id = @confluence.get_home_id(@space)
      docs_dir = 'docs'
      files = Dir.entries(docs_dir).reject { |d| d == '.' || d == '..' }.map { |f| f.sub('.md', '') }

      start_page_file = files.first { |f| f.upcase == 'README' }

      start_page = upsert_page(start_page_file, home_id, docs_dir, @app_name)

      start_page_id = start_page['id']

      files.reject { |f| f == start_page_file }.each do |f|
        upsert_page(f, start_page_id, docs_dir)
      end
    end

    def upsert_page(file, start_page_id, docs_dir, title = file)
      begin
        page = @confluence.get_page_by_space(@space, title)
        # TODO: Catch the specific exception we want
      rescue
        page = { "content" => "", "title" => "", "space" => @space, "parentId" => start_page_id }
      end

      rendered = @markdown.render(File.read("#{docs_dir}/#{file}.md"))
      page['content'] = "#{@header}<hr/>#{rendered}"
      page['title'] = title

      @confluence.save_page(page)
    end
  end
end
