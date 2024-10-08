resource "aws_appautoscaling_target" "gymcoach_asg_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.gymcoach_ecs_cluster.name}/${aws_ecs_service.gymcoach_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "gymcoach_asg_policy__scale_up" {
  name               = "scale-out"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gymcoach_asg_target.id
  scalable_dimension = aws_appautoscaling_target.gymcoach_asg_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.gymcoach_asg_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_out_cooldown = 60
    scale_in_cooldown  = 60
  }
}
