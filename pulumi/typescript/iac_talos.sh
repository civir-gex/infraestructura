#!/bin/bash
pulumi login
pulumi stack select k8sgex
pulumi up -y
pulumi logout
