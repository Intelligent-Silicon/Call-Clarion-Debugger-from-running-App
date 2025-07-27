
    PROGRAM 

Glo:CurrentPID              Ulong 
! https://github.com/Intelligent-Silicon/CSIDL
ISEQ:CSIDL_DESKTOP          Equate(0)  ! C:\Users\Admin1\Desktop
ISEQ:CSIDL_COMMON_STARTUP   Equate(24) ! C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
ISEQ:CSIDL_APPDATA          Equate(26) ! C:\Users\Admin1\AppData\Roaming
ISEQ:CSIDL_COMMON_APPDATA   Equate(35) ! C:\ProgramData or C:\Documents and Settings\All Users\Application Data
Glo:CSIDL_FolderPath        Cstring(1024)
Glo:RVLong                  Long ! Return Value Long
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
    
    ! Debugger Elevated  
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)

    ! Debugger Not Elevated
    !Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)


    ! After setting your breakpoints, click the message box OK button and the debugger will stop at the first breakpoint it encounters after this message.
    Message('Glo:CurrentPID = ' & Glo:CurrentPID) ! This halts the program so the Debugger can load properly.    
    
    ! Set you breakpoint on Main()
    Main()  ! Now sTep through the code.
    Return

Main    Procedure

    Code              
            
    Message('Another Message Box')
    Glo:RVLong = ISWA_SHGetFolderPathA(0,ISEQ:CSIDL_APPDATA,0,0,Address(Glo:CSIDL_FolderPath))
    IF Glo:CSIDL_FolderPath
        Message('Glo:CSIDL_FolderPath = ' & Glo:CSIDL_FolderPath )
    End
    ! Implicit Return