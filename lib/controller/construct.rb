class Construct < BaseAppController
    def do_init() 
        module_load("command")
        m = Command.new(@env)
        m.install_infrastructure()
    end


    def initialize(options,env)
        @env = env
        self.do_init
    end
end