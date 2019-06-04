import os
import subprocess as sp


def test_greetings():
    sp.run(
        ['invoke', 'clean', 'configure', 'build', 'test'],
        cwd='tests/greetings',
        check=True,
    )
