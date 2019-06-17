from conans import python_requires

CMakeConanFile = python_requires('autorecipes/[*]@jfreeman/testing').cmake()


class Recipe(CMakeConanFile):
    name = CMakeConanFile.name
    version = CMakeConanFile.version

    def package_info(self):
        pass
