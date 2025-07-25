package main

import (
	"net"

	"github.com/sirupsen/logrus"
)

func (f *simpleFormatter) Format(entry *logrus.Entry) ([]byte, error) {
	return []byte(entry.Message + "\n"), nil
}

func findFirstFreeIP(ipNet *net.IPNet, usedIPs map[rune]bool) string {
	network := ipNet.IP
	ones, _ := ipNet.Mask.Size()
	numIPs := uint32(1) << (32 - ones)
	if numIPs == 0 {
		return ""
	}
	for i := uint32(0); i < numIPs; i++ {
		ip := incrementIP(network, i)
		ipStr := ip.String()
		if !usedIPs[[]rune(ipStr)[0]] {
			return ipStr
		}
	}
	return ""
}

func incrementIP(base net.IP, n uint32) net.IP {
	ip := make(net.IP, len(base))
	copy(ip, base)
	for i := len(ip) - 1; i >= 0 && n > 0; i-- {
		num := uint32(ip[i]) + (n & 0xff)
		ip[i] = byte(num & 0xff)
		n >>= 8
	}
	return ip
}
