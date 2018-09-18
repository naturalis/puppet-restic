puppet-restic
==================

Restic role manifest for puppet in a foreman environment.
Creates: 
- config files, exclude file, password file , and scripts for manual restic commands, cron driven usage and sensu checks in /opt/restic
- cronjob for backup with loging in /var/log/restic
- logrotate for restic logs
- sensu check is exported to the localhost and can be picked up by sensu monitoring
- pre backup scripts for mysql, postgresql and samba

Parameters
-------------
All parameters are read from defaults in init.pp and can be overwritten by hiera or The foreman


```
# general options
  $restic_aws_access_key = "XXXXXXXXXXXXXXXXXX",
  $restic_aws_secret_key = "XXXXXXXXXXXXXXXXXX",
  $restic_password       = "backuppassword",
  $restic_aws_repo       = "s3:https://s3.amazonaws.com/restic-repo-name",
  $restic_upload_limit   = '204800',
  $restic_download_limit = '204800',
  $restic_path           = '/opt/restic',
  $restic_binary         = 'restic_0.9.2_linux_amd64',
  $restic_download_url   = 'https://github.com/restic/restic/releases/download/v0.9.2/restic_0.9.2_linux_amd64.bz2',
  $pgsqlbackupuser       = 'postgres',
  $pgsqlalldatabases     = false,
  $pgsqldatabasearray    = ['db1', 'db2'],
  $backuprootfolder      = '/var/backup',
  $mysqlbackupuser       = 'backupuser',
  $mysqlbackuppassword   = 'backupuserpwd',
  $mysqlalldatabases     = false,
  $mysqlfileperdatabase  = true,
  $mysqldatabasearray    = ['db1', 'db2'],
  $chkwarninghours       = 28,
  $chkcriticalhours      = 48,
  $chkmaxruntimehours    = 48,

# backup options
  $mysqlrestore          = false,
  $mysqlbackup           = false,
  $sambabackup           = false,
  $pgsqlbackup           = false,
  $pgsqlprebackupvacuum  = false,
  $cron                  = false,
  $pre_command           = undef,
  $cronminute            = '*/20',
  $cronhour               = '*',
  $exclude_list          = [
                            '/bin',
                            '/boot',
                            '/dev',
                            '/lib',
                            '/lib64',
                            '/lost+found',
                            '/proc',
                            '/root',
                            '/run',
                            '/sbin',
                            '/sys',
                            '/var/backups',
                            '/var/cache',
                            '/var/log',
                            '/var/tmp',
                            '/var/spool',
                            '/var/lib',
                            '/tmp',
                            '/swapfile',
                            '/opt/puppetlabs',
                            '/opt/sensu',
                            '/.*',
                            '/initrd.*',
                            '/vmlinuz.*',
                            '/usr',
                           ],
  $docker_compose        = false,
  $docker_compose_dir    = "/opt/docker_compose-dir",
  $docker_container      = "db",

# restore options
  $resticrestorecname      = undef,
  $pgsqlrestore          = false,
  $restorescript         = false,
  $restorefromclient     = undef,
  $restoresource         = 'restic',
  $post_restore_command  = '',
  $pre_restore_command   = '',
  $restorecron           = false,
  $restorecronminute     = '0',
  $restorecronhour       = '5',
  $restorecronweekday    = '0',

```

Classes
-------------
- restic


Dependencies
-------------




Result
-------------
Configurable cron run Restic installation including monitoring scripts. 


Limitations
-------------
This module has been built on and tested against Puppet 4 and higher.

The module has been tested on:
- Ubuntu 16.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

