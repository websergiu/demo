resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}




resource "aws_iam_policy" "ecs_secrets" {
  name        = "EcsSecretsPolicy"
  path        = "/"
  description = "Allow ECS tasks to access secrets in Secrets Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": "${var.secret_manager_db_arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets.arn
}





resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "example" {
  name = var.name
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.example.name

  capacity_providers = var.capacity_providers

  default_capacity_provider_strategy {
    base              = var.base
    weight            = var.weight
    capacity_provider = var.capacity_provider
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.family
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "nginx_http"
      image     = "839287169874.dkr.ecr.us-east-1.amazonaws.com/ecrnew-intakt-oradea:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],

      environment = [
        {
          name = "DB_HOST"
          #          value = aws_db_instance.default.address
          value = var.db_address
        },
        {
          name  = "DB_USER"
          value = var.username
        },
        {
          name  = "DB_PASS"
          value = var.password
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      },
      secrets = [
        {
          name = "DB_PASSWORD",
          #          valueFrom = "arn:aws:secretsmanager:region:account-id:secret:secret-name-1a2b3c"
          valueFrom = var.secret_manager_db_arn
        }
      ]
    },
  ])


}

resource "aws_ecs_service" "example" {
  name            = "example"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 2

  enable_execute_command = true


  network_configuration {
    assign_public_ip = var.assign_public_ip
    security_groups  = ["${var.sg_id}"]
    subnets          = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "nginx_http"
    container_port   = 80
  }

}


resource "aws_lb" "example" {
  name               = "intakt-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.sg_id}"]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "intakt-lb"
  }
}

resource "aws_lb_target_group" "example" {
  name        = "example"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" #target type ip or instance - preferable ip

  health_check {
    enabled  = true
    interval = 30
    path     = "/"
    timeout  = 3
  }
}


resource "aws_cloudwatch_log_group" "app" {
  name = "/aws/ecs/app"
}



resource "aws_cognito_user_pool" "main" {
  name = "my_user_pool"

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "email"
    required            = true

    string_attribute_constraints {
      min_length = 7
      max_length = 254
    }
  }
}


resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    #client_id        = #"231487993575-69pkllrdsmdjap2f0rg9086a13oph418.apps.googleusercontent.com"
    #client_secret    = #"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"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}



resource "aws_cognito_user_pool_client" "client" {
  name                                 = "user_pool_client_name"
  user_pool_id                         = aws_cognito_user_pool.main.id
  generate_secret                      = true
  explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  #  allowed_oauth_scopes                 = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  #  allowed_oauth_scopes                 = ["openid", "https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo"]
  callback_urls = ["https://${aws_lb.example.dns_name}/oauth2/idpresponse"]
  supported_identity_providers = ["COGNITO", "Google"]
}



resource "aws_cognito_user_pool_domain" "main" {
  domain       = "sergiu-oradea-test"
  user_pool_id = aws_cognito_user_pool.main.id
}
#
#
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Specify the appropriate SSL policy
  certificate_arn   = "arn:aws:acm:us-east-1:839287169874:certificate/6bb61399-39be-4028-a66f-7d6b41aef4b7"

  default_action {
    type = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.main.arn
      user_pool_client_id = aws_cognito_user_pool_client.client.id
      user_pool_domain    = aws_cognito_user_pool_domain.main.domain
      #      user_pool_client_id = aws_cognito_identity_provider.google.id
      #      user_pool_domain    = aws_cognito_user_pool_domain.main.domain
    }
    order = 1
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
    order            = 2
  }
}

