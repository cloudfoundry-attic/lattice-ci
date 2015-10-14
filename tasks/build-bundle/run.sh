#!/bin/bash

set -ex

lattice_release_version=$(git -C lattice-release describe --tags --always)
vagrant_box_version=$(cat vagrant-box-version/number)
lattice_tgz_url=$(cat lattice-tgz/url)

output_dir=lattice-vagrant-$lattice_release_version
mkdir -p $output_dir/vagrant $output_dir/terraform

vagrantfile=$(sed "s/config\.vm\.box_version = '0'/config.vm.box_version = '$vagrant_box_version'/" lattice-release/vagrant/Vagrantfile)
echo "LATTICE_TGZ_URL = '$lattice_tgz_url'\n$vagrantfile" > $output_dir/vagrant/Vagrantfile

ami_json=$(cat terraform-ami-metadata/ami-metadata-v*)

ami_ap_northeast_1_brain=$(echo "$ami_json" | jq -r .brain.ap-northeast-1)
ami_ap_southeast_1_brain=$(echo "$ami_json" | jq -r .brain.ap-southeast-1)
ami_ap_southeast_2_brain=$(echo "$ami_json" | jq -r .brain.ap-southeast-2)
ami_eu_central_1_brain=$(echo "$ami_json" | jq -r .brain.eu-central-1)
ami_eu_west_1_brain=$(echo "$ami_json" | jq -r .brain.eu-west-1)
ami_sa_east_1_brain=$(echo "$ami_json" | jq -r .brain.sa-east-1)
ami_us_east_1_brain=$(echo "$ami_json" | jq -r .brain.us-east-1)
ami_us_west_1_brain=$(echo "$ami_json" | jq -r .brain.us-west-1)
ami_us_west_2_brain=$(echo "$ami_json" | jq -r .brain.us-west-2)

ami_ap_northeast_1_cell=$(echo "$ami_json" | jq -r .cell.ap-northeast-1)
ami_ap_southeast_1_cell=$(echo "$ami_json" | jq -r .cell.ap-southeast-1)
ami_ap_southeast_2_cell=$(echo "$ami_json" | jq -r .cell.ap-southeast-2)
ami_eu_central_1_cell=$(echo "$ami_json" | jq -r .cell.eu-central-1)
ami_eu_west_1_cell=$(echo "$ami_json" | jq -r .cell.eu-west-1)
ami_sa_east_1_cell=$(echo "$ami_json" | jq -r .cell.sa-east-1)
ami_us_east_1_cell=$(echo "$ami_json" | jq -r .cell.us-east-1)
ami_us_west_1_cell=$(echo "$ami_json" | jq -r .cell.us-west-1)
ami_us_west_2_cell=$(echo "$ami_json" | jq -r .cell.us-west-2)

terraform_ami_variables=$(cat <<EOF
variable "brain_ami" {
    description = "Brain base image AMI"
    default = {
        ap-northeast-1 = "$ami_ap_northeast_1_brain"
        ap-southeast-1 = "$ami_ap_southeast_1_brain"
        ap-southeast-2 = "$ami_ap_southeast_2_brain"
        eu-central-1 = "$ami_eu_central_1_brain"
        eu-west-1 = "$ami_eu_west_1_brain"
        sa-east-1 = "$ami_sa_east_1_brain"
        us-east-1 = "$ami_us_east_1_brain"
        us-west-1 = "$ami_us_west_1_brain"
        us-west-2 = "$ami_us_west_2_brain"
    }
}

variable "cell_ami" {
    description = "Cell base image AMI"
    default = {
        ap-northeast-1 = "$ami_ap_northeast_1_cell"
        ap-southeast-1 = "$ami_ap_southeast_1_cell"
        ap-southeast-2 = "$ami_ap_southeast_2_cell"
        eu-central-1 = "$ami_eu_central_1_cell"
        eu-west-1 = "$ami_eu_west_1_cell"
        sa-east-1 = "$ami_sa_east_1_cell"
        us-east-1 = "$ami_us_east_1_cell"
        us-west-1 = "$ami_us_west_1_cell"
        us-west-2 = "$ami_us_west_2_cell"
    }
}
EOF

zip -r ${output_dir}.zip "$output_dir"

