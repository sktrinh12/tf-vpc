resource "aws_iam_role" "eks_cluster" {
  name = "${var.name}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.name}-knte-k8s-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  version = var.k8s_version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.private_subnets[0].id,
      aws_subnet.private_subnets[1].id,
      aws_subnet.private_subnets[2].id,
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  ]
}

resource "aws_iam_role" "nodes_eks" {
  name               = "role-node-group-eks"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }, 
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes_eks.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_eks.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_eks.name
}


resource "aws_eks_node_group" "nodes_eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.name}-k8s-node-group"
  node_role_arn   = aws_iam_role.nodes_eks.arn
  subnet_ids = [
    aws_subnet.private_subnets[0].id,
    aws_subnet.private_subnets[1].id,
    aws_subnet.private_subnets[2].id,
  ]
  remote_access {
    ec2_ssh_key = "eks-apps-sandbox"
  }

  scaling_config {
    desired_size = 2
    max_size     = 6
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = 30
  instance_types = [var.instance_type]
  labels = {
    role = "nodes-group-1"
  }

  version = var.k8s_version

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_eks,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_eks,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}

resource "aws_autoscaling_group_tag" "asg_tag" {
  autoscaling_group_name = aws_eks_node_group.nodes_eks.resources[0].autoscaling_groups[0].name

  tag {
    key   = "Name"
    value = "${var.name}-k8s-node-group"

    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.nodes_eks
  ]
}
