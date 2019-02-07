## configure
edit environment variables
```console
$ cp _common/{tmp_,}TF_VAR_export.sh
```

```console
$ vim _common/TF_VAR_export.sh
```


set environment variables
```console
$ $(cat _common/TF_VAR_export.sh)
```
or

```console
$ source _common/TF_VAR_export.sh
```


## setup remote state

if set up it before skip this section.  

setup backend
```
$ prefix=<workspace_prefix>
$ cd backend
$ terraform workspace new $prefix
$ terraform init
$ terraform plan
$ terraform apply
$ cd ..
```


## second setup base 

init base
```console
$ sh init-backend-config.sh base
$ cd base
```

create key_pair if doesn't already exists
```console 
$ cd
$ mkdir -p ~/keyfiles 
$ cd ~/keyfiles && ssh-keygen -t rsa -N "" -f ${prefix}_key_pair -C "" && cd -
```
copy file to the directory
```console
$ cp ~/keyfiles/${prefix}_key_pair.pub ./key_pair.pub
```

set ip you want to allow to access
```console
$ vim var_secips.tf
```
or
```console
$ cp var_secips{,_override}.tf
$ vim var_secips_override.tf
```

```console
$ terraform paln
$ terraform apply
```

## setup other resources group

init
```
$ sh ini-backend-config.sh workers
```
