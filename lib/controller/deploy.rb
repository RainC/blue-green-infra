class Deploy < BaseAppController
    def TestMethod
        p "Deployment Controller Initalized"
    end

    def do_deploy(init=false, appname="sampleapp")
        # remove green container
        # new green container
        # if init process, make blue, green container 

        module_load("command")
        m = Cli.new(@host,@user,@pass)
        if init == "init" 
            p "Deploy init .. - Network "
            m.construct_network()
            p "Deploy init process.. "
            m.deploy_app_container_init("sampleapp") # Blue/Green Deploy for Lb
            p "Deploy loadbalancer.. "
            m.deploy_loadbalancer() # LB Deploy
        else
            m.deploy_app_container("sampleapp") # Green Deploy
        end
    end

    def do_deploy_green

        p "Deploy Green container.. "
        module_load("command")
        m = Cli.new(@host,@user,@pass)
        m.deploy_app_container("sampleapp")
    end 


    def do_deploy_lb()
        # LB init Process
        p "Deploy LB.. "
        module_load("command")
        m = Cli.new(@host,@user,@pass)
        m.deploy_loadbalancer()
    end

    def initialize(host,user,pass)
        @host = host
        @user = user
        @pass = pass
    end
end 
