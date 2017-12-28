CLASSIC_WB = ClassicWB_FULL_v28
AMIGA_FOREVER = ~/amigaforever
# CLASSIC_WB = ClassicWB_ADVSP_v28
CLASSICWB_URL = http://download.abime.net/classicwb/$(CLASSIC_WB).zip
HDF = build/System.hdf
GEOMETRY="chs=16278,15,62"

WHDLOAD_SUBDIRS := 0 A 
WHDLOAD_DIRS := $(foreach dir,$(WHDLOAD_SUBDIRS),build/whdload/$(dir))
WHDLOAD_ZIPS := $(foreach dir,$(WHDLOAD_SUBDIRS),tmp/whdload/$(dir))


all: dh0 dh1 dh2


whdload_packs: $(WHDLOAD_DIRS)
	
build:
	mkdir build

build/whdload: build
	mkdir build/whdload

build/$(CLASSIC_WB).zip: build
	curl -o $@ $(CLASSICWB_URL)

clean:
	rm -rf build

build/$(CLASSIC_WB): build/$(CLASSIC_WB).zip
	unzip $< -d build

tmp:
	mkdir tmp

tmp/whdload: tmp
	[ -d "tmp/whdload" ] || mkdir "tmp/whdload"

tmp/whdload/%.zip: tmp/whdload
	[ -f "$@" ] || wget http://kg.whdownload.com/kgwhd/files/GamePacks/WHDLoad%20Games%20Pack%20$(basename $(@F))%20-%202009-05-28.zip -O $@

build/whdload/%: build/whdload tmp/whdload/%.zip
	@if [ ! -d "$@" ]; then \
		unzip tmp/whdload/$(@F).zip -d $@; \
		unzip "build/whdload/$(@F)/*.zip" -d build/whdload/$(@F); \
		rm build/whdload/$(@F)/*.zip; \
	fi


$(HDF): build
	rdbtool $(HDF) create $(GEOMETRY)
	rdbtool $(HDF) open $(GEOMETRY) + init

dh0: build/$(CLASSIC_WB) $(HDF)
	rdbtool $(HDF) open $(GEOMETRY) + add size=500MiB bootable=1
	xdftool $(HDF) open $(GEOMETRY) part=0 + format System ffs
	xdftool -v -f $(HDF) open $(GEOMETRY) part=0 + repack build/$(CLASSIC_WB)/System.hdf

dh1: $(HDF)
	rdbtool $(HDF) open $(GEOMETRY) + add size=4000MiB bootable=0
	xdftool $(HDF) open $(GEOMETRY) part=1 + format Games ffs

dh2:
	rdbtool $(HDF) open $(GEOMETRY) + add size=2000MiB bootable=0
	xdftool $(HDF) open $(GEOMETRY) part=2 + format Work ffs

.PRECIOUS: tmp/whdload/%.zip
