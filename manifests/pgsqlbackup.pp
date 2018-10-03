# == Class: restic::pgsqlbackup
#
# Mysql backup script class
#
class restic::pgsqlbackup(
){

# create pgsql directory in backuprootfolder
  if ($restic::ensure_backuprootfolder == true ) {
    file { "pgSQL folder in backup root":
      ensure                  => 'directory',
      mode                    => '0700',
      path                    => "${restic::backuprootfolder}/pgsql",
      require                 => File[$restic::backuprootfolder]
    }
  }

# Create pqsql backup script
  file {"${restic::restic_path}/pgsqlbackup.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/pgsqlbackup.sh.erb')
  }

}
