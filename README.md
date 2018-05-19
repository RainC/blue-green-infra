# infra
- deployment infra App based Docker container
# Concept
- 아래와 같은 그림으로 운영이 가능합니다.
- Simple Application Concept
![](https://i.imgur.com/evlwF8j.png)

- Multi-Application Conecpt Concept

![](https://i.imgur.com/snA7vMu.png)

- 추가로 위 컨셉도 구축 가능하도록 개발을 완료 했습니다. 
- 한 서버에서 여러 green-blue 서비스를 운영해야 하는 사용자를 위해서 설명을 돕기 위해 만들었습니다. 



# 특징 
- 인프라 환경 구성 자동화
- Green Container 에 배포하기
- 무중단 배포
- Docker Container Application 에 최적화
- 웹 어플리케이션에 최적화

# Purpose
- High-availability Application - 고가용성 어플리케이션
- Easy to use for Developers - 개발자들 사용하기 쉽게
- more Less infrastructure works - 인프라에 들어가는 시간을 줄이기 위해

# Note
- 현재는 단일 서버에 최적화 되어 있지만, 추후에 docker-swarm, kubernetes 등을 활용하여 Loadbalancing 도 될 수 있도록 기능을 추가할 계획입니다.
- 사용자가 작은 서비스이지만, 운영은 해야하고, 그렇다고 서버가 꺼지면 곤란한 서비스이면서, 업데이트는 주기적으로 해야 하는 그런 서비스에 이걸 사용하는것이 적합합니다.
- 현재 계속 기능 추가 및 유지 보수가 진행 중 입니다. 
- construct, deployment 까지 충분한 Test 를 해봤지만, 그래도 생각하지 못한 버그가 있을 수 있습니다. Pull Request 해주시면 정말 감사하겠습니다..

# Turorial 

## Requirements
- Tutorial 을 진행하기 위한 Requirement 입니다.

![](https://i.imgur.com/y4n9bHw.png)

- 클라우드 서버가 아닌 Bare-metal (리얼 서버) 이여도 됩니다.
- 서버가 OS 가 Amazon Linux, CentOS, Ubuntu 16.04 셋 중 하나이면 됩니다. 
- Local PC 에서는 manager.rb 를 실행하기 위한 ruby 2.4 +  버젼이 설치되어 있으면 됩니다.
 
## 절차
- Sample App Repository 생성 및 소스 추가
- Sample App 을 서버에 배포
- 받은 소스에 기능을 몇개 더 추가하고 Green 에 배포해보기
- 배포한 기능을 Production 에 배포해보기

## 준비 과정
- Sample 앱을 배포하기 위한 Github Repository 를 만듭니다. 여기서는 `simplesinatra` 로 사용합니다.
- Github 계정이 필요합니다.
- Local PC 에서 Repository 를 받아줍니다.
```
git clone https://github.com/ExUser/simplesinatra
```
- Sample 앱은 간단한 웹 어플리케이션이며, 
```
cd simplesinatra
```
- `Gemfile`
```
source 'https://rubygems.org'
gem 'sinatra'
```

- `config.ru`
```
require './hello'
run Sinatra::Application
```

- `hello.rb`
```
require 'sinatra'

get '/' do
  "This is V1"
end
```

- 위 앱을 Local PC 에서 실행해 봅시다.
- bundler, bundle install 은 requirement 를 자동으로 설치해줍니다.  
```
gem install bundler
```
- requirement 자동 설치
```
bundle install
```
- 4567 포트로 앱 서버를 실행합니다. 
```
rackup -p 4567
```
- CURL 으로 `Hello World` 가 나오는지 확인합니다. 정상적으로 실행되는지 확인하는 과정입니다.
```
curl localhost:4567
Hello World
```

- 파일 3개를 모두 작성했다면, 커밋 후 Repository 에 푸쉬 해주세요. 
```
git add .
git commit -sm "Added ruby app"
git push
```

- 이제 지금 보고계시는 repository 를 받아줍니다.
```
git clone https://github.com/rainc/infra
```

- clone 받은 경로로 이동해 줍니다.
```
cd infra
```

- packages 설치를 위한 bundler 를 먼저 설치 해줍니다.
- 패캐지 다운로드
```
bundle install
```
- environment.json.example 이름 변경 (윈도우는 move)
```
mv environment.json.example environment.json
```



- environment.json 편집
```
{
    "server_name" : "ip",
    "server_user" : "ec2-user",
    "connect_method" : "keyfile",
    "keyfile" : "./keyfile.pem",
    "install_infra_dest" : "/home/ec2-user",
    "app_deployment_dest" : "/home/ec2-user/app_dest",
    "app_target" : "sampleapp",
    "app_publish_port" : "4567",
    "app_name" : "samplerubyapp",
    "loadbalancer_port" : "8063", 
    "os" : "ami",
    "infra_repo" : "https://github.com/rainc/infra"
}
```
- attributes 설명
    - `server_name` : 서버 주소
    - `server_user` : 서버 사용자 이름
    - `connect_method` : SSH 연결 방법 선택
        - 패스워드 연결 방법일 경우 `password`
        - SSH 개인키 연결 방법일 경우 `keyfile`
    - `keyfile` :  (Optional) 로컬 pc 의 SSH 개인키 경로 입력
    - `server_pass` : (Optional) SSH 패스워드 
    - `install_infra_dest` : 인프라 설치 위치
    - `app_deployment_dest` : 어플리케이션을 보관할 위치, 만약 서버에서 폴더가 존재하지 않으면 `construct` 에서 만들어 줍니다.
    - `app_target` : `app_deployment_dest` 경로에서 어떤 앱을 선택할것인지 선택 가능
    - `app_publish_port` : 앱 서버의 내부 포트 입력
    - `app_name` : 앱 이름 입력 (사용자가 지정 해줘야함)
    - `loadbalancer_port` : 0.0.0.0:XXXX 형식으로 바인딩, 즉 example.com:XXXX 에 쓰일 포트 입력
    - `os` : `ami` - Amazon Linux 일 경우 ami ,CentOS 는 `centos` , Ubuntu 일 경우 `ubuntu`
    - `infra_repo` : 기존 값 유지
- 초기 서버 구성
```
ruby manager.rb construct
```

- 서버 - Sample App 환경을 위한 Dockerfile 작성
```
ssh ec2-user@your-server.com
```
```
cd /home/ec2-user/app_dest
```
 
- 아래와 같이 작성하면 environment.json 에서 해당 `Dockerfile` 을 찾을 수 있게 `environment.json` 파일의 `app_deployment_dest` 설정을 잘 맞춰 줘야 함.
- `git clone` 영역에서 아까 커밋한 Repository URL 을 맞춰줘야 합니다.
```
vim Dockerfile
```
```
FROM ruby
RUN mkdir -p /app
WORKDIR /app/
RUN git clone https://github.com/ExUser/simplesinatra
RUN rm -rf /app/rubyapp/Gemfile.lock
WORKDIR /app/rubyapp
RUN bundle install
CMD rackup -p 4567 --host 0.0.0.0
```

- 다시 Local PC 로 돌아옵니다.
- ruby 앱 배포와 동시에 초기 환경 구축
```
ruby manager.rb deploy init
```
- 접속 확인
    - example.com - Blue Container
    - example.com/stage - Green Container
- /stage 에 배포 해보기
- 로컬 PC 에서 아까 만든 SampleApp 으로 콘솔에서 이동해 봅시다. 
```
cd ExUser/simplesinatra
```

- demo 에서는 기존 V1 을 `This is V2` 로 변경 , 라우터 하나를 더 추가 했습니다. 
- hello.rb
```
get '/' do
  "This is V2"
end
get '/module-manage'
    "this is Module Manage page"
end
```
- hello.rb 파일을 저장하고 자신의 Repository 에 커밋 후 푸쉬합니다.
```
git add .
git commit -sm "/stage 에 반영하기 위한 commit"
git push origin master
```
- 이제 Repository 에 올려뒀으니, `green`서버에 배포해봅시다 .
```
ruby manager.rb deploy
"[module] command Loaded"
"[initializer] argument_helper Loaded"
"[controller] deploy Loaded"
"Module Load Request - command"
Already up-to-date.
Sending build context to Docker daemon  2.048kB
Step 1/9 : FROM ruby
 ---> fb664b54b956
Step 2/9 : RUN mkdir -p /app
 ---> Running in 1a07f1ed7768
Removing intermediate container 1a07f1ed7768
 ---> c426cccaee53
Step 3/9 : ARG repourl

 ---> Running in 1e596a578db7
Removing intermediate container 1e596a578db7
 ---> 5ac165e0da7d
Step 4/9 : WORKDIR /app/

Removing intermediate container 671a7f48155b
 ---> 804509fd0983
Step 5/9 : RUN git clone $repourl

 ---> Running in 96681fa98292
Cloning into 'rubyapp'...

Removing intermediate container 96681fa98292
 ---> fb63693e9cdf
Step 6/9 : RUN rm -rf /app/rubyapp/Gemfile.lock

 ---> Running in ec4c38ffdd3f
Removing intermediate container ec4c38ffdd3f
 ---> 4a519c129636
Step 7/9 : WORKDIR /app/rubyapp

Removing intermediate container 065de9f4bcb5
 ---> f0d1f35ce0b7
Step 8/9 : RUN bundle install

 ---> Running in 9f964edc89b9
Fetching gem metadata from https://rubygems.org/

.
Resolving dependencies...

Using bundler 1.16.1
Fetching mustermann 1.0.2
Installing mustermann 1.0.2
Fetching rack 2.0.5
Installing rack 2.0.5
Fetching rack-protection 2.0.1
Installing rack-protection 2.0.1
Fetching tilt 2.0.8
Installing tilt 2.0.8
Fetching sinatra 2.0.1
Installing sinatra 2.0.1
Bundle complete! 1 Gemfile dependency, 6 gems now installed.
Bundled gems are installed into `/usr/local/bundle`
Removing intermediate container 9f964edc89b9
 ---> e94218079da3
Step 9/9 : CMD rackup -p 4567 --host 0.0.0.0

 ---> Running in 83039e387521
Removing intermediate container 83039e387521
 ---> 73a103a3cfa2
Successfully built 73a103a3cfa2
Successfully tagged app_image:latest
f5f601735728d377299334b40133585f20c01dbd2619d5f58f4cbb723ffa657c
```
- 이렇게 나오고 example.com/stage 에 접속이 된다면 안전하게 배포가 된 것입니다. 그래도 혹시나 모르니 확인해 봅시다.
```
curl example.com/
This is V1

curl example.com/stage
This is V2

curl example.com/stage/module-manage
this is Module Manage page
```
- 만약 오류가 난다면, 서버 에서 `docker logs green` 을 통해 마지막으로 발생한 오류를 찾아 냅니다. 거의 `syntax` 오류일 겁니다. 고쳐서 다시 커밋 후 배포하면 됩니다. 이 상황이 실제로 일어나도 실 운영에 영향을 미치지 않습니다. 이게 제일 핵심입니다!!!
- `green` 으로 배포가 안전하게 끝났다면 최종적으로 Production 에 배포해 봅시다. 
```
ruby manager.rb publish
"[module] command Loaded"
"[initializer] argument_helper Loaded"
"[controller] publish Loaded"
"Switching Process.."
"Module Load Request - command"
Already on 'master'
Your branch is up-to-date with 'origin/master'.
Already up-to-date.
Reloading nginx: nginx
.
```
- 이렇게 나오고, example.com/ 으로 접속하면 Hello World! 였던게 `TINY rubyrain` 으로 변경이 됐습니다. /stage 에 있던게 그대로 옮겨주는 작업이 `publish` 입니다. 
```
curl example.com/stage/module-manage
- 404, 이전 버젼이 나옵니다.
``` 

- 이후 Stage 는 이렇게 되어 있습니다. 이전 버젼의 Production 이 Stage 로 이동 되었음을 보여줍니다.
```
curl exmaple.com/stage/
This is V1
```

# Program 간단한 아키텍쳐
![](https://i.imgur.com/K9gHfJZ.png)
