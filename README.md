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
git clone <your-repo-url>
cd <your-repo-url>
