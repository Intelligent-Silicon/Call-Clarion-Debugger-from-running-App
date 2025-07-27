
    PROGRAM 

Glo:CurrentPID              Ulong 
! https://github.com/Intelligent-Silicon/CSIDL
ISEQ:CSIDL_DESKTOP          Equate(0)  ! C:\Users\Admin1\Desktop
ISEQ:CSIDL_COMMON_STARTUP   Equate(24) ! C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
ISEQ:CSIDL_APPDATA          Equate(26) ! C:\Users\Admin1\AppData\Roaming
ISEQ:CSIDL_COMMON_APPDATA   Equate(35) ! C:\ProgramData or C:\Documents and Settings\All Users\Application Data
Glo:CSIDL_FolderPath        Cstring(1024)
Glo:RVLong                  Long ! Return Value Long
Glo:AssertMessage           Cstring(8196)

Glo:SomeCondition           Long(1)

    MAP
Example1        PROCEDURE()
Example2        PROCEDURE()
Example3        PROCEDURE()
CallDebugger    PROCEDURE(),Long
CallDebuggerNE  PROCEDURE(),Long

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

    Example1()
    Return
  
Example1    Procedure
Loc:MessageResult   Long
    Code 

    Loc:MessageResult = Message(   'Process ID = ' & Glo:CurrentPID &'<32,10>Launch Debugger?<32,10>',|
                                    'Example1',ICON:Question,'Goto &Example2| Launch &Cladb.exe| Launch Cladb&NE.exe')
    Case Loc:MessageResult 
    OF 2
        Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    OF 3
        Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    End
     
    IF Loc:MessageResult = 1
        Example2()
    ElsIF Loc:MessageResult = 2 or Loc:MessageResult = 3
        MEssage('Wait for the Debugger to load,<32,10>' & |
                'then click Window, Source, and select a "filename.clw",<32,10>' & |
                'then set a Breakpoint on Example3().<32,10>' & |
                'When that is done, come back to this message box and click the OK button below.','Example1')
        Example3()
    End
        
    

Example2    Procedure

    Code
    IF Glo:SomeCondition = True 
        ! This wont crash on Program Return.
        ! Comment one of these out.
        CallDebugger()  
        !CallDebuggerNE()
        ! You cant format an Assert() message like you can using Message(). <32,10> are ignored.
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Example3(), then return here, click Continue button below.')
    End
    
    ! Unfortunately these Assert() messages crash on Program Return because CallDebugger() and CallDebuggerNE() are being called inside the Assert()
    ! In practice as this only happens when Build Configuration is set to Debug, this might be acceptible for you?          
    Compile('DebugOnly',_DEBUG_) ! Both of these Assert() cause a crash on Program Return because the CallDebugger() & CallDebuggerNE() are called.
    !    Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Example3(), then return here, click Continue button below.' & CallDebugger())
    !DebugOnly  

    Omit('ReleaseOnly',_DEBUG_) ! You cant debug a Release version in reality, but demonstrates how ClaDBne.exe could be called.
    !    Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Example3(), then return here, click Continue button below.' )
    !ReleaseOnly

    Example3()

Example3    Procedure()
Loc:ReturnVal   Long
    Code
    Message('Glo:CSIDL_FolderPath = ' & Glo:CSIDL_FolderPath ) 
    Message('Here endeth the Program')
    Loc:ReturnVal = 0

CallDebugger    PROCEDURE()
Loc:ErrorCode   Long
    Code
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0

CallDebuggerNE  PROCEDURE()
Loc:ErrorCode   Long
    Code  
    Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0