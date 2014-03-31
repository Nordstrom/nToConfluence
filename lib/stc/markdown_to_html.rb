require 'redcarpet'

# Convert markdown contents to html
class StashToConfluence
  class MarkdownToHtml
    def initialize
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    end

    def render(markdown)
      @markdown.render(markdown)
    end
  end
end
