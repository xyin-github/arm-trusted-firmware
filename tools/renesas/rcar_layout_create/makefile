#
# Copyright (c) 2024, Arm Limited and Contributors. All rights reserved.
# Copyright (c) 2015-2018, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

toolchains := aarch64

include ../../../make_helpers/build-rules.mk
include ../../../make_helpers/common.mk
include ../../../make_helpers/toolchain.mk

###################################################
# makefile
###################################################

#output file name
FILE_NAME_SA0   = bootparam_sa0
FILE_NAME_SA6   = cert_header_sa6

OUTPUT_FILE_SA0 = $(FILE_NAME_SA0).elf
OUTPUT_FILE_SA6 = $(FILE_NAME_SA6).elf

#object file name
OBJ_FILE_SA0 =	sa0.o
OBJ_FILE_SA6 =	sa6.o

#linker script name
MEMORY_DEF_SA0 = sa0.ld.S
MEMORY_DEF_SA6 = sa6.ld.S

###################################################
# Convenience function for adding build definitions
# $(eval $(call add_define,FOO)) will have:
# -DFOO if $(FOO) is empty; -DFOO=$(FOO) otherwise
define add_define
DEFINES			+=	-D$(1)$(if $(value $(1)),=$(value $(1)),)
endef

# Process RCAR_SA0_SIZE flag
ifndef RCAR_SA0_SIZE
RCAR_SA0_SIZE := 1
else
ifeq (${RCAR_SA0_SIZE},0)
RCAR_SA0_SIZE := 0
else
RCAR_SA0_SIZE := 1
endif
endif
$(eval $(call add_define,RCAR_SA0_SIZE))

# Process RCAR_SA6_TYPE flag
ifndef RCAR_SA6_TYPE
RCAR_SA6_TYPE := 0
else
ifeq (${RCAR_SA6_TYPE},0)
RCAR_SA6_TYPE := 0
else
RCAR_SA6_TYPE := 1
endif
endif
$(eval $(call add_define,RCAR_SA6_TYPE))

# Handle different VMA adjustment on D3
ifeq (${RCAR_LSI},${RCAR_D3})
RCAR_VMA_ADJUST_ADDR := 0xE6320000
else
RCAR_VMA_ADJUST_ADDR := 0xE6312000
endif
$(eval $(call add_define,RCAR_VMA_ADJUST_ADDR))


###################################################

#c compiler
CFLAGS += ${DEFINES}
CFLAGS += -I../../include/lib/stdlib

#clean
CL = rm -f

###################################################
.SUFFIXES : .s .c .o

###################################################
# command

.PHONY: all

all: $(FILE_NAME_SA0).srec $(FILE_NAME_SA0).bin
all: $(FILE_NAME_SA6).srec $(FILE_NAME_SA6).bin

###################################################
# Linker
###################################################

$(FILE_NAME_SA0).srec: $(OUTPUT_FILE_SA0) | $$(@D)/
	$(aarch64-oc) -O srec --adjust-vma=$(RCAR_VMA_ADJUST_ADDR) --srec-forceS3 $(OUTPUT_FILE_SA0) $(FILE_NAME_SA0).srec

$(FILE_NAME_SA0).bin: $(OUTPUT_FILE_SA0) | $$(@D)/
	$(aarch64-oc) -O binary --adjust-vma=$(RCAR_VMA_ADJUST_ADDR) --srec-forceS3 $(OUTPUT_FILE_SA0) $(FILE_NAME_SA0).bin

$(OUTPUT_FILE_SA0): $(MEMORY_DEF_SA0) $(OBJ_FILE_SA0) | $$(@D)/
	$(aarch64-ld) $(OBJ_FILE_SA0) -nostdlib -static -Wl,--build-id=none -T $(MEMORY_DEF_SA0) -o $(OUTPUT_FILE_SA0) -Wl,-Map $(FILE_NAME_SA0).map

$(FILE_NAME_SA6).srec: $(OUTPUT_FILE_SA6) | $$(@D)/
	$(aarch64-oc) -O srec --adjust-vma=$(RCAR_VMA_ADJUST_ADDR) --srec-forceS3 $(OUTPUT_FILE_SA6) $(FILE_NAME_SA6).srec

$(FILE_NAME_SA6).bin: $(OUTPUT_FILE_SA6) | $$(@D)/
	$(aarch64-oc) -O binary --adjust-vma=$(RCAR_VMA_ADJUST_ADDR) --srec-forceS3 $(OUTPUT_FILE_SA6) $(FILE_NAME_SA6).bin

$(OUTPUT_FILE_SA6): $(MEMORY_DEF_SA6) $(OBJ_FILE_SA6) | $$(@D)/
	$(aarch64-ld) $(OBJ_FILE_SA6) -nostdlib -static -Wl,--build-id=none -T $(MEMORY_DEF_SA6) -o $(OUTPUT_FILE_SA6) -Wl,-Map $(FILE_NAME_SA6).map

###################################################
# Compile
###################################################

%.o: %.c | $$(@D)/
	$(aarch64-cc) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	$(CL)  *.bin *.map *.srec *.elf *.o
