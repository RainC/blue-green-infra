class Cli < BaseAppModule
    def connect_server(join_deploy)
        begin
            if @cli_env["connect_method"] == "password"
                ssh = Net::SSH.start(@cli_env["server_name"], @cli_env["server_user"] , :password => @cli_env["server_pass"]) 
            else
                ssh = Net::SSH.start(@cli_env["server_name"], @cli_env["server_user"] , :host_key => "ssh-rsa", :encryption  => "blowfish-cbc" , :keys => [  @cli_env["keyfile"] ]  ) 
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
        s = "cd  #{@cli_env["install_infra_dest"]}/infra  ; git checkout master -f ; git pull ; cd #{@cli_env["app_deployment_dest"]}/#{@cli_env["app_target"]};  docker build -t app_image . ; docker rm -f front_nginx ;  docker rm -f blue; docker rm -f green ;  docker run -itd --network base_network --name blue --hostname blue app_image; docker run --network base_network -itd --name green --hostname green app_image ; docker exec green bash -c 'echo green > /etc/env'; docker exec blue bash -c 'echo blue > /etc/env'; "
        self.connect_server(s)
    end

    def deploy_app_container()
        s = "cd #{@cli_env["app_target"]} ; git checkout master -f ; git pull ;  docker build -t app_image . ; set_container_name=$(sh #{@cli_env["install_infra_dest"]}/infra/host/update_green) ;  docker run -itd --network base_network --name $set_container_name --hostname $set_container_name app_image; docker exec $set_container_name bash -c 'echo green > /etc/env'; "
        self.connect_server(s)
    end
    def deploy_loadbalancer()
        s = "cd #{@cli_env["install_infra_dest"]}/infra/host/nginx/ ; git checkout master -f ; git pull ; docker build -t nginx_lb . ; docker rm -f  front_nginx ; docker run -itd -e 'ACTIVE=blue' -e 'STANDBY=green' -e 'PORT=#{@cli_env["app_publish_port"]}' --network base_network --name front_nginx -p 80:80 --hostname front_lb nginx_lb bash -c \"envsubst < /etc/nginx/conf.d/production.template > /etc/nginx/conf.d/default.conf && cat /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'\""
        self.connect_server(s)
    end
    
    def construct_network()
        s = "docker network rm #{@cli_env["network"]}; docker network create #{@cli_env["network"]}"
        self.connect_server(s)
    end
    def switch_container
        # Auto Switch from LB Container
        container_label_switch = "bash -c 'if [[ $(cat /etc/env | grep \"green\") = \"green\" ]]; then echo blue > /etc/env ; else echo green > /etc/env ;fi'"
        s = "cd /home/rubyrain/infra/host/nginx/ ; git checkout master -f ; docker exec blue #{container_label_switch} ; docker exec green #{container_label_switch} ;  git pull ;docker exec front_nginx bash -c '/etc/nginx/switch'"
        self.connect_server(s)
    end

    def install_infrastructure()
        centos_install_docker = "sudo yum install -y yum-utils device-mapper-persistent-data lvm2;sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo ; sudo yum install docker-ce -y ; sudo systemctl start docker ; sudo systemctl enable docker"
        ubuntu_install_docker = "sudo apt-get update -y ; sudo apt-get install apt-transport-https ca-certificates curl software-properties-common; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; sudo apt-key fingerprint 0EBFCD88; sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable\"; sudo apt-get update ; sudo apt-get install docker-ce -y ; sudo usermod -aG docker $USER "
        ami_install_docker = "sudo yum update -y ; sudo yum install -y git docker; sudo usermod -aG docker #{@cli_env["server_user"]}; sudo service docker start "
        selection = Hash.new
        selection["centos"] = centos_install_docker
        selection["ubuntu"] = ubuntu_install_docker
        selection["ami"] = ami_install_docker

        s = "cd #{@cli_env["install_infra_dest"]} ; git clone https://github.com/rainc/infra; #{selection[@cli_env["os"]]}"
        self.connect_server(s)
    end

    def initialize(env)
        @cli_env = env
    end

end
