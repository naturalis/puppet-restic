# == Class: role_backup::mysqlbackup
#
# Mysql backup script class
#
class restic::mysqlbackup(
){

# create mysql directory in backuprootfolder
  if ($restic::ensure_backuprootfolder == true ) {
    file { "Mysql folder in backup root":
      ensure                  => 'directory',
      mode                    => '0700',
      path                    => "${restic::backuprootfolder}/mysql",
      require                 => File[$restic::backuprootfolder]
    }
  }

# create mysql backup script from template
  file {"${restic::restic_path}/mysqlbackup.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/mysqlbackup.sh.erb')
  }

# Create mysql password file
  file {"${restic::restic_path}/mysqlpasswd":
    ensure                  => 'file',
    mode                    => '0600',
    content                 => template('restic/mysqlpasswd.erb')
  }


}
