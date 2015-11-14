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

if [ ! -n "$1" ]; then
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
        for session in "$CONFDIR/${X}"/*; do
            [ -x "$session" ] && echo $(basename "$session")
        done
        echo
        echo "Other session list : "
        for session in "$CONFDIR/$EXTRA"/*; do
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
            echo "Checking $(readlink "$CONFDIR/default")"
            check $(readlink "$CONFDIR/default")
	elif [ ! -n "$3" ]
	then
            if [ -x "$CONFDIR/${X}/$2" ]
	    then
		echo "Setting default to $2"
		ln -sf "$CONFDIR/${X}/$2" "$CONFDIR/default"
	    elif [ -x "$CONFDIR/$EXTRA/$2" ]
	    then
		echo "Setting default to $2"
		ln -sf "$CONFDIR/$EXTRA/$2" "$CONFDIR/default"
            else
		echo "fdmctl error: $2 is not available"
            fi
	elif[ ! -n "$4" ]
	then
	    if [ -x "$CONFDIR/$2/$3" ]
	    then
		echo "Setting default to $3"
		ln -sf "$CONFDIR/$2/$3" "$CONFDIR/default"
            else
		echo "fdmctl error: $2/$3 is not available"
            fi
	else
	    echo "fdmctl error: syntaxe is fdmctl default [ [ folder ] interface ]"
	    usage
        fi
        ;;
    check)
        if [ ! -n "$2" ]; then
            usage
        fi
        FILE="$CONFDIR/${X}/$2"
        if [ -f "$FILE" ]; then
            check "$FILE"
        else
	    FILE="$CONFDIR/$EXTRA/$2"
            if [ -f "$FILE" ]; then
		check "$FILE"
            else
		echo "$2 not exist!"
		exit 1
            fi
        fi
        ;;
    add)
        [ -n "$3" ]||usage
        if [[ "$4" == "X" || "$4" == "" ]]; then
            ln -s "$3" "${CONFDIR}/${X}/$2"
        elif [ "$4" == "extra" ]; then
            ln -s "$3" "${CONFDIR}/$EXTRA/$2"
        else
            usage
        fi
        ;;
    enable)
        if [ -f "${CACHEDIR}/X$2" ]; then
            cp -v "${CACHEDIR}/X$2" "${CONFDIR}/${X}/$2"
        fi
        if [ -f "${CACHEDIR}/E$2" ]; then
            mv -v "${CACHEDIR}/E$2" "${CONFDIR}/$EXTRA/$2"
        fi
        ;;
    disable)
        if [ ! -d "${CACHEDIR}" ]; then
            mkdir -p "${CACHEDIR}"
        fi
        # backup to cache
        if [ -f "${CONFDIR}/${X}/$2" ]; then
            mv -v "${CONFDIR}/${X}/$2" "${CACHEDIR}/X$2"
        fi
        if [ -f "${CONFDIR}/$EXTRA/$2" ]; then
            mv -v "${CONFDIR}/$EXTRA/$2" "${CONFDIR}/E$2"
        fi
        ;;
    *)
        usage
        ;;
esac
