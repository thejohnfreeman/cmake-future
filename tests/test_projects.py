from pathlib import Path
import subprocess as sp

import pytest  # type: ignore


@pytest.mark.parametrize('project', ['kitchen_sink'])
def test_project(tmp_path, project):
    print(f'tmp_path = {tmp_path}')
    sp.run(
        [
            'cmake',
            '-Wdev',
            '-Werror=dev',
            str(Path(f'tests/projects/{project}').resolve()),
        ],
        cwd=tmp_path,
        check=True,
    )
