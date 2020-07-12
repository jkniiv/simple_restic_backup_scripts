# simple_restic_backup_scripts
These are some simple bash scripts to be used when scheduling a daily backup of your user profile on Windows with Restic. The scripts in the `bin` folder are:

  - restic-run-backup.sh: the main backup script; to be invoked daily from `cron(8)` etc.
  - restic-do-check.sh: a script to check the consistency of the backup repository/destination; to be invoked daily after a successful restic-run-backup.sh
  - restic-forget-according-to-my-policy.sh: a script to maintain the number of daily, weekly, monthly, etc. backups that one wishes to keep and then "forget" or drop the rest; to be invoked daily after a successful restic-do-check.sh
  - restic-execute-pruning-phase.sh: a script to prune the old backups dropped by restic-forget-according-to-my-policy.sh thus reclaiming disk space; to be invoked less frequently than daily – for instance weekly, bi-weekly or monthly – due to its long running time
  
There are some maintenance or recovery scripts in the `bin/maint` folder that can be occasionally useful but don’t need to be scheduled regularly:

  - restic-do-check--read-data.sh: does the same as restic-do-check.sh but calls `restic check` with the `--read-data` flag causing it to go through all the stored data in the backup repository looking for errors (takes a long time)
  - restic-execute-rebuild-index.sh: rebuilds the Restic repository index based on actual stored data a.k.a. pack files; a recovery command that does `restic rebuild-index`
  - restic-run-backup--force.sh: runs the Restic backup proper but this version forces the re-reading of all the files to be backed; a recovery command identical with restic-run-backup.sh except that it that calls `restic backup` with the `--force` flag
