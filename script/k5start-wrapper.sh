#!/usr/bin/env bash

# set to "" or unset to turn off debugging
#debug="TRUE"
debug=""

# set to "" or unset to decrease verbosity
#verbose="-v"
verbose=""

if [[ $debug == "TRUE" ]]; then
    set -x
fi

echoerr () {
    printf "$@" >&2
}

# k5start path - assume standard brew path, but you can adjust here
K5START=$(command -v k5start || echo "/opt/homebrew/bin/k5start")

if [[ ! -x $K5START ]]; then
    echoerr "ERROR: k5start not found or not executable at ${K5START}\n"
    exit 1
fi

# refresh if current ticket is less than expire_time in minutes
expire_time=60

# get username
user=${LOGNAME:-$USER}

if [[ -z $user ]]; then
    echoerr "ERROR: LOGNAME nor USER are set! exiting"
    exit 1
fi


# Get current credential cache
if CCNAME=$(klist -f 2>&1); then
    CCNAME=$(echo "${CCNAME}" | grep "Credentials cache:" | cut -d: -f2- | tr -d ' ');
else
    echoerr "ERROR: Failed to get Kerberos credentials cache\n"
    exit 1
fi

# build command array - this avoids bugs with empty arguments
cmd=("${K5START}" -k "${CCNAME}" -u "${user}" -H "${expire_time}")
if [[ -n $verbose ]]; then
    cmd+=("$verbose")
fi

# Run k5start with current cache
exec "${cmd[@]}"
