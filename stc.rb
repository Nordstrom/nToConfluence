require 'lib/stc/confluence'
require 'lib/stc/markdown_to_html'
require 'lib/stc/sources/stash'
require 'lib/stc/sources/knife.rb'

class StashToConfluence
  class Application
    def initialize(user, password, space, app_name, project, repo, confluence_url, stash_url)
      @confluence = Confluence.new(confluence_url, user, password)
      @stash = Stash.new(user, password, project, repo, stash_url)
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
