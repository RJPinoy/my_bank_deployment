# Project MyBank

## Frontend

Project MyBank uses React for the frontend.

## Backend

Project MyBank uses Symfony for the backend.

## How to setup Jenkins

Jenkins is used for CI (Continious Integration) to automate the server.
Using docker, first install jenkins :
```
docker run -p 8080:8080 -p 50000:50000 --restart=on-failure jenkins/jenkins:lts-jdk17
```

Then log in to Jenkins and set up a pipeline job for the project.
Configure its pipeline script to look for the git repo.
```
pipeline {
    agent any

    stages {
        stage('CI') {
            steps {
                git 'https://github.com/RJPinoy/MyBank_project.git'
            }
        }
    }
}
```

## Create jenkins agent for symfony

Documentation of the base image : https://hub.docker.com/r/jenkins/inbound-agent

docker build . -t <your_image_name>

docker run --name <your_container_name> --init <your_image_name> -url http://<IPAdresse_of_jenkins_master>:8080 <secret_key> <node_name>

For Docker, use :
docker run --init --name <your_container_name> -v /var/run/docker.sock:/var/run/docker.sock <your_image_name> -url http://<IPAdresse_of_jenkins_master>:8080 -workDir=/home/jenkins/agent <secret_key> <node_name>

To get the <IPAdresse_of_jenkins_master>, make this command :
docker inspect jenkins_master_container

<secret_key> and <node_name> are given by jenkins when you create a node

### Setup Jenkins Agent

First get the IP Address of the Jenkins container. Run this command :

```
docker inspect <name_of_the_jenkins_container>
```

From that IP, run this command so the agent run automated tasks :

```
docker run --init jenkins/inbound-agent -url http://<jenkins_container_ipaddress>:8080 -workDir=/home/jenkins/agent <agent_secret_key> <agent_name>
```

Modify the pipeline script :

```
pipeline {
    agent {
        label "${AGENT}"
    }

    stages {
        stage("Continuous Integration / Intégration Continue") {
            steps {
                git branch: 'main', url: 'https://github.com/<your_repo>'
                sh 'npm install'
            }
        }
        stage("Continuous Delivery / Livraison Continue") {
            steps {
                sh "docker build . -t ${DOCKERHUB_USERNAME}/next_cicdcd"
                sh "docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKER_PASSWORD}" // Créer un PAT sur Docker Hub : https://app.docker.com/settings/personal-access-tokens
                sh "docker push ${DOCKERHUB_USERNAME}/next_cicdcd"
            }
        }
    }
}
```

## How to Setup NGROK
First install chocolatey for Windows if not installed yet :
Run this command :
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Once installed, run NGROK :
You should first create an account to get your key. https://dashboard.ngrok.com/get-started/setup/windows
Then run this command :
```
choco install ngrok
```

Run the following command to add your authtoken to the default ngrok.yml configuration file.
```
ngrok config add-authtoken $YOUR_AUTHTOKEN
```

Put your app online at an ephemeral domain forwarding to your upstream service. For example, if it is listening on port http://localhost:8080, run:
```
ngrok http http://localhost:8080
```

## How to Setup Github so it can communicate with Jenkins

Once Jenkins and NGROK are setup, go to the project repo > Settings > Webhooks.
Create a new Webhook and put the link you get from NGROK into your Payload URL as follow :
```
<website_url_from_ngrok>/github-webhook/
```

# Ressources
## Adresse github :
https://github.com/RJPinoy/MyBank_project.git

## Recherches internet :
### Redux :
https://react-redux.js.org/introduction/getting-started

### Symfony :
https://symfony.com/doc/current/setup.html
https://symfony.com/doc/current/security.html
https://symfony.com/doc/current/doctrine.html

### Jenkins :
https://github.com/jenkinsci/docker/blob/master/README.md

### Chocolatey :
https://chocolatey.org/install

### NGROK :
https://dashboard.ngrok.com/get-started/setup/windows