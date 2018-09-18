# == Class: restic::pgsqlbackup
#
# Mysql backup script class
#
class restic::pgsqlbackup(
  $pgsqlalldatabases    = undef,
  $pgsqldatabasearray   = undef,
  $pgsqlbackupuser      = undef,
  $backuprootfolder     = undef,
  $pgsqlprebackupvacuum = undef,
){

# create mysql directory in backuprootfolder
  file {"${backuprootfolder}/pgsql":
    ensure                  => 'directory',
    mode                    => '0700',
    require                 => File[$backuprootfolder]
  }

# Create pqsql backup script
  file {'/usr/local/sbin/pgsqlbackup.sh':
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/pgsqlbackup.sh.erb')
  }

}
