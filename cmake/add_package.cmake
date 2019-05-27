file(READ "${input}" text)
configure_file(package-config.cmake.in "${output}" @ONLY)
