#!/bin/bash
# 2015-12-10 Rafael Skodlar
#

myenvironment() {
myIP="10.0.100.102"
port=5000
version=v2.0

# With the addition of Keystone, to use an openstack cloud you should
# authenticate against keystone, which returns a **Token** and **Service
# Catalog**.  The catalog contains the endpoint for all services the
# user/tenant has access to - including nova, glance, keystone, swift.
#
# *NOTE*: Using the 2.0 *auth api* does not mean that compute api is 2.0.  We
# will use the 1.1 *compute api*
export OS_AUTH_URL=http://${myIP}:${port}/${version}

# With the addition of Keystone we have standardized on the term **tenant**
# as the entity that owns the resources.
export OS_TENANT_ID=feacce5a1fc347f88cfc0dee838429d6
export OS_TENANT_NAME=tenant

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
export OS_USERNAME=username

# With Keystone you pass the keystone password.
echo "OpenStack Password: "
read -s OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT

source admin-openrc.sh
}

service_compute() {
mode=$1

if [ "$mode" == "restart" ]; then
    service nova-api restart
    service nova-cert restart
    service nova-consoleauth restart
    service nova-scheduler restart
    service nova-conductor restart
    service nova-novncproxy restart
fi

}

nova() {
mode=$1

apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

# Create the nova user
openstack user create --password-prompt nova

# Add the admin role to the nova user
openstack role add --project service --user nova admin

# Create the nova service entity
openstack service create --name nova --description "OpenStack Compute" compute

# Create the Compute service API endpoint
openstack endpoint create \
  --publicurl http://controller:8774/v2/%\(tenant_id\)s \
  --internalurl http://controller:8774/v2/%\(tenant_id\)s \
  --adminurl http://controller:8774/v2/%\(tenant_id\)s \
  --region RegionOne \
  compute

# install and configure Compute controller components
apt-get install nova-api nova-cert nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler python-novaclient

vi /etc/nova/nova.conf

# install and configure the Compute hypervisor components
apt-get install nova-compute sysfsutils

vi /etc/nova/nova.conf

nova service-list

}

db_setup() {
sqlite_file=/var/lib/nova/nova.sqlite

if [ -e $sqlite_file ]
    rm -f $sqlite_file
fi
su -s /bin/sh -c "nova-manage db sync" nova

}
