require "yaml"
vagrant_root = File.dirname(File.expand_path(__FILE__))
setting = YAML.load_file("#{vagrant_root}/setting.yaml")

IP_SECTIONS = setting["network"]["control_ip"].match(/^([0-9.]+\.)([^.]+)$/)
# First 3 octets including the trailing dot:
IP_NW = IP_SECTIONS.captures[0]
# Last octet excluding all dots:
IP_START = Integer(IP_SECTIONS.captures[1])
NUM_WORKER_NODES = setting["nodes"]["workers"]["count"]
DNS_SERVERS1 = setting["network"]["dns_servers"][0]
DNS_SERVERS2 = setting["network"]["dns_servers"][1]

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.provision "shell", env: { "IP_NW" => IP_NW, "IP_START" => IP_START, "NUM_WORKER_NODES" => NUM_WORKER_NODES, "DNS_SERVERS1" => DNS_SERVERS1, "DNS_SERVERS2" => DNS_SERVERS2  }, inline: <<-SHELL
      echo "$IP_NW$((IP_START)) master.local master" >> /etc/hosts
      sudo systemctl disable systemd-resolved.service
      sudo systemctl stop systemd-resolved.service
      sudo rm /etc/resolv.conf
      touch /etc/resolv.conf
      echo "nameserver $DNS_SERVERS1" > /etc/resolv.conf
      echo "nameserver $DNS_SERVERS2" >> /etc/resolv.conf
      for i in `seq 1 ${NUM_WORKER_NODES}`; do
        echo "$IP_NW$((IP_START+i)) worker-node0${i}.local worker_node0${i}" >> /etc/hosts
      done
      apt update -y
  SHELL

  # Master node
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "debian/bullseye64"
    master.vm.network :private_network, ip: "192.168.56.101"
    master.vm.provider "virtualbox" do |vb|
      vb.cpus = setting["nodes"]["control"]["cpu"]
      vb.memory = setting["nodes"]["control"]["memory"]
    end
    master.vm.provision "shell", path: "scripts/all-nodes.sh"
    master.vm.provision "shell", path: "scripts/kubeadm-cluster-debian.sh"
    master.vm.provision "shell",
      env: {
        "CALICO_VERSION" => setting["software"]["calico"],
        "CONTROL_IP" => setting["network"]["control_ip"],
        "POD_CIDR" => setting["network"]["pod_cidr"],
        "SERVICE_CIDR" => setting["network"]["service_cidr"]
      },
      path: "scripts/master.sh"
  end


  (1..NUM_WORKER_NODES).each do |i|

    config.vm.define "worker-node0#{i}" do |node|
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
      node.vm.box = "debian/bullseye64"
      node.vm.provider "virtualbox" do |vb|
          vb.cpus = setting["nodes"]["workers"]["cpu"]
          vb.memory = setting["nodes"]["workers"]["memory"]
      end
      node.vm.provision "shell", path: "scripts/all-nodes.sh"
      node.vm.provision "shell", path: "scripts/kubeadm-cluster-debian.sh"

      # Only install the dashboard after provisioning the last worker (and when enabled).
      if i == NUM_WORKER_NODES and setting["software"]["dashboard"] and setting["software"]["dashboard"] != ""
        node.vm.provision "shell", path: "scripts/dashboard.sh"
      end
    end

  end
end
