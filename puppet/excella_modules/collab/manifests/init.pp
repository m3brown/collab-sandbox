class collab {

  $packages = [ "python", "git", "mysql-devel", "python-pip", "python-devel" ]
  Package { ensure => installed, }

  $collab_apps = hiera_hash("collab_apps", {})
  $collab_repo_owner = hiera("collab_repo_owner", 'cfpb')

  package { python: }
  -> package { git: }
  -> package { mysql-devel: }
  -> package { python-pip: }
  -> package { python-devel: }

  class { '::mysql::server':
  }

  vcsrepo { "/www/collab":
    ensure => present,
    provider => git,
    source => "git://github.com/${collab_repo_owner}/collab.git"
  }

  unless empty($collab_apps) {
    create_resources(collab::collab_app_installer, $collab_apps)

    file { "/www/collab/collab/local_apps.py":
      ensure => file,
      content => template('collab/local_apps.erb'),
      require => Vcsrepo['/www/collab'],
    }
  }

  exec { "install collab packages":
    command => "/usr/bin/pip install -r /www/collab/requirements.txt",
    timeout => 1800,
    require => [Package['python-pip'],
                Package['mysql-devel'],
                Package['python-devel'],
                Vcsrepo['/www/collab']],
  }
  ->
  exec { "install test packages":
    command => "/usr/bin/pip install -r /www/collab/requirements-test.txt",
    timeout => 1800,
  }

  Vcsrepo <| |> ->
  file { "/www/collab/collab/local_settings.py":
    ensure => file,
    source => 'puppet:///modules/collab/local_settings.py',
  }

  exec { "create db":
    command => "/usr/bin/mysql -u root -e 'create database collab'",
    require => [Class['::mysql::server'],
                File['/www/collab/collab/local_settings.py']],
    creates => "/var/lib/mysql/collab",
  }

  exec { "django syncdb":
    command => "/www/collab/manage.py syncdb --noinput",
    require => [Exec['install collab packages'],
                File['/www/collab/collab/local_settings.py'],
                File['/www/collab/collab/local_apps.py'],
                Exec['create db']],
  }
  ->
  exec { "django migrate":
    command => "/www/collab/manage.py syncdb --noinput --migrate",
  }
  ->
  exec { "load test fixtures":
    command => "/www/collab/manage.py loaddata /www/collab/core/fixtures/core-test-fixtures.json",
  }
  ->
  exec { "load sample users":
    command => "/www/collab/manage.py create_users 20",
  }

  supervisor::program { 'collab':
    ensure => present,
    enable => true,
    command => '/usr/bin/gunicorn collab.wsgi:application',
    directory => '/www/collab',
    user => 'vagrant',
    group => 'vagrant',
    require => Exec['django syncdb'],
  }

  file { "/var/static":
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant',
  }

  exec { "collectstatic":
    command => "/www/collab/manage.py collectstatic --noinput",
    user => vagrant,
    returns => [0,1],
    require => [File['/var/static'],
                #Exec['remove fonts file'],
                Exec['install collab packages']],
  }

  class { 'nginx':
    require => File['/var/static'],
  }

  nginx::resource::upstream { 'collab':
    members => [
      'localhost:8000',
    ],
  }

  nginx::resource::vhost { 'collab-host':
    ensure => present,
    use_default_location => false,
    proxy_set_header => [ 'X-Forwarded-For $proxy_add_x_forwarded_for', 'Host $http_host' ],
  } 

  nginx::resource::location { "/":
    ensure => present,
    vhost => 'collab-host',
    proxy  => 'http://collab',
    proxy_redirect => 'default',
    proxy_set_header => [ 'X-Forwarded-For $proxy_add_x_forwarded_for', 'Host $http_host' ],
  }

  nginx::resource::location { "collab-static":
    ensure => present,
    vhost => 'collab-host',
    location => '/static',
    www_root => '/www/collab/',
  }

}
