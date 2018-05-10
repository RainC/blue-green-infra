class ArgumentHelper
    def initialize(options, m, env)
        file = File.read('./environment.json')
        json_data = JSON.parse(file)
        @options = options
        @m = m
        @env = json_data
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
    
        if @options[0] == "construct"
            process_construct
        end

    end
    
    def process_construct
        if @m.load("controller", "infra") == true
            m = Infra.new(@env)
        else 
            raise GeneralLoadError
        end

    end

    def process_deploy
        if @m.load("controller","deploy") == true
            if @options[1] == "loadbalancer" 
                deploy = Deploy.new(@env) 
                deploy.do_deploy_lb() # must be prepared Blue/Green container 
            else
                deploy = Deploy.new(@env) 
                deploy_opt = @options[1]
                deploy.do_deploy(deploy_opt)
            end 
        else
            raise GeneralLoadError
        end 
    end

    def process_publish
        if @m.load("controller","publish") == true
            publish = Publish.new(@env) 
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
