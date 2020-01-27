---
title: Reusable Configusets
nav_text: Reusable
categories: configsets
order: 1
nav_order: 22
---

Typically, configsets are directly hardcoded into the CloudFormation template. Unfortunately, this makes them hard to reuse. With Lono, configsets are separate files. This allows them to be reusable with different templates. Lono takes the separate configset files and injects them into your CloudFormation templates.

## Example

Let's say you have two blueprints: ec2 and asg.

* The ec2 blueprint has an "Instance" resource.
* The asg blueprint has an "AutoScalingGroup" and a "LaunchConfiguration" resource.

You can reuse the same configsets for both blueprints. Example:

configs/ec2/configsets/base.rb:

```ruby
configset("cfn-hup", resource: "Instance")
configset("httpd", resource: "Instance")
```

configs/asg/configsets/base.rb:

```ruby
configset("cfn-hup", resource: "LaunchConfiguration")
configset("httpd", resource: "LaunchConfiguration")
```

## UserData cfn-init

The UserData script for the ec2 blueprint calls cfn-init like this:

```bash
#!/bin/bash
/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource Instance --region ${AWS::Region}
```

The asg blueprint's UserData calls cfn-init like this:

```bash
#!/bin/bash
/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchConfiguration --region ${AWS::Region}
```

The beauty is that you can choose whichever configsets needed.  You don't have to copy and paste the configset into different templates. Just configure them, and lono injects them into the CloudFormation template for you.

{% include prev_next.md %}