CLASSIC_WB = ClassicWB_FULL_v28
AMIGA_FOREVER = ~/amigaforever
# CLASSIC_WB = ClassicWB_ADVSP_v28
CLASSICWB_URL = http://download.abime.net/classicwb/$(CLASSIC_WB).zip
HDF = build/System.hdf
GEOMETRY="chs=16278,15,62"

WHDLOAD_SUBDIRS := 0 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
WHDLOAD_DIRS := $(foreach dir,$(WHDLOAD_SUBDIRS),build/whdload/$(dir))
WHDLOAD_ZIPS := $(foreach dir,$(WHDLOAD_SUBDIRS),tmp/whdload/$(dir))

DEMO_SUBDIRS := 0-D E-L M-R S-Z
DEMO_DIRS := $(foreach dir,$(DEMO_SUBDIRS),build/demos/$(dir))


all: dh0 dh1 dh2


whdload_packs: $(WHDLOAD_DIRS)
demo_packs: $(DEMO_DIRS)
	
build:
	mkdir build

build/whdload: build
	[ -d "build/whdload" ] || mkdir "build/whdload"

build/demos: build
	[ -d "build/demos" ] || mkdir "build/demos"

tmp/$(CLASSIC_WB).zip: tmp
	[ -f "$@" ] || wget $(CLASSICWB_URL) -O $@

clean:
	rm -rf build

build/$(CLASSIC_WB): tmp/$(CLASSIC_WB).zip
	unzip $< -d build

tmp:
	mkdir tmp

tmp/whdload: tmp
	[ -d "tmp/whdload" ] || mkdir "tmp/whdload"

tmp/demos: tmp
	[ -d "tmp/demos" ] || mkdir "tmp/demos"

tmp/whdload/%.zip: tmp/whdload
	[ -f "$@" ] || wget http://kg.whdownload.com/kgwhd/files/GamePacks/WHDLoad%20Games%20Pack%20$(basename $(@F))%20-%202009-05-28.zip -O $@

tmp/demos/%.zip: tmp/demos
	[ -f "$@" ] || wget http://kg.whdownload.com/kgwhd/files/DemoPacks/WHDLoad%20Demos%20Pack%20$(basename $(@F))%20-%202009-06-01.zip -O $@

build/whdload/%: build/whdload tmp/whdload/%.zip
	@if [ ! -d "$@" ]; then \
		unzip tmp/whdload/$(@F).zip -d $@; \
		unzip "build/whdload/$(@F)/*.zip" -d build/whdload/$(@F); \
		rm build/whdload/$(@F)/*.zip; \
	fi

build/demos/%: build/demos tmp/demos/%.zip
	@if [ ! -d "$@" ]; then \
		unzip tmp/demos/$(@F).zip -d $@; \
		unzip "build/demos/$(@F)/*.zip" -d build/demos/$(@F); \
		rm build/demos/$(@F)/*.zip; \
	fi

tmp/pfs3aio.lha: tmp
	[ -f "$@"] || wget http://aminet.net/disk/misc/pfs3aio.lha -O tmp/pfs3aio.lha

build/pfs3aio: tmp/pfs3aio.lha
	@if [ ! -d "$@" ]; then \
		echo "got called"; \
		mkdir $@; \
		cp $< $@; \
		cd $@ && lha x pfs3aio.lha && cd -; \
		rm $@/pfs3aio.lha; \
	fi

$(HDF): build
	rdbtool $(HDF) create $(GEOMETRY)
	rdbtool $(HDF) open $(GEOMETRY) + init + info
	rdbtool $(HDF) open $(GEOMETRY) + add size=500Mib max_transfer=0x1fe00 dostype=ffs bootable=true automount=true + \
		add size=500Mib max_transfer=0x1fe00 dostype=ffs + \
		add size=4Gib dostype=ffs max_transfer=0x1fe00

dh0: build/$(CLASSIC_WB) $(HDF)
	xdftool $(HDF) open $(GEOMETRY) part=0 + format System
	xdftool -v -f $(HDF) open $(GEOMETRY) part=0 + \
		repack build/$(CLASSIC_WB)/System.hdf

dh1: $(DEMO_DIRS) $(HDF)
	xdftool -v -f $(HDF) open $(GEOMETRY) part=1 + \
		format Demos
		# pack build/demos

dh2: $(WHDLOAD_DIRS) $(HDF)
	xdftool -v -f $(HDF) open $(GEOMETRY) part=2 + \
		format Games

.PHONY: clean_up_whdload
clean_up_whdload:
	# Fr De It Es
	find build/whdload -maxdepth 2 -regex ".*/*Fr" -exec rm -rf {} +
	find build/whdload -maxdepth 2 -regex ".*/*Fr.info" -exec rm {} +
	find build/whdload -maxdepth 2 -regex ".*/*De" -exec rm -rf {} +
	find build/whdload -maxdepth 2 -regex ".*/*De.info" -exec rm {} +
	find build/whdload -maxdepth 2 -regex ".*/*It" -exec rm -rf {} +
	find build/whdload -maxdepth 2 -regex ".*/*It.info" -exec rm {} +
	find build/whdload -maxdepth 2 -regex ".*/*Es" -exec rm -rf {} +
	find build/whdload -maxdepth 2 -regex ".*/*Es.info" -exec rm {} +
	find build/whdload -maxdepth 2 -regex ".*/*CDTV" -exec rm -rf {} +
	find build/whdload -maxdepth 2 -regex ".*/*CDTV.info" -exec rm {} +

.PRECIOUS: tmp/demos/%.zip tmp/whdload/%.zip tmp/%.zip tmp/%.lha build/pfs3aio/%
