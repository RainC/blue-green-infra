class Cli < BaseAppController
    @server_host
    @server_user
    @server_pass
    def connect_server(join_deploy)
        begin
            ssh = Net::SSH.start(@server_host, @server_user, @server_pass)
            ssh.exec!(join_deploy) do
                |ch, stream, line|
                puts line
            end
            ssh.close
        rescue
            puts "Unable to connect"
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
        s = "cd /home/deployer/infra/app/#{app} ; docker build -t app_image . ; docker run -itd app_image --name app_container_green"
        self.connect_server(s.join(";"))
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
