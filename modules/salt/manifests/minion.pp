# == Class: salt::minion
#
# Provisions a Salt minion.
#
# === Parameters
#
# [*master*]
#   Sets the location of the salt master server. May be a string or
#   an array (for multi-master setups).
#
# [*master_finger*]
#   Fingerprint of the master public key to double verify the master
#   is valid. Find the fingerprint by running 'salt-key -F master' on
#   the salt master.

# [*master_key*]
#   Public key of the master server. Found at
#   /etc/salt/pki/master/master.pub on salt master. Overwrites
#   minion_master.pub on minion to avoid the need to remove that file
#   manually.
#
# [*id*]
#   Explicitly declare the ID for this minion to use.
#   Defaults to the value of $::fqdn.
#
# [*grains*]
#   An optional hash of custom static grains for this minion.
#
# === Examples
#
#   class { '::salt::minion':
#     master          => 'misc3.miraheze.org',
#     master_finger   => 'a0:ce:17:67:fb:1e:07:da:c7:5f:45:27:d7:f3:11:d0'
#     grains          => {
#       cluster => $::cluster,
#     },
#   }
#
class salt::minion(
    String $master,
    String $master_finger,
    Optional[Boolean] $master_key = undef,
    String $id        = $::fqdn,
    Hash $grains    = {},
) {
    include salt::apt

    include ssl::wildcard

    $config = {
        id                  => $id,
        master              => $master,
        master_finger       => $master_finger,
        grains              => $grains,
        dns_check           => false,
        random_reauth_delay => 10,
        recon_default       => 1000,
        recon_max           => 10000,
        recon_randomize     => true,
        keysize             => 2048,
        ping_interval       => 15,
        auth_retries        => 5,
        auth_safemode       => false,
        ssl                 => {
            keyfile => '/etc/ssl/private/wildcard.miraheze.org.key',
            certfile => '/etc/ssl/certs/wildcard.miraheze.org.crt',
            ssl_version => 'PROTOCOL_TLSv1_2',
        },
    }

    # our config file must be in place before
    # package installation, so that the deb postinst
    # step which automatically starts the minion
    # will start it with the correct settings
    
    # May be installed in the future again,
    # but with proper measures in place.
    package { 'salt-minion':
        ensure => absent,
    }

    # Do NOT install and run this service
    # on any Miraheze server. Salt is NOT safe
    # for usage here, EVEN with the patch in place.
    service { 'salt-minion':
        ensure   => stopped,
        require  => Package['salt-minion'],
    }

    file { '/etc/init/salt-minion.override':
        ensure => absent,
        notify => Service['salt-minion'],
    }

    file { '/etc/salt':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['salt-minion'],
    }

    file { '/etc/salt/minion':
        content => ordered_yaml($config),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service['salt-minion'],
        require => File['/etc/salt'],
    }

    if $master_key {
        file { '/etc/salt/pki':
            ensure  => directory,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => File['/etc/salt'],
        }

        file { '/etc/salt/pki/minion':
            ensure  => directory,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            require => File['/etc/salt/pki'],
        }

        file { '/etc/salt/pki/minion/minion_master.pub':
            owner   => 'root',
            group   => 'root',
            mode    => '0444',
            source  => 'puppet:///modules/salt/minion_master.pub',
            require => File['/etc/salt/pki/minion'],
        }
    }

    file { '/etc/logrotate.d/salt-common':
        ensure => present,
        source => 'puppet:///modules/salt/logrotate.conf',
    }

    file { '/etc/systemd/system/salt-minion.service.d/':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/etc/systemd/system/salt-minion.service.d/killmode.conf':
        content => "[Service]\nKillMode=process\n",
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }
}
