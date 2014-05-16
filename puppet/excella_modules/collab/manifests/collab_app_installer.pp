define collab::collab_app_installer(
    $repo_name,
    $repo_origin
) {

  #include collab

  Exec { path => ['/bin', '/usr/bin'] }

  vcsrepo { "/www/${repo_name}":
    ensure => present,
    provider => git,
    source => "git://github.com/${repo_origin}/${repo_name}.git",
    require => Vcsrepo['/www/collab'],
  }
  ->
  exec { "${title} symlink option 1":
    command => "ln -s /www/${repo_name}/${title} /www/collab/${title}",
    onlyif => "test -d /www/${repo_name}/${title}",
    creates => "/www/collab/${title}",
  }
  ->
  exec { "${title} symlink option 2":
    command => "ln -s /www/${repo_name}/src/${title} /www/collab/${title}",
    onlyif => "test -d /www/${repo_name}/src/${title}",
    creates => "/www/collab/${title}",
  }

}
