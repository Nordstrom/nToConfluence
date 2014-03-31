require 'xmlrpc/client'

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
end
