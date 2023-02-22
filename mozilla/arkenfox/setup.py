from setuptools import setup

setup(
    name='install_journoSEC_firefox_config',
    version='1.0',
    description='Installs JournoSec Firefox configuration files',
    author='Your Name',
    author_email='you@example.com',
    packages=['install_journoSEC_firefox_config'],
    install_requires=[],
    entry_points={
        'console_scripts': ['install_journoSEC_config=install_journoSEC_config.__main__:main']
    },
)
