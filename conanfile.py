from conans import python_requires

CMakeConanFile = python_requires('autorecipes/[*]@jfreeman/testing').cmake()


class Recipe(CMakeConanFile):
    name = CMakeConanFile.name
    version = CMakeConanFile.version
    settings = None

    def package_id(self):
        return self.info.header_only()
