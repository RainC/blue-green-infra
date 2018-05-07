class Cli < BaseAppModule 
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
        self.connect_server(s)    
    end
    
    def generate_container
        s = "cd /home/deployer/infra/host/nginx/; docker build -t . "
        self.connect_server(s)
    end

    def deploy_app_container_init(app)
        s = "cd /home/rubyrain/infra/app/#{app} ; git checkout master -f ; git pull ;  docker build -t app_image . ; docker rm -f green ;  docker run -itd --network base_network --name blue --hostname blue app_image; docker run --network base_network -itd --name green --hostname green app_image"
        self.connect_server(s)
    end
    def deploy_app_container(app)
        s = "cd /home/rubyrain/infra/app/#{app} ; git checkout master -f ; git pull ;  docker build -t app_image . ; docker rm -f green ;  docker run -itd --network base_network --name green --hostname green app_image"
        self.connect_server(s)
    end
    def deploy_loadbalancer()
        s = "cd /home/rubyrain/infra/host/nginx/ ; git checkout master -f ; git pull ; docker build -t nginx_lb . ; docker rm -f  front_nginx ; docker run -itd -e 'ACTIVE=blue' -e 'STANDBY=green' --network base_network --name front_nginx -p 80:80 --hostname front_lb nginx_lb bash -c \"envsubst < /etc/nginx/conf.d/production.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'\""
        self.connect_server(s)
    end
    
    def construct_network()
        s = "docker network rm base_network; docker network create base_network"
        self.connect_server(s)
    end
    def switch_container
        # Auto Switch from LB Container
        s = "cd /home/rubyrain/infra/host/nginx/ ; git checkout master -f ; git pull ;docker exec front_nginx bash -c '/etc/nginx/switch'"
        self.connect_server(s)
    end


    def initialize(host,user,pass)
        @server_host = host
        @server_user = user
        @server_pass = pass 
    end

end
