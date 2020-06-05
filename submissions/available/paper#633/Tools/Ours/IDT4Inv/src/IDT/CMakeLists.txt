aux_source_directory(. IDT_LIB_SRCS)

include_directories(include ../include/api)

add_library (IDT STATIC ${IDT_LIB_SRCS})

# target_link_libraries (IDT Helper)
# target_link_libraries (IDT SearchStrategy)
# target_link_libraries (IDT ThresholdStrategyServer)
# target_link_libraries (IDT TreePrinterServer)

#add_library (IDT STATIC ${IDT_LIB_SRCS})

include(GenerateExportHeader)

generate_export_header(IDT)