#!/bin/sh
declare -a ALIASES
declare -a VALID
declare -a VALID_UNTIL
declare -a STATUS
ALIASES_RAW=""
VALID_RAW=""
counter=0
TIMEOUT="timeout -k 10s 5s"
KEYTOOL="$TIMEOUT keytool"
PASSWORD=""
CRITICAL=15
WARNING=60
CRITICAL_CHECK=0
WARNING_CHECK=0
exitcode=0

ARGS=`getopt -o "k:p:c:w:h" -l "keystore:,password:,critical:,warning:,help" -n "$0" -- "$@"`

function usage {
		echo "$0 -k <keystore> [-p <password>] [-c <Days>] [-w <Days>]"
		echo
		echo "-k, --keystore	Path of keystore. Example: /tmp/java/keystore.jks"
		echo
		echo "-p, --password	Password to open the keystore."
		echo
		echo "-c, --critical	Defines the critical expiration. (Default 15)"
		echo
		echo "-w, --warning	Defines the warning for expiration. (Default 60)"
        exit 0
}

function start {
	ALIASES_RAW=`echo $PASSWORD | $KEYTOOL -list -v -keystore "$KEYSTORE" 2>/dev/null | grep Alias | awk '{print $3}'`
	readarray -t ALIASES <<<"$ALIASES_RAW"
	VALID_RAW=`echo $PASSWORD | $KEYTOOL -list -v -keystore "$KEYSTORE" 2>/dev/null | grep Valid`
	readarray -t VALID <<<"$VALID_RAW"

	for i in "${VALID[@]}"
	do
		VALID_UNTIL[$counter]=`echo $i | perl -ne 'if(/until: (.*?)\n/) { print "$1\n"; }'`
		counter=`expr $counter + 1`
	done
	counter=0
	for i in "${VALID_UNTIL[@]}"
	do
		VALID_UNTIL_SECONDS=`date -d "$i" +%s`
		SECONDS_REMAINING=$(($VALID_UNTIL_SECONDS - $(date +%s)))
		DAYS_REMAINING=$(($SECONDS_REMAINING / 60 / 60 / 24 ))
		if [ $DAYS_REMAINING -le $CRITICAL ]; then
			CRITICAL_CHECK=1
			STATUS[$counter]=`echo -e "${ALIASES[$counter]}=[\e[31mCRITICAL\e[0m] $DAYS_REMAINING day(s)"`
		elif [ $DAYS_REMAINING -le $WARNING ]; then
			WARNING_CHECK=1
			STATUS[$counter]=`echo -e "${ALIASES[$counter]}=[\e[33mWARNING\e[0m] $DAYS_REMAINING day(s)"`
		elif [ $DAYS_REMAINING -gt $WARNING ]; then
			STATUS[$counter]=`echo -e "${ALIASES[$counter]}=[\e[32mOK\e[0m] $DAYS_REMAINING day(s)"`
		fi
		counter=`expr $counter + 1`
	done
	if [ $CRITICAL_CHECK -eq 1 ]; then
		echo -e "\e[31mCRITICAL\e[0m"
		exitcode=2
	elif [ $WARNING_CHECK -eq 1 ]; then
		echo -e "\e[33mWARNING\e[0m"
		exitcode=1
	elif [ $CRITICAL_CHECK -eq 0 -a $WARNING_CHECK -eq 0 ]; then
		echo -e "\e[32mOK\e[0m"
		exitcode=0
	fi
	for i in "${STATUS[@]}"
	do
	echo $i
	done
	exit $exitcode
}

eval set -- "$ARGS"

while true
do
	case "$1" in
		-k|--keystore)
                        if [ ! -f "$2" ]; then echo "Keystore not found: $1"; exit 1; else KEYSTORE=$2; fi
                        shift 2;;
		-p|--password)
			if [ -n "$2" ]; then PASSWORD="$2"; else echo "Invalid password"; exit 1; fi
			shift 2;;
		-c|--critical)
			if [ -n "$2" ] && [[ $2 =~ ^[0-9]+$ ]]; then CRITICAL=$2; else echo "Invalid threshold"; exit 1; fi
			shift 2;;
		-w|--warning)
			if [ -n "$2" ] && [[ $2 =~ ^[0-9]+$ ]]; then WARNING=$2; else echo "Invalid threshold"; exit 1; fi
			shift 2;;
		-h|--help)
			usage;;
		--)
			shift
			break;;
	esac
done
 
if [ -n "$KEYSTORE" ]; then
        start
else
        usage
fi
