class Infra < BaseAppController
    def do_init() 
        module_load("command")
        m = Cli.new(@env)
        m.install_infrastructure()
    end


    def initialize(env)
        @env = env
        self.do_init
    end
end