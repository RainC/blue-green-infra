# infra
- deployment infra App based Docker container
# Concept
![](https://i.imgur.com/evlwF8j.png)

# Features 
- Deployable to green (Staging container) - 스테이징 서버로 배포 
- Switchable Green-Blue Deployment - 스테이징을 운영으로 바꾸고, 기존 운영을 스테이징으로 변경
- Accessable to Stage - 스테이징 영역으로 접근 가능

# Purpose
- High-availability Application 고가용성 어플리케이션
- Easy to use for Developers - 개발자들 사용하기 쉽게
- more Less infrastructure works - 쉘로 직접 치는 일을 덜 하기 위해

# Note
- 현재는 단일 서버에 최적화 되어 있지만, 추후에 docker-swarm, kubernetes 등을 활용하여 Loadbalancing 도 될 수 있도록 기능을 추가할 계획입니다.
- 사용자가 작은 서비스이지만, 운영은 해야하고, 그렇다고 서버가 꺼지면 곤란한 서비스이면서, 업데이트는 주기적으로 해야 하는 그런 서비스에 이걸 사용하는것이 적합합니다.
- 현재 계속 기능 추가 및 유지 보수가 진행 중 입니다. 
- construct, deployment 까지 충분한 Test 를 해봤지만, 그래도 생각하지 못한 버그가 있을 수 있습니다. Pull Request 해주시면 정말 감사하겠습니다..

# Turorial 
- Sample App 배포 해보기
- Sample App blue-green switching
## Requirements
- Tutorial 을 진행하기 위한 Requirement 입니다.

![](https://i.imgur.com/gRMMwAF.png)

- 클라우드 서버가 아닌 Bare-metal (리얼 서버) 이여도 됩니다.
- 서버가 OS 가 Amazon Linux, CentOS, Ubuntu 16.04 셋 중 하나이면 됩니다. 
- Local PC 에서는 manager.rb 를 실행하기 위한 ruby 2.4 +  버젼이 설치되어 있으면 됩니다.
 

## 준비 과정
- 아래 내용은 Local PC 에서 진행합니다. 
- packages 설치를 위한 bundler 를 먼저 설치 해줍니다.
```
gem install bundler
```
- Repository 를 fork 해주세요. 
```
https://github.com/RainC/rubyapp/
```
![](https://i.imgur.com/LCPag2a.png)

- 패캐지 다운로드
```
bundle install
```
- deployment.json.example 이름 변경 (윈도우는 move)
```
mv deployment.json.example deployment.json
```
- deployment.json 편집
```
{
    "server_name" : "example.com",
    "server_user" : "ec2-user",
    "server_pass" : "만약 패스워드 연결 방식일경우 채우기"
    "connect_method" : "password or keyfile",
    "keyfile" : "./개인키 경로 입력",
    "install_infra_dest" : "/home/ec2-user",
    "app_deployment_dest" : "/home/ec2-user/infra/app",
    "app_target" : "sampleapp",
    "app_publish_port" : "80",
    "network" : "base_network",
    "os" : "ami",
    "infra_repo" : "https://github.com/rainc/infra",
    "app_repo" : "https://github.com/<Your-forked-id>/rubyapp"
}
```
- attributes 설명
    - `server_name` : 서버 주소
    - `server_user` : 서버 사용자 이름
    - `connect_method` : SSH 연결 방법 선택
        - 패스워드 연결 방법일 경우 `password`
        - SSH 개인키 연결 방법일 경우 `keyfile`
    - `keyfile` : 로컬 pc 의 SSH 개인키 경로 입력
    - `server_pass`
    - `install_infra_dest` : 인프라 설치 위치
    - `app_deployment_dest` : 어플리케이션 보관 위치
    - `app_target` : 배포할 앱 선택
    - `network` : `base_network` 값 유지 
    - `os` : `ami` - Amazon Linux 일 경우 ami ,CentOS 는 `centos` , Ubuntu 일 경우 `ubuntu`
    - `infra_repo` : 기존 값 유지
    - `app_repo` : 자신이 fork 한 Repository 입력
- 초기 서버 구성
    - Docker 를 설치해주고, 서버에 인프라 Repository 를 받아 줍니다.
```
ruby manager.rb construct
```
- ruby 앱 배포와 동시에 초기 환경 구축
```
ruby manager.rb deploy init
```
- 접속 확인
    - example.com - Blue Container
    - example.com/stage - Green Container
- /stage 에 배포 해보기
- rubyapp 을 Clone 합니다.
```
git clone https://github.com/<your-forked-id>/rubyapp
```
- hello.rb 을 열어서 hello world 영역에 자기가 원하는 글자를 넣어 봅시다.
```
get '/' do
  "Hello World!"
end
```
- demo 에서는 `TINY rubyrain` 로 변경 했습니다.
- hello.rb
```
get '/' do
  "TINY rubyrain"
end
```
- hello.rb 파일을 저장하고 커밋 후 푸쉬합니다.
```
git add .
git commit -sm "/stage 에 반영하기 위한 commit"
git push origin master
```
- 이제 Repository 에 올려뒀으니, 서버에 배포해보려고 합니다.
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
Hello World!

curl example.com/stage
TINY rubyrain
```
- 만약 오류가 난다면, 서버 에서 `docker logs green` 을 통해 마지막으로 발생한 오류를 찾아 냅니다. 거의 `syntax` 오류일 겁니다. 고쳐서 다시 커밋 후 배포하면 됩니다. 이 상황이 실제로 일어나도 실 운영에 영향을 미치지 않습니다. 이게 제일 핵심입니다!!!
- 배포가 안전하게 끝났다면 example.com/ 으로 배포가 되어야 합니다. 아래 명령어를 통해 스위치 합니다.
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
curl example.com
TINY rubyrain
``` 

- 이후 Stage 는 이렇게 되어 있습니다. 이전 버젼의 Production 이 Stage 로 이동 되었음을 보여줍니다.
```
curl exmaple.com/stage
Hello World!
```

# Program 간단한 아키텍쳐
![](https://i.imgur.com/K9gHfJZ.png)
