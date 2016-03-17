#!/bin/bash
# joshcb@amazon.com
# Generates an Ansible Inventory file from an EC2 Tag
# v1.0.0

# Set environment for ec2 tools
source ~/.bash_profile

# Query metadata for our instance id and fetch values of the Roles tag
tags="$(/opt/aws/bin/ec2-describe-tags --filter \"resource-type=instance\" \
  --filter \"resource-id=$(/opt/aws/bin/ec2-metadata -i | cut -d ' ' -f2)\" \
  --filter \"key=Roles\" | cut -f5)"

# Whitespace get outta here we don't need you
tags_no_whitespace="$(echo -e "${tags}" | tr -d '[[:space:]]')"

# Wipe out existing file :fire:
printf '' > /tmp/inventory

# http://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
IFS=', ' read -r -a array <<< "$tags_no_whitespace"

# Write out each role into an Ansible host group
for element in "${array[@]}"
do
    printf "[$element]\nlocalhost ansible_connection=local\n" >> /tmp/inventory
done
