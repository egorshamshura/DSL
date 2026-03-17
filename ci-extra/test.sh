PRESET_NAME=$1

# Run tests
cmake --build --preset ${PRESET_NAME} --target simtests
