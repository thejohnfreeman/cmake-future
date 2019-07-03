from conans import python_requires

CMakeConanFile = python_requires('autorecipes/[*]@jfreeman/testing').cmake()


class Recipe(CMakeConanFile):
    name = CMakeConanFile.__dict__['name']
    version = CMakeConanFile.__dict__['version']

    def package_info(self):
        pass

    def package_id(self):
        return self.info.header_only()
