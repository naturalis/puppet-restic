# == Class: role_backup::mysqlbackup
#
# Mysql backup script class
#
class restic::mysqlbackup(
){

# create mysql directory in backuprootfolder
  file {"${restic::backuprootfolder}/mysql":
    ensure                  => 'directory',
    mode                    => '0700',
    require                 => File[$restic::backuprootfolder]
  }

# create mysql backup script from template
  file {"${restic::restic_path}/mysqlbackup.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/mysqlbackup.sh.erb')
  }

}
