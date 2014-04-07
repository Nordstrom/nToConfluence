class N2Confluence
  class Sources
    # TODO: Handle recursion
    class Source
      def get_content
        raise 'override me'
      end
    end
  end
end
