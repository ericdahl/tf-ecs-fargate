# tf-ecs-fargate

Demo apps deployed to AWS ECS Fargate using Terraform

- httpbin - see http://httpbin.org
    - simplest app
    - logs to CloudWatch
    - behind an ALB
    
    
## TODO

- [ ] autoscaling example (target tracking)
- [ ] pull secrets from AWS SSM or SM
- [ ] splunk logging to a splunk-on-ecs deployment
    - [ ] automatic config of HEC
    - [ ] secure HEC token and pass to apps
    - [ ] configure filesystem limit to be usable on fargate