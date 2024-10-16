class profile::icinga2::main (
    String $icinga2_db_host                 = lookup('icinga_ido_db_host', {'default_value' => 'db7.miraheze.org'}),
    String $icinga2_db_name                 = lookup('icinga_ido_db_name', {'default_value' => 'icinga'}),
    String $icinga2_db_user                 = lookup('icinga_ido_user_name', {'default_value' => 'icinga2'}),
    String $ido_db_user_password            = lookup('passwords::icinga_ido'),
    String $mirahezebots_password           = lookup('passwords::irc::mirahezebots'),
    String $icingaweb2_db_host              = lookup('icingaweb_db_host', {'default_value' => 'db7.miraheze.org'}),
    String $icingaweb2_db_name              = lookup('icingaweb_db_name', {'default_value' => 'icingaweb2'}),
    String $icingaweb2_db_user_name         = lookup('icingaweb_user_name', {'default_value' => 'icingaweb2'}),
    String $icingaweb2_db_user_password     = lookup('passwords::icingaweb2'),
    String $icingaweb2_ido_db_host          = lookup('icinga_ido_db_host', {'default_value' => 'db7.miraheze.org'}),
    String $icingaweb2_ido_db_name          = lookup('icinga_ido_db_name', {'default_value' => 'icinga'}),
    String $icingaweb2_ido_db_user_name     = lookup('icinga_ido_user_name', {'default_value' => 'icinga2'}),
    String $icingaweb2_icinga_api_password  = lookup('passwords::icinga_api'),
    String $ticket_salt                     = lookup('passwords::ticket_salt', {'default_value' => ''}),
    String $ldap_password                   = lookup('passwords::ldap_password'),
) {
    class { '::monitoring':
        db_host               => $icinga2_db_host,
        db_name               => $icinga2_db_name,
        db_user               => $icinga2_db_user,
        db_password           => $ido_db_user_password ,
        mirahezebots_password => $mirahezebots_password,
        ticket_salt           => $ticket_salt,
    }

    class { '::icingaweb2':
        db_host               => $icingaweb2_db_host,
        db_name               => $icingaweb2_db_name,
        db_user_name          => $icingaweb2_db_user_name,
        db_user_password      => $icingaweb2_db_user_password,
        ido_db_host           => $icingaweb2_ido_db_host,
        ido_db_name           => $icingaweb2_ido_db_name,
        ido_db_user_name      => $icingaweb2_ido_db_user_name,
        ido_db_user_password  => $ido_db_user_password ,
        icinga_api_password   => $icingaweb2_icinga_api_password,
        ldap_password         => $ldap_password,
    }
}
