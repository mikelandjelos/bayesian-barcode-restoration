from conan import ConanFile
from conan.tools.cmake import CMakeDeps, CMakeToolchain


class ProjectNameRecipe(ConanFile):
    name = "project_name"
    version = "0.1.0"
    package_type = "application"
    settings = "os", "compiler", "build_type", "arch"
    generators = "VirtualBuildEnv"

    def requirements(self):
        self.requires("gtest/1.15.0")
        self.requires("benchmark/1.9.1")

    def layout(self):
        self.folders.build = "build"
        self.folders.generators = "conan"

    def generate(self):
        dependencies = CMakeDeps(self)
        dependencies.generate()
        toolchain = CMakeToolchain(self)
        toolchain.user_presets_path = False
        toolchain.generate()

    def validate(self):
        cppstd = str(self.settings.compiler.cppstd)
        cppstd_number = int(cppstd.removeprefix("gnu")) if cppstd else None
        if cppstd_number is not None and cppstd_number < 20:
            raise Exception("project_name requires C++20 or newer")
