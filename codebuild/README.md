# codebuild

## import (before apply)

https://docs.aws.amazon.com/cli/latest/reference/codebuild/import-source-credentials.html

```console
$ aws codebuild import-source-credentials --token <TOKEN> --server-type GITHUB --auth-type PERSONAL_ACCESS_TOKEN
```



## list and delete

```console
$ aws codebuild list-source-credentials
```

```console
$ aws codebuild delete-source-credentials --arn arn:aws:codebuild:us-east-1:000000000000:token/github
```
