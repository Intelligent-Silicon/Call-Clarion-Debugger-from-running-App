# Call Clarion Debugger from running App

Most people are familiar with calling the Clarion Debugger from the IDE, but less are familiar with breaking/stepping into the Clarion Debugger from a running App.


One way to step into a running app to debug it, is add the following to the Clarion app.

```clarion

PROGRAM 
    INCLUDE('KEYCODES.CLW'),ONCE
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
Example6StackTrace                  PROCEDURE()
Example6StackTraceA                 PROCEDURE()
Example6StackTraceB                 PROCEDURE()
Example6StackTraceC                 PROCEDURE()
Example7AppGenAssert                Procedure()
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
    Compile('DebugOnly',_DEBUG_)
        Case Message('Build Configuration:Debug<32,10>Do you want to continue?','Question',ICON:Question,Button:Yes+Button:No)
        OF Button:No
            Return
        End
    !DebugOnly

    ! If Build, Set Configuration is set to Release, this Halt will stop the program.
    Omit('ReleaseOnly',_DEBUG_)
        !Comment this Halt() to test Example4Omit_Debug_CompilerFlag()
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
    Example6StackTrace()
    Example7AppGenAssert()
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
                'then set a Breakpoint on Line 85.<32,10>' & |
                'When that is done, come back to this message box and click the OK button below.','Example1')
        Glo:SVCstring = 'Case Message - CallDeubgger() or CallDebuggerNE()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example1CaseMessage')
    End

Example2IfConditionAssert    Procedure

    Code
    ! If Condition CallDebugger() and standard Assert()
    IF Glo:SomeCondition = True 
        CallDebugger()  
        Assert(0,'Example2IfConditionAssert:Debugger, Window, Source, select Filename.clw, Breakpoint Line 96, then return here, click Continue button below.')
        Glo:SVCstring = 'If Condition, CallDebugger() and standard Assert()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example2IfConditionAssert')
    End

Example3Compile_Debug_CompilerFlag    Procedure()
    Code
    ! CallDebugger() is appended to the Assert Message - it should return 0  
    Compile('DebugOnly',_DEBUG_) 
        Assert(0,'Example3Compile_Debug_CompilerFlag:Debugger, Window, Source, select Filename.clw, Breakpoint Line 105, then return here, click Continue button below.' & CallDebugger())
        Glo:SVCstring = 'CallDebugger() is appended to the Assert Message'
        Message(Glo:SVCstring &'|'& Glo:CSIDL_FolderPath,'Example3Compile_Debug_CompilerFlag')
    !DebugOnly
                  
Example4Omit_Debug_CompilerFlag    Procedure()
    Code
    ! You cant debug a Release version in reality, but demonstrates how ClaDBne.exe could be called.
    ! Whilst its good being able to step into the Debugger, if you use multiple Assert()'s, using the Non Elevated
    ! removes the UAC prompt choice to not launch the debugger when not using the Debugger to start the program
    ! from the IDE.
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
    Omit('ReleaseOnly',_DEBUG_) 
        Assert(0+CallDebuggerNE(),'Example4Omit_Debug_CompilerFlag:Debugger, Window, Source, select Filename.clw, Breakpoint Line 118, then return here, click Continue button below.' )
        Glo:SVCstring = 'You cant debug in Release Mode'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example4Omit_Debug_CompilerFlag')
    !ReleaseOnly     

Example5Col1QuestionMark    Procedure()
    Code
    ! All the lines of code starting with ? are only compiled when Build Configuration is set to Debug
    ! CallDebugger() is added to the Assert Expression - it should return 0
?   Assert(0+CallDebugger(),'Example5Col1QuestionMark:Debugger, Window, Source, select Filename.clw, Breakpoint Line 127, then return here, click Continue button below.' )
?   Glo:SVCstring = '? in column 1 for Build Configuration:Debug'
?   Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example5Col1QuestionMark') 

Example6StackTrace    Procedure()
    Code
    Assert(0,'Example6StackTrace:Assert1: Before the call to Example6StackTraceA(). Called by _main which is top entry in the Call Stack. Now click Continue button.' )
    Example6StackTraceA()   ! Calls Example6StackTraceB(), and Example6StackTraceB() calls Example6StackTraceC() 
    Assert(0,'Example6StackTrace:Assert2: After the call to Example6StackTraceA(). Called by _main which is now top entry in the Call Stack. Now click Continue button.' )
            
Example6StackTraceA   Procedure()
    Code
    Assert(0,'Example6StackTraceA. Called by Example6StackTrace which is top entry in the Call Stack. Now click Continue button.' )
    Example6StackTraceB()

Example6StackTraceB   Procedure()
    Code
    Assert(0,'Example6StackTraceB. Called by Example6StackTraceA which is top entry in the Call Stack. Now click Continue button.' )
    Example6StackTraceC()

Example6StackTraceC   Procedure()
    Code
    Assert(0,'Example6StackTraceC:Assert1. Called by Example6StackTraceB which is top entry in the Call Stack. Now click Continue button.' )
    Assert(0,'Example6StackTraceC:Assert2. Called by Example6StackTraceB which is still top entry in the Call Stack. Now click Continue button.' )
 

Example7AppGenAssert Procedure()

Window WINDOW('AppGen Window Procedure'),AT(,,395,224),GRAY,FONT('Segoe UI',9,, |
            FONT:regular+FONT:underline)
        BUTTON('&OK'),AT(259,201,41,14),USE(?OkButton),FONT(,,,FONT:regular),DEFAULT
        BUTTON('&Cancel'),AT(303,201,42,14),USE(?CancelButton),FONT(,,,FONT:regular)
        BUTTON('&Help'),AT(348,201,36,14),USE(?HelpButton),STD(STD:Help), |
                FONT(,,,FONT:regular)
        STRING('Press Ctrl + D to load the Debugger.'),AT(2,11,391,23),USE(?STRING1), |
                CENTER,FONT(,16,,FONT:regular)
        STRING('Debugger: Window, Source, select Filename.clw'),AT(2,41,391,23), |
                USE(?STRING2),CENTER,FONT(,16,,FONT:regular)
        STRING('Set Breakpoint, then click Assert window''s Continue button.'), |
                AT(2,71,391,23),USE(?STRING3),CENTER,FONT(,16,,FONT:regular)
    END 


    Code
    Open(Window)
    ALERT(CtrlD)
    Accept
        CASE EVENT()
        OF EVENT:AlertKey       !Alert processing
            IF KeyCode() = CtrlD
                Assert(0+CallDebugger(),'Example7AppGenAssert:Debugger, Window, Source, select Filename.clw, Breakpoint Line 177, then return here, click Continue button below.') 
                Glo:SVCstring = 'AppGen Procedure using Alert Key'
                Message(Glo:SVCstring &'|'& Glo:CSIDL_FolderPath,'Example7AppGenAssert')
            End
        End

        CASE ACCEPTED()
        OF ?OkButton
            Close(Window)
        OF ?CancelButton
            Close(Window)
        OF ?HelpButton
            Close(Window)
        End
    End
    




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
| B | Toggle (B)reakpoint on and off on the currently highlighted line |
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

The ```Memory()``` window pane controls in the bottom right.

| Key | Activity |
| --- | --- |
| N | Open a new Memory() window with the highlighted address now positioned on the top row |
| L | Pops up a window where the memory address can be Located |

There are also two vertical scroll bars side by side in the Memory() window. One mouse click on the inner scroll bar or click on the inner scrollbar arrows will jump to the next 10000 memory address and will span the entire memory range. The outer scroll bar will navigate approximately the current 10000 memory addresses and only span the current 10000 memory addresses.

The ```Locate``` popup window only accepts hexadecimal values without any trailing ```h```.

Right mouseclicking anywhere in the ```Memory()``` window pane will also popup a menu with the same options. 


### Clarion Debug Runtime
To use the Clarion Debug Runtime which displays additional information to help track down problems in code, copy the ```Clarion110.RED``` Redirection file to the ```C:\ClaDebugProcess```.
Change the line ```*.dll```
```
[Copy]
-- Directories only used when copying dlls
*.dll = %BIN%\Debug;%BIN%;%BIN%\AddIns\BackendBindings\ClarionBinding\Common;%ROOT%\Accessory\bin
```
by prepending ```%BIN%\Debug``` to the folder paths, the IDE will copy the ```ClaRUN.dll``` from the ```%BIN%\Debug``` folder to the ```C:\ClaDebugProcess``` folder, because ```%BIN%\Debug``` is encountered before the ```%BIN%``` folder in the folder paths.

The fastest way to determine which version of ```ClaRUN.dll``` is in use is to check the file size in ```C:\ClaDebugProcess``` or use ```Assert()``` in your code to see if the additional info is displayed in the resulting ```Assert()``` window. 

| ClaRUN.dll Type | File Size |
| --- | --- |
| Release | 1746 KB |
| Debug | 1755 KB | 

Alternatively you could run a Powershell command and hash the ClaRun.dll files.
```
PS C:\WINDOWS\system32> Get-FileHash -Path "C:\Clarion11\bin\debug\claRun.dll" -Algorithm MD5

Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
MD5             6679BCEE992BF5B4876C6A88C819D883                                       C:\Clarion11\bin\debug\claRun.dll
```
```
PS C:\WINDOWS\system32> Get-FileHash -Path "C:\Clarion11\bin\claRun.dll" -Algorithm MD5

Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
MD5             7A780A0320838E781E873A948FE0658F                                       C:\Clarion11\bin\claRun.dll
```


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
                'then set a Breakpoint on Line 85.<32,10>' & |
                'When that is done, come back to this message box and click the OK button below.','Example1')
        Glo:SVCstring = 'Case Message - CallDeubgger() or CallDebuggerNE()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example1CaseMessage')
    End
```
In the image below, a Breakpoint has been set on Line 85 denoted by the Yellow line bar (Breakpoint and Highlight bar), the Line Number can be seen in the window title for the filename.clw eg ```C:\ClaDebugProcess\CLADEBUGPROCESS.CLW () L: 85 of 159```. Once the Developer clicks OK on the message box, the Globals() and Stack Trace() window panes on the right will appear. 



