if (NOT DEFINED BUNDLE_PATH)
  set(BUNDLE_PATH "bundle")
endif()

execute_process(
  COMMAND ${BUNDLE_PATH} config set --local path ${CMAKE_BINARY_DIR}/bundle
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

execute_process(
  COMMAND ${BUNDLE_PATH} install
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
