class ArgumentHelper
    def initialize(options, m, env)
        if options[0] == "deploy"
            if m.load("controller","deploy") == true
                
                if options[1] == "loadbalancer" 
                    deploy = Deploy.new(env["server_name"], env["server_user"], env["server_pass"]) 
                    deploy.do_deploy_lb() # must be prepared Blue/Green container 
                else
                    deploy = Deploy.new(env["server_name"], env["server_user"], env["server_pass"]) 
                    deploy_opt = options[1]
                    deploy.do_deploy(deploy_opt)
                end 
            else
                raise ModuleLoadError
            end 
        end
        if options[0] == "publish"
            if m.load("controller","publish") == true
                publish = Publish.new(env["server_name"], env["server_user"], env["server_pass"]) 
                publish.switch() 
            else
                raise ModuleLoadError
            end
        end
        if options[0] == "help"
            p "-------------------------"
            p "Cli options"
            p "ruby manager.rb deploy"
            p "ruby manager.rb publish"
        end
    end
end
