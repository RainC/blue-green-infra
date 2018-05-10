class InitConstruct
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
end