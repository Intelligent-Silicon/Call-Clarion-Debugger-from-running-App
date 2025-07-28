
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
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Line 92, then return here, click Continue button below.')
        Glo:SVCstring = 'If Condition, CallDebugger() and standard Assert()'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example 2')
    End
    

    

Example3Compile_Debug_CompilerFlag    Procedure()
    Code
    ! CallDebugger() is appended to the Assert Message - it should return 0  
    Compile('DebugOnly',_DEBUG_) 
        Assert(0,'Debugger, Window, Source, select Filename.clw, Breakpoint Line 104, then return here, click Continue button below.' & CallDebugger())
        Glo:SVCstring = 'CallDebugger() is appended to the Assert Message'
        Message(Glo:SVCstring &'|'& Glo:CSIDL_FolderPath,'Example 3')
    !DebugOnly
                  
Example4Omit_Debug_CompilerFlag    Procedure()
    Code
    ! You cant debug a Release version in reality, but demonstrates how ClaDBne.exe could be called.
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
    Omit('ReleaseOnly',_DEBUG_) 
        Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Line 114, then return here, click Continue button below.' )
        Glo:SVCstring = 'You cant debug in Release Mode'
        Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example 4')
    !ReleaseOnly     

Example5Col1QuestionMark    Procedure()
    Code
    ! CallDebuggerNE() is added to the Assert Expression - it should return 0
?   Assert(0+CallDebuggerNE(),'Debugger, Window, Source, select Filename.clw, Breakpoint Line 122, then return here, click Continue button below.' )
?   Glo:SVCstring = '? in column 1 for Build Configuration:Debug'
?   Message(Glo:SVCstring &'<32,10>'& Glo:CSIDL_FolderPath,'Example 5')


CallDebugger    PROCEDURE()
    Code
    Run('C:\Clarion11\bin\Cladb.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0

CallDebuggerNE  PROCEDURE()
    Code  
    Run('C:\Clarion11\bin\Cladbne.exe -p ' & Glo:CurrentPID, 0)
    Return ErrorCode() ! ErrorCode should return 0