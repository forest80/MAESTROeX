DEBUG      = FALSE
DIM        = 2
COMP	   = gnu
USE_MPI    = FALSE
USE_OMP    = TRUE
USE_REACT  = TRUE

TINY_PROFILE = FALSE
PROFILE      = FALSE # TRUE overrides TINY_PROFILE


# define the location of the MAESTROEX home directory
MAESTROEX_HOME  := ../../..

# if not already defined, point to Microphysics
MICROPHYSICS_HOME ?= ../../../../Microphysics

# Set the EOS, conductivity, and network directories
# We first check if these exist in $(MAESTROEX_HOME)/Microphysics/(EOS/conductivity/networks)
# If not we use the version in $(MICROPHYSICS_HOME)/Microphysics/(EOS/conductivity/networks)
EOS_DIR          := helmholtz
CONDUCTIVITY_DIR := stellar
NETWORK_DIR      := general_null
GENERAL_NET_INPUTS := $(MAESTROEX_HOME)/Microphysics/networks/$(NETWORK_DIR)/H_He.net

Bpack   := ./Make.package
Blocs   := .

PROBIN_PARAMETER_DIRS := .

include $(MAESTROEX_HOME)/Exec/Make.Maestro
