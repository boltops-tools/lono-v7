<div align="center">
  <img src="http://lono.cloud/img/logos/lono-logo-small.png" />
</div>

# Lono

![CodeBuild](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiaHF3Y2pqSVBlZ0JMdXhPL010bTI2cVd6SkpHQWlLRkJ5SHlCcDFueUtHVFNCVFZyWEVZd01yWDZ1VjZCRjNVQ1F4d2JlTlJOWDRtU3R3NkJzVkJKSHJ3PSIsIml2UGFyYW1ldGVyU3BlYyI6IkZIRVZwM00rQzQxcDJWaVMiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)
[![Support](https://img.shields.io/badge/get-support-blue.svg)](https://boltops.com?utm_source=badge&utm_medium=badge&utm_campaign=lono)

Lono is a powerful CloudFormation framework. Lono handles the entire CloudFormation lifecycle. It builds, manages and deploys CloudFormation templates.

* Lono generates CloudFormation templates based on a [DSL](http://lono.cloud/docs/dsl/).
* Lono takes simple env-like files and generates the CloudFormation parameter files.
* Lono provides a simple CLI interface to launch the CloudFormation stacks.

See [lono.cloud](http://lono.cloud) for full lono documentation.

## Upgrading

If you are on version 4.2 and upgrade to 5.0.  You can run `lono upgrade v4to5` within your project to upgrade it to version 5.0.  Refer to the [Upgrading Guide](http://lono.cloud/docs/extras/upgrading/).

## Quick Usage

It only takes a couple of commands to start using lono.

    gem install lono
    lono new infra
    cd infra
    lono cfn deploy demo

![Lono flowchart](http://lono.cloud/img/tutorial/lono-flowchart.png "Lono flowchart")

## DSL

Here's an example of what the Lono CloudFormation DSL looks like:

```ruby
description "Demo stack"

parameter(:instance_type, "t3.micro")

mapping(:ami_map,
  "us-east-1": { ami: "ami-0de53d8956e8dcf80" },
  "us-west-2": { ami: "ami-061392db613a6357b" }
)

resource(:instance, "AWS::EC2::Instance",
  instance_type: ref(:instance_type),
  image_id: find_in_map(:ami_map, ref("AWS::Region"), :ami),
  security_group_ids: [get_att("security_group.group_id")],
  user_data: base64(user_data("bootstrap.sh"))
)
resource(:security_group, "AWS::EC2::SecurityGroup",
  group_description: "demo security group",
)

output(:instance)
output(:security_group, get_att("security_group.group_id"))
```

### Lono Cfn Lifecycle Commands

Lono provides a `lono cfn` lifecycle command that allows you to launch stacks quickly.  The `lono cfn` tool automatically runs `lono generate` internally and then launches the CloudFormation stack all in one command.  If you are in a lono project and have a `demo` lono blueprint.  To create a stack you can simply run:

    $ lono cfn deploy demo

The above command will generate files to `output/infra/templates/demo.yml` and `output/infra/params/demo.txt` and use them to create a CloudFormation stack.  Here are some more examples of cfn commands:

    lono cfn deploy demo # shorthand if blueprint, template and params file matches.
    lono cfn deploy demo-$(date +%Y%m%d%H%M%S) --blueprint demo --template demo --param demo
    lono cfn diff demo-1493859659
    lono cfn preview demo-1493859659
    lono cfn update demo-1493859659
    lono cfn delete demo-1493859659
    lono cfn deploy -h # getting help

See [lono.cloud](http://lono.cloud) for full lono documentation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
