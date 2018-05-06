class ArgumentHelper
    def initialize(options, m, env)
        if options[0] == "deploy"
            if m.load("controller","deploy") == true
                deploy = Deploy.new(env["server_name"], env["server_user"], env["server_pass"]) 
                deploy_opt = options[1]
                deploy.do_deploy(deploy_opt)
            else
                raise ModuleLoadError
            end
        end
        
        if options[0] == "publish"
            if m.load("controller","publish") == true
                Publish.new
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
