
#Security-group

resource "aws_security_group" "sg" {
  name   = "Devops-workflow-sg"
  vpc_id = aws_vpc.main.id

  ingress{
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress  = []
}

#Ec2-Creation

resource "aws_instance" "ins" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t2.large"
  key_name = "backend"
  root_block_device{
    volume_size = 70
    volume_type = "gp3"
    delete_on_termination = true
  }
  tags = {
    Name = "Devops-workflow-trail"
  }
}
