# == Class: restic
#
#
class restic(
# general options
  $restic_aws_access_key            = "XXXXXXXXXXXXXXXXXX",
  $restic_aws_secret_key            = "XXXXXXXXXXXXXXXXXX",
  $restic_password                  = "backuppassword",
  $restic_aws_repo                  = "s3:https://s3.amazonaws.com/restic-repo-name",
  $restic_upload_limit              = '204800',
  $restic_download_limit            = '204800',
  $restic_path                      = '/opt/restic',
  $restic_binary                    = 'restic_0.9.6_linux_amd64',
  $restic_download_url              = 'https://github.com/restic/restic/releases/download/v0.9.6/restic_0.9.6_linux_amd64.bz2',
  $restic_pre_command               = '',
  $restic_keep_prune_job            = true,
  $restic_keep_prune_job_random     = true,    # if enabled a random hour and weekday will be taken in which a prune and forget job wil run instead of backup. 
  $restic_keep_prune_job_hour       = 10,      # hour when random = false
  $restic_keep_prune_job_weekday    = 6,       # prune by default on saturday
  $restic_keep_last                 = 60,      # restic forget options
  $restic_keep_within_duration      = '60d',   # restic forget options
  $restic_disable_during_prune      = true,    # disable running backups during prune_job_hour and prune_job_hour+prune_hours
  $restic_disable_during_prune_hours= 12,      # amount of hours to let prune complete
  $restic_enable_swap               = false,   # enables the use of a temporary swapfile which might help with out of memory issues
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

)
{

# Create restic folder location for restic application and script related files
  file { $restic_path:
    ensure                  => 'directory',
    mode                    => '0700'
  }

# include class and sambascript with sambabackup=true
  if ($sambabackup == true ) {
    $sambascript =  "${restic_path}/sambabackup.sh"
      class { 'restic::sambabackup':
    }
  }

# include class and mysqlscript with mysqlbackup=true
  if ($mysqlbackup == true ) {
    $mysqlscript =  "${restic_path}/mysqlbackup.sh"
      class { 'restic::mysqlbackup':
    }
  }

# include class and pgsqlscript with pgsqlbackup=true
  if ($pgsqlbackup == true ) {
    $pgsqlscript =  "${restic_path}/pgsqlbackup.sh"
      class { 'restic::pgsqlbackup':
    }
  }

# define backup interval should be low if backup is scheduled else bidaily backups will be made instead of daily backups.
  if ($cronhour == "*" ){
    $_restic_time_between_backup = $restic_time_between_hourlybackup
  } else {
    $_restic_time_between_backup = $restic_time_between_backup
  }

# Create array from scripts which will be used in the resticscript.sh
$pre_command_array = [$restic_pre_command, $sambascript, $mysqlscript, $pgsqlscript]

# Create backupscript from template
  if ($pre_command_array != '') {
    $pre_backup_script_command = "${restic_path}/prebackup.sh 2>&1 >> /var/log/restic/prebackup.log"
    file {"${restic_path}/prebackup.sh":
      ensure                  => 'file',
      mode                    => '0700',
      content                 => template('restic/prebackup.sh.erb')
    }
  }

# include restic class
  exec { 'install restic':
    command        => "/usr/bin/wget ${restic_download_url} -O ${restic_path}/${restic_binary}.bz2 && /bin/bzip2 -d ${restic_path}/${restic_binary}.bz2 && chmod +x ${restic_path}/${restic_binary}",
    unless         => "/usr/bin/test -f ${restic_path}/${restic_binary}",
  }

# create restic config script
  file { "${restic_path}/config.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/config.sh.erb'),
    require                 => File[$restic_path]
  }

# create restic password file
  file { "${restic_path}/password":
    ensure                  => 'file',
    mode                    => '0600',
    content                 => $restic_password,
    require                 => File[$restic_path]
  }


# create restic exclude script
  file { "${restic_path}/exclude_list":
    ensure                  => 'file',
    mode                    => '0600',
    content                 => template('restic/exclude_list.erb'),
    require                 => File[$restic_path]
  }

# Create logration script for backup
  file { '/etc/logrotate.d/restic':
    ensure        => present,
    mode          => '0644',
    source        => 'puppet:///modules/restic/logrotate_restic',
  }

# Create logging directory
  file { '/var/log/restic':
    ensure                  => 'directory',
    mode                    => '0700'
  }

# set random minute if cronrandom=true, this implies hourly backups. 
  if ($cronrandom == true){
     $_cronminute = fqdn_rand(59)
  } else {
     $_cronminute = $cronminute
  }

# Create restic cronjob
  if ($cron == true){
    cron { 'initiate backup':
      command => "${restic_path}/run_backup.sh 2>&1 >> /var/log/restic/cron.log",
      user    => root,
      hour    => $cronhour,
      minute  => $_cronminute
    }
  }

# create restic check script for usage with monitoring tools ( sensu )
  file { "${restic_path}/chkrestic.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/chkrestic.sh.erb'),
    require                 => File[$restic_path]
  }

# create chkrestic symlink for running manual commands
  file { "/usr/bin/chkrestic":
    ensure                  => link,
    target                  => "${restic_path}/chkrestic.sh",
    require                 => File["${restic_path}/chkrestic.sh"]
  }

# create restic run script for backups using crontab
  if ($restic_keep_prune_job_random == true){
    $prune_hour = fqdn_rand(23)
    $prune_weekday = fqdn_rand(6)
  } else {
    $prune_hour = $restic_keep_prune_job_hour
    $prune_weekday = $restic_keep_prune_job_weekday
  }

  file { "${restic_path}/run_backup.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/run_backup.sh.erb'),
    require                 => File[$restic_path]
  }

# create restic run script for running manual commands
  file { "${restic_path}/run_restic.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/run_restic.sh.erb'),
    require                 => File[$restic_path]
  }

# create restic symlink for running manual commands
  file { "/usr/bin/restic":
    ensure                  => link,
    target                  => "${restic_path}/run_restic.sh",
    require                 => File["${restic_path}/run_restic.sh"]
  }


# add restore script to /usr/local/sbin/restore.sh when restorescript = true
  if ($restic::restorescript == true){
    class { 'restic::restore': }
  }


# Add entries to sudoers sensu user must start check using sudo permissions
  augeas { "sudochkbackup":
    context => "/files/etc/sudoers",
    changes => [
      "set Cmnd_Alias[alias/name = 'RESTICSERVICES']/alias/name RESTICSERVICES",
      "set Cmnd_Alias[alias/name = 'RESTICSERVICES']/alias/command[1] '${restic_path}/chkrestic.sh'",
      "set spec[user = 'sensu']/user sensu",
      "set spec[user = 'sensu']/host_group/host ALL",
      "set spec[user = 'sensu']/host_group/command RESTICSERVICES",
      "set spec[user = 'sensu']/host_group/command/runas_user root",
      "set spec[user = 'sensu']/host_group/command/tag NOPASSWD",
      ],
  }


# export check so sensu monitoring can make use of it
  @@sensu::check { 'Check Restic Backup' :
    command => "sudo ${restic_path}/chkrestic.sh",
    tag     => 'central_sensu',
  }


}
