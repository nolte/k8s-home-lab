

resource "minio_s3_bucket" "state_terraform_s3" {
  bucket = "terraform-state"
  acl    = "private"
}



resource "minio_iam_group" "tf_svcs" {
  name = "tf-service-accounts"
}
resource "minio_iam_user" "svc_tf_argo" {
  name = "svc-tf-argo"
}


locals {
  secrets_engine = "secrets-tf"
}

resource "vault_generic_secret" "svc_tf_argo" {
  path = format("%s/services/s3/users/svc-tf-argo", local.secrets_engine)

  data_json = <<EOT
{
  "accesskey":   "${minio_iam_user.svc_tf_argo.name}",
  "secretkey":   "${minio_iam_user.svc_tf_argo.secret}"
}
EOT
}


resource "minio_iam_user" "svc_tf_operator" {
  name = "svc-tf-operator"
}

resource "vault_generic_secret" "svc_tf_operator" {
  path = format("%s/services/s3/users/svc-tf-operator", local.secrets_engine)

  data_json = <<EOT
{
  "accesskey":   "${minio_iam_user.svc_tf_operator.name}",
  "secretkey":   "${minio_iam_user.svc_tf_operator.secret}"
}
EOT
}

resource "minio_iam_group_user_attachment" "tf_svcs_argo" {
  group_name = minio_iam_group.tf_svcs.name
  user_name  = minio_iam_user.svc_tf_argo.name
}

resource "minio_iam_group_user_attachment" "tf_svcs_operator" {
  group_name = minio_iam_group.tf_svcs.name
  user_name  = minio_iam_user.svc_tf_operator.name
}

data "minio_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      format("arn:aws:s3:::%s", minio_s3_bucket.state_terraform_s3.bucket),
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
      ]
    }
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      format("arn:aws:s3:::%s", minio_s3_bucket.state_terraform_s3.bucket),
      format("arn:aws:s3:::%s/*", minio_s3_bucket.state_terraform_s3.bucket),
    ]
  }
}
resource "minio_iam_policy" "test_policy" {
  name   = "state-terraform-s3"
  policy = data.minio_iam_policy_document.example.json

}

resource "minio_iam_group_policy_attachment" "developer" {
  group_name  = minio_iam_group.tf_svcs.name
  policy_name = minio_iam_policy.test_policy.id
}
