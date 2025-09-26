# sample-aws-app

EKS Observability Platform on AWS with Terraform
This project uses Terraform to provision a fully-featured Kubernetes platform on AWS EKS, complete with a service mesh and observability stack. All infrastructure is defined as code, allowing for easy, repeatable deployments.

Deliverables
Infrastructure as Code: All infrastructure is created using Terraform. This guide and the provided .tf files constitute the infra code.

Kubernetes Manifests: All Kubernetes applications (demo apps, Istio Gateway) are managed by Terraform and defined in the .yaml files.

Documentation: This README.md provides a complete guide with all the necessary commands and verification steps.

How it was Created
This EKS cluster and its components were created using Terraform. Terraform modules were used for the VPC and EKS cluster to simplify the process and follow best practices. Helm was used within Terraform to deploy the complex applications like Istio, ELK, Tempo, and SigNoz.

Prerequisites
Before you begin, ensure you have the following tools installed and configured:

AWS CLI

Terraform

kubectl

Helm

Istio istioctl CLI

Make sure your AWS CLI is configured with the necessary credentials and a default region.

Setup and Deployment
Clone this repository:

git clone <your-repo-url>
cd <your-repo-url>

Initialize Terraform: This command downloads the required providers and modules.

terraform init

Review the plan: This command shows you the resources Terraform will create.

terraform plan

Apply the configuration: This will provision the entire infrastructure on AWS and deploy the applications. This process can take 15-20 minutes.

terraform apply --auto-approve

Configure kubectl: After the terraform apply is complete, update your kubeconfig to point to the new cluster.

aws eks update-kubeconfig --region <your-region> --name <cluster-name>

(Note: The cluster name is specified in variables.tf, e.g., eks-observability-platform).

Verification Commands
1. EKS Cluster
Verify that your EKS nodes are running.

kubectl get nodes

You should see at least 2 nodes in a Ready state.

2. Demo Services
Check that all 5 demo services are up and running in the demo-apps namespace.

kubectl get pods -n demo-apps
kubectl get services -n demo-apps

3. Istio Service Mesh
Verify the Istio control plane and ambient data plane are installed and healthy.

# Check Istio system pods
kubectl get pods -n istio-system

# Check Ambient Ztunnel pods
kubectl get pods -n istio-system -l app=ztunnel

# Verify Istio installation and Ambient status
istioctl version
istioctl analyze

To test external access to the httpbin service, first get the public IP of the Istio ingress gateway:

kubectl get svc istio-ingressgateway -n istio-system

Once you have the public IP, you can curl the service:

curl http://<istio-ingress-ip>/status/200

This should return a 200 HTTP status.

4. Observability Stack
The observability stacks (ELK, Tempo, SigNoz) are deployed via Helm. To access their UIs, you will need to port-forward the services.

Accessing Kibana (Logs)
Get the service name and port-forward to your local machine.

kubectl get svc -n elk
kubectl port-forward svc/kibana-kibana 5601:5601 -n elk

Now, you can access Kibana at http://localhost:5601. To see logs from your demo-apps, you may need to configure a log index pattern in Kibana. The alpine-deployment container sends regular requests, which will generate logs.

Screenshot:

Accessing Tempo (Tracing)
Tempo is used for distributed tracing. To view traces, you will need to configure your applications to send traces to the Tempo backend. However, for a basic check, you can port-forward to see the service is running.

kubectl get svc -n observability
kubectl port-forward svc/tempo 3200:3200 -n observability

Screenshot:

Accessing SigNoz (Dashboards/APM)
SigNoz provides dashboards and APM features.

kubectl get svc -n observability
kubectl port-forward svc/signoz-frontend-cluster-ip 3301:3301 -n observability

You can access the SigNoz dashboard at http://localhost:3301. You will need to click on "Traces" on the left-hand navigation pane to view traces. The alpine-deployment will generate traces that SigNoz can pick up.

Screenshot:

Cleanup
To destroy all the resources created by Terraform, run the following command. Warning: This will delete your EKS cluster and all associated resources.

terraform destroy --auto-approve
