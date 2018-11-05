#!/bin/bash

backenddir=backend
dott=.terraform


# check environmanet
if [[ -v TF_VAR_profile && -v TF_VAR_region ]]
then
        region="$TF_VAR_region"
        profile="$TF_VAR_profile"
else

        echo "set TF_VAR"
        exit 1
fi

dir="$1"

if [[ -z "$1" ]]
then
        echo "usage: command dir"
        exit 1
fi

if [[ "$1" == "backend" ]]
then
        echo "backend can not init "
        exit 1
fi


mkdir -p "$dir"



workspace=$(cd $backenddir || exit ; terraform workspace show 2>/dev/null)
bucket=$(cd $backenddir || exit ;terraform output bucket 2>/dev/null)
dynamodb_table=$(cd $backenddir || exit ;terraform output dynamodb_table 2>/dev/null)


#if [[ "$bucket" == "" || $workspace == "default" || $workspace == "" ]];then
#       echo "setup $backenddir first"
#       exit 1
#fi


if [[ -z "$bucket" ]]
then
        read -p "input bucketname of s3: " -r bucket
        if [[ -z "$bucket" ]]
        then
                echo "no bucket"
                exit 1
        fi
fi


if [[ -z "$workspace" || "$workspace" == "default" ]]
then
        read -p "input name of workspace: " -r workspace
        if [[ -z "$workspace" ]]
        then
                echo "no workspace"
                exit 1
        fi
fi

ln -s ../_common/{tags,provider,data}.tf "$dir"/


cat <<'EOF' > "$dir"/state.tf
terraform {
  backend "s3" {}
}
EOF


cd "$dir" || exit 1

if [[ -e "$dott" ]]
then
 rm -r "$dott"
fi

terraform init \
-backend=true \
-backend-config="bucket=$bucket" \
-backend-config="key=terraform_state" \
-backend-config="region=$region" \
-backend-config="profile=$profile" \
-backend-config="dynamodb_table=$dynamodb_table" \
-backend-config="workspace_key_prefix=$dir"

if ! terraform workspace select "$workspace" > /dev/null 2>&1
then
terraform workspace new "$workspace"
fi
