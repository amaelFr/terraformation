import terrascript as ts
import terrascript.provider as provider
import terrascript.resource as resource
import terrascript.data as data

import json

import ipaddress as ip

import re

with open('static.json') as static_file:
    static = json.load(static_file)
    with open('archi.json') as archi_file:
        archi = json.load(archi_file)

        config = ts.Terrascript()

        config += provider.openstack(user_name="admin", tenant_name="admin", password="Ertyuiop",
                                     auth_url="http://192.168.1.53/identity", region="RegionOne")

        if not 'name' in archi['publicNet'] or not 'cidr' in archi['publicNet'] or not re.findall(r"\/[0-9]{1,3}$", archi['publicNet']['cidr']):
            print("the archi public net need a valid cidr")
            exit(1)

        ip.ip_network(archi['publicNet']['cidr'])

        if 'exist' in archi['publicNet'] and not archi['publicNet']['exist']:
            print("TODO create public net")
            # TODO create public net and get data about it

        publicNet = config.add(data.openstack_networking_network_v2(
            "public_network", name=archi['publicNet']['name']))

        publicSubNet = config.add(data.openstack_networking_subnet_v2(
            "public_subNet", network_id="${"+publicNet.id+"}", cidr=archi['publicNet']['cidr']))

        for network in archi['networks']:
            if not 'cidr' in network or not re.findall(r"\/[0-9]{1,3}$", network['cidr']):
                print("the network "+network['name']+" need a valid cidr")
                exit(1)
            network['obj'] = ip.ip_network(network['cidr'])

        for i in range(len(archi['networks'])):
            for j in range(len(archi['networks'])):
                if i != j:
                    if archi['networks'][i]['name'] == archi['networks'][j]['name'] or archi['networks'][i]['obj'].supernet_of(archi['networks'][j]['obj']) or archi['networks'][i]['obj'].subnet_of(archi['networks'][j]['obj']) or archi['networks'][i]['obj'].compare_networks(archi['networks'][j]['obj']) == 0:
                        print(
                            "Error to network are in relation same cidr, supernet, subnet")
                        exit(1)
            archi['networks'][i]['net'] = config.add(resource.openstack_networking_network_v2(
                'lab_network_'+archi['networks'][i]['name'], name='lab_network_'+archi['networks'][i]['name']))
            archi['networks'][i]['subnet'] = config.add(resource.openstack_networking_subnet_v2(
                'lab_subnet_'+archi['networks'][i]['name'], cidr=archi['networks'][i]['cidr'], network_id="${"+archi['networks'][i]['net'].id+"}", name='lab_subnet_'+archi['networks'][i]['name']))

        for i in range(len(archi['machines'])):
            machine = archi['machines'][i]
            if machine['type'] == 'router':
                print("TODO add router functionnality")
                # TODO add a router
            else:
                foudImage=False
                for image in static['images']:
                    if 'version' not in machine and 'version' not in image and machine['type'] == image['type'] or 'version' in machine and 'version' in image and machine['type'] == image['type'] and machine['version'] == image['version']:
                        foudImage=True
                        name = machine['name'] if 'name' in machine else 'lab_' + \
                            machine['type']+'_'+str(i)
                        machineObj = config.add(resource.openstack_compute_instance_v2(
                            name, name=name, image_name=image['name'], flavor_id=1))
                        break
                if not foudImage:
                    print("Issue with machine, corresponding image not found:"+machine['type'])
                    exit(1)

        # config.add(ts.Output("networkID", value="${"+publicSubNet.id+"}"))

        with open('test/config.tf.json', 'wt') as fp:
            fp.write(str(config))
