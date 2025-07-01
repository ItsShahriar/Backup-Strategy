provider "aws" {
  alias   = "central"
  region  = var.region
}

provider "aws" {
  alias   = "workload"
  region  = var.region
}