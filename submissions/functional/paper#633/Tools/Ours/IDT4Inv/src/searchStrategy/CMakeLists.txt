aux_source_directory(. SEARCH_STRATEGY_LIB_SRCS)

include_directories(include ../include/api)

# add_subdirectory (thresholdStrategy)

# target_link_libraries (SearchStrategy ThresholdStrategy)

# add_library (SearchStrategy SHARED ${SEARCH_STRATEGY_LIB_SRCS})
add_library (SearchStrategy STATIC ${SEARCH_STRATEGY_LIB_SRCS})

# add_subdirectory (../thresholdStrategy)

target_link_libraries (SearchStrategy ThresholdStrategy)
target_link_libraries (SearchStrategy IDT)
target_link_libraries (SearchStrategy Helper)


include(GenerateExportHeader)

generate_export_header(SearchStrategy)