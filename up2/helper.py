from fabric.api import *

def apt_install(package):
    """
    Install a single package on the remote server with Apt.
    """

    if apt_check(package) == False:
        # with settings(warn_only=True):
        sudo('apt install -y %s' % package)


def apt_check(package):
    """
    Verify is an Ubuntu package is installed. Returns True or False.
    """

    with hide('warnings'), settings(warn_only=True):
        result = run("dpkg --status %s 2>&1| egrep 'is not installed and no information is available' -c" % package)
        return(True if (result == "0") else False)

def npm_check(package):
    """
    Install a NPM package
    """
    with hide('warnings'), settings(warn_only=True):
        result = run("npm list -g %s 2>&1| egrep %s -c".format(package, package))
        return(True if (result == "0") else False)

def npm_install(package):
    """
    Install a single package on the remote server with npm.
    """
    if npm_check(package) == False:
        with settings(warn_only=True):
            sudo("npm install -g %s" % package)

def repository_key_check(keyid):
    """
    Check if a repository key is installed
    """
    result = run("apt-key list | egrep {0} -c".format(keyid))
    return(True if (result == "0") else False)














def easy_install(package):
    """
    Install a single package on the remote server with easy_install.
    """
    sudo('easy_install %s' % package)


def pip_install(package):
    """
    Install a single package on the remote server with pip.
    """
    sudo('pip install %s' % package)


def with_virtualenv(command):
    """
    Executes a command in this project's virtual environment.
    """
    run('source bin/activate && %s' % command)
