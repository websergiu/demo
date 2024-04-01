module "ec2_instance" {
  source                     = "./modules/ec2"
  name                       = local.var.ec2.name
  ami                        = local.var.ec2.ami
  instance_type              = local.var.ec2.instance_type
  monitor                    = local.var.ec2.monitor
  public_ip                  = local.var.ec2.public_ip
  subnet_ids                 = module.vpc.public_subnet_ids #module.vpc.private_subnet_ids
  sg_id                      = module.sg.security_group_id
  root_device_name           = local.var.ec2.root_device_name
  root_volume_type           = local.var.ec2.root_volume_type
  root_volume_size           = local.var.ec2.root_volume_size
  root_delete_on_termination = local.var.ec2.root_delete_on_termination
  user_data                  = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install java-1.8.0-openjdk -y
  sudo sysctl -w vm.max_map_count=262144
  sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
  sudo yum install -y https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.1-x86_64.rpm
  sudo systemctl daemon-reload
  sudo systemctl enable elasticsearch.service
  sudo systemctl start elasticsearch.service
  sudo yum install mysql-client -y
  # Install Docker
  sudo yum install docker -y
  sudo systemctl enable docker.service
  sudo systemctl start docker.service
  # Install Docker Compose (optional, but recommended for managing multi-container Docker applications)
  sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  # Pull and run SonarQube Docker container
  sudo docker pull sonarqube:latest
  sudo docker run -d --name sonarqube --restart always -p 9000:9000 sonarqube:latest
  sudo docker pull blackducksoftware/blackduck-scan:2024.1.1
  sudo docker run -d --name blackduck --restart always -p 8080:8080 blackducksoftware/blackduck-scan:2024.1.1
  # Pull and run Black Duck Docker container (replace 'blackduck_image' with the actual image name)
  # Note: Black Duck requires a license, ensure you have one before running the container
  # sudo docker pull blackduck_image
  # sudo docker run -d --name blackduck -p <PORTS_NEEDED>:<PORTS_NEEDED> blackduck_image
  # Note: You will need to configure Black Duck with the proper settings after it starts up
  EOF
}
