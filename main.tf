# Look up the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create subnets in two different availability zones
resource "aws_subnet" "public_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.${16 + count.index}.0/20"
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index}"
  }
}

# Create subnets in two different availability zones
resource "aws_subnet" "private_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.${32 + count.index}.0/20"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "eks-private-subnet-${count.index}"
  }
}

# Create the EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = var.cluster_name
  cluster_version = "1.26"

  vpc_id                   = data.aws_vpc.default.id
  subnet_ids               = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
  control_plane_subnet_ids = aws_subnet.public_subnet[*].id

  eks_managed_node_groups = {
    default = {
      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size
      instance_types = [var.node_group_instance_type]
      create_iam_role = true
      launch_template = {
        name = "eks-node-template"
      }
    }
  }
}

# Get cluster details to configure the Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Install Istio with Ambient profile using Helm
resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = "istio-system"
  create_namespace = true
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.18.0"
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.18.0"
  depends_on = [helm_release.istio_base]
  values = [
    yamlencode({
      meshConfig = {
        defaultConfig = {
          # Use ambient profile
          interceptionMode = "NONE"
        }
      }
      profile = "ambient"
    })
  ]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.18.0"
  depends_on = [helm_release.istiod]
}

# Install Elasticsearch and Kibana using Helm
resource "helm_release" "elk" {
  name       = "elk-stack"
  namespace  = "elk"
  create_namespace = true
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.17.1"
  values = [
    yamlencode({
      replicas = 1
      clusterName = "elk-cluster"
      service = {
        type = "ClusterIP"
      }
    })
  ]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = "elk"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.17.1"
  depends_on = [helm_release.elk]
  values = [
    yamlencode({
      elasticsearchHosts = "http://elk-stack-elasticsearch-master:9200"
      service = {
        type = "ClusterIP"
      }
    })
  ]
}

# Install Tempo using Helm
resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = "observability"
  create_namespace = true
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.4.2"
}

# Install SigNoz using Helm
resource "helm_release" "signoz" {
  name       = "signoz"
  namespace  = "observability"
  repository = "https://charts.signoz.io"
  chart      = "signoz"
  version    = "0.22.0"
  depends_on = [helm_release.tempo]
}

# Apply Kubernetes manifests for demo applications
resource "null_resource" "kubectl_apply" {
  provisioner "local-exec" {
    command = "kubectl apply -f demo-apps.yaml -f istio-gateway.yaml"
    environment = {
      KUBECONFIG = "~/.kube/config"
    }
  }
  depends_on = [helm_release.istio_ingress, helm_release.signoz]
}
