# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define :easy_client do |machine|
#    machine.vm.box = "centos/7"
#    machine.vm.box = "debian/8"
    machine.vm.box = "suse/sles11sp3"
    machine.vm.hostname = "redmineserver"
    machine.vm.network :public_network
#    machine.vm.provision :shell, path: "easycheck.sh", args: "42", keep_color: true
  end

end