![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Example1Debug.png)

### Example2IfConditionAssert
This example shows the ```CallDebugger()``` being called first, and whilst the Clarion Debugger is loading, the Assert() function will halt the program, displaying a message on how to proceed.

```clarion
Example2IfConditionAssert    Procedure

    Code
    ! If Condition CallDebugger() and standard Assert()
    IF Glo:SomeCondition = True 
        CallDebugger()  
        Assert(0,'Example2IfConditionAssert:Debugger, Window, Source, select Filename.clw, Breakpoint Line 96, then return here, click Continue button below.')
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
        Assert(0,'Example3Compile_Debug_CompilerFlag:Debugger, Window, Source, select Filename.clw, Breakpoint Line 105, then return here, click Continue button below.' & CallDebugger())
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
    ! Whilst its good being able to step into the Debugger, if you use multiple Assert()'s, using the Non Elevated
    ! removes the UAC prompt choice to not launch the debugger when not using the Debugger to start the program
    ! from the IDE.
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
    Omit('ReleaseOnly',_DEBUG_) 
        Assert(0+CallDebuggerNE(),'Example4Omit_Debug_CompilerFlag:Debugger, Window, Source, select Filename.clw, Breakpoint Line 118, then return here, click Continue button below.' )
        Glo:SVCstring = 'You cant debug in Release Mode'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example4Omit_Debug_CompilerFlag')
    !ReleaseOnly
```

