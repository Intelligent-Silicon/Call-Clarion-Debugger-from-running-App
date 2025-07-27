# Call Clarion Debugger from running App

Most people are familiar with calling the Clarion Debugger from the IDE, but less are familiar with stepping into the Clarion Debugger from a running App.


One way to step into a running app to debug it, is add the following to the Clarion app.

```clarion
    Program
    MAP
ClarionProc1    Procedure()
ClarionProc2    Procedure()
    Module('Api') ! uses C:\Clarion11\Lib\Win32.lib
ISWA_GetCurrentProcessId(Long),Ulong,Pascal,Name('GetCurrentProcessId')
    End
    End
    
    
ClarionProc1    Procedure()

    Code
    OMIT('DebugOnly',_DEBUG_)
        Halt(0,'Not Compiled for Debugging')
    !DebugOnly
    
    Glo:CurrentPID = ISWA_GetCurrentProcessId(0)
    Message('Glo:CurrentPID = ' & Glo:CurrentPID)
    !Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0) ! Only use this if you want to be stuck in an infinite loop. Runs as elevated as Administrator
    !Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0) ! Only use this if you want to be stuck in an infinite loop. Runs asinvoker and Not Elevated.
```

Tip.

If you are going to be copying a Project to new folders in order to debug & test the performance of different sections of code, you need to edit the ```"Clarion_AppName".sln.cache``` to update the new folder location (see below).

```
<PropertyGroup>
    <SolutionDir>C:\ClaAppName\v1\test\</SolutionDir>
    <SolutionExt>.sln</SolutionExt>
    <SolutionFileName>ClaAppName.sln</SolutionFileName>
    <SolutionName>ClaAppName</SolutionName>
    <SolutionPath>C:\ClaAppName\v1\test\ClaAppName.sln</SolutionPath>
  </PropertyGroup>
```


Everytime you copy the Project files (.clw, .sln, .cache, .cwproj, .red) to a new folder, edit the ```"Clarion_AppName".sln.cache```, load it into the IDE and compile it, the Build Configuration Set will default to ```Release``` and not ```Debug```. So the code below will throw an error message when its not compiled for Debugging.

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

Once you have obtained the ProcessID, paste the following into the Run window, a Dos window, or a Powershell window, and replace 1234 with the actual ProcessID.

Elevated to Administrator level
```
"c:\Clarion11\bin\cladb.exe" -p 1234
```

Non Elevated asInvoker.
```
"c:\Clarion11\bin\cladbne.exe" -p 1234
```

Once the debugger has loaded, click ```Window```, then click ```Source``` and select the ```filename.clw``` for the code you want to debug.

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/SelectSourceCLW.png)

Set a break point on the line of the code, and this action of selecting a line prompts the debugger into loading the remaining debugger window panes, to then enable you to carry out a debugging session, including stepping into Assembler if you fancy rolling your sleeves up a bit more.

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/ClarionDebugger.png)




If you want to get technical, check out the ```D32.log``` file, this is the Trace window, that documents the steps the Debugger peforms to load an app for debugging from the IDE or by breaking into a running app process by using this Win32 API [DebugActiveProcess](https://learn.microsoft.com/en-us/windows/win32/api/debugapi/nf-debugapi-debugactiveprocess). Obviously using this API also presents a security risk so use with caution.

Sample D32.log
``` 
Started 
Heap handle: 06D90000
start process 
Debug active process 00001D70
event 00000000
Redirection file :> 
CREATE_PROCESS_DEBUG_EVENT  ! No image name found
g.debug_name 
BaseOfImage                00400000
CREATE_PROCESS_DEBUG_EVENT: process main thread tid=00002634
thread handle=000005E4
ntdll.dll Loaded at: 77650000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=00001268
thread handle=00000600
CREATE_THREAD_DEBUG_EVENT: tid=00002EC8
thread handle=00000614
CREATE_THREAD_DEBUG_EVENT: tid=00002918
thread handle=00000618
KERNEL32.dll Loaded at: 75E00000
No debug information
KERNELBASE.dll Loaded at: 750F0000
No debug information
SHELL32.dll Loaded at: 769C0000
No debug information
msvcp_win.dll Loaded at: 767C0000
No debug information
ucrtbase.dll Loaded at: 757D0000
No debug information
ClaRUN.dll Loaded at: 01000000
WslDb$$NotifyDebugger 010E0C9C
USER32.dll Loaded at: 76300000
No debug information
ADVAPI32.dll Loaded at: 758F0000
No debug information
win32u.dll Loaded at: 76190000
No debug information
msvcrt.dll Loaded at: 77450000
No debug information
GDI32.dll Loaded at: 750C0000
No debug information
SECHOST.dll Loaded at: 75A40000
No debug information
gdi32full.dll Loaded at: 76500000
No debug information
WinTypes.dll Loaded at: 75540000
No debug information
RPCRT4.dll Loaded at: 76900000
No debug information
combase.dll Loaded at: 75F00000
No debug information
COMDLG32.dll Loaded at: 75980000
No debug information
COMCTL32.dll Loaded at: 6B5B0000
No debug information
SHCORE.dll Loaded at: 75C40000
No debug information
SHLWAPI.dll Loaded at: 753C0000
No debug information
ole32.dll Loaded at: 75AE0000
No debug information
OLEAUT32.dll Loaded at: 75420000
No debug information
MPR.dll Loaded at: 73720000
No debug information
oledlg.dll Loaded at: 6E530000
No debug information
WINSPOOL.DRV Loaded at: 6E570000
No debug information
CFGMGR32.dll Loaded at: 73460000
No debug information
ClaTPS.dll Loaded at: 00630000
No debug information
IMM32.dll Loaded at: 764D0000
No debug information
MSIMG32.dll Loaded at: 6E520000
No debug information
UxTheme.dll Loaded at: 729D0000
No debug information
TextShaping.dll Loaded at: 6DFA0000
No debug information
MSCTF.dll Loaded at: 77520000
No debug information
AppCore.dll Loaded at: 74880000
No debug information
bcryptPrimitives.dll Loaded at: 75D90000
No debug information
TextInputFramework.dll Loaded at: 6E730000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=00000944
thread handle=00000720
EXIT_THREAD_DEBUG_EVENT: tid=00000944
CREATE_THREAD_DEBUG_EVENT: tid=000022F8
thread handle=00000590
CREATE_THREAD_DEBUG_EVENT: tid=00000350
thread handle=0000071C
EXIT_THREAD_DEBUG_EVENT: tid=00002918
EXIT_THREAD_DEBUG_EVENT: tid=00002EC8
EXIT_THREAD_DEBUG_EVENT: tid=00001268
CoreMessaging.dll Loaded at: 6A9E0000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=00000950
thread handle=00000C50
CoreUIComponents.dll Loaded at: 6A740000
No debug information
CRYPTBASE.dll Loaded at: 705A0000
No debug information
CREATE_THREAD_DEBUG_EVENT: tid=00001D48
thread handle=00000D40
CREATE_THREAD_DEBUG_EVENT: tid=00002AD4
thread handle=00000748
```
