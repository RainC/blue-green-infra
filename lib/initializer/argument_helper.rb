class ArgumentHelper
    def initialize(options, m)
        if options[0] == "deploy"
            if m.load("controller","deploy") == true
                Deploy.new
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
