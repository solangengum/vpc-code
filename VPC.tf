provider "aws" {
  region = "us-east-2" # Ohio region
}
provider "aws" {
  region = "us-west-2" # Oregon region
  alias  = "oregon"
}
# Define the data source for the existing VPC in Ohio
data "aws_vpc" "existing_vpc" {
  provider = aws
  id       = "vpc-0033e38e20d15d6c1" 
}
# Create the disaster recovery (DR) VPC in Oregon
resource "aws_vpc" "dev-vpc" {
  provider   = aws.oregon
  cidr_block = data.aws_vpc.existing_vpc.cidr_block
  tags = {
    Name = "DR_dev_VPC"
  }
}
# Create Subnets in the Oregon region

resource "aws_subnet" "dev-tgw-subnet-2b" {
    provider = aws.oregon
    cidr_block          = "10.2.112.0/24" 
    vpc_id              = aws_vpc.dev-vpc.id
    availability_zone   = "us-west-2b" 
    tags = {
        Name = "dev-tgw-subnet-2b"
    }
  
}

resource "aws_subnet" "dev-private-be-subnet-2b" {
    provider = aws.oregon
    cidr_block          = "10.2.31.0/24" # Replace with your desired CIDR block
    vpc_id              = aws_vpc.dev-vpc.id
    availability_zone   = "us-west-2b" # Replace with your desired AZ in Oregon
    tags = {
        Name = "dev-private-be-subnet-2b"
    }
  
}

resource "aws_subnet" "dev-private-mid-subnet-2a" {
    provider = aws.oregon
    cidr_block          = "10.2.20.0/24" # Replace with your desired CIDR block
    vpc_id              = aws_vpc.dev-vpc.id
    availability_zone   = "us-west-2a" # Replace with your desired AZ in Oregon
    tags = {
        Name = "dev-private-mid-subnet-2a"
    }
  
}

resource "aws_subnet" "dev-private-fe-subnet-2a" {
    provider = aws.oregon
    cidr_block          = "10.2.10.0/24" # Replace with your desired CIDR block
    vpc_id              = aws_vpc.dev-vpc.id
    availability_zone   = "us-west-2a" # Replace with your desired AZ in Oregon
    tags = {
        Name = "dev-private-fe-subnet-2a"
    }
  
}

resource "aws_subnet" "dev-tgw-subnet-2a" {
    provider = aws.oregon
    cidr_block          = "10.2.111.0/24" # Replace with your desired CIDR block
    vpc_id              = aws_vpc.dev-vpc.id
    availability_zone   = "us-west-2a" # Replace with your desired AZ in Oregon
    tags = {
        Name = "dev-tgw-subnet-2a"
    }
  
}   

resource "aws_subnet" "dev-private-be-subnet-2a" {
    provider = aws.oregon
    cidr_block          = "10.2.30.0/24" # Replace with your desired CIDR block
    vpc_id              = aws_vpc.dev-vpc.id
    availability_zone   = "us-west-2a" # Replace with your desired AZ in Oregon
    tags = {
        Name = "dev-private-be-subnet-2a"
    }
  
} 

resource "aws_subnet" "dev-public-subnet-2a" {
  provider            = aws.oregon
  cidr_block          = "10.2.0.0/24" # Replace with your desired CIDR block
  vpc_id              = aws_vpc.dev-vpc.id
  availability_zone   = "us-west-2a" # Replace with your desired AZ in Oregon
  tags = {
    Name ="dev-public-subnet-2a"
  }
}

resource "aws_route_table" "dev-public-rt" {
  provider    = aws.oregon
  vpc_id      = aws_vpc.dev-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id # Replace with the Internet Gateway ID attached to the Oregon VPC
  }
  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_internet_gateway" "dev-igw" {
  provider = aws.oregon
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-igw"
  }
}

resource "aws_eip" "dev-natgw-pub-2a" {
  provider = aws.oregon
  vpc = true
  tags = {
    Name = "dev-nat-gw-public-2a"
  }
}

