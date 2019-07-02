from pathlib import Path
import subprocess as sp

import pytest  # type: ignore


@pytest.mark.parametrize('project', ['kitchen_sink'])
def test_good_project(tmp_path, project):
    """Test expected successes."""
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


# Expected failures.
@pytest.mark.parametrize('project', ['no_license'])
def test_bad_project(tmp_path, project):
    """Test expected failures."""
    # TODO: We need to make sure these fail in the expected way.
    print(f'tmp_path = {tmp_path}')
    with pytest.raises(sp.CalledProcessError):
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
