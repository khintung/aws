provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "node" {
  count = 2
  ami = "ami-08a28a73"
  instance_type = "t2.micro"
  #instance_type = "t2.nano"
  subnet_id = "subnet-979879ab"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              
              yum install ansible -y

              EOF
  tags { 

     Name = "node-${count.index}"
  }

}


resource "aws_s3_bucket" "terraform_state" {  
  bucket = "khin_terraform_state" 
  versioning { enabled = true  }
  lifecycle {  prevent_destroy = false  }
}
