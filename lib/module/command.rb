class Command < BaseAppModule
    def connect_server(join_deploy)
        begin
            if @cli_env["connect_method"] == "password"
                ssh = Net::SSH.start(@cli_env["server_name"], @cli_env["server_user"] , :password => @cli_env["server_pass"]) 
            else
                ssh = Net::SSH.start(@cli_env["server_name"], @cli_env["server_user"]  , :keys => [  @cli_env["keyfile"] ] ) 
            end
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

    def deploy_app_container_init()
        s = "cd  #{@cli_env["install_infra_dest"]}/infra  ; 
        git checkout master -f ; 
        git pull ; 
        cd #{@cli_env["app_deployment_dest"]}/#{@cli_env["app_target"]};
        docker build --no-cache --build-arg repourl=#{@cli_env["app_repo"] }  -t #{@cli_env["app_name"]}_app_image . ;
        docker rm -f #{@cli_env["app_name"]}_proxy ; 
        docker rm -f #{@cli_env["app_name"]}_blue; 
        docker rm -f #{@cli_env["app_name"]}_green ;  
        docker run -itd --network #{@cli_env["app_name"]}_network --name #{@cli_env["app_name"]}_blue --hostname #{@cli_env["app_name"]}_blue #{@cli_env["app_name"]}_app_image; 
        docker run --network #{@cli_env["app_name"]}_network -itd --name #{@cli_env["app_name"]}_green --hostname #{@cli_env["app_name"]}_green #{@cli_env["app_name"]}_app_image ; 
        docker exec #{@cli_env["app_name"]}_green bash -c 'echo green > /etc/env'; 
        docker exec #{@cli_env["app_name"]}_blue bash -c 'echo blue > /etc/env'; "
        self.connect_server(s)
    end

    def deploy_app_container()
        s = "cd #{@cli_env["install_infra_dest"]}/infra  git checkout master -f ; 
        git pull ; cd #{@cli_env["app_deployment_dest"]}/#{@cli_env["app_target"]} ; 
        docker build --no-cache -t #{@cli_env["app_name"]}_app_image . ; 
        export setblue=#{@cli_env["app_name"]}_blue;
        export setgreen=#{@cli_env["app_name"]}_green;
        myvars='$setblue:$setgreen';
        envsubst  < #{@cli_env["install_infra_dest"]}/infra/host/update_green;
        set_container_name=$(envsubst  \"$myvars\" < #{@cli_env["install_infra_dest"]}/infra/host/update_green | bash) ;
        docker run -itd --network #{@cli_env["app_name"]}_network --name $set_container_name --hostname $set_container_name #{@cli_env["app_name"]}_app_image;
        docker exec $set_container_name bash -c 'echo green > /etc/env'; "
        self.connect_server(s)
    end
    def deploy_loadbalancer()
        s = "cd #{@cli_env["install_infra_dest"]}/infra/host/nginx/ ;
         git checkout master -f ; 
         git pull ; docker build -t #{@cli_env["app_name"]}_proxy_image . ; 
         docker rm -f  #{@cli_env["app_name"]}_proxy ; 
         docker run -itd -e 'ACTIVE=#{@cli_env["app_name"]}_blue' -e 'STANDBY=#{@cli_env["app_name"]}_green' -e 'PORT=#{@cli_env["app_publish_port"]}' --network #{@cli_env["app_name"]}_network --name #{@cli_env["app_name"]}_proxy -p #{@cli_env["loadbalancer_port"]}:80 --hostname #{@cli_env["app_name"]}_proxy #{@cli_env["app_name"]}_proxy_image bash -c \"envsubst < /etc/nginx/conf.d/production.template > /etc/nginx/conf.d/default.conf && cat /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'\""
        self.connect_server(s)
    end
    
    def construct_network()
        s = "docker network rm #{@cli_env["app_name"]}_network; 
        docker network create #{@cli_env["app_name"]}_network"
        self.connect_server(s)
    end
    
    def switch_container
        # Auto Switch from LB Container
        container_label_switch = "bash -c 'if [[ $(cat /etc/env | grep \"green\") = \"green\" ]]; then echo blue > /etc/env ; else echo green > /etc/env ;fi'"
        s = "cd #{@cli_env["install_infra_dest"]}/infra ; git checkout master -f ; 
        docker exec #{@cli_env["app_name"]}_blue #{container_label_switch} ; 
        docker exec #{@cli_env["app_name"]}_green #{container_label_switch} ;  
        git pull ;docker exec #{@cli_env["app_name"]}_proxy bash -c '/etc/nginx/switch #{@cli_env["app_name"]}_blue #{@cli_env["app_name"]}_green'"
        self.connect_server(s)
    end

    def install_infrastructure()
        centos_install_docker = "sudo yum install -y gettext yum-utils device-mapper-persistent-data lvm2;sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo ; sudo yum install docker-ce -y ; sudo systemctl start docker ; sudo systemctl enable docker"
        ubuntu_install_docker = "sudo apt-get update -y ; sudo apt-get install gettext apt-transport-https ca-certificates curl software-properties-common; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; sudo apt-key fingerprint 0EBFCD88; sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable\"; sudo apt-get update ; sudo apt-get install docker-ce -y ; sudo usermod -aG docker $USER "
        ami_install_docker = "sudo yum update -y ; sudo yum install -y gettext git docker; sudo usermod -aG docker #{@cli_env["server_user"]}; sudo service docker start "
        selection = Hash.new
        selection["centos"] = centos_install_docker
        selection["ubuntu"] = ubuntu_install_docker
        selection["ami"] = ami_install_docker

        s = "#{selection[@cli_env["os"]]}; mkdir -p #{@cli_env["install_infra_dest"]}; mkdir -p #{@cli_env["app_deployment_dest"]};  cd #{@cli_env["install_infra_dest"]} ;  git clone #{@cli_env["infra_repo"]} ;"
        self.connect_server(s)
    end

    def initialize(env)
        @cli_env = env
    end

end
