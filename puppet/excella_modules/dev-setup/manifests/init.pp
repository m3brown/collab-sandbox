class dev-setup {

  $gitconfig_email = hiera('gitconfig_email')
  $gitconfig_name = hiera('gitconfig_name')

  file { ".gitconfig":
    ensure => file,
    content => template('dev-setup/gitconfig.erb'),
    path => '/home/vagrant/.gitconfig',
  }

}
