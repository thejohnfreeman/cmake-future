"""Test every example project."""

import subprocess as sp

import pytest  # type: ignore


@pytest.mark.parametrize('example', ['greetings'])
def test_example(example: str):
    sp.run(
        ['invoke', 'clean', 'configure', 'build', 'test'],
        cwd=f'examples/{example}',
        check=True,
    )
