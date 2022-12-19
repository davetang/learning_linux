#!/usr/bin/env bash
#
# Adapted from Wicked Cool Shell Scripts, 2nd Edition https://nostarch.com/wcss2
#
# Creates either a full or incremental backup of a set of defined directories
# on the system. By default, the output file is compressed and saved in /tmp
# with a timestamped filename. Otherwise, specify an output device (another
# disk, a removable storage device, etc.)
#
set -euo pipefail

usage(){
   >&2 cat <<EOF
Usage: $0 [-o output] [-c compression_tool] [-i|-f] [-n] directory
  -o where to save the archive
  -c specify compression tool, default is bzip2
  -i perform incremental backup
  -f perform full backup
  -n do not update timestamp
EOF
   exit 1
}

get_ts(){
   cat ${tsfile} | grep ${1} | cut -f2 -d',' | tail -1 || true
}

timestamp=$(date +'%Y%m%d%H%M.%S')

# I am unclear of how inclist is used
# defaults
compress="bzip2"
inclist="/tmp/backup.inclist.${timestamp}"
output="/tmp/backup.${timestamp}.bz2"
btype="incremental"
noinc=0

trap "/bin/rm -f ${inclist}" EXIT

while getopts "o:c:ifn" arg; do
   case "${arg}" in
      o) output="${OPTARG}";    ;;
      c) compress="${OPTARG}";  ;;
      i) btype="incremental";   ;;
      f) btype="full";          ;;
      n) noinc=1;               ;;
      *) usage                  ;;
   esac
done

DIR=${@:${OPTIND}:1}
if [[ -z ${DIR} ]]; then
   usage
fi

if [[ ! -x $(command -v ${compress}) ]]; then
   >&2 echo [ Error ] Could not find compression tool ${compress}
   >&2 echo [ Error ] Exiting
   exit 1
fi

shift $(( ${OPTIND} - 1 ))

# file to store timestamps
tsfile="${HOME}/.backup.timestamp"
if [[ ! -f ${tsfile} ]]; then
   >&2 echo Creating ${tsfile}
   touch ${tsfile}
fi

if [ "${btype}" = "incremental" ] ; then

   if [[ -z $(get_ts ${DIR}) ]]; then
      >&2 echo "[ Error ] Can't perform incremental backup of ${DIR}: no timestamp entry"
      >&2 echo "[ Error ] Perform a full backup first"
      >&2 echo "[ Error ] Exiting"
      exit 1
   fi

   latest=$(get_ts ${DIR})
   touch -t ${latest} /tmp/${latest}

   # -depth - Process each directory's contents before the directory itself.
   # -newer file - File was modified more recently than file.
   # -user uname - File is owned by user uname
   # ${LOGNAME} is used as the default user
   to_backup=$(find ${DIR} -depth -type f -newer /tmp/${latest} -user ${USER:-LOGNAME})
   rm /tmp/${latest}
   if [[ -z ${to_backup} ]]; then
      >&2 echo "[ Warn ] Nothing new to backup in ${DIR}"
      >&2 echo "[ Warn ] Exiting"
      exit 0
   fi

   >&2 echo "[ Warn ] Performing ${btype} backup of ${DIR}, saving output to ${output}"
   echo ${to_backup} | \
   # pax - portable archive interchange
   # -w - Write files to the standard output in the specified archive format.
   # -x format - Specify the output archive format.
   pax -w -x tar | ${compress} > ${output}
   failure="$?"
else
   >&2 echo "[ Warn ] Performing ${btype} backup of ${DIR}, saving output to ${output}"
   find ${DIR} -depth -type f -user ${USER:-LOGNAME} | \
   pax -w -x tar | ${compress} > ${output}
   failure="$?"
fi

# update timestamp after successfully archiving
if [ "${noinc}" = "0" -a "${failure}" = "0" ] ; then
   >&2 echo "[ Warn ] Updating ${tsfile}"
   echo "${DIR},${timestamp}" >> ${tsfile}
fi
>&2 echo "[ Warn ] Done"
exit 0
