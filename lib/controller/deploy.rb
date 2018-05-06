class Deploy < BaseAppController
    def TestMethod
        p "Deployment Controller Initalized"
    end

    def do_deploy()
        # remove green container
        # new green container

        module_load("cli")
        m = Cli.new(@host,@user,@pass)
        m.deploy_app_continaer("sampleapp")
    end

    def publish
        
    end 


    def initialize(host,user,pass)
        @host = host
        @user = user
        @pass = pass
    end
end 
