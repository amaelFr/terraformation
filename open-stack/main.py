import terrascript as ts
import terrascript.provider as provider
import terrascript.resource as resource
import terrascript.data as data

import json
from jsonschema import validate
import ipaddress as ip
import re
import os
import argparse

parser = argparse.ArgumentParser(
    description="Tools used to generate terraform files for architecture")
parser.add_argument('-a', '--archi', type=str, dest="archi",
                    default="./archi.json", help="archi.json path")
parser.add_argument('-s', '--static', type=str, dest="static",
                    default="./static.json", help="static.json path")
parser.add_argument('-i', '--inventory', type=str, dest="inventory", default="",
                    help="inventory fiel from ansible-inventory -i path/to/inventory --list --output inventory.json")
parser.add_argument('-o', '--out', type=str, dest="out",
                    default="out", help="out directory")

args = parser.parse_args()

if os.path.exists(args.out) and os.path.isdir(args.out):
    for file in os.listdir(args.out):
        if file.endswith(".tf.json"):
            os.remove(os.path.join(args.out, file))
else:
    os.mkdir(args.out)


def raiseError(msg):
    print(msg)
    exit(1)


def writeOut(path, tsConf):
    try:
        with open(path, 'wt') as fp:
            fp.write(str(tsConf))
    except:
        raiseError("Error while write the terrascript file "+path)


ansible = False
if args.inventory != "":
    try:
        with open(args.inventory) as ansible_file:
            ansible = json.load(ansible_file)
    except:
        raiseError("Error while getting inventory data")

