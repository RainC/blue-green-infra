require 'net/ssh'
require 'awesome_print'
require 'abstract_method'
require 'dotenv/load' 

class ModuleLoadError < StandardError
    def initialize(msg="Module/Controller Not found.")
        super(msg)
    end
end


class BaseAppController
    abstract_method :initialize
    def module_load(module_name)
        p "Module Load Request - #{module_name}"
        require "#{File.dirname(File.realpath(__FILE__))}/lib/module/#{module_name}.rb"
    end 
end

class Manager
    def initialize
        self.load("module","init")
        self.load("initializer","argument_helper")
        options = ARGV
        ArgumentHelper.new(options, self, ENV)
    end

    def load(type,name)
        begin
            fileload(type,name)
            return true
        rescue LoadError => e
            return false
        end
    end

    private
    def fileload(type,name)
        p "Module Load - #{name}"
        require "#{File.dirname(File.realpath(__FILE__))}/lib/#{type}/#{name}.rb"
    end
end  


Manager.new

