if (Get-WmiObject -Class Win32_ComputerSystem | Where-Object Manufacturer -Like QEMU) {
	powercfg /change monitor-timeout-ac 0
	powercfg /change monitor-timeout-dc 0
	powercfg /change standby-timeout-ac 0
	powercfg /change standby-timeout-dc 0
	powercfg /hibernate off
}
