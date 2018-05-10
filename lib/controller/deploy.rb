class Deploy < BaseAppController
   

    def do_deploy(opt)
        # remove green container
        # new green container
        # if init process, make blue, green container 

        module_load("command")
        m = Cli.new(@env)
        if opt == "init" 
            p "Deploy init .. - Network "
            m.construct_network()
            p "Deploy init process.. "
            m.deploy_app_container_init() # Blue/Green Deploy for Lb
            p "Deploy loadbalancer.. "
            m.deploy_loadbalancer() # LB Deploy
        else
            m.deploy_app_container() # Green Deploy
        end
    end

    def do_deploy_green

        p "Deploy Green container.. "
        module_load("command")
        m = Cli.new(@env)
        m.deploy_app_container()
    end 


    def do_deploy_lb()
        # LB init Process
        p "Deploy LB.. "
        module_load("command")
        m = Cli.new(@env)
        m.deploy_loadbalancer()
    end

    def initialize(env)
        @env = env
    end
end 
