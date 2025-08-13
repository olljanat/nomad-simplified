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
	if ipNet == nil {
		return ""
	}

	// Calculate the number of usable IPs in the subnet
	ones, bits := ipNet.Mask.Size()
	totalIPs := 1 << uint(bits-ones) // 2^(32-ones) for IPv4

	// Iterate through usable IPs
	ip := ipNet.IP.Mask(ipNet.Mask)
	for i := 0; i < totalIPs; i++ {
		if !ipNet.Contains(ip) {
			return "" // Stop if we've gone beyond the subnet
		}
		ipStr := ip.String()
		if !usedIPs[ipStr] {

			// Verify that IP is not already used locally
			usedLocalIPsLock.RLock()
			usedLocally := usedLocalIPs[ipStr]
			usedLocalIPsLock.RUnlock()
			if !usedLocally {
				return ipStr
			}
		}
		ip = incrementIP(ip)
		if ip == nil {
			return ""
		}
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
