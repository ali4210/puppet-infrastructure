class system_setup {
# ^^^ OPEN CLASS

  # ==========================================
  # LOGIC FOR LINUX (PARROT OS) - APACHE & MySQL
  # ==========================================
  if $facts['kernel'] == 'Linux' {
    
    # 1. Apache Web Server
    package { 'apache2':
      ensure => installed,
    }

    service { 'apache2':
      ensure  => running,
      enable  => true,
      require => Package['apache2'],
    }

    file { '/var/www/html/index.html':
      ensure  => file,
      content => epp('system_setup/webpage.epp'),
      require => Package['apache2'],
    }

    # 2. Configure MySQL Client
    class { 'mysql::client':
      package_name => 'mariadb-client',
    }

    # 3. Configure MySQL Server (Using Hiera for Password)
    class { 'mysql::server':
      package_name            => 'mariadb-server',
      service_name            => 'mariadb',
      # [HIERA UPDATE] We ask the database for the password
      root_password           => lookup('system_setup::db_root_password'),
      remove_default_accounts => true,
    }

    # 4. Create the Database (Using Hiera for User/Pass)
    mysql::db { 'puppet_db':
      # [HIERA UPDATE] asking Hiera for the user and password
      user     => lookup('system_setup::db_user'),
      password => lookup('system_setup::db_user_password'),
      host     => 'localhost',
      grant    => ['SELECT', 'UPDATE'],
    }

  } # <--- Closes the Linux IF block


  # ==========================================
  # LOGIC FOR WINDOWS 10 - IIS WEB SERVER
  # ==========================================
  if $facts['kernel'] == 'windows' {

    # 1. Install IIS (Windows 10 Version)
    exec { 'install_iis':
      command   => 'Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart',
      provider  => powershell,
      # I fixed the cut-off line below for you:
      unless    => 'if ((Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole).State -eq \'Enabled\') { exit 0 } else { exit 1 }',
    }

    # 2. Ensure parent folder
    file { 'c:/inetpub':
      ensure => directory,
    }

    # 3. Ensure webroot folder
    file { 'c:/inetpub/wwwroot':
      ensure  => directory,
      require => Exec['install_iis'],
    }

    # 4. Create the Homepage
    file { 'c:/inetpub/wwwroot/index.html':
      ensure  => file,
      content => epp('system_setup/webpage.epp'),
      require => File['c:/inetpub/wwwroot'],
    }
  } # <--- Closes the Windows IF block

} 
# ^^^ CLOSE CLASS
