package main

import (
	"net"

	"github.com/sirupsen/logrus"
)

func (f *simpleFormatter) Format(entry *logrus.Entry) ([]byte, error) {
	return []byte(entry.Message + "\n"), nil
}

// findFirstFreeIP finds the first available IP in the given subnet, excluding used IPs
func findFirstFreeIP(ipNet *net.IPNet, usedIPs map[string]bool) string {
	ip := ipNet.IP.Mask(ipNet.Mask)
	// Increment to skip network address
	for i := 0; i < 1; i++ {
		ip = incrementIP(ip)
	}

	// Iterate through the subnet to find a free IP
	for ipNet.Contains(ip) {
		ipStr := ip.String()
		if !usedIPs[ipStr] {
			return ipStr
		}
		ip = incrementIP(ip)
	}
	return ""
}

// incrementIP increments an IPv4 address by 1
func incrementIP(ip net.IP) net.IP {
	ip = ip.To4()
	if ip == nil {
		return nil
	}
	newIP := make(net.IP, 4)
	copy(newIP, ip)
	for i := len(newIP) - 1; i >= 0; i-- {
		newIP[i]++
		if newIP[i] != 0 {
			break
		}
	}
	return newIP
}
