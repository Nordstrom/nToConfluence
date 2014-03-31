require 'faraday'
require 'json'

class StashToConfluence
  class Stash
    # https://developer.atlassian.com/static/rest/stash/2.12.0/stash-rest.html
    def initialize(user, password, project, repo, url)
      @api = "/rest/api/1.0/projects/#{project}/repos/#{repo}"
      @raw = "/projects/#{project}/repos/#{repo}/browse/"
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
end
