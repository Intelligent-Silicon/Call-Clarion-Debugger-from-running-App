# Call Clarion Debugger from running App

Most people are familiar with calling the Clarion Debugger from the IDE, but less are familiar with breaking/stepping into the Clarion Debugger from a running App.


One way to step into a running app to debug it, is add the following to the Clarion app.

```clarion

    PROGRAM 

Glo:CurrentPID              Ulong 
! https://github.com/Intelligent-Silicon/CSIDL
ISEQ:CSIDL_DESKTOP          Equate(0)  ! C:\Users\Admin1\Desktop
ISEQ:CSIDL_COMMON_STARTUP   Equate(24) ! C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
ISEQ:CSIDL_APPDATA          Equate(26) ! C:\Users\Admin1\AppData\Roaming
ISEQ:CSIDL_COMMON_APPDATA   Equate(35) ! C:\ProgramData or C:\Documents and Settings\All Users\Application Data
Glo:CSIDL_FolderPath        Cstring(1024)
Glo:RVLong                  Long ! Return Value Long
Glo:SVCstring               CString(1024)

Glo:SomeCondition           Long(1)

    MAP
Example1CaseMessage                 PROCEDURE()
Example2IfConditionAssert           PROCEDURE()
Example3Compile_Debug_CompilerFlag  PROCEDURE()
Example4Omit_Debug_CompilerFlag     PROCEDURE()
Example5Col1QuestionMark            PROCEDURE()
CallDebugger                        PROCEDURE(),Long,Proc
CallDebuggerNE                      PROCEDURE(),Long,Proc

    MODULE('api')
    ISWA_GetCurrentProcessId(Long),Ulong,Pascal,Name('GetCurrentProcessId')
    ISWA_SHGetFolderPathA(Long, Long, Long, Ulong, Long), Long, Pascal,Raw,Name('SHGetFolderPathA') 
    END

    END

!region File Declaration
!endregion


    CODE

    ! If Build, Set Configuration is set to Release, this Halt will stop the program.
    Compile('DebugOnly',_DEBUG_)
        Case Message('Build Configuration:Debug<32,10>Do you want to continue?','Question',ICON:Question,Button:Yes+Button:No)
        OF Button:No
            Return
        End
    !DebugOnly
    Omit('ReleaseOnly',_DEBUG_)
        Halt(0,'You cant debug with Build Configuration set to Release')
    !ReleaseOnly

    ! <ProcessID> for the Clarion Debugger 
    Glo:CurrentPID  = ISWA_GetCurrentProcessId(0)
    Glo:RVLong      = ISWA_SHGetFolderPathA(0,ISEQ:CSIDL_APPDATA,0,0,Address(Glo:CSIDL_FolderPath))

    Example1CaseMessage()
    Example2IfConditionAssert()
    Example3Compile_Debug_CompilerFlag()
    Example4Omit_Debug_CompilerFlag()
    Example5Col1QuestionMark()
    Return
  
Example1CaseMessage    Procedure
Loc:MessageResult   Long
    Code 
    ! Case Message - CallDeubgger() or CallDebuggerNE()
    Loc:MessageResult = Message(   'Process ID = ' & Glo:CurrentPID &'<32,10>Launch Debugger?<32,10>',|
                                    'Example1CaseMessage',ICON:Question,'Goto &Example2| Launch &Cladb.exe| Launch Cladb&NE.exe')

    Case Loc:MessageResult 
    OF 2
        Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    OF 3
        Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    End
     
    IF Loc:MessageResult = 2 or Loc:MessageResult = 3
        MEssage('Wait for the Debugger to load,<32,10>' & |
                'then click Window, Source, and select a "filename.clw",<32,10>' & |
                'then set a Breakpoint on Line 79.<32,10>' & |
                'When that is done, come back to this message box and click the OK button below.','Example1')
        Glo:SVCstring = 'Case Message - CallDeubgger() or CallDebuggerNE()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example1CaseMessage')
    End

Example2IfConditionAssert    Procedure

    Code
    ! If Condition CallDebugger() and standard Assert()
    IF Glo:SomeCondition = True 
        CallDebugger()  
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Line 90, then return here, click Continue button below.')
        Glo:SVCstring = 'If Condition, CallDebugger() and standard Assert()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example2IfConditionAssert')
    End

Example3Compile_Debug_CompilerFlag    Procedure()
    Code
    ! CallDebugger() is appended to the Assert Message - it should return 0  
    Compile('DebugOnly',_DEBUG_) 
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Line 99, then return here, click Continue button below.' & CallDebugger())
        Glo:SVCstring = 'CallDebugger() is appended to the Assert Message'
        Message(Glo:SVCstring &'|'& Glo:CSIDL_FolderPath,'Example3Compile_Debug_CompilerFlag')
    !DebugOnly
                  
Example4Omit_Debug_CompilerFlag    Procedure()
    Code
    ! You cant debug a Release version in reality, but demonstrates how ClaDBne.exe could be called.
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
    Omit('ReleaseOnly',_DEBUG_) 
        Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Line 109, then return here, click Continue button below.' )
        Glo:SVCstring = 'You cant debug in Release Mode'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example4Omit_Debug_CompilerFlag')
    !ReleaseOnly     

Example5Col1QuestionMark    Procedure()
    Code
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
?   Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Line 117, then return here, click Continue button below.' )
?   Glo:SVCstring = '? in column 1 for Build Configuration:Debug'
?   Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example5Col1QuestionMark')


CallDebugger    PROCEDURE()
    Code
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0

CallDebuggerNE  PROCEDURE()
    Code  
    Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0
```


