class dev_setup {

  $gitconfig_email = hiera('gitconfig_email')
  $gitconfig_name = hiera('gitconfig_name')

  file { ".gitconfig":
    ensure => file,
    content => template('dev_setup/gitconfig.erb'),
    path => '/home/vagrant/.gitconfig',
  }

}
