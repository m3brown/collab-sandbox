collab-sandbox
==============

Installation instructions

1) Download and install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html)

2) Clone this repo

3) From the root of the repo, edit `puppet/hieradata/common.yaml` to include your gitconfig settings and any additional collab apps

4) Run `vagrant up` to initalize the environment
 * The CentOS 6.5 VM itself is about 500MB
 * If you have a CentOS 6.5 vagrant box already, before running `vagrant up`:
   * Create the file path `$HOME/.vagrant.d/boxes/centos-65/virtualbox/`
   * Place the .box file inside the virtualbox directory above
   * Extract the .box file (*nix command: `tar -xvzf *.box`)

When completed, you can access the virtual machine in two ways:

1) SSH - run the command `vagrant ssh`
 * The Django server is deployed to `/www/collab/`

2) Browser - access Collab at `http://localhost:8080`
 * Default login: `test1@example.com`
 * Default pw: `1`
