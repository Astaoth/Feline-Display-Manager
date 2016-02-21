PREFIX=/usr/local
#PREFIX=/opt/fdm/
OBJECTS=fdm fdmctl fdm_core fdm.cfg header.tmp
BINARIES=fdm fdmctl fdm_core
DESTDIR=

all: ${OBJECTS}

header.tmp: header
	cat header > header.tmp
	echo "source ${PREFIX}/etc/fdm.cfg" >> header.tmp

fdm.cfg: fdm-config
	echo "#PREFIX" > fdm.cfg
	echo "#Dont touch this variable, unless you want to move change your fdm prefix" >> fdm.cfg
	echo "PREFIX=${PREFIX}" >> fdm.cfg
	echo "" >> fdm.cfg
	cat fdm-config >> fdm.cfg

fdmctl: fdminit.sh fdmctl.sh header.tmp
	cat header.tmp fdminit.sh fdmctl.sh > fdmctl

fdm: header.tmp fdm.sh
	cat header.tmp fdm.sh > fdm

fdm_core: header.tmp fdm_core.sh
	cat header.tmp fdm_core.sh > fdm_core

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	install ${BINARIES} ${DESTDIR}${PREFIX}/bin/
	mkdir -p ${DESTDIR}${PREFIX}/etc
	install fdm.cfg ${DESTDIR}${PREFIX}/etc/
	install -d ${DESTDIR}${PREFIX}/share/fdm/X
	install -d ${DESTDIR}${PREFIX}/share/fdm/Wayland
	install -d ${DESTDIR}${PREFIX}/share/fdm/extra
	cp -Rv cfg/* ${DESTDIR}${PREFIX}/share/fdm/
	cat WMLIST|while read NAME DEST; \
	do \
		ln -s "$${DEST}" "${DESTDIR}${PREFIX}/share/fdm/$${NAME}"; \
	done 
	install -Dm644 bash_comp ${DESTDIR}/usr/share/bash-completion/completions/fdmctl
	install -Dm644 zsh_comp ${DESTDIR}/usr/share/zsh/site-functions/_fdmctl

uninstall:
	rm -f ${PREFIX}/bin/fdm
	rm -f ${PREFIX}/bin/fdmctl
	rm -f ${PREFIX}/bin/fdm_core
	rm -f ${PREFIX}/etc/fdm.cfg
	rm -rf ${PREFIX}/share/fdm
	rm -f /usr/share/bash-completion/completions/fdmctl
	rm -f /usr/share/zsh/site-functions/_fdmctl

clean:
	rm header.tmp fdm.cfg fdmctl fdm fdm_core

.PHONY: clean all install uninstall
