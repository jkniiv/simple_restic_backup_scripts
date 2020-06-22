#! /usr/bin/bash
# Forget (or "drop") old Restic backups according to your personal policy.

set -eu
set -o pipefail

# Assumes Scoop (and Restic) has been installed under c:\Scoop ; make sure you use Msys2 unix-style paths!
PATH=${PATH}:/c/scoop/shims
export PATH
restic=/c/scoop/apps/restic/current/restic.exe

# Please configure the following variables according to your needs:

# (1) Repository location; notice that I use Backblaze B2 (EU datacentre). If you wish to use B2, you need
# configure the Rclone "remote" (in my case 'b2eu') in advance with 'rclone config'. The subfolder
# 'restic_destination' under the bucket 'My-restic-bucket' is entirely optional.
repo=rclone:b2eu:My-restic-bucket/restic_destination
# (2) Password file for restic / the repo above; I keep mine under my Windows Documents folder
pwfile=c:/Users/myusernameunderwindows/Documents/my-secret-for-something--really-not-telling.txt
# (3) Arbitrary host name string. I use a random GUID but it could be a simple host name. Optional if you don't
# have multiple computers to backup (but then remember to remove the '--host' flag and parameter below). Must be
# the same you use with 'restic backup' if you want the 'restic forget' operations to target the same dataset.
host=eff74b7e-aaaa-bbbb-cccc-eb5ccexxxxxx

# Tailor the following invocation accordingly. Here I tee all restic output to a log file under ~/restic_recent_logs
# This 'forget' operation makes sure to keep 14 daily, 8 weekly, 20 monthly and 9 yearly backups.
#
# N.B. When it comes to the weekly, monthly and yearly period, remember that Restic considers the last
# backup of that (calendar) period the one to keep (with Sunday as the *last* day of the week), with the most
# recent backup *also* being the very latest weekly, monthly and yearly backup. So for instance with N weekly backups
# you are only able to restore files at most N-1 weeks back and on Mondays closer to N-2 weeks back (because
# the current day also consumes a "keep"). This may feel unintuitive at first.
#
# TL;DR: Always make sure to add 2 to your estimates as to how far your backup you needs to be able to recover files.
# The policy below makes sure you can go *at least* 6 weeks back in weeklies, 18 months back in monthlies and finally
# at least 7 years back in terms of yearlies.
${restic} -r "${repo}" -p "${pwfile}" --verbose=4 \
    forget --host "${host}" --keep-daily 14 --keep-weekly 8 --keep-monthly 20 --keep-yearly 9 2>&1 \
    | tee "${HOME}/restic_recent_logs/forget.LOG"
