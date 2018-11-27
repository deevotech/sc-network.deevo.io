source $(dirname "$0")/env.sh

usage() {
	echo "Usage: $0 [-f <cert file path>]" 1>&2
	exit 1
}
while getopts ":f:" o; do
	case "${o}" in
	f)
		f=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND - 1))
if [ -z "${f}" ]; then
	usage
fi

openssl x509 -in $f -noout -text