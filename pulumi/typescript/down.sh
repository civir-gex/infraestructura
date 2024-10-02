#!/bin/bash
./prerequisitos.sh

pulumi login
pulumi stack select k8sgex
pulumi destroy -y
pulumi logout
rm -rf $HOME/.talos*