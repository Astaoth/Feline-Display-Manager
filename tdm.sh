


# TDM, tbk display manager, or tiny display manager,
# is a session selector after login.
# It links the starting script to default and start
# the startx script.


fallback(){
	if [[ -n $1 ]]; then
		echo -e "\033[31;1m$1\033[0m"
	fi
	exec $SHELL
}

warning(){
	if [[ -n $1 ]]; then
		echo -e "\033[31;1m$1\033[0m"
	fi
}

# started from startx, so start session
if [[ -n $1 && $1 = "--xstart" ]]; then
	if [[ -f "${CONFDIR}/tdmexit" ]]; then
		. "${CONFDIR}/tdmexit"
	fi
	if [[ -x "/tmp/tdmdefault" ]]; then
		exec /tmp/tdmdefault
	else
		exec "${CONFDIR}/default"
	fi
fi

# check for a 'good' tty
(basename $(tty)|grep -q tty) || fallback "Invalid tty"

# X started, exit
pgrep X>/dev/null&&fallback 'X started.'

# build confdir
if [ ! -d "${CONFDIR}" ]; then
	tdmctl init
fi

# otherwise, run as the session chosen script
if [[ -f "${CONFDIR}/tdminit" ]]; then
	source "${CONFDIR}/tdminit"
fi

if [[ -x "${CONFDIR}/default" ]]; then
	SDEFAULT=$(readlink "${CONFDIR}/default")
else
	SDEFAULT=
fi

let XID=0
let TOTAL=0
xsessions=()

if ! type dialog > /dev/null 2> /dev/null; then
#no dialog program, force to use tdm_text
	TDMUI=tdm_text
fi

source tdm_core
if [ ! "${TDMUI}" == "tdm_text" ]; then
	TDMUI=tdm_curses
fi
${TDMUI}

rm -f /tmp/tdmdefault
if [[ (-n $sid) && ($sid -lt $TOTAL) && ($sid -ge $XID) ]]; then
	exec ${xsessions[$sid]}
elif [[ (-n $sid) && ($sid -lt $XID) && ($sid -ge 0) ]]; then
	if [[ ${SAVELAST} -ne 0 ]]; then
		ln -sf ${xsessions[${sid}]} "${CONFDIR}/default"
	else
		ln -sf ${xsessions[${sid}]} "/tmp/tdmdefault"
	fi
	startx
	logout
else
	echo "Unknown value,load default."
	if [ -x "${CONFDIR}/default" ]; then
		startx
		logout
	else
		fallback "Session not defined,fallback."
	fi
fi
