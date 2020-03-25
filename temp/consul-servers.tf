data "template_file" "consul-install-1" {
    template = "${file("${path.module}/scripts/consul-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region_1}"
        CONSUL_ID = "1"
        CONSUL_DL_URL = "${var.consul_dl_url}"
        CONSUL_JOIN_KEY = "${var.consul_join_key_r1}"
        CONSUL_JOIN_VALUE = "${var.consul_join_value_r1}"
        CONSUL_LICENSE = "${var.consul_license_key}"
    }
}

data "template_file" "consul-install-2" {
    template = "${file("${path.module}/scripts/consul-install.sh")}"

    vars = {
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_REGION = "${var.aws_region_1}"
        CONSUL_ID = "2"
        CONSUL_DL_URL = "${var.consul_dl_url}"
        CONSUL_JOIN_KEY = "${var.consul_join_key_r1}"
        CONSUL_JOIN_VALUE = "${var.consul_join_value_r1}"
        CONSUL_LICENSE = "${var.consul_license_key}"
    }
}

data "template_file" "consul-install-3" {
    template = file("${path.module}/scripts/consul-install.sh")

    vars = {
        AWS_ACCESS_KEY = var.aws_access_key
        AWS_SECRET_KEY = var.aws_secret_key
        AWS_REGION = var.aws_region_1
        CONSUL_ID = "3"
        CONSUL_DL_URL = var.consul_dl_url
        CONSUL_JOIN_KEY = var.consul_join_key_r1
        CONSUL_JOIN_VALUE = var.consul_join_value_r1
        CONSUL_LICENSE = var.consul_license_key
    }
}

resource "aws_instance" "consul-server-1" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_size
    key_name = var.key_pair_r1
    vpc_security_group_ids = [aws_security_group.consul-server-sg.id]
    user_data = data.template_file.consul-install-1.rendered
    iam_instance_profile = aws_iam_instance_profile.consul-tag-profile.id

    tags = {
        Name = "consul-server-1-${var.unit_suffix}"
        TTL = var.instance_ttl
        owner = var.instance_owner
        "${var.consul_join_key_r1}" = var.consul_join_value_r1
    }
}

resource "aws_instance" "consul-server-2" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_size
    key_name = var.key_pair_r1
    vpc_security_group_ids = [aws_security_group.consul-server-sg.id]
    user_data = data.template_file.consul-install-2.rendered
    iam_instance_profile = aws_iam_instance_profile.consul-tag-profile.id

    tags = {
        Name = "consul-server-2-${var.unit_suffix}"
        TTL = var.instance_ttl
        owner = var.instance_owner
        "${var.consul_join_key_r1}" = var.consul_join_value_r1
    }
}

resource "aws_instance" "consul-server-3" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_size
    key_name = var.key_pair_r1
    vpc_security_group_ids = [aws_security_group.consul-server-sg.id]
    user_data = data.template_file.consul-install-3.rendered
    iam_instance_profile = aws_iam_instance_profile.consul-tag-profile.id

    tags = {
        Name = "consul-server-3-${var.unit_suffix}"
        TTL = var.instance_ttl
        owner = var.instance_owner
        "${var.consul_join_key_r1}" = var.consul_join_value_r1
    }
}

resource "aws_security_group" "consul-server-sg" {
    name = "consul-server-sg-${var.unit_suffix}"
    description = "Consul server security group"
    vpc_id = data.aws_vpc.primary-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8500
        to_port = 8500
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8300
        to_port = 8303
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}