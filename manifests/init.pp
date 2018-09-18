# == Class: restic
#
#
class restic(
# general options
  $backup                = false,
  $restic_aws_access_key = "XXXXXXXXXXXXXXXXXX",
  $restic_aws_secret_key = "XXXXXXXXXXXXXXXXXX",
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
  $chkwarninghours       = 24,
  $chkcriticalhours      = 48,

# backup options
  $mysqlrestore          = false,
  $mysqlbackup           = false,
  $sambabackup           = false,
  $pgsqlbackup           = false,
  $pgsqlprebackupvacuum  = false,
  $resticcron            = false,
  $pre_command           = undef,
  $resticcronminute      = '*/20',
  $resticcronhour        = '*',
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

)
{

# Create backup location for database dumps or other script related backup files
  file { $restic::restic_path:
    ensure                  => 'directory',
    mode                    => '0700'
  }


# include class and sambascript with sambabackup=true
  if ($restic::sambabackup == true ) {
    $sambascript =  "${restic::restic_path}/sambabackup.sh"
    class { 'restic::sambabackup':
      backuprootfolder      => $restic::backuprootfolder
    }
  }

# include class and mysqlscript with mysqlbackup=true
  if ($restic::mysqlbackup == true ) {
    $mysqlscript =  "${restic::restic_path}/mysqlbackup.sh"
    class { 'restic::mysqlbackup':
      mysqlbackupuser       => $restic::mysqlbackupuser,
      mysqlalldatabases     => $restic::mysqlalldatabases,
      mysqldatabasearray    => $restic::mysqldatabasearray,
      mysqlbackuppassword   => $restic::mysqlbackuppassword,
      backuprootfolder      => $restic::backuprootfolder,
    }
  }

# include class and pgsqlscript with pgsqlbackup=true
  if ($restic::pgsqlbackup == true ) {
    $pgsqlscript =  "${restic::restic_path}/pgsqlbackup.sh"
    class { 'restic::pgsqlbackup':
      pgsqlbackupuser       => $restic::pgsqlbackupuser,
      pgsqlalldatabases     => $restic::pgsqlalldatabases,
      pgsqldatabasearray    => $restic::pgsqldatabasearray,
      backuprootfolder      => $restic::backuprootfolder,
      pgsqlprebackupvacuum  => $restic::pgsqlprebackupvacuum,
    }
  }

# Create array from scripts which will be used in the resticscript.sh
$pre_command_array = [$restic::pre_command, $sambascript, $mysqlscript, $pgsqlscript]


# Create backupscript from template
  if ($restic::backup == true) {
    if ($restic::pre_command_array != '') {
      $backup_script_pre = "backup_script_pre=${restic::restic_path}/resticscript.sh"
      file { "${restic::restic_path}/resticscript.sh":
        ensure                  => 'file',
        mode                    => '0700',
        content                 => template('restic/resticscript.sh.erb'),
        require                 => File[$restic_path]
      }
    }
  }
  
# include restic class
  exec { 'install restic':
    command        => "/usr/bin/wget ${restic_download_url} -O ${restic_path}/${restic_binary}.bz2 && /bin/bzip2 -d ${restic_path}/${restic_binary}.bz2 -C ${restic_path} && chmod +x ${restic_path}/${restic_binary}",
    unless         => "/usr/bin/test -d ${restic_path}/${restic_binary}",
  }

# create restic exclude script
  file { "${restic_path}/exclude_list":
    ensure                  => 'file',
    mode                    => '0600',
    content                 => template('restic/exclude_list.erb'),
    require                 => File[$restic_path]
  }

# create restic check script for usage with monitoring tools ( sensu )
  file { "${restic_path}/chkrestic.sh":
    ensure                  => 'file',
    mode                    => '0777',
    content                 => template('restic/chkrestic.sh.erb'),
    require                 => File[$restic_path]
  }

# export check so sensu monitoring can make use of it
  @@sensu::check { 'Check Backup' :
    command => "${restic_path}/chkrestic.sh",
    tag     => 'central_sensu',
  }

}
