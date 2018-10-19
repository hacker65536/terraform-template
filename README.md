## configure
cp var file and edit
```console
$ cp _common/TF_VAR_export.sh{_temp,}
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


## first setup remote state
setup backend
```
$ cd backend
$ terraform workspace new prefix_name
$ terraform plan
$ terraform apply
```


## second setup base 

init base
```
$ sh init-backend-config.sh base
$ cd base
$ terraform paln
$ terraform apply
```

## setup other resources group

init
```
$ sh ini-backend-config.sh workers
```
