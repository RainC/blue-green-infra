class Publish < BaseAppController 
    def switch
        # green to blue
        # blue to green
        p "Switching Process.."
        module_load("cli")
        m = Cli.new(@host,@user,@pass)
        m.switch_container()
    end 
    
    def initialize(host,user,pass)
        @host = host
        @user = user
        @pass = pass
    end
end