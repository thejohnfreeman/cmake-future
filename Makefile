# This Makefile exists just to assist development.
# Do not treat it as a continuous integration test.

build_dir := build
install_dir := prefix

${install_dir} :
	umask 0022; mkdir --parents ${install_dir}/lib/cmake

${build_dir} :
	mkdir --parents ${build_dir}

# The installation directory needs to exist to avoid a warning.
# TODO: Find all CMakeLists.txt to be dependencies of the configuration.
${build_dir}/configured : CMakeLists.txt | ${build_dir} ${install_dir}
	cd ${build_dir}; cmake \
		-Wdev -Werror=dev -Wdeprecated -Werror=deprecated \
		-DCMAKE_INSTALL_PREFIX=../${install_dir} \
		..
	touch $@

configure : ${build_dir}/configured

install : configure ${install_dir}
	cd ${build_dir}; cmake --build . --target install

# Test that modules are installed complete and with the correct permissions.
test1: install
	ls -ld ${install_dir}
	ls -l ${install_dir}
	ls -l ${install_dir}/lib
	ls -l ${install_dir}/lib/cmake
	ls -l ${install_dir}/lib/cmake/install_project-*
	ls -l ${install_dir}/lib/cmake/future-*
	cd ${build_dir}; ctest --verbose

# Test that rebuild is incremental,
# but watches changes to CMake configuration.
test2 : install
	cd ${build_dir}; cmake --build .
	cd ${build_dir}; cmake --build .
	touch cmake/add_package.cmake
	cd ${build_dir}; cmake --build .
	touch cmake/package-config.cmake.in
	cd ${build_dir}; cmake --build .
	cd ${build_dir}; cmake --build .

clean :
	rm --recursive --force ${build_dir} ${install_dir}

.PHONY : build install

.DEFAULT_GOAL :=
