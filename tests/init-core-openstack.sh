#!/bin/bash

set -o xtrace
set -o errexit
set -o pipefail

export PYTHONUNBUFFERED=1


function init_runonce {
    . /etc/kolla/admin-openrc.sh
    . ~/openstackclient-venv/bin/activate

    echo "Initialising OpenStack resources via init-runonce"
    KOLLA_DEBUG=1 tools/init-runonce ${RUN_ONCE_PARAMS} |& gawk '{ print strftime("%F %T"), $0; }' &> /tmp/logs/ansible/init-runonce

    if [[ $IP_VERSION -eq 6 ]]; then
        # NOTE(yoctozepto): In case of IPv6 there is no NAT support in Neutron,
        # so we have to set up native routing. Static routes are the simplest.
        sudo ip route add ${DEMO_NET_CIDR} via ${EXT_NET_DEMO_ROUTER_ADDR}
        if [[ "${RUN_ONCE_PARAMS}" != "" ]]; then
            sudo ip route add ${KOLLA_PROJECT_NET_CIDR} via ${EXT_NET_KOLLA_PROJECT_ROUTER_ADDR}
        fi
    fi
}


init_runonce
