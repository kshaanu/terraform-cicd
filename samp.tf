provider "aws" {
    region = "us-east-1"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
  }
  resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "tfvpc"
  }
}
resource "aws_subnet" "sub1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "tfsub1"
    }  
}
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}
resource "aws_route_table_association" "ra" {
  subnet_id      = "${aws_subnet.sub1.id}"
  route_table_id = "${aws_route_table.r.id}"
} 

resource "aws_security_group" "sg" {
  name        = "sg1"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks  =  ["0.0.0.0/0"]
  }
}
resource "aws_instance" "inst1" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.sub1.id}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  key_name = "key"
  tags = {
    Name = "awsins"
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("./key.pem")}"
    host     = "${aws_instance.inst1.public_ip}"
  }
  provisioner "remote-exec" {
      inline = [
      "ansible-playbook ansjenk.yml"
      ]
  }
}
    


