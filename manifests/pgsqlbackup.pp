# == Class: restic::pgsqlbackup
#
# Mysql backup script class
#
class restic::pgsqlbackup(
){

# create mysql directory in backuprootfolder
  file {"${restic::backuprootfolder}/pgsql":
    ensure                  => 'directory',
    mode                    => '0700',
    require                 => File[$restic::backuprootfolder]
  }

# Create pqsql backup script
  file {"${restic::restic_path}/pgsqlbackup.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/pgsqlbackup.sh.erb')
  }

}
