aux_source_directory(. HELPER_LIB_SRCS)

include_directories(include ../include/api)

# add_library (Helper SHARED ${HELPER_LIB_SRCS})

add_library (Helper STATIC ${HELPER_LIB_SRCS})

include(GenerateExportHeader)

generate_export_header(Helper)