


# FDM, feline display manager is a fork of
# tdm, tbk display manager, or tiny display manager.
# It is a session selector after login.
# It links the starting script to default and start
# the startx script.


fallback(){
    if [[ -n $1 ]]
    then echo -e "\033[31;1m(-) ERROR: $1\033[0m"
    fi
    exec $SHELL
}

warning(){
    if [[ -n $1 ]]
    then echo -e "\033[31;1m/!\\ WARNING: $1\033[0m"
    fi
}

# started from startx, so start session
if [[ -n $1 && $1 = "--xstart" ]]
then
    if [[ -f "${CONFDIR}/fdmexit" ]]
    then . "${CONFDIR}/fdmexit"
    fi
    if [[ -x "/tmp/fdmdefault" ]]
    then exec /tmp/fdmdefault
    else
	exec "${DEFAULT}"
    fi
fi

# check for a 'good' and true tty
(basename $(tty)|grep -q tty) || fallback "Invalid tty"

# X started, informe and continue
# X can be started few times from different tty
if [ $(pgrep X) ]
then
    warning 'X already started.'
    ps aux | grep "Xorg" | grep -v "grep" | while read LINE
    do
	echo -e "\t- X started by user \"$(echo $LINE | tr -s ' ' | cut -d ' ' -f1)\" from tty \"$(echo $LINE | tr -s ' ' | cut -d ' ' -f7)\" on display \"$(echo $LINE | tr -s ' ' | cut -d ' ' -f14)\"."
    done
    read -p "Press enter to continue ..."
fi

# build confdir
if [ ! -d "${CONFDIR}" ]
then fdmctl init
fi

# otherwise, run as the session chosen script
if [[ -f "${CONFDIR}/fdminit" ]]
then source "${CONFDIR}/fdminit"
fi

let XID=0
let WID=0
let TOTAL=0
xsessions=()

if [ $UI = "ncurses" ] && [ $(type dialog 2>/dev/null) ]
then CUR_UI="fdm_ncurses"
else CUR_UI="fdm_text"
fi

source fdm_core
${CUR_UI}

rm -f /tmp/fdmdefault
if [[ (-n $sid) && ($sid -lt $TOTAL) && ($sid -ge $WID) ]]
then
    #extra session
    exec ${xsessions[$sid]}
elif [[ (-n $sid) && ($sid -lt $WID) && ($sid -ge $XID) ]]
then
    #Wayland session
    if [[ ${SAVELAST} -ne 0 ]]
    then
	ln -sf ${xsessions[${sid}]} "${DEFAULT}"
    fi
    exec ${xsessions[$sid]}
elif [[ (-n $sid) && ($sid -lt $XID) && ($sid -ge 0) ]]
then
    #X session
    if [[ ${SAVELAST} -ne 0 ]]; then
	ln -sf ${xsessions[${sid}]} "${DEFAULT}"
    else
	ln -sf ${xsessions[${sid}]} "/tmp/fdmdefault"
    fi
    startx
    logout
else
    #Wrong session value
    echo "Unknown value,load default."
    if [ -x "${DEFAULT}" ]; then
	startx
	logout
    else
	fallback "Session not defined,fallback."
    fi
fi

