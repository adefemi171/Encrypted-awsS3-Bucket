// Creating a Terraform Template
// tpl: Template file format
data "template_file" "encrypted_bucket_s_three"{
    template = "${file("s3_bucket.json.tpl")}"
    vars {
        encrypted_bucket         = "${aws_s3_bucket.encrypted_bucket.bucket}"
    }
}
provider "aws"{
    region                  = "us-east-1"
}

// Specifying my KMS key
resource "aws_kms_key" "kms_encrypt" {
  description               = "KMS key 1"
  deletion_window_in_days   = 7
}

// Specifying my AWS S3 Bucket
resource "aws_s3_bucket" "encrypted_bucket"{
    bucket                  = "encrypted-s3-bucket-femi"
    acl                     = "private"
    // encrypt     = true
    versioning{
        enabled             = true
    }
    tags {
        Name                = "An Encrypted S3 Bucket"
    }
    // Specifying LifeCycle Using Expiration
    lifecycle_rule {
        enabled             = true

        expiration {
            date            = "2019-06-03"
    }

  }
}

// Encrypting with KMS Key
resource "aws_s3_bucket_object" "encrypted_bucket_object" {
    key                     = "new_object"
    bucket                  = "${aws_s3_bucket.encrypted_bucket.id}"
    source                  = "index.html"
    kms_key_id              = "${aws_kms_key.kms_encrypt.arn}"
}

// Creating an IAM Policy
//     policy = "${data.template_file.cloud-trail-logs-s3-readonly.rendered}"

resource "aws_iam_policy" "encrypted-bucket-s-three" {
    name                    = "encrypted-s-three-policy"
    path                    = "/"
    description             = "Acess to Encypted S3 Buckets"
    policy                  = "${data.template_file.encrypted_bucket_s_three.rendered}"
}
