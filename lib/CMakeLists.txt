project(protea_irgen)

add_custom_command(
  OUTPUT IR.yaml
  DEPENDS Target/RISC-V/Common/registers.rb Target/RISC-V/32I.rb Target/RISC-V/32M.rb ADL/base.rb ADL/builder.rb Target/RISC-V/encoding.rb
  COMMAND ${BUNDLE_PATH} exec ruby ${CMAKE_CURRENT_SOURCE_DIR}/ir_gen.rb
  COMMENT "Running ${PROJECT_NAME}"
)
add_custom_target(${PROJECT_NAME} DEPENDS IR.yaml)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/IR.yaml DESTINATION share/)
