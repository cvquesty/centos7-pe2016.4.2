#!/bin/bash

# Turn off and disable FirewallD
/bin/systemctl stop  firewalld
/bin/systemctl disable firewalld
