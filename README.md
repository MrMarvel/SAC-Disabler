# SAC (Smart App Control) Temporarly Disabler Service
## What does it do?
SAC-Disabler is windows service to temporarly disable Smart App Control to workaround starting your blocked applications or services.
Microsoft does not provide any ways to whitelist hashes of executable/library files.  
Service is launched via wrapper [NSSM](https://www.nssm.cc/usage)  (Non-Sucking Service Manager) (their website actually is pretty old and seems broken but tool still works on latest Windows 11 versions).
## Why possibly you actually need it?
1. You have applications that are blocked by Smart App Control (SAC).
   SAC-Disabler service disables Smart App Control for 10 seconds after it launches. So you need just to make .ps1 script that launches service before running application (requires admin).  
2. You have services that are blocked by SAC.
   You can specify that blocked services dependencies: just add SAC-Disabler Service as dependency to this service so when that service is starting SAC-Disabler will be launched automatically.
3. You are trying to launch blocked apps/services via workarounds because you don't want to disable Smart App Control permanently.
## Installation
### Automatic
1. Download latest release
2. Unpack to persistant folder (for example `C:\Program Files\SAC Disabler Service`, `C:\Utilities\Portable\SAC Disabler Service`, ...)
3. Run create_service.ps1 as admin.
After that you will have SAC-Disabler service installed.
### If you want manually install
1. Download NSSM: https://web.archive.org/web/20260530114058/https://nssm.cc/release/nssm-2.24.zip
2. Download script `SAC_service.ps1`
3. Manually install service in NSSM `./nssm.exe create SAC-Disabler`
## Usage manual
### Application unblocking
There is example script `examples/example_unsecure_script_start_notepad.ps1` that runs "unsecure" windows app notepad.exe that starts the service and then start the app.
#### Service unblocking
You can modify in registries dependencies to service. You need to add "SAC-Disabler" as dependency to service that you want unblock.
