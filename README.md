# Call Clarion Debugger from running App

Most people are familiar with calling the Clarion Debugger from the IDE, but less are familiar with stepping into the Clarion Debugger from a running App.


One way to step into a running app to debug it, is add the following to the Clarion app.

```clarion
    
    PROGRAM 
Glo:CurrentPID          Ulong
    
    MAP
Main        PROCEDURE()
    MODULE('api')
    ISWA_GetCurrentProcessId(Long),Ulong,Pascal,Name('GetCurrentProcessId')
    END

    END

    CODE

    OMIT('DebugOnly',_DEBUG_)
        Halt(0,'Not Compiled for Debugging<32,10>In the IDE, select Build, Set Configuration, Debug')
    !DebugOnly  

    Glo:CurrentPID = ISWA_GetCurrentProcessId(0)

    ! Debugger Elevated running as Administrator, so different CSIDL paths apply  
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)

    ! Debugger Not Elevated running as User, so the logged on User's CSIDL paths apply.
    !Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)

    Message('Glo:CurrentPID = ' & Glo:CurrentPID) ! This halts the program so the Debugger can load properly.    
    
    Main()
    Return

Main    Procedure

    Code              
            
    Message('Another Message Box')

    ! Implicit Return
```

Tip.

If you are going to be copying a Project to new folders in order to debug & test the performance of different sections of code, you need to edit the ```"Clarion_AppName".sln.cache``` to update the new folder location (see below).

```
<PropertyGroup>
    <SolutionDir>C:\ClaDebugProcess\</SolutionDir>
    <SolutionExt>.sln</SolutionExt>
    <SolutionFileName>ClaDebugProcess.sln</SolutionFileName>
    <SolutionName>ClaDebugProcess</SolutionName>
    <SolutionPath>C:\ClaDebugProcess\ClaDebugProcess.sln</SolutionPath>
  </PropertyGroup>
```

You'll also need to edit the ```"Clarion_AppName".cwproj``` file.
```
    <RootNamespace>ClaDebugProcess</RootNamespace>
    <AssemblyName>ClaDebugProcess</AssemblyName>
    <OutputName>ClaDebugProcess</OutputName>
```
and 
```
    <Compile Include="ClaDebugProcess.clw" />
```



Everytime you copy the Project files eg. (.clw, .sln, .cache, .cwproj, .red, etc.) to a new folder, edit the ```"Clarion_AppName".sln.cache``` and ```"Clarion_AppName".cwproj```, load it into the IDE and compile it, the Build Configuration Set will default to ```Release``` and not ```Debug```. So the code below will throw an error message when its not compiled for Debugging.

```clarion
   OMIT('DebugOnly',_DEBUG_)
        Halt(0,'Not Compiled for Debugging')
   !DebugOnly
```


Anyway the code below pops up the ProcessID in a modal message dialog box, and its easy to add this before the section of code you want to debug, using the message dialog box as a psuedo breakpoint.

```clarion
    Glo:CurrentPID = ISWA_GetCurrentProcessId(0)
    Message('Glo:CurrentPID = ' & Glo:CurrentPID)
```



 Another way to get the ProcessID for the running app is to use [SysInternals procexp64.exe](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer) but requires you to find a convenient procedure and thus ```Accept``` loop to break into with the Clarion Debugger statement shown below.

Once you have obtained the ProcessID, paste the following into a Run window, a Dos window, or a Powershell window, and replace 1234 with the actual ProcessID.

Debugger Elevated running as Administrator, so Administrator CSIDL paths apply.  
```
"c:\Clarion11\bin\cladb.exe" -p 1234
```

Debugger Not Elevated running as User, so the logged on User's CSIDL paths apply.
```
"c:\Clarion11\bin\cladbne.exe" -p 1234
```

Once the debugger has loaded, click ```Window```, then click ```Source``` and select the ```filename.clw``` for the code you want to debug.

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/SelectSourceCLW.png)

Set a break point on the line of the code, and this action of selecting a line prompts the debugger into loading the remaining debugger window panes, to then enable you to carry out a debugging session, including stepping into Assembler if you fancy rolling your sleeves up a bit more.

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/ClarionDebugger.png)




