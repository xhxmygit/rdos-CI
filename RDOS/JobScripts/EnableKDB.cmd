@REM EnableKernel debug on RDOS Host
@REM %1 Debug Host IP, %2 Port, %3 Hypervisor port, %4 Device ,%5 Key 
@echo off
bcdedit /set {default} debug on
bcdedit /dbgsettings net hostip:%1 port:%2 key:%5
bcdedit /set {dbgsettings} busparams %4
bcdedit /hypervisorsettings net hostip:%1 port:%3 key:%5
bcdedit /set hypervisordebug on
bcdedit /set hypervisorlaunchtype auto
@echo on
