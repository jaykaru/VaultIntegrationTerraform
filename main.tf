provider "aws" {
  region = "eu-west-2"
}

variable login_approle_role_id {
   default = "fe641da2-2358-58d8-5e8b-cb5e41b94386"

}
variable login_approle_secret_id {
    default = "ee24c1cc-8246-8453-1a57-06b4a9fe479d"
}

provider "vault" {
  address = "http://18.175.133.149:8200"
  skip_child_token = true // Prevents creating a child token as we are authenticating via token
  
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}

resource "aws_instance" "example" {
  ami           = "ami-046c2381f11878233" // Amazon Linux 2 AMI
  instance_type = "t3.micro"

  tags = {
    Name = "VaultIntegratedInstance"
    secret = data.vault_kv_secret_v2.example.data["username"]
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv" // Adjust if your KV engine is mounted at a different path
  name  = "test-secret"
}