class Publish < BaseAppController 
    def switch
        # green to blue
        # blue to green
        p "Switching Process.."
        module_load("command")
        m = Command.new(@env)
        m.switch_container()
    end 
    
    def initialize(env)
        @env = env
    end
end