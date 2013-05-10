"""
Custom states for UFW (Uncomplicated Firewall)

Based on https://gist.github.com/dreid/3115254

Usage:

ufw_policy:
  ufw.default:
    - policy: deny

ufw_status:
  ufw.enabled:
    - enabled: true

ufw.allow:
  - enabled: true
  - proto: tcp
  - names:
     - '22'
     - '80'
     - '443'

or

ssh:
  ufw.allow:
    - name: '22'
    - enabled: true
"""


def _make_ufw_args(action, enabled, port, **kwargs):
    cmd = []

    if enabled in ('false', 'False', False):
        cmd.append('delete')

    cmd.append(action)

    proto = kwargs.get('proto')
    if proto in ['tcp', 'udp']:
        cmd.extend(['proto', proto])

    source = kwargs.get('from', 'any')
    if source is not None:
        cmd.extend(['from', source])

    destination = kwargs.get('to', 'any')
    if destination is not None:
        cmd.extend(['to', destination])

    if source and destination:
        cmd.append('port')
        cmd.append(port)

    return cmd


def _do_ufw(action, enabled, port, **kwargs):
    args = _make_ufw_args(action, enabled, port, **kwargs)

    result = __salt__['cmd.run'](' '.join(['ufw'] + args))

    ret = dict(
        name=port,
        changes={},
        comment='',
        result=None
    )

    if 'Skipping' in result or 'non-existent' in result:
        ret['result'] = True
        ret['comment'] = result
        return ret

    if __opts__['test']:
        ret['comment'] = result
        return ret

    ret['changes'] = {'rule': ' '.join(args)}
    ret['comment'] = result
    ret['result'] = True
    return ret


def allow(name, enabled, **kwargs):
    return _do_ufw('allow', enabled, name, **kwargs)


def deny(name, enabled, **kwargs):
    return _do_ufw('dey', enabled, name, **kwargs)


def default(name, policy):
    ret_val = __salt__['cmd.run']('ufw default {0}'.format(policy))

    return dict(
        name='%s-default' % name,
        changes={'policy': policy},
        comment=ret_val,
        result=True
    )


def enabled(name, enabled):

    if enabled in ('false', 'False', False):
        ret_val = __salt__['cmd.run']('ufw disable')
        status = 'disabled'
    else:
        ret_val = __salt__['cmd.run']('ufw --force enable')
        status = 'enabled'

    return dict(
        name='%s-status' % name,
        changes={'status': status},
        comment=ret_val,
        result=True
    )