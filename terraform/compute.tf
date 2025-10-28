resource "aws_instance" "web1" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t2.micro"
  subnet_id     = aws_subnet.main_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  tags = {
    Name = "Production 1 Ticatactoe"
  }
}

resource "aws_instance" "web2" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t2.micro"
  subnet_id     = aws_subnet.main_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  tags = {
    Name = "Production 2 Ticatactoe"
  }
}

resource "aws_instance" "web3" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t2.micro"
  subnet_id     = aws_subnet.main_b.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  tags = {
    Name = "Staging Tictacoe"
  }
}

resource "aws_instance" "web4" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t2.micro"
  subnet_id     = aws_subnet.main_b.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  tags = {
    Name = "Testing Tictacoe"
  }
}

resource "aws_instance" "jenkins" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t3.medium"
  subnet_id     = aws_subnet.main_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  user_data       = file("../scripts/jenkins_install.sh")
  tags = {
    Name = "JenkinsController"
  }
}

resource "aws_instance" "jenkinsPermanentAgent" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t2.micro"
  subnet_id     = aws_subnet.main_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  user_data       = file("../scripts/jenkins_install.sh")
  tags = {
    Name = "JenkinsPermanentAgent"
  }
}

resource "aws_instance" "jenkinsDynamicAgent" {
  ami             = "ami-0440d3b780d96b29d"
  instance_type   = "t2.micro"
  subnet_id     = aws_subnet.main_a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  user_data       = file("../scripts/jenkins_install.sh")
  tags = {
    Name = "JenkinsDynamicAgent"
  }
}

