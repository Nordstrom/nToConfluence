require 'n2c/confluence'
require 'n2c/markdown_to_html'
require 'n2c/sources/source'
require 'n2c/sources/stash'
require 'n2c/sources/knife'
require 'n2c/sources/disk'

class N2Confluence
  class Application
    def initialize(user, password, space, confluence_url, source)
      @confluence = Confluence.new(confluence_url, user, password)
      @markdown = MarkdownToHtml.new
      @header = @markdown.render(File.read('../header.md'))

      @space = space
      @source = source
    end

    def go
      home_id = @confluence.get_home_id(@space)
      md_files = @source.get_content

      start_page_md = md_files.first
      start_page_rendered = @markdown.render(start_page_md[:md])

      start_page = @confluence.upsert_page(@space, start_page_md[:title], home_id, start_page_rendered, @header)
      start_page_id = start_page['id']

      md_files.drop(1).each do |md|
        rendered = @markdown.render(md[:md])
        @confluence.upsert_page(@space, md[:title], start_page_id, @header, rendered)
      end
    end

    def upsert_page(file, path, start_page_id, docs_dir, title = file)
      file_from_reader = @stash.get_file("#{path}#{file}.md")
      rendered = @markdown.render(file_from_reader)

      @confluence.upsert_page(@space, title, start_page_id, rendered, @header)
    end
  end
end
