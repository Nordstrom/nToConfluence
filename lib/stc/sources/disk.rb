class StashToConfluence
  class Sources
    # TODO: Handle recursion
    class Disk < Source
      def initialize(path, start_file)
        @path = path
        @start_file = start_file.sub('.md', '')
      end

      def get_content
        files = get_md_files(@path)
        files.unshift(files.delete_at(files.index { |f| f == @start_file }))

        files.map { |f| { title: f, md: get_file(@path, f) } }
      end

      def get_file(path, file)
        File.read("#{path}/#{file}.md")
      end

      def get_md_files(path)
        Dir.entries(path).reject { |d| d == '.' || d == '..' }.map { |f| f.sub('.md', '') }
      end
    end
  end
end
