class profile::db {

  # --- Linux Logic (Keep this as is) ---
  if $facts['kernel'] == 'Linux' {
    class { 'mysql::client': package_name => 'mariadb-client' }
    class { 'mysql::server':
      package_name            => 'mariadb-server',
      service_name            => 'mariadb',
      root_password           => lookup('system_setup::db_root_password'),
      remove_default_accounts => true,
    }
    mysql::db { 'puppet_db':
      user     => lookup('system_setup::db_user'),
      password => lookup('system_setup::db_user_password'),
      host     => 'localhost',
      grant    => ['SELECT', 'UPDATE'],
    }
  }

# --- Windows Logic ---
  if $facts['kernel'] == 'windows' {
    
    include chocolatey

    package { 'mariadb':
      ensure          => installed,
      provider        => 'chocolatey',
      # THIS LINE IS CRITICAL FOR SECURITY:
      install_options => ['--install-arguments', "\"PASSWORD=${lookup('system_setup::db_root_password')}\""],
      require         => Class['chocolatey'], 
    }
  }
}


