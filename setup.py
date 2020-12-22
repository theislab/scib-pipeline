from setuptools import setup
import os

with open("requirements.txt", "r") as f:
    requirements = f.read().splitlines()
    requirements = [x for x in requirements if not x.startswith("#") and x != ""]

extra_files = []
for (path, directories, filenames) in os.walk('scibp/'):
    directories[:] = [d for d in directories if not (d.startswith('.') or d.startswith('__'))]
    filenames[:] = [f for f in filenames if not f.startswith('.') and not f.endswith('.py')]
    for filename in filenames:
        extra_files.append(os.path.join('..', path, filename))

setup(
    name='scib-pipeline',
    version='0.1.0',
    packages=['scibp'],
    requirements=requirements,
    include_package_data=True,
    package_data={'scibp': extra_files},
    entry_points={'console_scripts': ['scibp=scibp.cli:main']},
    url='https://theislab.github.io/scib-reproducibility/',
    license='MIT',
    author='mumichae',
    author_email='mumichae@in.tum.de',
    description='Pipeline for single-cell integration benchmarking'
)
