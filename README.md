Install jenkins , maven,docker and git into bastion ec2:
Jenkin install:
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
====
Docker:
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
=======================
=== Maven install automatically from jenkins tools installation:
===============================================================================================================================================
**With the below cmds, From the Bastion EC2 create the KOPS cluster:**

sudo apt-get update
sudo apt-get install -y wget
sudo apt install openjdk-11-jdk -y
wget https://github.com/kubernetes/kops/releases/download/v1.22.0/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl      #kubectl installing
sudo mv ./kubectl /usr/local/bin/kubectl
sudo apt-get update
sudo apt-get install snapd –y
sudo snap install aws-cli --classic
aws configure
aws s3api put-bucket-versioning --bucket (your s3 bucket) --versioning-configuration Status=Enabled

nano ~/.bashrc
export AWS_ACCESS_KEY_ID= (your access key) 
export AWS_SECRET_ACCESS_KEY=(your secret key)
export KOPS_STATE_STORE=s3://(your s3 bucket)
export KOPS_CLUSTER_NAME=(yourclustername).k8s.local
source ~/.bashrc

kops create cluster --zones us-east-1a --name ${KOPS_CLUSTER_NAME}
kops update cluster --name yogeshk8scluster.k8s.local --yes --admin
kops validate cluster
kops edit ig --name=yogeshk8scluster.k8s.local nodes-us-east-1a

To increase worker node copy the yaml file from the s3 and update with the changes to s3 bucket:
aws s3 cp s3://demo-sam-rds/yogeshk8scluster.k8s.local/instancegroup/nodes-us-east-1a nodes-us-east-1a.yaml
ls
chmod 777 nodes-us-east-1a.yaml
ls
vi nodes-us-east-1a.yaml
aws s3 cp nodes-us-east-1a.yaml s3://demo-sam-rds/yogeshk8scluster.k8s.local/instancegroup/nodes-us-east-1a
## After changes update the cluster:
kops update cluster --name yogeshk8scluster.k8s.local --yes
kops rolling-update cluster --name yogeshk8scluster.k8s.local --yes
kops validate cluster
kubectl get nodes

Below to delete cluster
(( kops delete cluster --name yogeshk8scluster.k8s.local --state s3://demo-sam-rds –yes ))

================================================================================================================================================

After installing KOPS install below using helm.
Helm cmds:

# Update and install necessary tools
sudo apt-get update
sudo apt-get install -y docker.io unzip jq

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Helm (Package manager for Kubernetes)
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Install Maven (No need for Kubernetes, install locally)
sudo apt-get install -y maven

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Install Prometheus
kubectl create namespace prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace prometheus --set alertmanager.persistentVolume.enabled=false --set server.persistentVolume.enabled=false --set server.service.type=LoadBalancer

# Install Grafana
kubectl create namespace grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana --namespace grafana --set adminPassword='admin' --set service.type=LoadBalancer --set persistence.enabled=false

===============================================================================================================================================

After installation of kops and with a long gap, If kubectl or cluster not working try update cluster:
# kubectl config current-context
# kubectl config get-clusters
#  kops get clusters
#  kops update cluster --name yogeshk8scluster.k8s.local --yes --admin
===============================================================================================================================================
ArgoCD uses deployment-service.yml for deployment.
