# woro-s3

Adapter for [Woro remote task management](https://github.com/github/woro)
for using Amazons's S3 to share them with colleagues.

## Usage

On initialization of a new project, you can choose and setup S3-configuration with:

```shell
$ woro init
```

If you already have a configuration, you can add these lines to you `lib/config/woro.yml`

```yaml
adapters:
  s3:
    region: eu-west-1
    bucket_name: <bucket name>
    path: <path within bucket>
    access_key_id: <access key id>
    secret_access_key: <secret access key>
```

Use `s3` as adapter to upload your task to.

```shell
$ woro push s3:cleanup_users
```

_Attention, depending on the properties of the specified S3 bucket, the rake tasks may be public._

Now, to run a task remotely using Mina, specify the task:

```shell
$ mina woro:run task=s3:cleanup_users
```

Or to run it with Capistrano:

```shell
$ cap woro:run task=s3:cleanup_users
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
