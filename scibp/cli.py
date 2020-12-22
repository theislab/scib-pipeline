import scibp
from pathlib import Path
from shutil import copyfile
from distutils.dir_util import copy_tree, remove_tree
import click
import click_log
import logging

logger = logging.getLogger(__name__)
click_log.basic_config(logger)

@click.group()
@click_log.simple_verbosity_option(logger)
@click.version_option('0.1.0', prog_name='scibp')
def main():
    pass


@main.command()
def init():
    scibp_hidden = Path.cwd() / '.scibp'
    if scibp_hidden.is_dir():
        print('.scibp already exists, use scibp update instead to update to a newer version')
    else:
        Path.mkdir(scibp_hidden)
        check_version()
        logger.info('project initialised')


@main.command()
def update():
    check_version(force=True)
    logger.info('project updated')


@main.command()
def demo():
    set_files()
    copyfile(Path(scibp.__file__).parent / 'config' / 'config_demo.yaml', Path.cwd() / 'config_demo.yaml')

    # TODO data directory

    logger.info("created demo project")


def check_version(project_dir=None, force=False):
    if project_dir is None:
        project_dir = Path.cwd().resolve()
    if project_dir != Path.cwd().resolve():
        raise AssertionError(f"Specified project directory '{project_dir}' does not match current working directory "
                             f"'{Path.cwd().resolve()}'")

    version_file = project_dir / ".scibp" / "version"
    version_file.touch()
    with open(version_file, "r") as f:
        project_version = f.readline()

    if scibp.__version__ != project_version:
        logger.info(f"Update to version {scibp.__version__}")
        with open(version_file, "w") as f:
            f.write(scibp.__version__)
        set_files(project_dir)
    elif force:
        set_files(project_dir)


def set_files(project_dir=None):
    project_dir = Path.cwd().resolve() if project_dir is None else Path(project_dir)
    repo_dir = Path(scibp.__file__).parent

    # copy Snakefile
    copyfile(repo_dir / 'Snakefile', project_dir / 'Snakefile')

    # copy scripts
    scripts_proj = project_dir / "scripts"
    if scripts_proj.is_dir():
        remove_tree(scripts_proj)
        print(f"overwriting pipeline scripts")
    copy_tree(str(repo_dir / "scripts"), str(scripts_proj))

    config_file = project_dir / 'config_template.yaml'
    if not config_file.is_file():
        copyfile(repo_dir / 'config' / 'config_template.yaml', config_file)
