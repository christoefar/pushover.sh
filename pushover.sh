#!/bin/sh

# Default config vars
CURL="$(which curl)"
PUSHOVER_URL="https://api.pushover.net/1/messages.json"
TOKEN="" # May be set in pushover.conf or given on command line
USER="" # May be set in pushover.conf or given on command line
CURL_OPTS="--silent --output /dev/null"

# Functions used elsewhere in this script
usage() {
    echo "${0} <options> <message>"
    echo " -c <callback>"
    echo " -d <device>"
    echo " -D <timestamp>"
    echo " -e <expire>"
    echo " -f <config file>"
    echo " -p <priority>"
    echo " -r <retry>"
    echo " -t <title>"
    echo " -T <TOKEN> (required if not in config file)"
    echo " -m <msg_file>"
    echo " -s <sound>"
    echo " -u <url>"
    echo " -U <USER> (required if not in config file)"
    echo " -a <url_title>"
    exit 1
}
opt_field() {
    field=$1
    shift
    value="${*}"
    if [ -n "${value}" ]; then
        echo "-F \"${field}=${value}\""
    fi
}
validate_token() {
	field="${1}"
	value="${2}"
	opt="${3}"
	ret=1
	if [ -z "${value}" ]; then
		echo "${field} is unset or empty: Did you create ${CONFIG_FILE} or specify ${opt} on the command line?" >&2
	elif ! echo "${value}" | grep -E -q '[A-Za-z0-9]{30}'; then
		echo "Value of ${field}, \"${value}\", does not match expected format. Should be 30 characters of A-Z, a-z and 0-9." >&2;
	else
		ret=0
	fi
	return ${ret}
}

send_message() {
    curl_cmd="\"${CURL}\" -s -S \
        ${CURL_OPTS} \
        -F \"token=${TOKEN}\" \
        -F \"user=${USER}\" \
        -F \"message=${message}\" \
        $(opt_field device "${device}") \
        $(opt_field callback "${callback}") \
        $(opt_field timestamp "${timestamp}") \
        $(opt_field priority "${priority}") \
        $(opt_field retry "${retry}") \
        $(opt_field expire "${expire}") \
        $(opt_field title "${title}") \
        $(opt_field sound "${sound}") \
        $(opt_field url "${url}") \
        $(opt_field url_title "${url_title}") \
        \"${PUSHOVER_URL}\""

    # execute and return exit code from curl command
    eval "${curl_cmd}"
    
    r="${?}"
    
    if [ "${r}" -ne 0 ]; then
        echo "${0}: Failed to send message" >&2
    fi

    return
}

# Option parsing
optstring="c:d:D:e:f:p:r:t:T:s:u:U:a:m:h"

# Process the remaining options
OPTIND=1
while getopts ${optstring} c; do
    case ${c} in
        c) callback="${OPTARG}" ;;
        d) device="${device} ${OPTARG}" ;;
        D) timestamp="${OPTARG}" ;;
        e) expire="${OPTARG}" ;;
        p) priority="${OPTARG}" ;;
        r) retry="${OPTARG}" ;;
        t) title="${OPTARG}" ;;
        T) TOKEN="${OPTARG}" ;;
        s) sound="${OPTARG}" ;;
        m) msg_file="${OPTARG}" ;;
        u) url="${OPTARG}" ;;
        U) USER="${OPTARG}" ;;
        a) url_title="${OPTARG}" ;;

        [h\?]) usage ;;
    esac
done
shift $((OPTIND-1))

# Is there anything left?
if [ "$#" -lt 1 ] && [ "$msg_file" = "" ]; then
    usage
fi
message="$*"

# load the rest of the message from the file
if [ "$msg_file" != "" ] ; then
    if [ ! -f "$msg_file" ] ; then
	echo "failed to read message file: $msg_file"
	exit 1
    fi
    message="$message $(cat "$msg_file")"
fi	

# Check for required config variables
if [ ! -x "${CURL}" ]; then
    echo "CURL is unset, empty, or does not point to curl executable. This script requires curl!" >&2
    exit 1
fi
validate_token "TOKEN" "${TOKEN}" "-T" || exit $?
validate_token "USER" "${USER}" "-U" || exit $?

send_message

exit
