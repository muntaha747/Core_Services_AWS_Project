#######################################################################################
#CREATE REGION
#######################################################################################
provider "aws" {
  region = var.region_canada
}

#######################################################################################
#CREATE IAM USER NAME
#######################################################################################

resource "aws_iam_user" "dev_iam_user" {
  name = var.iam_user_name_dev
  path = "/"

  tags = {
    tag-key = "dev_iam_user"
  }
}

#######################################################################################
#CREATED IAM ACCESS KEY
#######################################################################################

resource "aws_iam_access_key" "dev_user_access_key" {
  user = aws_iam_user.dev_iam_user.name
}

#######################################################################################
#IAM CONSOLE LOGIN PROFILE
#######################################################################################

resource "aws_iam_user_login_profile" "dev_login" {
  user                    = aws_iam_user.dev_iam_user.name
  password_reset_required = true
}


#######################################################################################
#CREATED IAM POLICY DOCUMENT.
#######################################################################################

data "aws_iam_policy_document" "dev_iam_policy" {
  statement {
    effect = "Allow"
    actions = concat(var.ec2_full_access, var.s3_full_access,
    var.rds_full_access, var.alb_full_access, var.lambda_full_access, var.autoscaling_full_access, var.cloud_watch_full_access, var.iam_required_access)
    resources = ["*"]
  }
}

#######################################################################################
#MANAGED IAM POLICY.
#######################################################################################

resource "aws_iam_user_policy" "devops_iam_policy" {
  name   = "3_tier_architecture"
  user   = aws_iam_user.dev_iam_user.name
  policy = data.aws_iam_policy_document.dev_iam_policy.json
}

