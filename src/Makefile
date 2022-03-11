.PHONY: default

ELB_VERSION = c997820d263c229f8932d8f0789489a3233c6bf0

default: elbencho/bin.perlmutter/elbencho

elbencho:
	git clone https://github.com/breuner/elbencho.git "$@" && cd elbencho && git checkout $(ELB_VERSION)

elbencho/bin.%/: elbencho
	(if [ -d "$@" ]; then touch "$@"; else mkdir -v "$@"; fi)

elbencho/bin.%/elbencho: elbencho/bin.%/
	(cd elbencho && \
    module load boost && \
    make LDFLAGS_BOOST="-L$(BOOST_LIB) -lboost_program_options -lboost_system -lboost_thread")
	mv -v elbencho/bin/* "$<"
