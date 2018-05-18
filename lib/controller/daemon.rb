
class Daemon < BaseAppController 
    def router
        file_load("standalone_template/router.rb")
        run Sinatra::Application.run!
    end

    def initialize(options, env) 
        @env = env 
        self.router
    end
end
