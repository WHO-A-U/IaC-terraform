

data "template_file" "user_data" {
  template = templatefile("user-data.sh", {})
}

#server create
resource "ncloud_server" "server" {
  count = "2"
  description = "classic-test-lb"
  name = format("${var.server_name_prefix}-%s", count.index+1)
  server_image_product_code = var.server_image_product_code
  server_product_code       = var.server_product_code

  login_key_name = "NCP_test" 
  access_control_group_configuration_no_list = ["332017"] 
  zone = var.ncloud_zones[count.index]
  user_data = data.template_file.user_data.rendered
}

# LB create
resource "ncloud_load_balancer" "lb" {

  name           = "my-lb"
  algorithm_type = "RR"

  description    = "classic-test-lb"

  rule_list {
      protocol_type   = "HTTP"
      load_balancer_port   = 80
      server_port          = 80
      l7_health_check_path = "/"
    }

  server_instance_no_list = [ncloud_server.server.*.id[0], ncloud_server.server.*.id[1]]
  network_usage_type = "PBLIP"
  region               = "KR"
}


data "ncloud_server_products" "products" {
  server_image_product_code = "SPSW0LINUX000139"  // Search by 'CentOS 7.8 (64-bit)' image 

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }

  filter {
    name   = "cpu_count"
    values = ["1"]
  }

  filter {
    name   = "memory_size"
    values = ["2GB"]
  }

  filter {
    name   = "base_block_storage_size"
    values = ["50GB"]
  }

  filter {
    name   = "product_type"
    values = ["COMPT"]
  }

  output_file = "product.json"
}

output "products" {
  value = {
    for product in data.ncloud_server_products.products.server_products:
    product.id => product.product_name
  }
}