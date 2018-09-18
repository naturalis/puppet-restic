# == Class: role_backup::mysqlbackup
#
# Mysql backup script class
#
class restic::mysqlbackup(
  $mysqlalldatabases    = undef,
  $mysqldatabasearray   = undef,
  $mysqlbackupuser      = undef,
  $mysqlbackuppassword  = undef,
  $backuprootfolder     = undef,
){

# create mysql directory in backuprootfolder
  file {"${backuprootfolder}/mysql":
    ensure                  => 'directory',
    mode                    => '0700',
    require                 => File[$backuprootfolder]
  }

# create mysql backup script from template
  file {'/usr/local/sbin/mysqlbackup.sh':
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/mysqlbackup.sh.erb')
  }

}
