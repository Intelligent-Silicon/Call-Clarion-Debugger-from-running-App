# Call Clarion Debugger from running App

Most people are familiar with calling the Clarion Debugger from the IDE, but less are familiar with stepping into the Clarion Debugger from a running App.


One way to step into a running app to debug it, add the following to the Clarion app.

```clarion
    MAP
ClarionProc1    Procedure()
ClarionProc2    Procedure()
    Module('Api') ! uses C:\Clarion11\Lib\Win32.lib
ISWA_GetCurrentProcessId(Long),Ulong,Pascal,Name('GetCurrentProcessId')
    End
    End
    
    
ClarionProc1    Procedure()

    Code
    Glo:CurrentPID = ISWA_GetCurrentProcessId(0)
    Message('Glo:CurrentPID = ' & Glo:CurrentPID)
```

This pops up the ProcessID, and its easy to add this before the section of code you want to debug.

 Another way to get the ProcessID for the running app is to use [SysInternals procexp64.exe](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer) but requires you to find a convenient procedure and thus ```Accept``` loop to break into with the Clarion Debugger statement shown below.

Once you have obtained the ProcessID, paste the following into the Run window, or a Dos window, 1234 is replaced by the actual ProcessID.

```
"c:\Clarion11\bin\cladb.exe" -p 1234
```

Once the debugger has loaded, click ```Window```, then click ```Source``` and select the filename.clw for the code you want to debug.

Set a break point on the line of the code, and this action of selecting a line prompts the debugger into loading the remaining debugger window panes, to then enable you to carry out a debugging session, including stepping into Assembler if you fancy rolling your sleeves up a bit more.

Thats all you need to do regardless of Window permissions and what other apps shave called your Clarion app.

