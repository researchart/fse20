aux_source_directory(. TREE_PRINTER_LIB_SRCS)

include_directories(include ../include/api)

# add_library (TreePrinter SHARED ${TREE_PRINTER_LIB_SRCS})
add_library (TreePrinter STATIC ${TREE_PRINTER_LIB_SRCS})

target_link_libraries(TreePrinter IDT)

include(GenerateExportHeader)

generate_export_header(TreePrinter)