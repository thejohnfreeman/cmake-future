file(READ "${INPUT}" TEXT)
configure_file(package-config.cmake.in "${OUTPUT}" @ONLY)
