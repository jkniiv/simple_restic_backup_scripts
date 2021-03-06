#! /usr/bin/bash
# Prunes the Restic repository from old backups that have been dropped with 'restic forget'.

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

${restic} -r "${repo}" -p "${pwfile}" --verbose=4 \
    prune 2>&1 \
    | tee "${HOME}/restic_recent_logs/prune.LOG"
