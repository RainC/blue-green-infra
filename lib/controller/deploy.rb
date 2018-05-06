class Deploy < BaseAppController
    def TestMethod
        p "Deployment Controller Initalized"
    end

    def do_deploy(init=false, appname="sampleapp")
        # remove green container
        # new green container
        # if init process, make blue, green container 

        module_load("cli")
        m = Cli.new(@host,@user,@pass)
        if init == true
            m.deploy_app_container_init("sampleapp")
        else
            m.deploy_app_container("sampleapp")
        end 
    end

    def do_deploy_green
        module_load("cli")
        m = Cli.new(@host,@user,@pass)
        m.deploy_app_container("sampleapp")
    end 


    def do_deploy_lb()
        # LB init Process
        module_load("cli")
        m = Cli.new(@host,@user,@pass)
        m.deploy_loadbalancer()
    end

    def initialize(host,user,pass)
        @host = host
        @user = user
        @pass = pass
    end
end 
