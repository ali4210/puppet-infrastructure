class profile::web {

  # --- Linux Logic (Apache) ---
  if $facts['kernel'] == 'Linux' {
    package { 'apache2': ensure => installed }

    service { 'apache2':
      ensure  => running, 
      enable  => true,
      require => Package['apache2'],
    }

    file { '/var/www/html/index.html':
      ensure  => file,
      content => epp('profile/webpage.epp'), # <--- UPDATED PATH
      require => Package['apache2'],
    }
  }

  # --- Windows Logic (IIS) ---
  if $facts['kernel'] == 'windows' {
    exec { 'install_iis':
      command   => 'Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart',
      provider  => powershell,
      unless    => 'if ((Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole).State -eq \'Enabled\') { exit 0 } else { exit 1 }',
    }

    file { 'c:/inetpub': ensure => directory }

    file { 'c:/inetpub/wwwroot': 
      ensure  => directory, 
      require => Exec['install_iis'] 
    }

    file { 'c:/inetpub/wwwroot/index.html':
      ensure  => file,
      content => epp('profile/webpage.epp'), # <--- UPDATED PATH
      require => File['c:/inetpub/wwwroot'],
    }
  }

}
