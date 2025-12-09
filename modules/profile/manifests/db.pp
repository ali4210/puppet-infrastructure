class profile::db {

  if $facts['kernel'] == 'Linux' {
    class { 'mysql::client':
      package_name => 'mariadb-client',
    }

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

}
