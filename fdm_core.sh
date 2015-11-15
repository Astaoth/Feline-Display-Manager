


prglist=()
DEFOPT=""

# XID: X session Number
# WID: Wayand session number
# TOTAL: Number of items
# sid : id that user selects

if [ -e "${DEFAULT}" ]
then DEFAULTWM=$(basename $(readlink ${DEFAULT}))
fi


if [ -d ${X} ]
then
    for script in "${X}"/*
    do
	if [ -x "${script}" ]
	then
	    xsessions[$XID]="${script}"
	    NAME=$(basename ${script})
	    prglist=(${prglist[@]} ${XID} ${NAME})
	    if [ "${NAME}" = ${DEFAULTWM} ]
	    then
		DEFOPT="--default-item ${XID}"
	    fi
	    let XID=$(($XID+1))
	    let TOTAL=$(($TOTAL+1))
	fi
    done
else
    echo "${X} doesn't exist."
    echo "making this directory."
    mkdir -p ${X}
fi

let WID=$XID
if [ -d ${WAYLAND} ]
then
    for script in "${WAYLAND}"/*
    do
	if [ -x "${script}" ]
	then
	    xsessions[$WID]="${script}"
	    NAME=$(basename ${script})
	    prglist=(${prglist[@]} ${WID} ${NAME})
	    if [ "${NAME}" = ${DEFAULTWM} ]
	    then
		DEFOPT="--default-item ${WID}"
	    fi
	    let WID=$(($WID+1))
	    let TOTAL=$(($TOTAL+1))
	fi
    done
else
    echo "${WAYLAND} doesn't exist."
    echo "making this directory."
    mkdir -p ${WAYLAND}
fi

if [ -d ${EXTRA} ]
then
    for script in "${EXTRA}"/*
    do
	if [ -x "${script}" ]
	then
	    xsessions[$TOTAL]="${script}"
	    NAME=$(basename ${script})
	    prglist=(${prglist[@]} ${TOTAL} ${NAME})
	    if [ "${NAME}" = ${DEFAULTWM} ]
	    then
		DEFOPT="--default-item ${TOTAL}"
	    fi
	    let TOTAL=$(($TOTAL+1))
	fi
    done
else
    echo "${EXTRA} doesn't exist."
    echo "making this directory."
    mkdir -p ${EXTRA}	
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
	echo "This is FDM version \"${VERSION}\"."
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
	if [ ${XID} -ne ${WID} ]; then
		echo "Wayland sessions : "
		while [ ${_i} -lt ${WID} ]
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

