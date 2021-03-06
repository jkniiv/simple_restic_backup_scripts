#! /usr/bin/bash
# Run the Restic backup proper, this time with the --force flag which forces re-reading of the files to be backed.

set -u
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
# the same you use with 'restic forget' if you want the restic forget operations to target the same dataset.
host=eff74b7e-aaaa-bbbb-cccc-eb5ccexxxxxx

# Tailor this invocation accordingly. Here I tee all restic output to a log file under ~/restic_recent_logs
# This 'backup' operation for instance backs up your user profile 'C:\Users\myusernameunderwindows' and
# Scoop persistent settings folder 'C:\scoop\persist'
${restic} -r "${repo}" -p "${pwfile}" --verbose=3 \
    backup --force --host "${host}" 'C:\Users\myusernameunderwindows' 'C:\scoop\persist' 2>&1 \
    | ( iconv -c -t UTF-8 || true ) \
    | tee "${HOME}/restic_recent_logs/backup--force.LOG"

# Restic from version 0.10.0 onward differentiates between fatal errors and incomplete backups with exit
# codes 1 and 3 respectively. We'll assume that incomplete backups due to some files being locked (very common
# on Windows) are still ok. Feel free to adjust to your own needs or even delete this part if so inclined.
rc=$?
if [[ ${rc} == 3 ]]; then
    echo "*** Well, some files could not be backed up but I'm ok with that :)"
    exit 0
else
    exit ${rc}
fi
