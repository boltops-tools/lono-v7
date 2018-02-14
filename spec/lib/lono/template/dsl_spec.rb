describe Lono::Template::DSL do
  context "tmp/lono_project" do
    it "#evaluate_templates" do
      dsl = Lono::Template::DSL.new(
        quiet: true
      )
      dsl.evaluate_templates
      templates = dsl.instance_variable_get(:@templates)
      template_names = templates.map { |h| h[:name] }
      expect(template_names).to include("example")
    end
  end

  context "lono generate" do
    before(:each) do
      dsl = Lono::Template::DSL.new(quiet: true)
      dsl.run
    end

    it "should generate cloudformation template" do
      template = YAML.load_file("#{Lono.root}/output/templates/example.yml")
      expect(template['Description']).to include "AWS CloudFormation Sample Template"
    end

    # <%= partial("security_group", desc: "whatever", port: 22)
    it "partial local variables" do
      template = YAML.load_file("#{Lono.root}/output/templates/example.yml")
      desc = template['Resources']['InstanceSecurityGroup']['Properties']['GroupDescription']
      expect(desc).to eq 'Enable SSH access via port 22'
    end

    it "partials have access to variables" do
      text = IO.read("#{Lono.root}/output/templates/example.yml")
      expect(text).to include("override_test=2")
    end

    it "should include multiple user_data scripts" do
      raw = YAML.load_file("#{Lono.root}/output/templates/api-redis.json")
      expect(template['Description']).to eq "Api redis"
      user_data = template['Resources']['server']['Properties']['UserData']['Fn::Base64']['Fn::Join'][1]
      expect(user_data).to include("DB2=test\n")
    end

    it "should generate db template" do
      raw = YAML.load_file("#{Lono.root}/output/templates/api-redis.json")
      expect(template['Description']).to eq "Api redis"
      user_data = template['Resources']['server']['Properties']['UserData']['Fn::Base64']['Fn::Join'][1]
      expect(user_data).to include({"Ref" => "AWS::StackName"})
      expect(user_data).to include({"Ref" => "WaitHandle"})
      expect(user_data).to include({
        "Fn::FindInMap" => [
          "EnvironmentMapping",
          "HostnamePrefix",
          {"Ref" => "Environment"}
        ]
      })
      expect(user_data).to include({
        "Fn::FindInMap" => [
          "MapName",
          "TopLevelKey",
          "SecondLevelKey"
        ]
      })
      expect(user_data).to include({"Ref" => "DRINK"})

      expect(user_data).to include({"Fn::Base64" => "value to encode"})
      expect(user_data).to include({"Fn::GetAtt" => ["server", "PublicDnsName"]})
      expect(user_data).to include({"Fn::GetAZs" => "AWS::Region"})
      expect(user_data).to include({"Fn::Join" => [ ':', ['a','b','c']]})
      expect(user_data).to include({"Fn::Select" => [ '1', ['a','b','c']]})
    end

    it "should transform bash script to CF template user_data" do
      block = Proc.new { }
      template = Lono::Template::Template.new("foo", block)

      line = 'echo {"Ref"=>"AWS::StackName"} > /tmp/stack_name ; {"Ref"=>"Ami"}'
      data = template.transform(line)
      expect(data).to eq ["echo ", {"Ref"=>"AWS::StackName"}, " > /tmp/stack_name ; ", {"Ref"=>"Ami"}, "\n"]

      line = 'echo {"Ref"=>"AWS::StackName"} > /tmp/stack_name'
      data = template.transform(line)
      expect(data).to eq ["echo ", {"Ref"=>"AWS::StackName"}, " > /tmp/stack_name\n"]

      line = 'echo {"Fn::FindInMap" => [ "A", "B", {"Ref"=>"AWS::StackName"} ]}'
      data = template.transform(line)
      expect(data).to eq ["echo ", {"Fn::FindInMap" => ["A", "B", {"Ref"=>"AWS::StackName"}]}, "\n"]

      line = 'echo {"Fn::FindInMap" => [ "A", "B", {"Ref"=>"AWS::StackName"} ]} > /tmp/stack_name ; {"Ref"=>"Ami"}'
      data = template.transform(line)
      expect(data).to eq ["echo ", {"Fn::FindInMap" => ["A", "B", {"Ref"=>"AWS::StackName"}]}, " > /tmp/stack_name ; ", {"Ref"=>"Ami"}, "\n"]
    end

    it "should not transform user_data ruby scripts" do
      raw = YAML.load_file("#{Lono.root}/output/templates/api-worker.json")
      user_data = template['Resources']['LaunchConfig']['Properties']['UserData']['Fn::Base64']['Fn::Join'][1]
      expect(user_data).to include(%Q|ec2.tags.create(ec2.instances[my_instance_id], "Name", {value: Facter.hostname})\n|)
      expect(user_data).to include(%Q{find_all{ |record_set| record_set[:name] == record_name }\n})
    end

    it "should create parent folders for parent/db-stack.json" do
      directory_created = File.exist?("#{Lono.root}/output/templates/parent")
      expect(directory_created).to be true
    end

    it "task should generate CloudFormation templates" do
      raw = YAML.load_file("#{Lono.root}/output/templates/api-web.json")
      expect(template['Description']).to eq "Api Stack"
      expect(template['Mappings']['AWSRegionArch2AMI']['us-east-1']['64']).to eq 'ami-123'
    end
  end

end
