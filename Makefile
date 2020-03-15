PWD=$(shell pwd)
FDOS_URL=https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/repositories/latest
LARRY_URL=https://archive.org/download/LeisureSuitLarry1VGA/Leisure%20Suit%20Larry%201%20VGA.iso
P1SIZE=65473

.PHONY: all clean mkout

all: mkout b2l.img

b2l.img: out/b2l.img
	ln -sf out/b2l.img b2l.img

out/p1.img: out/fdroot/kernel.sys out/fdroot/command.com out/fdroot/fdxms.sys out/fdroot/LSL1VGA/SCIDHUV.EXE
	rm -f out/p1.img
	dd if=/dev/zero of=out/p1.img bs=512 count=$(P1SIZE)
	mformat -i out/p1.img -c4 -H63 -L16 ::
	dd if=scripts/fat16.com.bin of=out/p1.img bs=1 count=3 conv=notrunc
	dd if=scripts/fat16.com.bin of=out/p1.img bs=1 skip=62 seek=62 conv=notrunc
	mcopy -i out/p1.img out/fdroot/* ::

out/mbr.img:
	rm -f out/mbr.img
	dd if=/dev/zero of=out/mbr.img bs=512 count=63
	dd if=scripts/fd09mbr.bin of=out/mbr.img conv=notrunc

out/b2l.img: out/mbr.img out/p1.img
	rm -f out/b2l.img
	cat out/mbr.img out/p1.img >out/b2l.img
	cat scripts/b2l.sfdisk | sed "s/@P1SIZE@/$(P1SIZE)/g" | sfdisk out/b2l.img

out/dl/ms-sys-2.6.0.tar.gz:
	wget -O $@ $(MSYS_URL)

out/fdroot/kernel.sys: out/dl/2042.zip
	mkdir -p out/tmp/kernel
	bsdtar -C out/tmp/kernel -xvf $<
	cp out/tmp/kernel/BIN/KERNL386.SYS $@

out/fdroot/command.com: out/dl/0_84_pre7.zip
	mkdir -p out/tmp/freecom
	bsdtar -C out/tmp/freecom -xvf $<
	cp out/tmp/freecom/PROGS/FREECOM/COMMANDW.COM $@

out/fdroot/fdxms.sys: out/dl/fdxms.zip
	mkdir -p out/tmp/fdxms
	bsdtar -C out/tmp/fdxms -xvf $<
	cp out/tmp/fdxms/BIN/FDXMS.SYS $@

out/fdroot/LSL1VGA/SCIDHUV.EXE: out/dl/LSL1VGA.iso
	xorriso -osirrox on -indev $< -extract / out/tmp/LSL1VGA
	chmod -R u+w out/tmp/LSL1VGA
	rm out/tmp/LSL1VGA/LSL1VGA/RESOURCE.CFG
	cp -r out/tmp/LSL1VGA/LSL1VGA out/fdroot

out/dl/2042.zip:
	wget -O $@ $(FDOS_URL)/base/kernel/2042.zip

out/dl/0_84_pre7.zip:
	wget -O $@ $(FDOS_URL)/base/freecom/0_84_pre7.zip

out/dl/fdxms.zip:
	wget -O $@ $(FDOS_URL)/base/fdxms.zip

out/dl/LSL1VGA.iso:
	wget -O $@ $(LARRY_URL)

mkout:
	mkdir -p out out/dl out/tmp out/bin out/fdroot
	cp -r fdroot/* out/fdroot/

clean:
	rm -rf out b2l.img
