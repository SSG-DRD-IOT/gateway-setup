from fabric.api import *
from fabric.contrib import *
import os.path
import helper

def nodejs():
    """ Download and install nodejs """
    prog = "nodejs"
    if not helper.check(prog):
        print("%s is NOT installed" % prog)
        run("curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -")
        helper.apt_install(prog)

def watchman():
    """ Download and install watchman """

    helper.apt_install("autotools-dev")
    helper.apt_install("automake")
    helper.npm_install("nuclide@0.270.0")

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
