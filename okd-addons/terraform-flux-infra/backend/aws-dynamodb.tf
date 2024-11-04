data "aws_iam_user" "terraform" {
  user_name = "terraform"
}

data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    actions   = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem"
    ] 
    resources = [ "arn:aws:dynamodb:ca-central-1:871013608522:table/terraform-flux-infra-tfstate" ]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb-policy-flux-infra"
  description = "Access to DynamoDB with this account"
  policy      = data.aws_iam_policy_document.dynamodb_policy.json
}

resource "aws_iam_user_policy_attachment" "terraform_user_policy_attachment" {
  user        = data.aws_iam_user.terraform.user_name
  policy_arn  = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_dynamodb_table" "terraform-state" {
  name            = "terraform-flux-infra-tfstate"
  read_capacity   = 20
  write_capacity  = 20
  hash_key        = "LockID"

  attribute {
    name          = "LockID"
    type          = "S"
  }
}
