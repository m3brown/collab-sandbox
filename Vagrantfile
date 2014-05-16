Vagrant.configure("2") do |config|

  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box"
  config.vm.box = "centos-65"

  config.vm.synced_folder "puppet", "/etc/puppet"
  config.vm.synced_folder ".", "/www"

  config.vm.provision "shell", path: "librarian_bootstrap.sh"

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "init.pp"
    puppet.module_path = ["puppet/excella_modules", "puppet/modules"]
  end

  config.vm.define "web" do |web|
    web.vm.hostname = "web01.excella"
    web.vm.network "forwarded_port", guest: 80, host: 8080
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
  end

end
