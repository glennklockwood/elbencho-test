.PHONY: default

ELB_VERSION = 57ed7b6bf5c144bb70e5eb119bb4248b06b328ec
ELB_MAKE_FLAGS = BUILD_STATIC=0 LIBAIO_SUPPORT=1 LIBNUMA_SUPPORT=1
ELB_MAKE_FLAGS = BUILD_STATIC=1 LIBAIO_SUPPORT=0 

default: elbencho/bin.perlmutter/elbencho

elbencho:
	git clone https://github.com/glennklockwood/elbencho.git "$@" && cd elbencho && git checkout $(ELB_VERSION)

elbencho/bin.%/: elbencho
	(if [ -d "$@" ]; then touch "$@"; else mkdir -v "$@"; fi)

elbencho/bin.%/elbencho: elbencho/bin.%/
	(cd elbencho && \
    make $(ELB_MAKE_FLAGS) LDFLAGS_BOOST="-L$(BOOST_LIB) -L$(LIBNUMA_LIB_PATH) -lboost_program_options -lboost_system -lboost_thread")
	mv -v elbencho/bin/* "$<"