resource "aws_vpc_endpoint" "dev-files2-sftp-endpoint" {
  provider             = aws.oregon
  vpc_id               = aws_vpc.dev-vpc.id
  service_name         = "com.amazonaws.us-west-2.s3" # Replace with the service name of your VPC endpoint in Ohio
  vpc_endpoint_type    = "Gateway" # Replace with the VPC endpoint type (Gateway, Interface, etc.)
  # security_group_ids = [aws_security_group.sg_dev_files_sftp_oregon.id]
  # subnet_ids         = [aws_subnet.dev-public-subnet-2a.id]
  tags = {
    Name = "dev-files2-sftp-endpoint"
  }
}

resource "aws_nat_gateway" "dev-natgw-pub-2a" {
  provider       = aws.oregon
  allocation_id  = aws_eip.dev-natgw-pub-2a.id # Replace with the Elastic IP ID associated with the Ohio NAT Gateway
  subnet_id      = aws_subnet.dev-public-subnet-2a.id
  tags = {
    Name = "dev-natgw-pub-2a"
  }
}

resource "aws_security_group" "sg_default_oregon" {
  provider = aws.oregon
  name     = "Default VPC security group"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-api-sg"
  }
}
resource "aws_security_group" "sg_dev_smtp_oregon" {
  provider = aws.oregon
  name     = "Allow SMTP traffic to dev VPC Endpoint"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-smtp-endpoint-sg"
  }
}
resource "aws_security_group" "sg_dev_files_sftp_oregon" {
  provider = aws.oregon
  name     = "Allow SFTP access to files2.cambr.com"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-files2-sftp-endpoint-sg"
  }
}
resource "aws_security_group" "sg_dev_ui_oregon" {
  provider = aws.oregon
  name     = "Access for dev UI server"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-ui-sg"
  }
}
resource "aws_security_group" "sg_dev_cambrdb_oregon" {
  provider = aws.oregon
  name     = "Created by RDS management console"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-rds-sg"
  }
}
resource "aws_security_group" "sg_dev_api_oregon" {
  provider = aws.oregon
  name     = "Access for dev API server"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-api-sg"
  }
}
resource "aws_security_group" "sg_dev_rundeck_oregon" {
  provider = aws.oregon
  name     = "Dev Rundeck Security Group"
  vpc_id   = aws_vpc.dev-vpc.id
  tags = {
    Name = "dev-rundeck-sg"
  }
}
# Import security group rules to the Oregon region for the default security group
resource "aws_security_group_rule" "sg_default_import" {
  provider = aws.oregon
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  security_group_id = aws_security_group.sg_default_oregon.id
  cidr_blocks = ["0.0.0.0/0"]  
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_network_interface" "dev_network_interface_1_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-tgw-subnet-2b.id
  security_groups    = [aws_security_group.sg_dev_cambrdb_oregon.id]
}

resource "aws_network_interface" "dev_network_interface_2_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-tgw-subnet-2b.id
}

resource "aws_network_interface" "dev_network_interface_3_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-private-be-subnet-2a.id
  security_groups    = [aws_security_group.sg_dev_cambrdb_oregon.id] 
}

resource "aws_network_interface" "dev_network_interface_4_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-private-fe-subnet-2a.id
  security_groups    = [aws_security_group.sg_dev_api_oregon.id] 
}
resource "aws_network_interface" "dev_network_interface_5_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-public-subnet-2a.id
  tags = {
    Name = "dev-nat-gw-public-2a-nic-10.2.0.165"
  }
}

resource "aws_network_interface" "dev_network_interface_6_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-private-be-subnet-2a.id
  security_groups    = [aws_security_group.sg_dev_cambrdb_oregon.id] 
}

resource "aws_network_interface" "dev_network_interface_7_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-tgw-subnet-2a.id
}

resource "aws_network_interface" "dev_network_interface_8_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-private-fe-subnet-2a.id
  security_groups    = [aws_security_group.sg_dev_ui_oregon.id] 
}

resource "aws_network_interface" "dev_network_interface_9_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-private-mid-subnet-2a.id
  security_groups    = [aws_security_group.sg_dev_rundeck_oregon.id] 
}

resource "aws_network_interface" "dev_network_interface_10_oregon" {
  provider           = aws.oregon
  subnet_id          = aws_subnet.dev-public-subnet-2a.id
  security_groups    = [aws_security_group.sg_dev_files_sftp_oregon.id] 
  tags = {
    Name = "files2.cambr.com"
  }
}