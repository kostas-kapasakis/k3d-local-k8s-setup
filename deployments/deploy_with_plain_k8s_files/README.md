# Deployment solution with standard k8s yaml files.

## Description

 In this scenario we have chosen to use standard yaml files for creating the k8s objects that are needed for our service expected behavior.
 
 We would need to parameterized our files with some placeholders which will allow
 us to use the same files for local and dev/beta/prod releases.
 Then by using either a built in task of our selected CI/CD tool or a custom script task we replace
 these placeholders with our environment values for each case just before the release.

Local development could be achieved by creating a env file which has key value pairs content with
the necessary local values that our service/app expects. ( local connection string , local rabbitmq credentials etc.)
Also we would require a script that would imitate the CI/CD tasks and replace the placeholders
in the files like the replace_env.sh

## Example

We have the following files in a folder
- deployment.yaml
- service.yaml
- configMap.yaml
- secret.yaml

We have created a env.txt with content like the below







