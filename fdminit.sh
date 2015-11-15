
init(){
	[[ "$1" = "-f" || "$1" = "--force" ]]&&rm -rf "${CONFDIR}"
	# build the directory tree if not exist
	if [[ ! -d "${CONFDIR}" ]]; then
		cp -Rv "${PREFIX}/share/fdm" "${CONFDIR}"
	else
		echo "Nothing done."
	fi
}

