package main

import (
	"net"
	"testing"
)

// TestFindFirstFreeIP tests the findFirstFreeIP function under various scenarios
func TestFindFirstFreeIP(t *testing.T) {
	tests := []struct {
		name     string
		ipNetStr string
		usedIPs  map[string]bool
		wantIP   string
		wantErr  bool
	}{
		{
			name:     "Empty subnet, no used IPs",
			ipNetStr: "192.168.1.0/24",
			usedIPs:  map[string]bool{},
			wantIP:   "192.168.1.0",
			wantErr:  false,
		},
		{
			name:     "Some IPs used",
			ipNetStr: "192.168.1.0/24",
			usedIPs: map[string]bool{
				"192.168.1.0": true,
				"192.168.1.2": true,
			},
			wantIP:  "192.168.1.1",
			wantErr: false,
		},
		{
			name:     "All usable IPs taken",
			ipNetStr: "192.168.1.0/31", // Only 2 usable IPs: 192.168.1.0, 192.168.1.1
			usedIPs: map[string]bool{
				"192.168.1.0": true,
				"192.168.1.1": true,
			},
			wantIP:  "",
			wantErr: true,
		},
		{
			name:     "Do NOT skip network address",
			ipNetStr: "192.168.1.0/24",
			usedIPs: map[string]bool{
				"192.168.1.1": true,
			},
			wantIP:  "192.168.1.0",
			wantErr: false,
		},
		{
			name:     "Small subnet with one free IP", // Usable: 192.168.1.0
			ipNetStr: "192.168.1.0/31",
			usedIPs: map[string]bool{
				"192.168.1.0": true,
			},
			wantIP:  "192.168.1.1",
			wantErr: false,
		},
		{
			name:     "Invalid subnet",
			ipNetStr: "invalid",
			usedIPs:  map[string]bool{},
			wantIP:   "",
			wantErr:  true,
		},
		{
			name:     "Do NOT skip broadcast address",
			ipNetStr: "192.168.1.0/30",
			usedIPs: map[string]bool{
				"192.168.1.0": true,
				"192.168.1.1": true,
				"192.168.1.2": true,
			},
			wantIP:  "192.168.1.3",
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var ipNet *net.IPNet
			if tt.ipNetStr != "invalid" {
				_, ipNet, _ = net.ParseCIDR(tt.ipNetStr)
			}
			got := findFirstFreeIP(ipNet, tt.usedIPs)
			if got != tt.wantIP {
				t.Errorf("findFirstFreeIP() got = %v, want %v", got, tt.wantIP)
			}
			if (got == "" && !tt.wantErr) || (got != "" && tt.wantErr) {
				t.Errorf("findFirstFreeIP() error expectation mismatch: got empty = %v, wantErr = %v", got == "", tt.wantErr)
			}
		})
	}
}

// TestIncrementIP tests the incrementIP function
func TestIncrementIP(t *testing.T) {
	tests := []struct {
		name    string
		inputIP string
		wantIP  string
	}{
		{
			name:    "Increment middle IP",
			inputIP: "192.168.1.1",
			wantIP:  "192.168.1.2",
		},
		{
			name:    "Increment with carry",
			inputIP: "192.168.1.255",
			wantIP:  "192.168.2.0",
		},
		{
			name:    "Increment first IP",
			inputIP: "192.168.1.0",
			wantIP:  "192.168.1.1",
		},
		{
			name:    "Invalid IP",
			inputIP: "invalid",
			wantIP:  "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var ip net.IP
			if tt.inputIP != "invalid" {
				ip = net.ParseIP(tt.inputIP)
			}
			got := incrementIP(ip)
			var gotStr string
			if got != nil {
				gotStr = got.String()
			}
			if gotStr != tt.wantIP {
				t.Errorf("incrementIP() got = %v, want %v", gotStr, tt.wantIP)
			}
		})
	}
}
