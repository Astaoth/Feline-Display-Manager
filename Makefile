PREFIX=/usr/local
OBJECTS=fdm fdmctl fdm_core
DESTDIR=

all: ${OBJECTS}

fdmctl: fdminit.sh fdmctl.sh header
	echo "PREFIX=${PREFIX}" > hprefix
	cat header hprefix variables fdminit.sh fdmctl.sh > fdmctl

fdm: header fdm.sh
	echo "PREFIX=${PREFIX}" > hprefix
	cat header hprefix variables fdm.sh > fdm

fdm_core: header fdm_core.sh
	echo "PREFIX=${PREFIX}" > hprefix
	cat header hprefix variables fdm_core.sh > fdm_core

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	install ${OBJECTS} ${DESTDIR}${PREFIX}/bin/
	install -d ${DESTDIR}${PREFIX}/share/fdm/sessionsx
	install -d ${DESTDIR}${PREFIX}/share/fdm/extra
	cp -Rv cfg/* ${DESTDIR}${PREFIX}/share/fdm/
	cat WMLIST|while read NAME DEST; \
	do \
		ln -s "$${DEST}" "${DESTDIR}${PREFIX}/share/fdm/$${NAME}"; \
	done 
	install -Dm644 bash_comp ${DESTDIR}/usr/share/bash-completion/completions/fdmctl
	install -Dm644 zsh_comp ${DESTDIR}/usr/share/zsh/site-functions/_fdmctl

uninstall:
	rm -f ${PREFIX}/bin/{fdm,fdmctl,fdm_core}
	rm -rf ${PREFIX}/share/fdm
	rm -f /usr/share/bash-completion/completions/fdmctl
	rm -f /usr/share/zsh/site-functions/_fdmctl

clean:
	rm hprefix fdmctl

.PHONY: clean all install uninstall
