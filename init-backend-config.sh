#!/bin/bash

backenddir=backend
region=$TF_VAR_region
profile=$TF_VAR_profile
dir=$1

if [[ -z $1 ]];then
	echo "usage: command dir"
	exit 1
fi


mkdir -p $1



workspace=$(cd $backenddir; terraform workspace show 2>/dev/null)
bucket=$(cd $backenddir;terraform output bucketname 2>/dev/null)


if [[ "$bucket" == "" || $workspace == "default" || $workspace == "" ]];then
	echo "setup $backenddir first"
	exit 1
fi

ln -s ../_common/{tags,provider,data}.tf $dir/


cat <<'EOF' > $dir/state.tf
terraform {
  backend "s3" {}
}
EOF


cd $dir;

terraform init \
-backend=true \
-backend-config="bucket=$bucket" \
-backend-config="key=terraform_state" \
-backend-config="region=$region" \
-backend-config="profile=$profile" \
-backend-config="workspace_key_prefix=$dir"


terraform workspace new $workspace
