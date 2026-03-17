project(simtests)

add_subdirectory(Common)

add_subdirectory(C)
add_subdirectory(SnippetBased)

add_custom_target(${PROJECT_NAME})
add_dependencies(${PROJECT_NAME} c-simtests snippetbased-simtests)
