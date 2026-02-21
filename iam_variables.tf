variable "region_canada" {
  description = "Name of the IAM user"
  type        = string
  default     = "ca-central-1"
}

variable "iam_user_name_dev" {
  description = "Name of the IAM user"
  type        = string
  default     = "Dev_Project_User"
}

variable "iam_user_path" {
  description = "Path for the IAM user"
  type        = string
  default     = "/"
}

variable "iam_user_tags" {
  description = "Tags for IAM user"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "3_tier-architecture"
  }
}

variable "Three_Tier_Application_Policy" {
  description = "Inline policy name"
  type        = string
  default     = "3_Tier_Application_Policy"
}

variable "ec2_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["ec2:*"]
}

variable "s3_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["s3:*"]
}


variable "rds_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["rds:*"]
}

variable "alb_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["elasticloadbalancing:*"]
}

variable "lambda_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["lambda:*"]
}

variable "autoscaling_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["autoscaling:*"]
}

variable "cloud_watch_full_access" {
  description = "List of allowed IAM actions"
  type        = list(string)
  default     = ["cloudwatch:*"]
}

variable "iam_required_access" {
  type = list(string)
  default = [
    "iam:Get*",
    "iam:List*",
    "iam:CreateRole",
    "iam:DeleteRole",
    "iam:AttachRolePolicy",
    "iam:DetachRolePolicy",
    "iam:PassRole",
    "iam:ChangePassword"
  ]
}