with open('schema.json') as schema_file:
    schema = json.load(schema_file)

    tsNet = ts.Terrascript()
    tsImage = ts.Terrascript()
    tsMachine = ts.Terrascript()

    with open(args.static) as static_file:
        static = json.load(static_file)
        validate(instance=static, schema=schema['static'])

        # image
        for image in static['images']:
            image['ts_image'] = data.openstack_images_image_v2(
                re.sub(r'\.', '', image['name']), name=image['name'])

            tsImage.add(image['ts_image'])
            image['ts_image_id'] = "${"+image['ts_image'].id+"}"

            if 'cloud-init' in image and (not os.path.exists(image['cloud-init']) or not os.path.isfile(image['cloud-init'])):
                raiseError(
                    "Invalid cloud-init, it must be a cloud-init format")

        with open(args.archi) as archi_file:
            archi = json.load(archi_file)

            #####################ADD ansible inventory to archy
            if ansible:
                for machine in ansible['_meta']['hostvars']:
                    machineObj = ansible['_meta']['hostvars'][machine]

                    if 'interfaces' not in machineObj:
                        raiseError("Error the machine: "+machine +
                                   " has no interfaces set up")
                    newArchiMachine = {
                        "name": machine,
                        "version": "20.04",
                        "ips": [interface['ip'] if 'ip' in interface else machineObj['ansible_host'] for interface in machineObj['interfaces']]
                    }

                    foundImage = False
                    defaultImage = False

                    for image in static['images']:
                        if 'defaultSsh' in image and image['defaultSsh'] and 'ansible_connection' not in machineObj or 'defaultWinrm' in image and image['defaultWinrm'] and 'ansible_connection' in machineObj and machineObj['ansible_connection'] == 'winrm':
                            defaultImage = image
                        if 'image' in machineObj and ('version' not in machineObj['image'] and 'version' not in image and machineObj['image']['type'] == image['type'] or 'version' in machineObj['image'] and 'version' in image and machineObj['image']['type'] == image['type'] and str(machineObj['image']['version']) == image['version']):
                            foundImage = image
                            break
                    if not foundImage and defaultImage:
                        foundImage = defaultImage
                        print('Warnig machine: '+machine +
                              ' will use the default image: '+image['name'])
                    if not foundImage:
                        raiseError("Error with the machine "+machine +
                                   " no image found for the corresponding machine")
                    newArchiMachine['type'] = foundImage['type']
                    if 'version' in foundImage:
                        newArchiMachine['version'] = str(foundImage['version'])
                    if 'ressource' in machine:
                        if 'ram' in machine['ressource']:
                            newArchiMachine['ram'] = machine['ressource']['ram']
                        if 'cpu' in machine['ressource']:
                            newArchiMachine['cpu'] = machine['ressource']['cpu']
                    if 'ram' not in newArchiMachine:
                        newArchiMachine['ram'] = foundImage['ram']
                    if 'cpu' not in newArchiMachine:
                        newArchiMachine['cpu'] = foundImage['cpu']

                    archi['machines'].append(newArchiMachine)

            validate(instance=archi, schema=schema['archi'])

            # network
            publicNet = tsNet.add(data.openstack_networking_network_v2(
                "public_net", name=archi['publicNet']['name']))
            archi['publicNet']['ts_net_id'] = "${"+publicNet.id+"}"
            publicSubnet = tsNet.add(data.openstack_networking_subnet_v2(
                "public_subnet", network_id=archi['publicNet']['ts_net_id'], cidr=archi['publicNet']['cidr']))
            archi['publicNet']['ts_subnet_id'] = "${"+publicSubnet.id+"}"

            archi['publicNet']['obj'] = ip.ip_network(
                archi['publicNet']['cidr'])
            for network in archi['networks']:
                network['obj'] = ip.ip_network(network['cidr'])
                network['ts_net'] = resource.openstack_networking_network_v2(
                    'lab_network_'+network['name'], name='lab_network_'+network['name'])
                network['ts_net_id'] = "${"+network['ts_net'].id+"}"
                network['ts_subnet'] = resource.openstack_networking_subnet_v2(
                    'lab_subnet_'+network['name'], cidr=network['cidr'], network_id=network['ts_net_id'], name='lab_subnet_'+network['name'])
                network['ts_subnet_id'] = "${"+network['ts_subnet'].id+"}"

                tsNet.add(network['ts_net'])
                tsNet.add(network['ts_subnet'])

            # testing network intrigation
            for network in archi['networks']:
                if network['cidr'] == archi['publicNet']['cidr'] or network['obj'].subnet_of(archi['publicNet']['obj']) or network['obj'].supernet_of(archi['publicNet']['obj']) or network['obj'].compare_networks(archi['publicNet']['obj']) == 0:
                    raiseError("The network "+network['name']+" and the public net " +
                               archi['publicNet']['name']+" have a relation together")
                for networkTest in archi['networks']:
                    if network != networkTest and (network['cidr'] == networkTest['cidr'] or network['obj'].subnet_of(networkTest['obj']) or network['obj'].supernet_of(networkTest['obj']) or network['obj'].compare_networks(networkTest['obj']) == 0):
                        raiseError(
                            "The two networks "+network['name']+", "+networkTest['name']+" have a relation together")

            # machine ip
            for machine in archi['machines']:
                if 'name' in machine:
                    machine['name'] = "lab_machine_"+machine['name']
                else:
                    machine['name'] = "lab_machine_"+machine['type'] + \
                        str(archi['machines'].index(machine))

                publicInterface = False
                for i in range(len(machine['ips'])):
                    for machineTest in archi['machines']:
                        if machine != machineTest:
                            for machineTestIp in machineTest['ips']:
                                if type(machineTestIp) == str and machine['ips'][i] == machineTestIp or type(machineTestIp) == dict and machine['ips'][i] == machineTestIp['ip']:
                                    raiseError(
                                        'Error ip: '+machine['ips'][i]+' is used on two machine')

                    machine['ips'][i] = {
                        'ip': machine['ips'][i], 'obj': ip.ip_address(machine['ips'][i])}
                    foundNetwork = False
                    if machine['ips'][i]['obj'] in archi['publicNet']['obj']:
                        foundNetwork = archi['publicNet']
                        publicInterface = machine['ips'][i]
                    else:
                        for network in archi['networks']:
                            if machine['ips'][i]['obj'] in network['obj']:
                                foundNetwork = network
                                break
                    if not foundNetwork:
                        raiseError(
                            "Error ip:"+machine['ips'][i]['ip']+" not found in any network")

                    machine['ips'][i]['network'] = foundNetwork
                    machine['ips'][i]['ts_port'] = resource.openstack_networking_port_v2("lab_port_ip"+re.sub(r'\.', '', machine['ips'][i]['ip']), network_id=foundNetwork['ts_net_id'], fixed_ip={
                                                                                         'subnet_id': foundNetwork['ts_subnet_id'], 'ip_address': machine['ips'][i]['ip']})
                    machine['ips'][i]['ts_port_id'] = "${" + \
                        machine['ips'][i]['ts_port'].id+"}"

                if machine['type'] == 'router':
                    global router
                    if publicInterface:
                        router = resource.openstack_networking_router_v2(machine['name'], name=machine['name'], external_network_id=publicInterface['network']['ts_net_id'], external_fixed_ip={
                                                                         'subnet_id': publicInterface['network']['ts_subnet_id'], 'ip_address': publicInterface['ip']})
                        machine['ips'].remove(publicInterface)
                    else:
                        router = resource.openstack_networking_router_v2(
                            machine['name'], )
                    routerId = "${"+router.id+"}"
                    tsNet.add(router)

                    for i in range(len(machine['ips'])):
                        tsNet.add(resource.openstack_networking_router_interface_v2(
                            "interface"+str(i)+"_router_"+machine['name'], router_id=routerId, port_id=machine['ips'][i]['ts_port_id']))
                        tsNet.add(machine['ips'][i]['ts_port'])
                else:
                    foundImage = False
                    for image in static['images']:
                        if 'version' not in machine and 'version' not in image and machine['type'] == image['type'] or 'version' in machine and 'version' in image and machine['type'] == image['type'] and machine['version'] == image['version']:
                            foundImage = image
                            break
                    if not foundImage:
                        raiseError(
                            "Image not found for the machine: "+machine['name'])

                    flavor = tsMachine.add(resource.openstack_compute_flavor_v2('lab_flavor_'+machine['name'], name='lab_flavor_'+machine['name'], disk=machine['disk'] if 'disk' in machine else foundImage[
                                           'disk'], ram=machine['ram'] if 'ram' in machine else foundImage['ram'], vcpus=machine['cpu'] if 'cpu' in machine else foundImage['cpu']))

                    if 'cloud-init' in foundImage:
                        tsMachine.add(resource.openstack_compute_instance_v2(machine['name'], name=machine['name'], block_device=[{'uuid': foundImage['ts_image_id'], 'source_type': "image", 'volume_size': machine['disk'] if 'disk' in machine else foundImage['disk'], 'boot_index': 0, 'destination_type': "volume", 'delete_on_termination': True}], flavor_id="${"+flavor.id+"}", security_groups=[
                                      "default"], network=[({'uuid': interface['network']['ts_net_id'], 'port':interface['ts_port_id']}) for interface in machine['ips']], user_data='${file("'+foundImage['cloud-init']+'")}', config_drive=True))
                        # config.add(
                        #     ts.output("testing", value='${file("'+foundImage['cloud-init']+'")}'))
                    else:
                        tsMachine.add(resource.openstack_compute_instance_v2(machine['name'], name=machine['name'], block_device=[{'uuid': foundImage['ts_image_id'], 'source_type': "image", 'volume_size': machine['disk'] if 'disk' in machine else foundImage['disk'], 'boot_index': 0, 'destination_type': "volume",
                                                                                                                                  'delete_on_termination': True}], flavor_id="${"+flavor.id+"}", security_groups=["default"], network=[({'uuid': interface['network']['ts_net_id'], 'port':interface['ts_port_id']}) for interface in machine['ips']]))

                    [tsMachine.add(interface['ts_port'])
                     for interface in machine['ips']]
                    # for interface in machine['ips']]

            writeOut(os.path.join(args.out, "network.tf.json"), tsNet)
            writeOut(os.path.join(args.out, "image.tf.json"), tsImage)
            writeOut(os.path.join(args.out, "machine.tf.json"), tsMachine)
