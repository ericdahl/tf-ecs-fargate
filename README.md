# tf-ecs-fargate

Demo apps deployed to AWS ECS Fargate using Terraform, with ECS Exec and audited shell access

- httpbin - [go-httpbin](https://github.com/mccutchen/go-httpbin)
    - behind an internet-facing ALB
    - 2 tasks across 3 private subnets, on `FARGATE_SPOT`
    - logs to CloudWatch (`/ecs/httpbin`)
    - `debug` sidecar (busybox) for ECS Exec, since go-httpbin is distroless (no shell)
- jumphost - AL2023 in a public subnet, accessed via SSM Session Manager (no SSH)
    - can reach the ALB and the task ENIs on 8080
- session logs - S3 bucket (SSE-S3, TLS-only, 30-day expiry)
    - `ssm/` - Session Manager transcripts (jumphost)
    - `ecs-exec/` - ECS Exec transcripts

## Usage

```
terraform init
terraform apply
```

Requires the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) for the AWS CLI.

### ECS Exec

```
TASK=$(aws ecs list-tasks --cluster tf-ecs-fargate --service-name httpbin --query 'taskArns[0]' --output text)

aws ecs execute-command --cluster tf-ecs-fargate --task $TASK \
  --container debug --interactive --command /bin/sh
```

From the `debug` container:

- `wget -qO- localhost:8080/get` - same network namespace as httpbin
- `ps` - same PID namespace (`pid_mode = "task"`), with tini as PID 1 (`initProcessEnabled`)
- `ls /proc/<pid>/root/` - httpbin's filesystem; needs `SYS_PTRACE` since httpbin runs as a different (nonroot) UID

### Jumphost

```
aws ssm start-session --target $(terraform output -raw jumphost_instance_id)
```

### Session logs

```
aws s3 ls s3://$(terraform output -raw session_logs_bucket) --recursive
```

## Notes

- `enable_execute_command` only applies to tasks launched after it is set; force a new deployment when enabling it
- ECS Exec logging needs `script` and `cat` in the target container. If they are missing (e.g., the distroless
  httpbin container), the session still works but **no transcript is written**
- `ssm_session_preferences.tf` manages `SSM-SessionManagerRunShell`, the account/region-wide
  Session Manager preferences document. `terraform destroy` deletes it, reverting to defaults

## TODO

- [ ] autoscaling example (target tracking)
- [ ] pull secrets from AWS SSM or SM
- [ ] restrict ECS Exec to the `debug` container (`ecs:container-name` condition)
- [ ] splunk logging to a splunk-on-ecs deployment
    - [ ] automatic config of HEC
    - [ ] secure HEC token and pass to apps
    - [ ] configure filesystem limit to be usable on fargate
