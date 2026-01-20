all: release

PROJ_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Configuration of extension
EXT_NAME=encodings
EXT_CONFIG=${PROJ_DIR}extension_config.cmake

# --- Automated patching ---
# To manually apply/remove the CSV encoder patch:
# Apply:  cd duckdb && git apply ../fix_csv_encoder.patch
# Remove: cd duckdb && git checkout src/execution/operator/csv_scanner/encode/csv_encoder.cpp
.PHONY: apply_patches
apply_patches:
	@cd duckdb && git apply --check ../fix_csv_encoder.patch > /dev/null 2>&1 && \
		(echo "Applying fix_csv_encoder.patch..." && git apply --3way ../fix_csv_encoder.patch) || true

EXTENSION_CONFIG_STEP += apply_patches

# Include the Makefile from extension-ci-tools
include extension-ci-tools/makefiles/duckdb_extension.Makefile

# Override WASM targets: THIS IS AN HACK, needs fixing in DuckDB to allow passing optimization level and other options, but still allows this to be build as out of tree extension
wasm_pre_build_step: apply_patches
	cd duckdb && git apply --3way ../cmakelists.patch && cd ..
