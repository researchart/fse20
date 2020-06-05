aux_source_directory(. Threshold_STRATEGY_LIB_SRCS)

include_directories(include ../include/api)

# add_library (ThresholdStrategy SHARED ${Threshold_STRATEGY_LIB_SRCS})
add_library (ThresholdStrategy STATIC ${Threshold_STRATEGY_LIB_SRCS})

target_link_libraries (ThresholdStrategy IDT)
target_link_libraries (ThresholdStrategy Helper)


include(GenerateExportHeader)

generate_export_header(ThresholdStrategy)