provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP Server"
  default = 8080
}


resource "aws_security_group" "instance" {  
  name = "terraform-example-instance"
  ingress { from_port = "${var.server_port}"
            to_port   = "${var.server_port}"
            protocol  = "tcp"
            cidr_blocks = ["0.0.0.0/0"]  }
}

resource "aws_instance" "node" {
  count = 2
  ami = "ami-08a28a73"
  instance_type = "t2.micro"
  #instance_type = "t2.nano"
  subnet_id = "subnet-979879ab"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              yum install busybox -y

              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &

              yum install ansible -y

              EOF
  tags { Name = "node-${count.index}" }
}

resource "aws_s3_bucket" "terraform_state" {  
  bucket = "khin_terraform_state" 
  versioning { enabled = true  }
  lifecycle {  prevent_destroy = false  }
}
