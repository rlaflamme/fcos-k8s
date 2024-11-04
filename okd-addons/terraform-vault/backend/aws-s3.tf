resource "aws_kms_key" "terraform-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-bucket-key-1"
  target_key_id = aws_kms_key.terraform-bucket-key.key_id
}


resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_tfstate" {
  bucket = aws_s3_bucket.terraform_tfstate.id

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
        sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket" "terraform_tfstate" {
  bucket = "terraform-okd4-tfstate"
}

resource "aws_s3_bucket_acl" "terraform_tfstate" {
  bucket = aws_s3_bucket.terraform_tfstate.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.terraform_tfstate]
}


resource "aws_s3_bucket_versioning" "terraform_tfstate" {
  bucket = aws_s3_bucket.terraform_tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform_tfstate" {
  bucket = aws_s3_bucket.terraform_tfstate.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.terraform_tfstate.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::871013608522:user/terraform"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      aws_s3_bucket.terraform_tfstate.arn,
      "${aws_s3_bucket.terraform_tfstate.arn}/*"
    ]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::871013608522:user/terraform"]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_tfstate.arn,
    ]
  }
}
