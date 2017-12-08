from fabric.api import *
from fabric.contrib import *
import os.path
from helper import *

def nodejs():
    """ Download and install nodejs """
    prog = "nodejs"
    if not apt_check(prog):
        run("curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -")
        apt_install(prog)

def watchman():
    """ Download and install watchman """

    apt_install("autotools-dev")
    apt_install("automake")
    npm_install("nuclide@0.270.0")

    if not files.exists("/usr/local/bin/watchman"):
        with settings(warn_only=True):
            run("git clone https://github.com/facebook/watchman.git")
            with cd("./watchman"), settings(warn_only=True):
                result = run('pwd')
                run("git checkout v4.7.0")
                run("./autogen.sh")
                run("./configure")
                run("make")
                sudo("make install")

        # if result.return_code == 0:
        #     do something
        # elif result.return_code == 2:
        #     do something else
        # else: #print error to user
        #     print result
        #     raise SystemExit()

@task
def install():
    nodejs()
    watchman()
