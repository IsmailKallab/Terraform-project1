# -----------------------------------------------------------------------------------
# Configure Target Tracking Autoscaling Group
# -----------------------------------------------------------------------------------
/*
 | --
 | -- First Create two Launch Template because we have two different user data 
 | -- for each avialability zone for each instance  
 | -- Secound Create  two Autoscaling Group 
 | -- Third Define  two Target Tracking Policy
 | --
*/


resource "aws_launch_template" "zone1" {
  name = "launch_template_1"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
      volume_type = "gp2"
      encrypted   = true
    }
  }




  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  placement {
    availability_zone = "us-east-1a"
  }



  vpc_security_group_ids = [module.security_group_PS.Private_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "launch_template-1"
    }
  }

  user_data = var.user_data_scripts_base64[0]
}


resource "aws_launch_template" "zone2" {
  name = "launch_template_2"


  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
      volume_type = "gp2"
      encrypted   = true
    }
  }



  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  placement {
    availability_zone = "us-east-1b"
  }



  vpc_security_group_ids = [module.security_group_PS.Private_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "launch_template-2"
    }
  }

  user_data = var.user_data_scripts_base64[1]
}

# configure Auto-scaling-group

resource "aws_autoscaling_group" "ASGS_1" {
  name_prefix               = "ASG1"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.webTG.arn]
  vpc_zone_identifier       = [aws_subnet.private[0].id]

  lifecycle {
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.zone1.id
    version = "$Latest"
  }
  termination_policies = [
    "OldestInstance",
    "OldestLaunchTemplate",
  ]
}

resource "aws_autoscaling_group" "ASGS_2" {
  name_prefix               = "ASG2"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.webTG.arn]

  vpc_zone_identifier = [aws_subnet.private[1].id]
  lifecycle {
    create_before_destroy = true
  }

  launch_template {
    id      = aws_launch_template.zone2.id
    version = "$Latest"
  }
  termination_policies = [
    "OldestInstance",
    "OldestLaunchTemplate",
  ]
}

# Target Tracking Autoscaling Policy 

resource "aws_autoscaling_policy" "TTASGP_1" {

  autoscaling_group_name = aws_autoscaling_group.ASGS_1.name
  name                   = "target_tracking_asgp"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 70
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

  }
}

resource "aws_autoscaling_policy" "TTASGP_2" {

  autoscaling_group_name = aws_autoscaling_group.ASGS_2.name
  name                   = "target_tracking_asgp"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 70
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

  }
}