The code below will ```Halt``` the program when its not compiled for Debugging.

```clarion
   Omit('ReleaseOnly',_DEBUG_)
        Halt(0,'You cant debug with Build Configuration set to Release')
    !ReleaseOnly
```


The code calls the Window API ```GetCurrentProcessID``` to get the Process ID of the program when it runs. This is required so that it can be passed to the Clarion Debugger when its called from the command line using the ```-p <ProcessID>``` command switch.

```clarion
    ! <ProcessID> for the Clarion Debugger 
    Glo:CurrentPID  = ISWA_GetCurrentProcessID(0)
```
Another way to get the ProcessID for the running app is to use [SysInternals procexp64.exe](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer) but requires you to be able to identify the correct instance of the program and thus ProcessID when more than one instance of the program is running.

If you want to Break/Step into your running program manually, once you have obtained the ProcessID, paste the following into a Run window, a Dos window, or a Powershell window, and replace 1234 with the actual ProcessID.

Debugger Elevated. Using the Debugger to start the App from the IDE will make the CSIDL represent the Administrator folder paths.
```
"c:\Clarion11\bin\cladb.exe" -p 1234
```

Debugger Not Elevated. Using the Debugger to start the App from the IDE will make the CSIDL represent the logged in User folder paths.
```
"c:\Clarion11\bin\cladbne.exe" -p 1234
```

Once the debugger has loaded, click ```Window```, then click ```Source``` and select the ```filename.clw``` for the code you want to debug.

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/SelectSourceCLW.png)

Set a break point on the required line(s) of code, and this action of selecting a line prompts the debugger into loading the Procedures window pane on the bottom left. After setting Breakpoints, click OK on the message box and the Debugger will display the Globals() and Stack Trace() window panes on the right. The Assembler (Disassembly()) window is minimised on the bottom left of the debugger, it can also be accessed from the Window menu option, if you fancy diving into a bit of Assembler. If you display the Disassembly() window pane beneath the Filename.clw window pane, and STEP (T) through the filename.clw code using the controls on the bottom right of the Filename.clw window pane, a second Highlight bar will jump to the corresponding line of Assembler code. If you STEP (T) through the Disassembly() Assembler code using the controls on the bottom right of the Disassembly() window pane, the Highlight bar in the filename.clw will jump to the corresponding line of Clarion/C/Modula-2 code. If its not obvious one line of Clarion/C/Modula-2 code wraps several lines of Assembler().

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/ClarionDebugger.png)




