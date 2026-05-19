cmake_minimum_required(VERSION 3.22 FATAL_ERROR)

project(tests LANGUAGES CXX C ASM)

# ============================================================
# Common paths
# ============================================================

set(INIT_DIR                  "${CMAKE_CURRENT_BINARY_DIR}/init")
set(GENERATED_INIT_DIR        "${CMAKE_CURRENT_BINARY_DIR}/generated_init")

set(BIN_DIR                   "${CMAKE_CURRENT_BINARY_DIR}/init_bin")
set(QEMU_LOG_DIR              "${CMAKE_CURRENT_BINARY_DIR}/qemu_log")

set(OUTPUT_DIR                "${CMAKE_CURRENT_BINARY_DIR}/tests")

set(GENERATED_SNIPPETS_DIR    "${CMAKE_CURRENT_BINARY_DIR}/generated_snippets")

set(COMPILER      "${CMAKE_C_COMPILER}")
set(COMPILER_FLAGS
    "${CMAKE_C_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}"
    CACHE INTERNAL "Compiler flags for assembling and linking"
)

set(SCRIPT_PATH         "${CMAKE_CURRENT_SOURCE_DIR}/compile-and-run.sh")
set(COMPILE_SCRIPT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/compile-dir.sh")

# ============================================================
# ===================== NORMAL BRANCH ========================
# Target/${TARGET_NAME}/Snippets
# ============================================================

add_custom_target(init-tests
  COMMAND ${CMAKE_COMMAND} -E make_directory "${INIT_DIR}"
  COMMAND ${BUNDLE_PATH} exec ruby
          ${CMAKE_CURRENT_SOURCE_DIR}/InitTestGen.rb -n 4
          ${IR_PATH}
          ${CMAKE_CURRENT_SOURCE_DIR}/Target/${TARGET_NAME}/Snippets
          ${INIT_DIR}
  COMMENT "Generating init tests (normal snippets)"
)

add_custom_target(run-qemu-tests
  DEPENDS init-tests
  COMMAND ${CMAKE_COMMAND} -E make_directory "${BIN_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${QEMU_LOG_DIR}/normal"
  COMMAND "${SCRIPT_PATH}"
          "${INIT_DIR}"
          "${BIN_DIR}"
          "${COMPILER}"
          "${QEMU_PATH}"
          "${QEMU_LOG_DIR}/normal"
          "${COMPILER_FLAGS}"
  COMMENT "Compile and run normal snippet tests with QEMU"
  VERBATIM
)

add_custom_target(gen-tests
  DEPENDS run-qemu-tests
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OUTPUT_DIR}/normal"
  COMMAND ${BUNDLE_PATH} exec ruby
          "${CMAKE_CURRENT_SOURCE_DIR}/TestGen.rb"
          "${IR_PATH}"
          "${CMAKE_CURRENT_SOURCE_DIR}/Target/${TARGET_NAME}/Snippets"
          "${INIT_DIR}"
          "${QEMU_LOG_DIR}/normal"
          "${OUTPUT_DIR}/normal"
)

add_custom_target(compile-tests
  DEPENDS gen-tests
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OUTPUT_TESTS_DIR}"
  COMMAND ${COMPILE_SCRIPT_PATH}
          "${OUTPUT_DIR}/normal"
          "${OUTPUT_TESTS_DIR}"
          "${COMPILER}"
          "${COMPILER_FLAGS}"
)

# ============================================================
# ================= GENERATED BRANCH =========================
# generated_snippets
# ============================================================

add_custom_target(run-snippet-gen
  COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_SNIPPETS_DIR}"
  COMMAND ${BUNDLE_PATH} exec ruby
          "${CMAKE_CURRENT_SOURCE_DIR}/SnippetGen.rb"
          "${IR_PATH}"
          "${GENERATED_SNIPPETS_DIR}"
  COMMENT "Generating snippets dynamically"
)

add_custom_target(init-tests-snippet-gen
  DEPENDS run-snippet-gen
  COMMAND ${CMAKE_COMMAND} -E make_directory "${GENERATED_INIT_DIR}"
  COMMAND ${BUNDLE_PATH} exec ruby
          ${CMAKE_CURRENT_SOURCE_DIR}/InitTestGen.rb -n 4
          ${IR_PATH}
          "${GENERATED_SNIPPETS_DIR}"
          "${GENERATED_INIT_DIR}"
  COMMENT "Generating init tests (generated snippets)"
)

add_custom_target(run-qemu-tests-snippet-gen
  DEPENDS init-tests-snippet-gen
  COMMAND ${CMAKE_COMMAND} -E make_directory "${BIN_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${QEMU_LOG_DIR}/generated"
  COMMAND "${SCRIPT_PATH}"
          "${GENERATED_INIT_DIR}"
          "${BIN_DIR}"
          "${COMPILER}"
          "${QEMU_PATH}"
          "${QEMU_LOG_DIR}/generated"
          "${COMPILER_FLAGS}"
  COMMENT "Compile and run generated snippet tests with QEMU"
  VERBATIM
)

add_custom_target(gen-tests-snippet-gen
  DEPENDS run-qemu-tests-snippet-gen
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OUTPUT_DIR}/generated"
  COMMAND ${BUNDLE_PATH} exec ruby
          "${CMAKE_CURRENT_SOURCE_DIR}/TestGen.rb"
          "${IR_PATH}"
          "${GENERATED_SNIPPETS_DIR}"
          "${GENERATED_INIT_DIR}"
          "${QEMU_LOG_DIR}/generated"
          "${OUTPUT_DIR}/generated"
)

add_custom_target(compile-tests-snippet-gen
  DEPENDS gen-tests-snippet-gen
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OUTPUT_TESTS_DIR}"
  COMMAND ${COMPILE_SCRIPT_PATH}
          "${OUTPUT_DIR}/generated"
          "${OUTPUT_TESTS_DIR}"
          "${COMPILER}"
          "${COMPILER_FLAGS}"
)

# ============================================================
# Optional global targets
# ============================================================

add_custom_target(all-normal DEPENDS compile-tests)
add_custom_target(all-generated DEPENDS compile-tests-snippet-gen)

add_custom_target(all-tests
  ALL
  DEPENDS
    compile-tests
    compile-tests-snippet-gen
)
