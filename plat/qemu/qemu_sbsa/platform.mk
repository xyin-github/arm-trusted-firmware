#
# Copyright (c) 2019-2023, Linaro Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

PLAT_QEMU_PATH		:=	plat/qemu/qemu_sbsa
PLAT_QEMU_COMMON_PATH	:=	plat/qemu/common

include plat/qemu/common/common.mk

CRASH_REPORTING	:=	1

ifeq (${SPM_MM},1)
NEED_BL32		:=	yes
EL3_EXCEPTION_HANDLING	:=	1
GICV2_G0_FOR_EL3	:=	1
endif

# Enable new version of image loading on QEMU platforms
LOAD_IMAGE_V2		:=	1

CTX_INCLUDE_AARCH32_REGS := 0
ifeq (${CTX_INCLUDE_AARCH32_REGS}, 1)
$(error "This is an AArch64-only port; CTX_INCLUDE_AARCH32_REGS must be disabled")
endif

ifeq ($(NEED_BL32),yes)
$(eval $(call add_define,QEMU_LOAD_BL32))
endif

# Treating this as a memory-constrained port for now
USE_COHERENT_MEM	:=	0

# This can be overridden depending on CPU(s) used in the QEMU image
HW_ASSISTED_COHERENCY	:=	1

BL2_SOURCES		+=	$(LIBFDT_SRCS)

# Include GICv3 driver files
include drivers/arm/gic/v3/gicv3.mk

QEMU_GIC_SOURCES	:=	${GICV3_SOURCES}				\
				plat/common/plat_gicv3.c

BL31_SOURCES		+=	${PLAT_QEMU_PATH}/sbsa_gic.c 			\
				${PLAT_QEMU_PATH}/sbsa_pm.c			\
				${PLAT_QEMU_PATH}/sbsa_sip_svc.c		\
				${PLAT_QEMU_PATH}/sbsa_topology.c

BL31_SOURCES		+=	${FDT_WRAPPERS_SOURCES}

ifeq (${SPM_MM},1)
	BL31_SOURCES		+=	${PLAT_QEMU_COMMON_PATH}/qemu_spm.c
endif

SEPARATE_CODE_AND_RODATA	:= 1
ENABLE_STACK_PROTECTOR		:= 0

MULTI_CONSOLE_API	:= 1

# Disable the PSCI platform compatibility layer
ENABLE_PLAT_COMPAT	:= 0

# Use known base for UEFI if not given from command line
# By default BL33 is at FLASH1 base
PRELOADED_BL33_BASE	?= 0x10000000

# Qemu SBSA plafrom only support SEC_SRAM
BL32_RAM_LOCATION_ID	= SEC_SRAM_ID
$(eval $(call add_define,BL32_RAM_LOCATION_ID))

# Don't have the Linux kernel as a BL33 image by default
ARM_LINUX_KERNEL_AS_BL33	:=	0
$(eval $(call assert_boolean,ARM_LINUX_KERNEL_AS_BL33))
$(eval $(call add_define,ARM_LINUX_KERNEL_AS_BL33))

ARM_PRELOADED_DTB_BASE := PLAT_QEMU_DT_BASE
$(eval $(call add_define,ARM_PRELOADED_DTB_BASE))

# Later QEMU versions support SME and SVE.
ENABLE_SVE_FOR_NS	:= 2
ENABLE_SME_FOR_NS	:= 2

# QEMU 7.2+ has support for FGT and Linux needs it enabled to boot on max
ENABLE_FEAT_FGT 	:= 2
