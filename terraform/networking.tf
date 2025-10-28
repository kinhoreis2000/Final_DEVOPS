resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main_a" {
  subnet_id      = aws_subnet.main_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "main_b" {
  subnet_id      = aws_subnet.main_b.id
  route_table_id = aws_route_table.main.id
}

# --- BLOCO MODIFICADO (Versão Insegura) ---
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow web and internal traffic"
  vpc_id      = aws_vpc.main.id

  # REGRA ADICIONADA: Permite comunicação interna
  # Isso permite que o Controller e os Agentes (no mesmo SG) 
  # se comuniquem em qualquer porta (Ex: JNLP 50000 ou SSH interno).
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Regra HTTP (Porta 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra SSH (Porta 22) - ABERTA PARA O MUNDO
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <-- ALTERADO AQUI (PERIGOSO)
  }

  # Regra Jenkins UI (Porta 8080) - ABERTA PARA O MUNDO
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <-- ALTERADO AQUI (PERIGOSO)
  }

  # Regra de Saída (Permite tudo)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# --- FIM DO BLOCO MODIFICADO ---

resource "aws_subnet" "main_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "main_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}