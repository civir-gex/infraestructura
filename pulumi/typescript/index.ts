"use strict";
require("dotenv").config();
const pulumi = require("@pulumi/pulumi");
const proxmox = require("@muhlba91/pulumi-proxmoxve");

const virtualmachines = [
    { "Name": "TOSCP01", "Type": "ControlPlane", "MAC": "D6:00:00:AA:AA:C1", "Nodo": "sgex01", "Id": "801", "CORES": "4", "RAM": "4096" },
    { "Name": "TOSCP02", "Type": "ControlPlane", "MAC": "D6:00:00:AA:AA:C2", "Nodo": "sgex02", "Id": "802", "CORES": "4", "RAM": "4096" },
    { "Name": "TOSCP03", "Type": "ControlPlane", "MAC": "D6:00:00:AA:AA:C3", "Nodo": "sgex03", "Id": "803", "CORES": "4", "RAM": "4096" },
    { "Name": "TOSWRK01", "Type": "worker", "MAC": "D6:00:00:AA:AA:D1", "Nodo": "sgex01", "Id": "811", "CORES": "4", "RAM": "4096" },
    { "Name": "TOSWRK02", "Type": "worker", "MAC": "D6:00:00:AA:AA:D2", "Nodo": "sgex02", "Id": "812", "CORES": "4", "RAM": "4096" },
    { "Name": "TOSWRK03", "Type": "worker", "MAC": "D6:00:00:AA:AA:D3", "Nodo": "sgex03", "Id": "813", "CORES": "4", "RAM": "4096" }
]

const provider = new proxmox.Provider('proxmoxve', {
    virtualEnvironment: {
        endpoint: process.env.PROXMOX_VE_ENDPOINT,
        insecure: true,
        username: "root@pam",
        password: process.env.PROXMOX_VE_PASSWORD,
    }
});

virtualmachines.forEach(vm => {
    console.log("Creando recurso en PVE:" + vm.Name)
    new proxmox.vm.VirtualMachine(vm.Name, {
        nodeName: vm.Nodo,
        agent: {
            enabled: true,
            trim: true,
            type: 'virtio',
        },
        bios: 'seabios',
        cpu: {
            cores: vm.CORES,
            sockets: 1,
            type: "host",
        },
        disks: [
            {
                interface: 'scsi0',
                datastoreId: 'local',
                size: 40,
                fileFormat: 'qcow2',
            },
        ],
        cdrom: {
            enabled: true,
            file_id: "local:iso/talos-metal-amd64-v1.7.iso",
        },
        memory: {
            dedicated: vm.RAM,
        },
        name: vm.Name,
        vmId: vm.Id,
        networkDevices: [
            {
                bridge: 'vmbr0',
                model: 'e1000e',
                mac_address: vm.MAC
            },
        ],
        onBoot: true,
        operatingSystem: {
            type: 'l26',
        },
    }, {
        provider: provider
    },)
});