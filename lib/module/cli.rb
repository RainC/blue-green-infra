class Cli < BaseAppController

    def connect_server(join_deploy)
        begin
            ssh = Net::SSH.start(@server_host, @server_user, :password => @server_pass) 
            ssh.exec!(join_deploy) do
                |ch, stream, line|
                puts line
            end
            ssh.close
        rescue Exception => e
            puts "Unable to connect : #{e.message} "
        end
    end

    def remove_container
        s = "docker rm green_container;"
        self.connect_server(s.join(";"))    
    end
    
    def generate_container
        s = "cd /home/deployer/infra/host/nginx/; docker build -t . "
        self.connect_server(s.join(";"))
    end

    def deploy_app_continaer(app)
        s = "cd /home/rubyrain/infra/app/#{app} ; git checkout master -f ; git pull ;  docker build -t app_image . ; docker run -itd app_image --host green"
        self.connect_server(s)
    end


    def switch_container
        s = ""
    end

    def initialize(host,user,pass)
        @server_host = host
        @server_user = user
        @server_pass = pass 
    end

end
