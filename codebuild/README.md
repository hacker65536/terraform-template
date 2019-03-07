# codebuild

## credential

### import (before apply)

https://docs.aws.amazon.com/cli/latest/reference/codebuild/import-source-credentials.html

```console
$ aws codebuild import-source-credentials --token <TOKEN> --server-type GITHUB --auth-type PERSONAL_ACCESS_TOKEN
```

### list and delete

```console
$ aws codebuild list-source-credentials
```

```console
$ aws codebuild delete-source-credentials --arn arn:aws:codebuild:us-east-1:000000000000:token/github
```


## webhook


https://docs.aws.amazon.com/ja_jp/codebuild/latest/APIReference/API_CreateWebhook.html

require `aws-cli/1.16.119`

```json
{
  "projectName": "amibld-codebuild",
  "filterGroups": [
    [
      {
        "type": "EVENT",
        "pattern": "PULL_REQUEST_CREATED"
      },
      {
        "type": "ACTOR_ACCOUNT_ID",
        "pattern": "hacker65536"
      }
    ]
  ]
}
```

filterGroups or branchFilter


```console
$ aws codebuild update-webhook --cli-input-json file://./webhook.json
{
    "webhook": {
        "filterGroups": [
            [
                {
                    "pattern": "PULL_REQUEST_CREATED",
                    "type": "EVENT"
                },
                {
                    "pattern": "hacker65536",
                    "type": "ACTOR_ACCOUNT_ID"
                }
            ]
        ],
        "lastModifiedSecret": 1551779898.786
    }
}
```
