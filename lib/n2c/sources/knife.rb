require 'json'

class N2Confluence
  class Sources
    class Knife < Source
      def initialize(config, org_name)
        @config = config
        @org_name = org_name
      end

      def get_content
        content = []
        content.push({ title: "#{@org_name} Chef Nodes", md: get_file })
        content
      end

      def get_file
        output = `knife search "name:*" -c #{@config} -F json`
        search = JSON.parse(output)
        puts output
        markdown = "name | ip address | environment | run list \r"
        markdown += "--- | --- | --- | --- \r"

        search["rows"].each do |s|
          markdown += "#{s["name"]} | #{s["automatic"]["ipaddress"]} | #{s["chef_environment"]} | #{s["run_list"]} \r"
        end
        markdown
      end
    end
  end
end
