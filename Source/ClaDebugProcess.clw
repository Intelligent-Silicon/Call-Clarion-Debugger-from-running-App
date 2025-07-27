
    PROGRAM 

Glo:CurrentPID              Ulong 
! https://github.com/Intelligent-Silicon/CSIDL
ISEQ:CSIDL_DESKTOP          Equate(0)  ! C:\Users\Admin1\Desktop
ISEQ:CSIDL_COMMON_STARTUP   Equate(24) ! C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
ISEQ:CSIDL_APPDATA          Equate(26) ! C:\Users\Admin1\AppData\Roaming
ISEQ:CSIDL_COMMON_APPDATA   Equate(35) ! C:\ProgramData or C:\Documents and Settings\All Users\Application Data
Glo:CSIDL_FolderPath        Cstring(1024)
Glo:RVLong                  Long ! Return Value Long

Glo:SomeCondition           Long(1)
    MAP
Main        PROCEDURE()
    MODULE('api')
    ISWA_GetCurrentProcessId(Long),Ulong,Pascal,Name('GetCurrentProcessId')
    ISWA_SHGetFolderPathA(Long, Long, Long, Ulong, Long), Long, Pascal,Raw,Name('SHGetFolderPathA') 
    END

    END

!region File Declaration
!endregion


    CODE

    ! If Build, Set Configuration is set to Release, this Halt will stop the program.
    OMIT('DebugOnly',_DEBUG_)
        Halt(0,'Not Compiled for Debugging<32,10>In the IDE, select Build, Set Configuration, Debug')
    !DebugOnly  

    ! <ProcessID> for the Clarion Debugger 
    Glo:CurrentPID = ISWA_GetCurrentProcessId(0)


    ! When the Debugger loads...
    ! Select Window, then Source and then filename.clw in this case ClaDebugProcess.clw
    ! Set your breakpoint(s), for this example set the Breakpoint on Main().
    ! Once the Breakpoint is set, click OK on the Message('Glo:CurrentPID = ' & Glo:CurrentPID) message box.
    

    ! If both of these RUN statements below are commented out, the Run statement before the Assert provides
    ! another opportunity to start the Debugger, Window, Source, Select Filename.clw and set a breakpoint after the Assert, 
    ! before clicking the Continune button in the Assert message box.
 
    ! Debugger Elevated - Using the Debugger to start the App from the IDE will make the CSIDL represent the Administrator folder paths. 
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)

    ! Debugger Not Elevated - Using the Debugger to start the App from the IDE will make the CSIDL represent the logged in User folder paths.
    !Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)


    ! After setting your breakpoints, click the message box OK button and the debugger will stop at the first breakpoint it encounters after this message.
    Message('Glo:CurrentPID = ' & Glo:CurrentPID) ! This halts the program so the Debugger can load properly.    
    
    ! Set your breakpoint on Main()
    Main()  ! Now Step(T) through the code.
    Return

Main    Procedure

    Code              
    Compile('DebugOnly',_DEBUG_)
        ! IF condition is False
        IF Glo:SomeCondition = True
            ! Start the Debugger, attach to this App's ProcessID
            Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
            ! In the Debugger select Window, Source, Filename.clw, Set at least one BreakPoint after the Assert.
            ! When the Assert Message appears, click the Continue button to start Debugging
            Assert(0,'False Pauses the Debugger')
        End        
    !DebugOnly 
                  
    Message('Another Message Box') ! Set BreakPoint Here
    Glo:RVLong = ISWA_SHGetFolderPathA(0,ISEQ:CSIDL_APPDATA,0,0,Address(Glo:CSIDL_FolderPath))
    IF Glo:CSIDL_FolderPath
        ! When the Assert message window appears, make a note of the ProcessID and 
        ! manually run the Clarion Debugger using "C:\Clarion11\bin\Cladb.exe -p <ProcessID>"
        ! typed into a Run window, DOS window or Powershell window.
        ! Click Window, Source, select Filename.clw, set a Breakpoint after the Assert below
        ! and only then click the Assert window Continue button.
        Assert(0,'False Pauses the Debugger Again')
        Message('Glo:CSIDL_FolderPath = ' & Glo:CSIDL_FolderPath ) ! Set Breakpoint here.
    End
    ! Implicit Return