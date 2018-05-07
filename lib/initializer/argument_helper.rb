class ArgumentHelper
    def initialize(options, m, env)
        @options = options
        @m = m
        @env = env
        argument_parse()
    end
    
    def argument_parse()
        if @options[0] == "deploy"
            process_deploy
        end

        if @options[0] == "publish"
            process_publish
        end

        if @options[0] == "help"
            process_help
        end
    end
    
    def process_deploy
        if @m.load("controller","deploy") == true
            if @options[1] == "loadbalancer" 
                deploy = Deploy.new(@env["server_name"], @env["server_user"], @env["server_pass"]) 
                deploy.do_deploy_lb() # must be prepared Blue/Green container 
            else
                deploy = Deploy.new(@env["server_name"], @env["server_user"], @env["server_pass"]) 
                deploy_opt = @options[1]
                deploy.do_deploy(deploy_opt)
            end 
        else
            raise GeneralLoadError
        end 
    end

    def process_publish
        if @m.load("controller","publish") == true
            publish = Publish.new(@env["server_name"], @env["server_user"], @env["server_pass"]) 
            publish.switch() 
        else
            raise GeneralLoadError
        end
    end
    
    def process_help
        p "-------------------------"
        p "Cli options"
        p "ruby manager.rb deploy"
        p "ruby manager.rb publish"
    end

end
