export AWS_ACCESS_KEY=$(vault kv get -field aws_access_key kv/aws/root)
export AWS_SECRET_ACCESS_KEY=$(vault kv get -field aws_secret_access_key kv/aws/root)
