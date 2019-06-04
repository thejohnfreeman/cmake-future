# We want to pass the `build_type` parameter a task is given to its pre-task,
# but that value is not available in the declaration of pre-tasks.
# We could use a configuration parameter, but it is impossible (or at least
# undocumented) to override it on the command-line.
#
# We want a simple test command that we can run outside of the test framework.
# For now, we will stick with Makefile. When Cupcake is ready, we can switch
# to it.
#
# To get cross-platform testing, we will just always build the Debug
# configuration and rely on CMake to skip unnecessary work.

from invoke import task
import multiprocessing
import os
import shutil
import sys

pty = sys.stdout.isatty()

config = 'Debug'
source_dir = os.getcwd()
dependency_dirs = os.path.abspath(os.environ['CMAKE_PREFIX_PATH'])
build_dir = os.path.abspath(f'.build/{config}')
install_dir = os.path.abspath(f'.install/{config}')

ncpus = multiprocessing.cpu_count()


@task
def configure(ctx):
    os.makedirs(build_dir, exist_ok=True)
    os.makedirs(f'{install_dir}/lib/cmake', exist_ok=True)
    with ctx.cd(build_dir):
        ctx.run(
            f'cmake -DCMAKE_PREFIX_PATH={dependency_dirs} -DCMAKE_BUILD_TYPE={config} -DCMAKE_INSTALL_PREFIX={install_dir} {source_dir}',
            echo=True,
            pty=pty
        )


@task(configure)
def build(ctx):
    with ctx.cd(build_dir):
        ctx.run(
            f'cmake --build . --config {config} --parallel {ncpus}',
            echo=True,
            pty=pty
        )


@task(configure)
def test(ctx):
    with ctx.cd(build_dir):
        ctx.run(
            f'ctest --build-config {config} --parallel {ncpus}',
            echo=True,
            pty=pty
        )


@task(configure)
def install(ctx):
    with ctx.cd(build_dir):
        ctx.run(f'cmake --build . --target install', echo=True, pty=pty)


@task
def clean(ctx):
    shutil.rmtree(build_dir, ignore_errors=True)
    shutil.rmtree(install_dir, ignore_errors=True)
