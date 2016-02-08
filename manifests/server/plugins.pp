class teamcity::server::plugins(
  $plugin_urls      = [],
  $wget_opts        = '',)
{

  $plugin_urls.each |String $plugin_url| {
    $plugin_file = basename($plugin_url)
    exec { 'download teamcity plugin':
      command => "wget ${wget_opts} \"${plugin_url}\"",
      creates => "${teamcity::server::plugin_dir}/${plugin_file}",
      cwd     => $teamcity::server::plugin_dir,
      notify  => Exec['restart teamcity service'],
      timeout => 0
    }
  
    exec { 'set ownership teamcity plugin':
      command => "chown ${teamcity::server::user}:${teamcity::common::group} \"${teamcity::server::plugin_dir}/${plugin_file}\"",
      cwd     => $teamcity::server::plugin_dir,
      require => Exec['download teamcity plugin'],
      timeout => 0
    }
  }  
  
  exec { 'restart teamcity service':
    command     => "service ${teamcity::server::service} restart",
    cwd         => $teamcity::server::home_dir,
    refreshonly => true,
    timeout     => 0
  }
}
  