hiera_include('classes')

class { 'yum':
  extrarepo => [
    'epel',
  ],
}

# configure repo before installing any packages
Class['yum::repo::epel'] -> Package <| |>
