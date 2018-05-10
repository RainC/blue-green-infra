# infra
auto deployment infra App based Docker 

# Features 
- Deployable to green (Staging container)
- Switchable Green-Blue Deployment
- Accessable to Stage

# Purpose
- High-availability Application 
- Easy to use for Developers
- more Less infrastructure works
- just programming practice and make better deployment environment

# Todo Lists
- 1. Green-Blue Deployment 
- 2. GCP - gcloud features Implement with deployment
- 3. GCP - construct Auto Scale Group + Green/blue deployment
- 4. DR Automate with Green/Blue

# Todo Lists 2
- Automate Application Deployment on Google Cloud Platform
- Scalable 
- using Docker Swarm

# Todo  3 Load Balancing
- Google Loadbalancer with Kubernetes - 

# kubernetes ruby library 
- https://cloud.google.com/ruby/tutorials/bookshelf-on-kubernetes-engine

# Usage - Cli Options
```
rubyrain@DESKTOP-VT2AITM:/mnt/c/Users/rainc/Development/infra$ ruby manager.rb  help
"Module Load - init"
"Module Load - argument_helper"
"-------------------------"
"Cli options"
"ruby manager.rb deploy init"
"ruby manager.rb deploy"
"ruby manager.rb publish"
rubyrain@DESKTOP-VT2AITM:/mnt/c/Users/rainc/Development/infra$
```

# Usage - Green/Blue Switching
```
rubyrain@DESKTOP-VT2AITM:/mnt/c/Users/rainc/Development/infra$ ruby manager.rb publish
"Module Load - init"
"Module Load - argument_helper"
"Module Load - publish"
"Switching Process.."
"Module Load Request - cli"
Already on 'master'
Already up-to-date.
Reloading nginx: nginx
.
rubyrain@DESKTOP-VT2AITM:/mnt/c/Users/rainc/Development/infra$ ruby manager.rb publish
"Module Load - init"
"Module Load - argument_helper"
"Module Load - publish"
"Switching Process.."
"Module Load Request - cli"
Already on 'master'
Already up-to-date.
Reloading nginx: nginx
.
rubyrain@DESKTOP-VT2AITM:/mnt/c/Users/rainc/Development/infra$
```

# Blue Container Access
```
http://Your-Production-Domain
```

# Green Container Access
```
http://Your-Producion-Domain/stage/{URI..}
```

# Status
- Now Developing , Don't use this solution. 
- it have Deployment issues* with blue/green detection.