
import os
import os.path
import subprocess


FACILITIES = ['local0', 'local1', 'local2', 'local3', 'local4',
              'local5', 'local6', 'local7']

SEVERITIES = ['emerg', 'alert', 'crit', 'err', 'warning',
              'notice', 'info', 'debug']


def file(name, path, enable, tag, facility, severity, **kwargs):
    """
    Custom state for monitoring plaintext log files
    and forwarding to syslog.

    See: http://www.rsyslog.com/doc/v8-stable/configuration/modules/imfile.html

    Usage:

    watch_my_log:
      watchlog.file:
        - name: watch_my_log
        - path: /path/to/file.log
        - enable: true|false
        - tag: my_log
        - facility: local0
        - severity: info
        - requires:
          - syslog

    This works by creating a new conf.d file for rsyslog
    (if enable is true) or removing one if it exists (if enable
    is false). The name of the file is always <name>.conf and it
    goes in the /etc/rsyslog.d/ directory. If anything is changed,
    rsyslog is told to reload.

    If you don't want a log monitored anymore, don't just delete
    the state; change 'enable' to false, apply the state to the
    systems where the log was being monitored so that the config
    file gets removed, and only then delete the state from your
    config.

    At least rsyslog v8 must be installed. The state checks for
    this and will return an error otherwise.  Also, the 'imfile'
    rsyslog module must be loaded. The state checks for this too
    (at least, for the module loading syntax that the 'syslog'
    state would have used to enable it).

    There's a Margarita state 'syslog' that will ensure both of
    those requirements are met; just make your state depend on
    that.
    """
    ret = {'name': name,
           'changes': {},
           'result': False,  # Default to failed
           'comment': ''}

    if enable not in (False, True):
        ret['comment'] = 'enable must be false or true'
        return ret

    if facility not in FACILITIES:
        ret['comment'] = 'facility must be one of %s' % FACILITIES
        return ret

    if severity not in SEVERITIES:
        ret['comment'] = 'severity must be one of %s' % SEVERITIES
        return ret

    if __opts__['test']:
        ret['result'] = None
        ret['comment'] = "State %s would have executed" % name
        return ret

    # Make sure rsyslog v8 or later is installed
    version = __salt__['pkg_resource.version']('rsyslog')
    if not version:
        ret['comment'] = "rsyslog (at least version 8) must be installed.  Adding the 'syslog' state should do it."
        return ret
    cmp = __salt__['pkg.version_cmp'](version, '8.0')
    if cmp < 0:
        ret['comment'] = "rsyslog %s is too old. At least version 8 must be installed.   Adding the 'syslog' state should do it." % version
        return ret

    # See if imfile appears to be enabled
    main_conf_file = open("/etc/rsyslog.conf", "r").read()
    # This test is very simple, but good enough for now. Feel free to change to a
    # regex or something if you need to change the PollingInterval or anything like that.
    text = 'module(load="imfile" PollingInterval="10")'
    if text not in main_conf_file:
        ret['comment'] = "rsyslog needs to have imfile module loaded, and must use the exact " \
                         "syntax '{}' because that's what this checks for. " \
                         "Adding the 'syslog' state will do that.".format(text)
        return ret

    conf_file_path = os.path.join("/etc/rsyslog.d", "%s.conf" % name)

    if not enable:
        # Disabling
        if os.path.exists(conf_file_path):
            os.remove(conf_file_path)
            reload_rsyslog()
            ret['result'] = True
            ret['changes']['deleted'] = conf_file_path
            ret['comment'] = "deleted %s" % conf_file_path
            return ret
        ret['result'] = True
        ret['comment'] = "No change"
        return ret

    desired_content = """input(type="imfile"
      File="{logfile}"
      Tag="{tag}"
      Severity="{severity}"
      Facility="{facility}")
        """.format(
            logfile=path,
            tag=tag,
            facility=facility,
            severity=severity,
        )

    if os.path.exists(conf_file_path):
        current_content = open(conf_file_path, "r").read()
        if current_content == desired_content:
            ret['result'] = None
            ret['comment'] = "No change"
            return ret

    with open(conf_file_path, "w") as f:
        f.write(desired_content)
    reload_rsyslog()
    ret['result'] = True
    ret['changes']['wrote'] = conf_file_path
    ret['comments'] = 'wrote config to %s' % conf_file_path
    return ret


def reload_rsyslog():
    subprocess.check_call(["restart", "rsyslog"])