If you want to get technical, check out the [D32.log](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/D32.log) file, this is a log of the Trace window of all the Debugger steps. This example documents the steps the Debugger peforms to load an app for debugging (from the IDE or) by breaking into a running app process by using this Win32 API [DebugActiveProcess](https://learn.microsoft.com/en-us/windows/win32/api/debugapi/nf-debugapi-debugactiveprocess). Obviously using this API also presents a security risk so use with caution if you dont want other people to take control of your programs.

### Source Files:

Copy to ```C:\ClaDebugProcess```

[ClaDebugProcess.sln.cache](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.sln.cache)

[ClaDebugProcess.sln](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.sln)

[ClaDebugProcess.cwproj](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.cwproj)

[ClaDebugProcess.clw](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.clw)

### Debugger Colours 

The Debugger uses 3 colours to depict its current activity.
| Colour | Activity |
| --- | --- |
| Red | BreakPoints set on line |
| Yellow | BreakPoint with Highlight bar on the line |
| Green | Highlight bar on a line without a Breakpoint |

### Debugger Control Keys

The ```Filename.clw L: X of X``` window pane and ```Disassembly()``` window pane have controls in the bottom right. 

These are the keyboard letters that perform different functions.
| Key | Activity |
| --- | --- |
| G | (G)o - Run the program until the next Breakpoint |
| B | Toggle (B)reakpoint on and off |
| S | (S)tep through each line of Assembler - ```Disassembly()``` window pane does not have to be visible |
| O | Step (O)ver Assembler - Step over Assembler lines to the next Breakpoint - ```Disassembly()``` window pane does not have to be visible |
| T | S(t)ep through the (Clarion) source line by line - ```Filename.clw L: X of X``` window pane does not have to be visible |
| E | Step over the (Clarion) source to the next Breakpoint - ```Filename.clw L: X of X``` window pane does not have to be visible |
| C | Goto the current (C)ursor position in the (Clarion) source |
| L | (L)ocate line number |
| - | Contract the highlighted tree structure in the Globals() window pane and Stack Trace() window pane |
| + | Expand the highlighted tree structure in the Globals() window pane and Stack Trace() window pane |

You can also use the mouse to navigate around the debugger, double clicking on (Clarion) code and Assembler will toggle a Breakpoint.
Clicking on the Tree nodes will expand and contract tree structures like the "Library State" in the Globals() window pane.


### Clarion Debug Runtime
To use the Clarion Debug Runtime which displays additional information to help track down problems in code, copy the ```Clarion110.RED``` Redirection file to the ```C:\ClaDebugProcess```.
Change the line ```*.dll```
```
[Copy]
-- Directories only used when copying dlls
*.dll = %BIN%\Debug;%BIN%;%BIN%\AddIns\BackendBindings\ClarionBinding\Common;%ROOT%\Accessory\bin
```
by prepending ```%BIN%\Debug;``` to the paths, the IDE will copy the ```ClaRUN.dll``` from the ```%BIN%\Debug``` folder to the ```C:\ClaDebugProcess``` folder, because ```%BIN%\Debug;``` is first encountered before the ```%BIN%;``` folder the release version of the Clarion runtime exists.

The only way to determine which version of ```ClaRUN.dll`` is in use is to check the file size.

| ClaRUN.dll Type | File Size |
| --- | --- |
| Release | 1746 KB |
| Debug | 1755 KB | 



### Example1CaseMessage
This example shows how a ```Case Message``` statement can be used to capture a response and then respond accordingly.

```clarion
Example1CaseMessage    Procedure
Loc:MessageResult   Long
    Code 
    ! Case Message - CallDeubgger() or CallDebuggerNE()
    Loc:MessageResult = Message(   'Process ID = ' & Glo:CurrentPID &'<32,10>Launch Debugger?<32,10>',|
                                    'Example1CaseMessage',ICON:Question,'Goto &Example2| Launch &Cladb.exe| Launch Cladb&NE.exe')

    Case Loc:MessageResult 
    OF 2
        Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    OF 3
        Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    End
     
    IF Loc:MessageResult = 2 or Loc:MessageResult = 3
        MEssage('Wait for the Debugger to load,<32,10>' & |
                'then click Window, Source, and select a "filename.clw",<32,10>' & |
                'then set a Breakpoint on Line 79.<32,10>' & |
                'When that is done, come back to this message box and click the OK button below.','Example1')
        Glo:SVCstring = 'Case Message - CallDeubgger() or CallDebuggerNE()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example1CaseMessage')
    End
```
In the image below, a Breakpoint has been set on Line 79 denoted by the Yellow line bar (Breakpoint and Highlight bar), the Line Number can be seen in the window title for the filename.clw eg ```C:\ClaDebugProcess\CLADEBUGPROCESS.CLW () L: 79 of 129```. Once the Developer clicks OK on the message box, the Globals() and Stack Trace() window panes on the right will appear. 



![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Example1Debug.png)

### Example2IfConditionAssert
This example shows the ```CallDebugger()``` being called first, and whilst the Clarion Debugger is loading, the Assert() function will halt the program, displaying a message on how to proceed.

```clarion
Example2IfConditionAssert    Procedure

    Code
    ! If Condition CallDebugger() and standard Assert()
    IF Glo:SomeCondition = True 
        CallDebugger()  
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Line 90, then return here, click Continue button below.')
        Glo:SVCstring = 'If Condition, CallDebugger() and standard Assert()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example2IfConditionAssert')
    End