### Example5Col1QuestionMark
This example uses the question mark ```?``` in Column 1 of the Text Editor to include the line of code when the Build Configuration is set to
```Debug```. When the Build Configuration is set to ```Release``` these lines of code starting with a question mark will not be included by the Compiler.

```clarion
Example5Col1QuestionMark    Procedure()
    Code
    ! All the lines of code starting with ? are only compiled when Build Configuration is set to Debug
    ! CallDebugger() is added to the Assert Expression - it should return 0
?   Assert(0+CallDebugger(),'Example5Col1QuestionMark:Debugger, Window, Source, select Filename.clw, Breakpoint Line 127, then return here, click Continue button below.' )
?   Glo:SVCstring = '? in column 1 for Build Configuration:Debug'
?   Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example5Col1QuestionMark') 
```
![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Example5Col1QuestionMark.png)

### Example6StackTrace

If using the [Debug version of ClaRun.dll](README.md#clarion-debug-runtime), the ```Assert()``` window will display additional information in the ```Call Stack```.

![Screenshot](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Example6StackTraceC.png)

Firstly all the text in the ```Assert()``` window can be selected and copied using a mouse. In this example, you can see the text that appears when the procedure ```Example6StackTraceC``` calls the second ```Assert()```. 

```
Assertion failed  on line: 149 in file ClaDebugProcess.clw
Message: Example6StackTraceC:Assert2. Called by Example6StackTraceB which is still top entry in the Call Stack. Now click Continue button.
Process PID=6252  Image: C:\ClaDebugProcess\ClaDebugProcess.Exe
Thread 1  Handle=0000024C  TID=13172

Stack frame: 0019FE94

Call Stack:
004011FE  ClaDebugProcess.clw:144 - EXAMPLE6STACKTRACEB
0040123E  ClaDebugProcess.clw:139 - EXAMPLE6STACKTRACEA
0040127E  ClaDebugProcess.clw:134 - EXAMPLE6STACKTRACE
00401103  ClaDebugProcess.clw:64 - _main
010CF9E7  ClaRUN.dll:000CF9E7
010CF4D1  ClaRUN.dll:000CF4D1
76F1D1AB
76F1D131
```
At the time of writing the line number shown as ```:nnn``` after the ```filename.clw``` is out by 1, so subtract 1 from each number to get the correct line number. The line numbers should be what can be seen below. 
```
Call Stack:
004011FE  ClaDebugProcess.clw:143 - EXAMPLE6STACKTRACEB
0040123E  ClaDebugProcess.clw:138 - EXAMPLE6STACKTRACEA
0040127E  ClaDebugProcess.clw:133 - EXAMPLE6STACKTRACE
00401103  ClaDebugProcess.clw:63 - _main
```

The first column above shows a hex number which represents the memory address where the call originated from. The top line is the address in memory where the call to ```Example6StackTraceC``` originated from ```Example6StackTraceB```.

The centre column above shows the ```filename.clw:nnn``` and the line number in the source code file.

The third column above shows the procedure name that line 143 can be found in. 

The second line above shows the memory address where the call to ```Example6StackTraceB``` is located in ```Example6StackTraceA```.

The third line above shows the memory address where the call to ```Example6StackTraceA``` is located in ```Example6StackTrace```.

The fourth line above shows the memory address where the call to ```Example6StackTrace``` is located in ```_main``` 

Now if your Hex is a little rusty, or you dont speak fluent Hex (yes some people can do this), a quick way to find out where line ```ClaDebugProcess.clw:143``` fits in the ```MAP``` file below is to convert it into Decimal, [search online for a Hex to Decimal convertor website](https://www.google.com/search?q=hex+to+decimal+converter). The decimal value is the 3rd column seen below.

The ```MAP``` file is a summary of where different parts of an ```EXE```, ```DLL``` or ```Lib``` file can be found, these files follows rules based on the [Windows PE (Portable Executable) format](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format).

[C:\ClaDebugProcess\map\debug\ClaDebugProcess.map](https://github.com/Intelligent-Silicon/Call-Clarion-Debugger-from-running-App/blob/main/Source/ClaDebugProcess.MAP)
```
  40116C EXAMPLE6STACKTRACEC@F - 4198764
  4011C4 EXAMPLE6STACKTRACEB@F - 4198852
  401204 EXAMPLE6STACKTRACEA@F = 4198916
```

The first line in the Call Stack, memory address ```004011FE``` translates to ```4198910``` in decimal, so we can see the actual procedure call to ```Example6StackTraceC``` is located between ```Example6StackTraceB``` and ```Example6StackTraceA``` in the ```MAP``` file. 

The general rule is take the first address shown in the ```Assert()``` window ```Call Stack``` and look in the corresponding ```MAP``` file for the procedure with an address thats lower but closest to the address shown in the ```Assert()``` message. 

In this example ```4011C4 EXAMPLE6STACKTRACEB@F - 4198852``` has an address which is lower than ```004011FE``` aka ```4198910``` so it probably resides in the procedure ```Example6StackTraceB```, which we know because we can also see and compile the program source ```ClaDebugProcess.clw``` and it also happens to be on Line 143 of all things!

Repeat for the 2nd and subsequent lines in the ```Call Stack```.

At this stage, and with a certain level of practice, you wont need to use the ```Debug``` version of the Clarion Runtime, which is why its not included first in the ```*.dll = %BIN%\Debug;%BIN%;%BIN%\AddIns\BackendBindings\ClarionBinding\Common;%ROOT%\Accessory\bin``` ```[Copy]``` section of the default ```Clarion110.RED``` Redirection file.

The rest of the ```MAP``` file is worth exploring to become familiar with it but thats beyond the scope of this Repo.

Anyway when trying to narrow down the source of the problem, we have to start at the top of the ```Call Stack``` and work backwards, so downwards. The number of lines in the ```Call Stack``` can be variable as it depends on how many times a different procedure has been called since the start, which in this case is ```_main```. 

Fortunately its possible to work out what line of code within a procedure has made a procedure call, which can then help you to choose what lines to ```Breakpoint``` when you start a debugging session either starting from the IDE or by breaking into it with a carefully placed ```Assert()```, which this repo has now shown you.

### Example7AppGenAssert
This procedure is a minimal version of a Clarion AppGen Procedure. Here the ```Ctrl``` & ```D key``` are ```Alert```, so at any time during the normal operation of a window procedure, you can trigger the ```Alert``` which then calls the ```Assert``` that starts the Debugger and lets you step into the Procedure and set ```Breakpoint```'s.

```clarion
Example7AppGenAssert Procedure()

Window WINDOW('AppGen Window Procedure'),AT(,,395,224),GRAY,FONT('Segoe UI',9,, |
            FONT:regular+FONT:underline)
        BUTTON('&OK'),AT(259,201,41,14),USE(?OkButton),FONT(,,,FONT:regular),DEFAULT
        BUTTON('&Cancel'),AT(303,201,42,14),USE(?CancelButton),FONT(,,,FONT:regular)
        BUTTON('&Help'),AT(348,201,36,14),USE(?HelpButton),STD(STD:Help), |
                FONT(,,,FONT:regular)
        STRING('Press Ctrl + D to load the Debugger.'),AT(2,11,391,23),USE(?STRING1), |
                CENTER,FONT(,16,,FONT:regular)
        STRING('Debugger: Window, Source, select Filename.clw'),AT(2,41,391,23), |
                USE(?STRING2),CENTER,FONT(,16,,FONT:regular)
        STRING('Set Breakpoint, then click Assert window''s Continue button.'), |
                AT(2,71,391,23),USE(?STRING3),CENTER,FONT(,16,,FONT:regular)
    END 


    Code
    Open(Window)
    ALERT(CtrlD)
    Accept
        CASE EVENT()
        OF EVENT:AlertKey       !Alert processing
            IF KeyCode() = CtrlD
                Assert(0+CallDebugger(),'Example7AppGenAssert:Debugger, Window, Source, select Filename.clw, Breakpoint Line 177, then return here, click Continue button below.') 
                Glo:SVCstring = 'AppGen Procedure using Alert Key'
                Message(Glo:SVCstring &'|'& Glo:CSIDL_FolderPath,'Example7AppGenAssert')
            End
        End

        CASE ACCEPTED()
        OF ?OkButton
            Close(Window)
        OF ?CancelButton
            Close(Window)
        OF ?HelpButton
            Close(Window)
        End
    End
```

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