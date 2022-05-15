# -*- mode: ruby -*-
# vi: set ft=ruby :

# Usage:
#   vagrant box update --box archlinux/archlinux
#   vagrant up

require 'yaml'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

current_dir = File.dirname(File.expand_path(__FILE__))
configs = YAML.load_file("#{current_dir}/tests/config.yaml")
vagrant_config = configs['configs'][configs['configs']['use']]

unless Vagrant.has_plugin?("vagrant-libvirt")
  raise  Vagrant::Errors::VagrantError.new, "vagrant-libvirt plugin is missing. Please install it using 'vagrant plugin install vagrant-libvirt' and rerun 'vagrant up'"
end

Vagrant.configure("2") do |config|

  # update image with: "vagrant box update --box archlinux/archlinux"
  config.vm.box = "archlinux/archlinux"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = vagrant_config['cpus']
    libvirt.cputopology :sockets => '1', :cores => vagrant_config['cpus'].to_s(), :threads => '1'
    libvirt.nested = true
    libvirt.memory = vagrant_config['memory']
    libvirt.graphics_type = "spice"
    libvirt.video_type = "virtio"
    libvirt.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'
    libvirt.machine_virtual_size = vagrant_config['disksize']
  end

  config.vm.provision "shell", inline: <<-SHELL
    chmod +x /vagrant/tests/setup.sh
    sudo /vagrant/tests/setup.sh libvirt
  SHELL

  config.vm.provision :ansible do |ansible|
    ansible.verbose = "v"
    ansible.galaxy_role_file = 'requirements.yml'
    ansible.playbook = "./playbooks/test_001.yml"
  end
end
