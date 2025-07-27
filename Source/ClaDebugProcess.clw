
    PROGRAM 

Glo:CurrentPID          Ulong
    
    MAP
Main        PROCEDURE()
    MODULE('api')
    ISWA_GetCurrentProcessId(Long),Ulong,Pascal,Name('GetCurrentProcessId')
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
    
    ! Debugger Elevated running as Administrator, so Administrator CSIDL paths apply  
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)

    ! Debugger Not Elevated running as User, so the logged on User's CSIDL paths apply.
    !Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)


    ! After setting your breakpoints, click OK and the debugger will stop at the first breakpoint it encounters after this message.
    Message('Glo:CurrentPID = ' & Glo:CurrentPID) ! This halts the program so the Debugger can load properly.    
    
    ! Set you breakpoint on Main()
    Main()  ! Now sTep through the code.
    Return

Main    Procedure

    Code              
            
    Message('Another Message Box')

    ! Implicit Return