If you want to get technical, check out the ```D32.log``` file, this is the Trace window, that documents the steps the Debugger peforms to load an app for debugging from the IDE or by breaking into a running app process by using this Win32 API [DebugActiveProcess](https://learn.microsoft.com/en-us/windows/win32/api/debugapi/nf-debugapi-debugactiveprocess). Obviously using this API also presents a security risk so use with caution.


[ClaDebugProcess.sln.cache](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.sln.cache)
[ClaDebugProcess.sln](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.sln)
[ClaDebugProcess.cwproj](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.cwproj)
[ClaDebugProcess.clw](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.clw)

Sample D32.log
``` 
Started 
Heap handle: 06A20000
start process 
Debug active process 00000764
event 00000000
Redirection file :> 
CREATE_PROCESS_DEBUG_EVENT  ! No image name found
g.debug_name 
BaseOfImage                00400000
CREATE_PROCESS_DEBUG_EVENT: process main thread tid=00001044
thread handle=00000598
ntdll.dll Loaded at: 76FF0000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=00001D60
thread handle=0000058C
CREATE_THREAD_DEBUG_EVENT: tid=000029D4
thread handle=000005D0
CREATE_THREAD_DEBUG_EVENT: tid=000024A8
thread handle=00000584
CREATE_THREAD_DEBUG_EVENT: tid=00002B24
thread handle=0000062C
CREATE_THREAD_DEBUG_EVENT: tid=000011E8
thread handle=00000630
CREATE_THREAD_DEBUG_EVENT: tid=00000AAC
thread handle=00000634
CREATE_THREAD_DEBUG_EVENT: tid=000028A4
thread handle=00000624
CREATE_THREAD_DEBUG_EVENT: tid=00003290
thread handle=00000640
CREATE_THREAD_DEBUG_EVENT: tid=00003294
thread handle=00000644
CREATE_THREAD_DEBUG_EVENT: tid=000026BC
thread handle=00000648
KERNEL32.dll Loaded at: 75E60000
No debug information
KERNELBASE.dll Loaded at: 762B0000
No debug information
ClaRUN.dll Loaded at: 01000000
WslDb$$NotifyDebugger 010E0C9C
ADVAPI32.dll Loaded at: 76650000
No debug information
msvcrt.dll Loaded at: 76580000
No debug information
SECHOST.dll Loaded at: 766F0000
No debug information
RPCRT4.dll Loaded at: 76040000
No debug information
COMDLG32.dll Loaded at: 75B50000
No debug information
msvcp_win.dll Loaded at: 76220000
No debug information
ucrtbase.dll Loaded at: 76E30000
No debug information
combase.dll Loaded at: 74A70000
No debug information
SHCORE.dll Loaded at: 74F30000
No debug information
USER32.dll Loaded at: 75860000
No debug information
win32u.dll Loaded at: 75E10000
No debug information
GDI32.dll Loaded at: 75E30000
No debug information
gdi32full.dll Loaded at: 76BE0000
No debug information
SHLWAPI.dll Loaded at: 75FC0000
No debug information
SHELL32.dll Loaded at: 75190000
No debug information
WinTypes.dll Loaded at: 74D00000
No debug information
ole32.dll Loaded at: 75C10000
No debug information
OLEAUT32.dll Loaded at: 75AA0000
No debug information
COMCTL32.dll Loaded at: 69560000
No debug information
MPR.dll Loaded at: 72A30000
No debug information
WINSPOOL.DRV Loaded at: 6DAF0000
No debug information
CFGMGR32.dll Loaded at: 73810000
No debug information
oledlg.dll Loaded at: 72690000
No debug information
IMM32.dll Loaded at: 75830000
No debug information
MSIMG32.dll Loaded at: 72670000
No debug information
Windows.Storage.dll Loaded at: 73BB0000
No debug information
bcryptPrimitives.dll Loaded at: 76D50000
No debug information
AppCore.dll Loaded at: 73AB0000
No debug information
UxTheme.dll Loaded at: 749D0000
No debug information
PROPSYS.dll Loaded at: 73990000
No debug information
CLBCatQ.DLL Loaded at: 76F50000
No debug information
Windows.FileExplorer.Common.dll Loaded at: 738F0000
No debug information
profapi.dll Loaded at: 738C0000
No debug information
Windows.StateRepositoryPS.dll Loaded at: 6AC40000
No debug information
Windows.StateRepositoryClient.dll Loaded at: 725D0000
No debug information
edputil.dll Loaded at: 725B0000
No debug information
urlmon.dll Loaded at: 723F0000
No debug information
iertutil.dll Loaded at: 721A0000
No debug information
srvcli.dll Loaded at: 72170000
No debug information
netutils.dll Loaded at: 72680000
No debug information
cldapi.dll Loaded at: 72140000
No debug information
SspiCli.dll Loaded at: 743D0000
No debug information
VirtDisk.dll Loaded at: 72120000
No debug information
Wldp.dll Loaded at: 720C0000
No debug information
pcacli.dll Loaded at: 720A0000
No debug information
sfc_os.dll Loaded at: 72090000
No debug information
ServicingCommon.dll Loaded at: 71FD0000
No debug information
SETUPAPI.dll Loaded at: 76780000
No debug information
TextShaping.dll Loaded at: 6D5B0000
No debug information
MSCTF.dll Loaded at: 74E10000
No debug information
TextInputFramework.dll Loaded at: 6E000000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=0000087C
thread handle=00000728
EXIT_THREAD_DEBUG_EVENT: tid=0000087C
EXIT_THREAD_DEBUG_EVENT: tid=000028A4
EXIT_THREAD_DEBUG_EVENT: tid=000024A8
EXIT_THREAD_DEBUG_EVENT: tid=00001D60
EXIT_THREAD_DEBUG_EVENT: tid=000029D4
CoreMessaging.dll Loaded at: 6DF20000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=00002C20
thread handle=0000058C
CoreUIComponents.dll Loaded at: 6DC80000
No debug information
CRYPTBASE.dll Loaded at: 74400000
No debug information
UNLOAD_DLL_DEBUG_EVENT: BaseOfDll 6AC40000
```
