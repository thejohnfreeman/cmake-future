# This Makefile exists just to assist development.
# Do not treat it as a continuous integration test.

test :
	rm --recursive --force build prefix
	mkdir build
	mkdir --parents prefix/lib/cmake
	cd build; cmake -DCMAKE_INSTALL_PREFIX=${PWD}/prefix ..
	cd build; cmake --build . --target install
	cd build; ctest --verbose
