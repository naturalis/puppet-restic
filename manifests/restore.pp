# == Class: role_backup::restore
#
#
class restic::restore
{

# Define restore command
  if ($restic::restorefromclient == undef){
    $_restore_command = "restic restore -H \$HOST latest --target / --include ${restic::restoreinclude}"
  }else{
    $_restore_command = "restic restore -H ${restic::restorefromclient} latest --target / --include ${restic::restoreinclude}"
  }


# create restore script from template
  file {"${restic::restic_path}/restore.sh":
    mode         => '0700',
    content      => template('restic/restore.sh.erb')
  }

# install restore cron if true
 if ($restic::restorecron == 'true'){
    cron { 'initiate restore':
      command => "${restic::restic_path}/restore.sh",
      user    => root,
      hour    => $restic::restorecronhour,
      minute  => $restic::restorecronminute,
      weekday => $restic::restorecronweekday,
      monthday => $restic::restorecronmonthday
    }
  }
}
