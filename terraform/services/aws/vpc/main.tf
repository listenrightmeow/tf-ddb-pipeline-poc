variable "availability_zones" {}

# NOTE: 65.534k hosts
variable "cidr" {
  type = "map"
  default = {
    development = "172.16.0.0/16"
    test = "172.17.0.0/16"
    staging = "172.18.0.0/16"
    production = "172.19.0.0/16"
  }
}

# NOTE: NAT access
variable "private" {
  type = "map"
  default = {
    development = "172.16.1.0/24,172.16.2.0/24,172.16.3.0/24"
    test = "172.17.1.0/24,172.17.2.0/24,172.17.3.0/24"
    staging = "172.18.1.0/24,172.18.2.0/24,172.18.3.0/24"
    production = "172.19.1.0/24,172.19.2.0/24,172.19.3.0/24"
  }
}

# NOTE: VPN access
variable "public" {
  type = "map"
  default = {
    development = "172.16.101.0/24,172.16.102.0/24,172.16.103.0/24"
    test = "172.17.101.0/24,172.17.102.0/24,172.17.103.0/24"
    staging = "172.18.101.0/24,172.18.102.0/24,172.18.103.0/24"
    production = "172.19.101.0/24,172.19.102.0/24,172.19.103.0/24"
  }
}

# NOTE: AWS egress only
variable "intra" {
  type = "map"
  default = {
    development = "172.16.201.0/24,172.16.202.0/24,172.16.203.0/24"
    test = "172.17.201.0/24,172.17.202.0/24,172.17.203.0/24"
    staging = "172.18.201.0/24,172.18.202.0/24,172.18.203.0/24"
    production = "172.19.201.0/24,172.19.202.0/24,172.19.203.0/24"
  }
}

locals {
  environment = "${terraform.workspace == "master" ? "production" : terraform.workspace}"
}

resource "aws_eip" "nat" {
  count = 3
  vpc = true

  tags {
    Name = "${local.environment}-nat"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.40.0"

  cidr = "${var.cidr[local.environment]}"
  azs = ["${split(",", var.availability_zones)}"]

  enable_nat_gateway = true
  single_nat_gateway = false
  reuse_nat_ips = true
  one_nat_gateway_per_az = false

  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]

  enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_dns_support = true

  enable_dhcp_options = true

  private_subnets = ["${split(",", var.private[local.environment])}"]
  public_subnets = ["${split(",", var.public[local.environment])}"]
  intra_subnets = ["${split(",", var.intra[local.environment])}"]

  tags = { "env" = "${local.environment}" }
}

module "security" {
  source ="./security"
  vpc_id = "${module.vpc.vpc_id}"
}

# EXPORTS

output "intra_subnets" {
  value = "${module.vpc.intra_subnets}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "intra_subnets_cidr_blocks" {
  value = "${module.vpc.intra_subnets_cidr_blocks}"
}

output "private_subnets_cidr_blocks" {
  value = "${module.vpc.private_subnets_cidr_blocks}"
}

output "public_subnets_cidr_blocks" {
  value = "${module.vpc.public_subnets_cidr_blocks}"
}

output "security_group_internet" {
  value = "${module.security.internet}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
