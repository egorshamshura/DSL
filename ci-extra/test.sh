PRESET_NAME=$1

# Configure CMake
cmake -S . \
  --preset "${PRESET_NAME}" -DPROTEA_BUILD_TESTS=true -DQEMU_PATH=qemu-riscv32 -G Ninja

# Run tests
cmake --build --preset ${PRESET_NAME} --target simtests
