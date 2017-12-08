from fabric.api import *
import os.path
import atom
import helper

env.hosts = [
    #'192.168.3.44'
    '192.168.3.46'
]

env.user = "upsquared"
env.password = "upsquared"


@task
def whoami():
    """
    Update the default OS installation's
    basic default tools.
    """
    run("whoami")
