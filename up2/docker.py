from fabric.api import *
from fabric.contrib import *
import os.path
from helper import *

def docker():

    # The GPG keyid of the Docker repository
    repository_key_id = "39B88DE4"
    if not files.exists("/usr/bin/docker"):
        with settings(warn_only=True):
            apt_install("apt-transport-https")
            apt_install("curl")

            result = repository_key_check(repository_key_id)
            if result == False:
                sudo("curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -")
                sudo("add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'")
                sudo("apt-get update")
                apt_install("docker-ce")

@task
def install():
    docker()
