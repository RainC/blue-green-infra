class Deploy < BaseAppController
    def TestMethod
        p "Deployment Controller Initalized"
    end

    def deploy
        # remove green container
        # new green container

        module_load("cli")
        m = Cli.new("rubyrain.server","rubyrain","33")
        # m.deploy_app_continaer
    end

    def publish
        
    end 


    def initialize
        self.deploy
    end
end 
