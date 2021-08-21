#!/bin/bash

ip netns add ovpn0

ip netns exec ovpn0 ip addr add 127.0.0.1/8 dev lo
ip netns exec ovpn0 ip addr add '::1/128' dev lo
ip netns exec ovpn0 ip link set lo up

ip link add ovpn0_veth0 type veth peer name ovpn0_veth1
ip link set ovpn0_veth0 up
ip link set ovpn0_veth1 netns ovpn0 up

ip addr add 10.200.200.1/24 dev ovpn0_veth0
ip netns exec ovpn0 ip addr add 10.200.200.2/24 dev ovpn0_veth1
ip netns exec ovpn0 ip route add default via 10.200.200.1 dev ovpn0_veth1

iptables -A INPUT \! -i ovpn0_veth0 -s 10.200.200.0/24 -j DROP
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o wl+ -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o en+ -j MASQUERADE
sysctl -q net.ipv4.ip_forward=1

