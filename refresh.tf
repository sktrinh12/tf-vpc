resource "null_resource" "refresh_autoscale" {
  provisioner "local-exec" {
    command = "cd ${path.module}/scripts ; bash ./scale_refresh.sh"
    environment = {
      ASG_NAME        = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
      CLUSTER_NAME    = "${var.name}-knte-k8s-cluster"
      NODE_GROUP_NAME = "${var.name}-k8s-node-group"
      REGION          = var.region
      AWS_PROFILE     = var.aws_profile
      DESIRED_SIZE    = var.desired_size
      MIN_SIZE        = var.min_size
      MAX_SIZE        = var.max_size
    }
  }

  depends_on = [aws_eks_node_group.main]
}
