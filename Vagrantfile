# -*- mode: ruby -*-

hosts = {
    "prometheus" => { "memory" => 1536, "ip" => "192.168.10.40"},
}

Vagrant.configure("2") do |config|
    # Choose which box you want below
    #config.vm.box = "centos/7"
    config.vm.box = "generic/ubuntu1604"
    #config.vm.box = "generic/ubuntu1804"

    config.vm.synced_folder ".", "/vagrant", disabled: true

    # Loop over all machine names
    hosts.each_key do |host|
        config.vm.define host, primary: host == hosts.keys.first do |node|
            # Use custom box if set
            if hosts[host]["box"]
                node.vm.box = hosts[host]["box"]
            end

            node.vm.hostname = host
            node.vm.network :private_network, ip: hosts[host]["ip"]

            node.vm.provider :libvirt do |lv|
                lv.memory = hosts[host]["memory"]
                lv.cpus = 2
            end

            node.vm.provider :virtualbox do |vbox|
                vbox.customize ["modifyvm", :id, "--memory", hosts[host]["memory"]]
                vbox.cpus = 2
            end
            config.vm.provision :ansible do |ansible|
                    # Run on all hosts in parallel
                    ansible.limit = "all"
                    ansible.playbook = "ansible/playbooks/provision-all.yml"
                    ansible.inventory_path = "ansible/inventory.ini"
            end

           
#            config.vm.provision "file", source: "./ca.crt", destination: "prometheus/ca.crt"
#            config.vm.provision "file", source: "./token", destination: "prometheus/token"
#            config.vm.provision "file", source: "./prom-template.yaml", destination: "prometheus/template.yaml"
#            config.vm.provision "file", source: "./alerts.yaml", destination: "prometheus/alerts.yaml"
#            config.vm.provision "file", source: "./alert-template.yaml", destination: "alertmanager/config.yaml"
#            config.vm.provision "shell", path: "script.sh"
        end
    end

end
