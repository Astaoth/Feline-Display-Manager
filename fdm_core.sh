


prglist=()
DEFOPT=""

# XID: X session Number
# TOTAL: Number of items
# sid : id that user selects

if [ -d ${SESSIONS} ]; then
	if [ -n "${SDEFAULT}" ]; then
		DEFAULTWM=$(basename ${SDEFAULT})
	fi

	for script in "${SESSIONS}"/*; do
		if [ -x "${script}" ]; then
			xsessions[$XID]="${script}"
			NAME=$(basename ${script})
			prglist=(${prglist[@]} ${XID} ${NAME})
			if [ "${NAME}" == ${DEFAULTWM} ]; then
				DEFOPT="--default-item ${XID}"
			fi
			let XID=$(($XID+1))
			let TOTAL=$(($TOTAL+1))
		fi
	done
else
	echo "${SESSIONS} doesn't exist."
	echo "making this directory."
	mkdir -p ${SESSIONS}
fi

if [ -d ${EXTRA} ]; then
	for script in "${EXTRA}"/*; do
		if [ -x "${script}" ]; then
			xsessions[$TOTAL]="${script}"
			NAME="extra/$(basename ${script})"
			prglist=(${prglist[@]} ${TOTAL} ${NAME})
			let TOTAL=$(($TOTAL+1))
		fi
	done
else
	echo "${EXTRA} doesn't exist."
	echo "making this directory."
	mkdir -p ${EXTRA}
fi	
fi

if [ $TOTAL -eq 0 ]; then
	fallback "No sessions found."
fi

fdm_ncurses(){
	sid=$(dialog --stdout ${DEFOPT} --menu "FDM ${VERSION}" 0 0 0 ${prglist[@]})
	[ -n "$sid" ]||fallback "Falling back to shell."
}

fdm_text(){
	clear
	echo "This is FDM ${VERSION}, a tiny display manager."
	echo 'Please select a session.'

	local _i=0
	if [ ${XID} -gt 0 ]; then
		echo "X sessions : "
		while [ ${_i} -lt ${XID} ]
		do
			echo ${_i} ${prglist[${_i}*2+1]}
			let _i=${_i}+1
		done
	fi
	echo ""
	if [ ${XID} -lt ${TOTAL} ]; then
		echo "Other sessions : "
		while [ ${_i} -lt ${TOTAL} ]
		do
			echo ${_i} ${prglist[${_i}*2+1]}
			let _i=${_i}+1
		done
	fi

	echo -n "Program ID (default ${DEFAULTWM}) : "
	read sid
}

