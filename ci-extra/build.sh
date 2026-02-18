PRESET_NAME=$1

# Configure CMake
cmake -S . \
  --preset "${PRESET_NAME}" -G Ninja

# Build
cmake --build "build/${PRESET_NAME}" -j
