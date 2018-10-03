# == Class: restic::sambabackup
#
# Samba backup script class
#
class restic::sambabackup(
){

# Create samba directory in backuprootfolder
  if ($restic::ensure_backuprootfolder == true ) {
    file {"${restic::backuprootfolder}/samba":
      ensure                  => 'directory',
      mode                    => '0700',
      require                 => File[$restic::backuprootfolder]
    }
  }


# create samba backup script from template
  file {"${restic::restic_path}/sambabackup.sh":
    ensure                  => 'file',
    mode                    => '0700',
    content                 => template('restic/sambabackup.sh.erb')
  }

}
