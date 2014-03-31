require 'xmlrpc/client'
require 'redcarpet'
require 'faraday'
require 'json'

class StashToConfluence
  class Confluence
    # objects: https://developer.atlassian.com/display/CONFDEV/Remote+Confluence+Data+Objects
    # methods: https://developer.atlassian.com/display/CONFDEV/Remote+Confluence+Methods

    def initialize(url, user, password)
      server = XMLRPC::Client.new2(url)
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

  # TODO: Finish this up
  #class Disk
  #  def get_file(path)
  #    File.read("#{docs_dir}/#{file}.md")
  #  end

  #  def get_md_files(path)
  #    Dir.entries(docs_dir).reject { |d| d == '.' || d == '..' }.map { |f| f.sub('.md', '') }
  #  end
  #end

  class Stash
    # https://developer.atlassian.com/static/rest/stash/2.12.0/stash-rest.html
    def initialize(user, password, project, repo)
      url = "https://git.nordstrom.net/"
      @api = "rest/api/1.0/projects/#{project}/repos/#{repo}"
      @raw = "projects/#{project}/repos/#{repo}/browse/"
      @conn = Faraday.new(url, ssl: { verify: false }) do |f|
        f.basic_auth(user, password)
        f.request :url_encoded
        f.adapter  Faraday.default_adapter
      end
    end

    def get_file(path)
      response = @conn.get("#{@raw}#{path}?raw")
      response.body
    end

    def get_md_files(path)
      response = @conn.get("#{@api}/browse/#{path}")
      directory = JSON.parse(response.body)
      # choochoo, i can read it, can you?
      directory['children']['values'].map { |d| d['path']['name'] }.select { |d| d.end_with?('.md') }.map { |d| d.sub('.md', '') }
    end
  end

  class Application
    def initialize(user, password, space, app_name, project, repo)
      @confluence = Confluence.new("https://confluence.nordstrom.net/rpc/xmlrpc", user, password)
      @stash = Stash.new(user, password, project, repo)
      @markdown = MarkdownToHtml.new()
      @header = @markdown.render(File.read('header.md'))

      @space = space
      @app_name = app_name
    end

    def go
      home_id = @confluence.get_home_id(@space)
      docs_dir = 'docs'

      begin
        files = @stash.get_md_file(docs_dir)
      # TODO: Catch the specific exception we want
      rescue
        files = []
      end

      start_page_file = "README"

      start_page = upsert_page(start_page_file, "", home_id, docs_dir, @app_name)

      start_page_id = start_page['id']

      files.reject { |f| f == start_page_file }.each do |f|
        upsert_page(f, "#{docs_dir}/", start_page_id, docs_dir)
      end
    end

    def upsert_page(file, path, start_page_id, docs_dir, title = file)
      begin
        page = @confluence.get_page_by_space(@space, title)
      # TODO: Catch the specific exception we want
      rescue
        page = { "content" => "", "title" => "", "space" => @space, "parentId" => start_page_id }
      end

      file_from_reader = @stash.get_file("#{path}#{file}.md")
      rendered = @markdown.render(file_from_reader)

      page['content'] = "#{@header}<hr/>#{rendered}"
      page['title'] = title

      @confluence.save_page(page)
    end
  end
end
