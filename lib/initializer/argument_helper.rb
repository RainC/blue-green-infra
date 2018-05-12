class ArgumentHelper
    def initialize(options, m, env)
        file = File.read('./environment.json')
        json_data = JSON.parse(file)
        @options = options
        @manager = m
        @env = json_data
        self.argument_parse()
    end

    def argument_parse()
        if @manager.load("controller", @options[0]) == true
            capitalizer = @options[0].capitalize 
            eval("m = #{capitalizer}.new(#{@options}, #{@env}) ;") 
        else
            raise GeneralLoadError
        end
    end
end
