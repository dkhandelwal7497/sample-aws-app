# 🚀 EKS Observability Platform on AWS with Terraform

This project provisions a **fully-featured Kubernetes platform on AWS EKS** using Terraform.  
It includes a **service mesh (Istio Ambient)** and a complete **observability stack (ELK, Tempo, SigNoz)**.  
All infrastructure is defined as code, enabling **easy, repeatable, and automated deployments**.

---

## 📦 Deliverables

- **Infrastructure as Code** – All infra is created using Terraform (`.tf` files).  
- **Kubernetes Manifests** – Applications (demo apps, Istio Gateway) managed by Terraform & defined in `.yaml` files.  
- **Documentation** – This guide (`README.md`) with commands & verification steps.  

---

## ⚙️ How it was Created

- The **EKS cluster** and its components are provisioned with **Terraform modules** (for VPC and EKS).  
- **Helm (via Terraform)** is used to deploy complex apps like:
  - Istio (Ambient mesh)
  - ELK stack
  - Tempo
  - SigNoz  

This ensures **best practices** and a **modular approach**.

---

## ✅ Prerequisites

Install and configure the following tools before starting:

- [AWS CLI](https://docs.aws.amazon.com/cli/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Istioctl](https://istio.io/latest/docs/setup/getting-started/#download)

👉 Make sure your **AWS CLI is configured** with proper credentials and default region.

---

## 🚀 Setup & Deployment

Clone the repo:

```bash
git clone https://github.com/dkhandelwal7497/sample-aws-app.git
cd sample-aws-app
```

Initialize Terraform:

```bash
terraform init
```

Review the plan:

```bash
terraform plan
```

Apply the configuration (⚠️ takes ~15–20 minutes):

```bash
terraform apply --auto-approve
```

Update your kubeconfig:

```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```
The cluster name is specified in variables.tf, e.g., eks-observability-platform.

---

## 🔍 Verification

**EKS Cluster**

Check if nodes are running:

```bash
kubectl get nodes
```
✅ Expected: At least 2 nodes in Ready state.

**Demo Services**

Check demo apps:

```bash
kubectl get pods -n demo-apps
kubectl get services -n demo-apps
```
✅ Expected: Services running (nginx, httpbin, simple-web, alpine, etc.).

**Istio Service Mesh**

Check Istio components:

```bash
# Control plane
kubectl get pods -n istio-system

# Ambient ztunnel
kubectl get pods -n istio-system -l app=ztunnel

# Verify Istio
istioctl version
istioctl analyze
```

Test external access:

```bash
kubectl get svc istio-ingressgateway -n istio-system
curl http://<istio-ingress-ip>/status/200
```
✅ Expected: Returns 200 HTTP status.

**Observability Stack**

🟦 Kibana (Logs)

```bash
kubectl get svc -n elk
kubectl port-forward svc/kibana-kibana 5601:5601 -n elk
```
Access: http://localhost:5601

🟧 Tempo (Tracing)

```bash
kubectl get svc -n observability
kubectl port-forward svc/tempo 3200:3200 -n observability
```
Access: http://localhost:3200

🟩 SigNoz (Dashboards/APM)

```bash
kubectl get svc -n observability
kubectl port-forward svc/signoz-frontend-cluster-ip 3301:3301 -n observability
```
Access: http://localhost:3301

➡️ Navigate to Traces to view distributed traces from alpine-deployment.

