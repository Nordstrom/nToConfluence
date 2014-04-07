require 'faraday'
require 'json'

class StashToConfluence
  class Sources
    class Stash < Source
      # https://developer.atlassian.com/static/rest/stash/2.12.0/stash-rest.html
      def initialize(user, password, project, repo, url)
        @api = "/rest/api/1.0/projects/#{project}/repos/#{repo}"
        @raw = "/projects/#{project}/repos/#{repo}/browse/"
        @conn = Faraday.new(url, ssl: { verify: false }) do |f|
          f.basic_auth(user, password)
          f.request :url_encoded
          f.adapter  Faraday.default_adapter
        end

        @repo = repo

        @root = 'README.md'
        @docs_dir = 'docs'
      end

      def get_content
        begin
          files = get_md_file(@docs_dir)
        # TODO: Catch the specific exception we want
        rescue
          files = []
        end

        files.unshift(@root)

        files.map { |f| { title: get_title(f), md: get_file(f) } }
      end

      def get_title(file_name)
        if file_name == @root
          @repo
        else
          file_name.sub('.md', '')
        end
      end

      def get_file(path)
        response = @conn.get("#{@raw}#{path}?raw")
        response.body
      end

      def get_md_files(path)
        response = @conn.get("#{@api}/browse/#{path}")
        directory = JSON.parse(response.body)
        directory['children']['values'].map { |d| d['path']['name'] }.select { |d| d.end_with?('.md') }#.map { |d| d.sub('.md', '') }
      end
    end
  end
end
