usage(){
    echo "fdmctl init: initialize the config directory."
    echo "fdmctl list: list available X sessions."
    echo "fdmctl cache: list cached files."
    echo "fdmctl check <session>: see what <session> is."
    echo "fdmctl default [session]: show/set default X session."
    echo "fdmctl add <name> <path> [X(default)/extra]: add a session."
    echo "fdmctl enable/disable <session>: enable/disable session."
    exit
}

check(){
    readlink "$1" || cat "$1"
}

if [ ! -n "$1" ]
then
    usage
    exit
fi


case "$1" in
    init)
        shift
        init "$@"
        ;;
    list)
        echo "X session list : "
        for session in ${X}/*; do
            [ -x "$session" ] && echo $(basename "$session")
        done
        echo ""
	echo "Wayland session list : "
        for session in ${WAYLAND}/*; do
            [ -x "$session" ] && echo $(basename "$session")
        done
        echo ""
        echo "Other session list : "
        for session in ${EXTRA}/*; do
            [ -x "$session" ] && echo $(basename "$session")
        done
        ;;
    cache)
        for file in "$CACHEDIR"/*; do
            fn=$(basename "$file")
            echo ${fn:1}
        done
        ;;
    default)
        if [ ! -n "$2" ]
	then
            echo "Checking $(readlink ${DEFAULT})"
            check $(readlink ${DEFAULT})
	elif [ ! -n "$3" ]
	then
            if [ -x "${X}/$2" ]
	    then
		echo "Setting default to $2"
		ln -sf "${X}/$2" "${DEFAULT}"
	    elif [ -x "${WAYLAND}/$2" ]
	    then
		echo "Setting default to $2"
		ln -sf "${WAYLAND}/$2" "${DEFAULT}"
	    elif [ -x "${EXTRA}/$2" ]
	    then
		echo "Setting default to $2"
		ln -sf "${EXTRA}/$2" "${DEFAULT}"
            else
		echo "fdmctl error: $2 is not available"
            fi
	elif [ ! -n "$4" ]
	then
	    if [ -x "$CONFDIR/$2/$3" ]
	    then
		echo "Setting default to $3"
		ln -sf "$CONFDIR/$2/$3" "${DEFAULT}"
            else
		echo "fdmctl error: $2/$3 is not available"
            fi
	else
	    echo "fdmctl error: syntaxe is fdmctl default [ [ folder ] session ]"
	    usage
        fi
        ;;
    check)
        if [ ! -n "$2" ]
	then usage
        fi
        if [ -f "${X}/$2" ]
	then check "${X}/$2"
        elif [ -f "${WAYLAND}/$2" ]
	then check "${WAYLAND}/$2"
	elif [ -f "${EXTRA}/$2" ]
	then check "${EXTRA}/$2"
        else
	    echo "$2 not exist!"
	    exit 1
        fi
        ;;
    add)
        [ -n "$3" ]||usage
        if [[ "$4" == "X" || "$4" == "x" || "$4" == "" ]]
	then ln -s "$3" "${X}/$2"
	elif [ "$4" = "wayland" ] || [ "$4" = "w" ] || [ "$4" = "W" ]
	then ln -s "$3" "${WAYLAND}/$2"
        elif [ "$4" = "extra" ] || [ "$4" = "e" ] || [ "$4" = "E" ]
	then ln -s "$3" "${EXTRA}/$2"
        else usage
        fi
        ;;
    enable)
        if [ -f "${CACHEDIR}/X$2" ]
	then cp -v "${CACHEDIR}/X$2" "${X}/$2"
        fi
	if [ -f "${CACHEDIR}/W$2" ]
	then cp -v "${CACHEDIR}/W$2" "${WAYLAND}/$2"
        fi
        if [ -f "${CACHEDIR}/E$2" ]
	then mv -v "${CACHEDIR}/E$2" "${EXTRA}/$2"
        fi
        ;;
    disable)
        if [ ! -d "${CACHEDIR}" ]
	then mkdir -p "${CACHEDIR}"
        fi
        # backup to cache
        if [ -f "${X}/$2" ]
	then mv -v "${X}/$2" "${CACHEDIR}/X$2"
        fi
	if [ -f "${WAYLAND}/$2" ]
	then mv -v "${WAYLAND}/$2" "${CACHEDIR}/W$2"
        fi
        if [ -f "${EXTRA}/$2" ]
	then mv -v "${EXTRA}/$2" "${CACHEDIR}/E$2"
        fi
        ;;
    *)
        usage
        ;;
esac