```

### Example3Compile_Debug_CompilerFlag
This example uses the ```Compile``` directive to instruct the compiler to include the code wrapped between ```Compile('DebugOnly',_DEBUG_)``` and ```DebugOnly``` when the Build Configuration is set to ```Debug```. The ```!``` preceeding the ```DebugOnly``` is for visual reasons only to turn the line into a comment in the Text Editor and it could be removed. The Compiler will remove the terminator ```DebugOnly``` at compile time, leaving the ```!``` in place to do nothing. The ```CallDebugger()``` is appended to the message in the ```Assert()``` statement, so in practice it should add ```0``` to the end of the message after the ```CallDebugger()``` procedure has been called.

```clarion
Example3Compile_Debug_CompilerFlag    Procedure()
    Code
    ! CallDebugger() is appended to the Assert Message - it should return 0  
    Compile('DebugOnly',_DEBUG_) 
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Line 99, then return here, click Continue button below.' & CallDebugger())
        Glo:SVCstring = 'CallDebugger() is appended to the Assert Message'
        Message(Glo:SVCstring &'|'& Glo:CSIDL_FolderPath,'Example3Compile_Debug_CompilerFlag')
    !DebugOnly
```
![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Example3Compile_Debug_CompilerFlag.png)

### Example4Omit_Debug_CompilerFlag
This example use the ```Omit``` directive to instuct the compiler to exclude the code wrapped between ```Omit('ReleaseOnly',_DEBUG_)``` and ```ReleaseOnly``` when the Build Configuration is set to ```Debug```. This is the opposite of ```Example3Compile_Debug_CompilerFlag``` so when this program is compiled in ```Release``` mode, the code will be included by the Compiler enabling it to be called, even though you cant debug a program in ```Release``` mode. The ```!``` preceeding the ```ReleaseOnly``` is for visual reasons only to turn the line into a comment in the Text Editor and it could be removed. The compiler will remove the terminator ```ReleaseOnly``` at compile time, leaving the ```!``` in place to do nothing. The ```CallDebuggerNE()``` is added to the expression in the ```Assert()``` statement, so in practice it should add ```0``` to the zero in the expression after the ```CallDebuggerNE()``` procedure has been called. 

```clarion
Example4Omit_Debug_CompilerFlag    Procedure()
    Code
    ! You cant debug a Release version in reality, but demonstrates how ClaDBne.exe could be called.
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
    Omit('ReleaseOnly',_DEBUG_) 
        Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Line 109, then return here, click Continue button below.' )
        Glo:SVCstring = 'You cant debug in Release Mode'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example4Omit_Debug_CompilerFlag')
    !ReleaseOnly  
```

### Example5Col1QuestionMark
This example uses the question mark ```?``` in Column 1 of the Text Editor to include the line of code when the Build Configuration is set to 

```Debug```. When the Build Configuration is set to ```Release``` these lines of code will not be included by the Compiler.

```clarion
Example5Col1QuestionMark    Procedure()
    Code
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
?   Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Line 117, then return here, click Continue button below.' )
?   Glo:SVCstring = '? in column 1 for Build Configuration:Debug'
?   Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example5Col1QuestionMark')
```

Note in this image there is additional information being displayed.
```
ClaDebugProcess.clw:58 - _main
ClaRUN.dll:000CF9E7
ClaRUN.dll:000CF4D1
```

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Example5Col1QuestionMark.png)

This example is using the debug version of the Clarion runtime. 

### CallDebugger
This procedure calls the Clarion Debugger running it Elevated. Any ```ErrorCode()``` by the ```Run``` statement will be returned, otherwise ```ErrorCode()``` just returns 0.

```clarion
CallDebugger    PROCEDURE()
    Code
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0
```

### CallDebuggerNE
This procedure calls the Clarion Debugger running Not Elevated. Any ```ErrorCode()``` by the ```Run``` statement will be returned, otherwise ```ErrorCode()``` just returns 0.

```clarion
CallDebuggerNE  PROCEDURE()
    Code  
    Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0
```