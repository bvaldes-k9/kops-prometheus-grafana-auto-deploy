# Kops-Terraform-Ansible-Prometheus-Grafana-Ingress-Nginx-Controller
## Self managed kubernetes automated deployment

This repo will automate most of the deployment and configuration of a self managed Kubernetes cluster with Prometheus and Grafana.

## Technology Stack
- Kops
- Terraform
- Ansible
- AWS
- Route53
- Kubectl
- Helm
- Ingress Nginx Controller
- Prometheus
- Grafana
- Kubernetes

## Features

- Create your domain in Route53 and update the specified files with your subdomain/domain, and watch ass your cluster is deployed.

- Self managed so you can avoid the extra cost per HR of EKS managing and having more control of your cluster.

- Ansible is setup to deploy from one script, the only manual interaction needed is updating files with domain and setting up Grafan's dashboard.

- I will have this break down in two forms, a TLDR to get you up and running, while the other will be a more in depth explanation of how the entire repo works so you can make it your own.

- For our Prometheus and Grafana we use yaml configurations and helm charts of [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

## Caveats

- This is a public topology cluster with Prometheus and Grafana aimed to be pushed on subdomains, this is typically not best practice and I'd recommend setting up a proxy with authentication in front of them to protect against warry attackers.

- This is setup to depend on your domain being hosted in route53, you can have your domain with a different registar, just know you'll have to edit the config to your needs and update the CNAME on your registar too. I'd recommend the documentation advice on using a different registar [here](https://kops.sigs.k8s.io/getting_started/aws/) on the "Scenario 3: Subdomain for clusters in route53, leaving the domain at another registrar". At the end of this README I will have a section on what you'll need to remove from the repo for easier configuration for your custom deployment.

- There has been issue if you have a hosted-zone for your domain as this will deploy another hosted-zone for your domain. For testing purposes if you face any trouble with reaching nameservers with the cmd `dig NS yoursubdomain.domain.com` then delete the hosted-zone thats not managed by terraform and retry again.

- If you face any problems I have troubleshoot section close to the end of the README.md

# Requirements
- AWS CLI
- Terraform
- Ansible
- Python3
- Python3-pip
- Kubectl
- Helm
- Domain on AWS Route53
- AWS IAM user with Administrator Access permissions
- This project is deployed in Ubuntu distro, change the downloads commands based on your distro.

# Downloads

## Terraform
https://learn.hashicorp.com/tutorials/terraform/install-cli
• Ensure that your system is up to date, and you have the gnupg, software-properties-common, and curl packages installed. You will use these packages to verify HashiCorp's GPG signature, and install HashiCorp's Debian package repository.

- `$ sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl`

• Add the HashiCorp GPG key.
- `$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`

• Add the official HashiCorp Linux repository.
- `$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`

• Update to add the repository, and install the Terraform CLI.
- `$ sudo apt-get update && sudo apt-get install terraform`

## AWS
• Prerequisetes
- `$ sudo apt install unzip`

AWS setup
• Then download AWS
- `$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"`
- `$ unzip awscliv2.zip`
- `$ sudo ./aws/install`

• Remember to remove the zip afterwards with 
- `$ rm -r zip-file-name`

• Remember to update if doesn’t let you download package/install
- `$ sudo apt-get update`

## Ansible
• To install Ansible controller on your local Linux properly we'll require a few prerequisites
- Python3
- Python-pip

### Python3
• Depending on your distro of Linux your likely to have Python already installed.
• Check version with the following cmd:
- `$ python3 --version`

• If you don't have it install you can install Python3 with the following:
- Update your local Repositories.
    - `$ sudo apt update`
- Then upgrade packages installed on your local machine.
    - `$ sudo apt -y upgrade` 
- Its possible that you may see a python version now so try this one more time.
    - `$ python3 --version`
- If still no success we can now apply the python3 install cmd.
    - `$ sudo apt install python3` 

### Python3-pip
• Once Python3 is installed you can install pip with the following
- `$ sudo apt-get -y install python3-pip`

### Ansible-Install
• Now that we have our dependencies we can install ansible
- `$ sudo apt install ansible`

## Kubectl
• Download the latest release with the command:
- `$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`

• Install kubectl
- `$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`

• Test to ensure the version you installed is up-to-date:
- `$ kubectl version --client`

## Helm
•Helm install
- `$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`
- `$ chmod 700 get_helm.sh`
- `$ ./get_helm.sh`

# Prerequisites
Domain on AWS Route53
AWS IAM user with Administrator Access permissions

## AWS Configurations

• After creating your user that has programmatic access to with permissions to services you will be deploying on AWS, you head to your terminal and issue the cmd. 
- `$ aws configure --profile iam-user`

• After either moving your domain registar to route 53 or deciding on editing the terraform deployment and use a different registar, again I'd recommend the documentation advice on using a different registar [here](https://kops.sigs.k8s.io/getting_started/aws/) 

### Export
• These environment variables are required for kops.

This is the same bucket deployed in terraform/s3.tf kops_state
- `$ export KOPS_STATE_STORE=s3://insert-bucket-name-here` 

- `$ export AWS_PROFILE=iam-user`

- `$ export AWS_ACCESS_KEY_ID=iam-user-access-key`

- `$ export AWS_SECRET_ACCESS_KEY=iam-user-secret-access-key`

## Changes needed to files
### terraform/

`provider.tf` resources
- specify your region and aws profile

`route53.tf` resources
- Resource `sub_r53_k8s`
    - `name = custom subdomain.domain.com`

- Resource `k8s_ns`
    - `name = custom subdomain.domain.com`

`s3.tf` resources
- Remember the bucket name will be your export variable for `KOPS_STATE_STORE` 
    - I would typically name the bucket similar to the domain for example: clusters-yoursubdomain-domain-com
    - `bucket = custom-bucket-name`

- If your testing and add the below value you will have to manually delete every file afterwards when cleaning up.
     - `change lifecycle = true`
     - `prevent_destroy = true`

`variable.tf` resources
- `domains = custom domain.com`

`vpc.tf` resources
- `tf_ansible_vars_file_new`
- The below resource will also be the name of your cluster as Ansible will use this as a variable later on.
    - `tf_route53: yoursubdomain.yourdomain.com` 

### ansible/

• `main.yaml`
- If you want to add more nodes just be aware of these:
    - Task kops create config
        - edit `node-count=`
        
    - Task wait for cluster to be ready
        - node-count +  (Master Node) = 5 must match the count below value as this is what validates the cluster before continueing the configuration.
        - `count_read_nodes.stdout == "5"`


• ansible/ingress

• `ingress/0-prometheus-ingress.yaml `
- Change to your specific domain.
    - `host: prometheus.yoursubdomain.yourdomain.com`
    

• `ingress/1-grafana-ingress.yaml` 
- change to your specific domain.
    - `host: grafana.yoursubdomain.yourdomain.com`

• ansible/grafana/

- `grafana/0-secret.yaml`
    - `admin-user:`
    - `admin-password: `
- user/pass are encoded in base64, you can make your own with cmd
`$ echo -n "example-user" | base64`

- To decode use the following cmd
`$ echo -n "ZXhhbXBsZS11c2Vy" | base64`

- You will then use the decoded versions of the values at the login page for Grafana
- This is not recommended in production environment but if your goal is to test you can optionally use the current values that are set which are `user = admin` and `pass = devops123`


# Procedure

- cd into ansible folder
    - `$ cd ansible`

- With your exports already completed as mentioned before. You can double check all your exports with the following cmd.
    - `$ exports`

- Next is starting ansible playbook
    - `$ ansible-playbook -K main.yml`

- You'll be asked for password, afterwards it may take 10 to 15 minutes for the process to complete as dependencies are downloaded, cluster is validated, etc.

- After the ansible playbook has completed, verify all pods are running fine and none are stuck in a pending state
    - `$ kubectl get pods -n monitoring`

- Now to setup the subdomains for Prometheus Grafana, grab the LB address and create CNAME records in hosted zones on route53 or the registar for your domain.

- To get the LB address use the following cmd and copy the result for the address, grafana and Proemtehus will be using the same LB so you can use the same address value for both CNAME values.
    - `$ kubectl get ing -n monitoring`
    - Copy Address result and create records
    - In the record make the subdomain `grafana.yoursubdomain.yourdomain.com` 
    - CNAME
    - TTL 300
    - value: the result for address Ex. `4654151689060d8b1b1f0b28-9e402.elb.us-east-2.amazonaws.com`
    - Then create another record the same except the subdomain be `prometheus.yoursubdomain.yourdomain.com`

- After completing that you should be able to access them on your specified subdomain url on your browser, for example: 
    - `prometheus.yoursubdomain.yourdomain.com`
    - `grafana.yoursubdomain.yourdomain.com`

- Grafana Login
    - Remember the unformatted version of the user/pass you inputted in the `grafana/0-secret.yaml` use those credentials to login
- Setup dashboard
    - Now click on the Cog wheel > data sources
    - Add data source 
    - Select Prometheus
    - For url input `http://prometheus-operated:9090`
    - then scroll down and click save & test
    - Next click on the 4 squares in the mid left of the screen “Dashboards” > manage > import
    - In the small box you will input the code `9614` and then click load
    - The at the box above import select Prometheus and click import after
    - There you will now see metrics for nginx ingress

# Clean up
All done? 
- Lets start with deleting the cluster with the cmd:
    - `$ kops delete cluster cluster-name --yes`

- Head over to AWS terminal, route53 or your registar and delete the CNAME records you created for prometheus and grafana on Route53

- After kops delete and records is completed you can head out of ansible/ and now towards terraform/, to clean up terraform issue the destroy command 
- `$ terraform destory -auto-approve`

# Troubleshoot
• Beware if you redeploy and make too many changes to your domain's name servers you may have to either flush your DNS or change your local DNS server to such as 8.8.8.8, 1.1.1.1, etc.
A good way to test if your issue is the above is two options
- Use the cmd: 
    - $ `dig NS yoursubdomain.yourdomain.com`
    - which you should see 4 nameservers appear if route53 or your registar is configured correctly.
    
- If you've followed all the steps but still cant access the subdomain then it is likely this issue and changing your DNS server or cache, you'll see your subdomains. Just remember either to change your DNS server or flush your cache.

• If your cluster seems to be stuck on validation check and see if they can be SSH'd. If the servers are unreachable ensure that if you've made any adjustments to the vpc, subnets, routes are correctly configured.

• There has been issue if you have a hosted zone for your domain as this will deploy another hosted-zone for your domain. For testing purposes if you face any trouble with reaching nameservers with the cmd `dig NS yoursubdomain.domain.com` then delete the hosted zone thats not managed by terraform and retry again.

# What will conflict if I want to configure my domain from a different registar?

## terraform/

• Remove `route53.tf` entirely

• Edit `variable.tf`
- remove variable domains entirely

• Edit `vpc.tf`
- You'll need to edit the saved values that ansible will create with later on.
    - `tf_ansible_vars_file_new`
    - `tf_route53: yoursubdomain.domain.com`

• Like mentioned before I'd recommend the documentation advice on using a different registar [here](https://kops.sigs.k8s.io/getting_started/aws/) on the "Scenario 3: Subdomain for clusters in route53, leaving the domain at another registrar". 

• Once your've setup your domain correctly you should be able to run `dig NS yoursubdomain.domain.com` and get 4 nameservers as result.

• After thats been completed you can follow the instructions for the setup for this `README.md` from Downloads.
