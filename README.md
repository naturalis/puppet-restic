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
  $restic_aws_access_key            = "XXXXXXXXXXXXXXXXXX",
  $restic_aws_secret_key            = "XXXXXXXXXXXXXXXXXX",
  $restic_password                  = "backuppassword",
  $restic_aws_repo                  = "s3:https://s3.amazonaws.com/restic-repo-name",
  $restic_upload_limit              = '204800',
  $restic_download_limit            = '204800',
  $restic_path                      = '/opt/restic',
  $restic_binary                    = 'restic_0.9.2_linux_amd64',
  $restic_download_url              = 'https://github.com/restic/restic/releases/download/v0.9.2/restic_0.9.2_linux_amd64.bz2',
  $restic_pre_command               = '',
  $restic_keep_prune_job            = true,
  $restic_keep_prune_job_random     = true,    # if enabled a random hour will be taken in which a prune and forget job wil run instead of backup. 
  $restic_keep_prune_job_hour       = 10,       # hour when random = false
  $restic_keep_last                 = 60,       # restic forget options
  $restic_keep_within_duration      = '60d',    # restic forget options
  $restic_disable_during_prune      = true,     # disable running backups during prune_job_hour and prune_job_hour+1
  $restic_enable_swap               = false,    # enables the use of a temporary swapfile which might help with out of memory issues
  $restic_swap_size                 = '2G',
  $restic_swap_location             = '/tmp/.swapfile',
  $restic_time_between_backup       = '1',
  $restic_time_between_hourlybackup = 'yesterday',

# default check options
  $chkwarninghours                  = 26,
  $chkcriticalhours                 = 48,
  $chkmaxruntimehours               = 48,

# backup options
  $mysqlbackup                      = false,
  $sambabackup                      = false,
  $pgsqlbackup                      = false,
  $pgsqlprebackupvacuum             = false,
  $cron                             = false,
  $mysqldatabasearray               = ['db1', 'db2'],
  $pgsqlbackupuser                  = 'postgres',
  $pgsqlalldatabases                = true,
  $pgsqldatabasearray               = ['db1', 'db2'],
  $backuprootfolder                 = '/var/backup',
  $mysqlbackupuser                  = 'backupuser',
  $mysqlbackuppassword              = 'backupuserpwd',
  $mysqlalldatabases                = true,
  $mysqlfileperdatabase             = true,
  $mysqlshowcompatibility56         = true,   # needed for most mysql install on ubuntu 16.04LTS
  $cronminute                       = '*/20', # cronminute is ignored then $cronrandom is true
  $cronrandom                       = true,   # randomize minute 0-59 for spreading backups every hour
  $cronhour                         = '*',    # if cronhour = * then time_between_hourlybackup is active else time_between_backup is used,. 
  $restic_backup_path               = '/',
  $exclude_list                     = [
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
                                      '/vmlinuz',
                                      '/usr',
                                     ],
  $docker                           = false,
  $docker_container                 = "dockerapp_db_1",

# restore options
  $restorescript                    = false,
  $restorefromclient                = undef,
  $restoreinclude                   = '/var/backup',
  $post_restore_command             = '',
  $pre_restore_command              = '',
  $restorecron                      = false,
  $restorecronminute                = '0',
  $restorecronhour                  = '5',
  $restorecronweekday               = '0',
  $restorecronmonthday              = '*',

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

