require 'net/ssh'
require 'awesome_print'
require 'abstract_method'
require 'dotenv/load' 
require 'json'



class GeneralLoadError < StandardError
    def initialize(msg="General Error")
        set_msg = "message :: #{msg}"
        super(msg)
    end
end


class BaseAppModule
    abstract_method :initialize
end

class BaseAppController
    abstract_method :initialize
    def module_load(module_name)
        ap "Module load request from #{self.class.name} controller - #{module_name}"
        require "#{File.dirname(File.realpath(__FILE__))}/lib/module/#{module_name}.rb"
    end
    def file_load(path)
        ap "File load request from #{self.class.name} controller - #{path}"
        require "#{File.dirname(File.realpath(__FILE__))}/#{path}"
    end
end

class Manager
    def initialize
        self.load("initializer","argument_helper")
        options = ARGV
        ArgumentHelper.new(options, self, ENV)
    end

    def load(type,name)
        fileload(type,name)  
    end

    private
    def fileload(type,name)
        begin 
            require "#{File.dirname(File.realpath(__FILE__))}/lib/#{type}/#{name}.rb"
        rescue LoadError => e 
            raise GeneralLoadError, "#{type} load Error - '#{name}'"
            return false
        end
        ap "[#{type}] #{name} Loaded"
        return true
    end
end


Manager.new

