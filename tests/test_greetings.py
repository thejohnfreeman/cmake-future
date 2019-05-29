import os
import subprocess as sp


def test_greetings():
    env = {**os.environ, 'CMAKE_FUTURE_ROOT': os.path.abspath('.install/Debug')}
    sp.run(
        ['invoke', 'clean', 'configure', 'build', 'test'],
        cwd='tests/data/greetings',
        env=env,
        check=True,
    )
