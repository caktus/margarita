from __future__ import absolute_import

from fabric.state import env
from fabric.contrib.files import exists
from fabric.contrib.project import rsync_project
from fabric.operations import sudo

from margarita import get_margarita_directory


def sync_margarita_to_server(remote_directory):
    """
    Rsync the directories from margarita directory
    into the specified remote directory.  The remote
    directory will be created if it does not exist.
    """

    # Make sure the target directory exists, and is owned
    # by the user we're going to run rsync as.
    # The rsync_project tool doesn't have an option to use
    # sudo, so it always runs as the login user.
    if not exists(remote_directory):
        sudo("mkdir '%s'" % remote_directory)
    sudo("chown '%s' '%s'" % (env.user, remote_directory))

    local_margarita_directory = get_margarita_directory()

    # Sync the contents of the local directory, minus any
    # .files, into the remote directory.
    rsync_project(
        remote_dir=remote_directory,
        local_dir="%s/*" % local_margarita_directory,
        delete=True,
    )
