Attribute VB_Name = "MainModule"
Option Explicit
'-egs -corp "/GLOBAL" -groupsubscription "*" -file "c:\temp\myGS.xml"  -username su -password su123

' -igs -file "T:\Development\Core\MTProductCatalog\ImportExport\GROUPSUB\GlobalGroupSubscription.xml" -username su -password su123

Private booExitCode As Boolean

Private Const DEFAULT_NAMESPACE = "system_user"

Public Const APP_NAME = "PCImportExport Command Line Utility - version "

Public g_objCommandLine As New CCommandLine
Public g_objConsole     As New CConsoleWindow


Private m_objImport             As CImportWriter
Private m_objExport             As CExport

Public Sub Main()

    On Error GoTo ErrMgr

    'before 3.7 UpdateTestHarnessLogFile Main2(), Command
    ' I do not log the result of the exection in result.csv because of 4.0 implementation of the file result2.csv
    
    Main2
    
    Dim objTextFile As New cTextFile
    objTextFile.LogFile GetTestDatabaseTempFolder() & "\" & App.EXEName & ".ExitCode.Txt", IIf(booExitCode, 0, 1), True
    
THE_EXIT:
    Sleep 1000 ' Let the logger object flush the last string
    
    Exit Sub
ErrMgr:
    GoTo THE_EXIT:
End Sub


Public Function GetGMTDateFromCommandLine() As String

    Dim Tools As Object 'New MSIXTools
    
    Set Tools = CreateObject("MTMSIX.MSIXTools")
    GetGMTDateFromCommandLine = g_objCommandLine.GetValue("-date", Tools.GetCurrentGMTTime())
End Function
    


Public Function Main2() As Boolean

    Dim i           As Long
    Dim booOK       As Boolean
    
    Dim eMode As IMPORT_EXPORT_MODE
    
    MTGlobal_VB_MSG.MTInitializeLogFileForPCImportExport
    
    MTGlobal_VB_MSG.TRACE APP_NAME & App.Major & "." & App.Minor & "." & App.Revision
    'MTGlobal_VB_MSG.TRACE "CommandLine=" & Command
    
    Set g_objConsole = New CConsoleWindow
    g_objConsole.Initialize App.EXEName & ".exe"
        
'Debug.Assert 0
        
    If Len(Command) = 0 Then
    
        ShowArguments
    Else
        
        g_objCommandLine.Init Command
        
        eMode = eMode + IMPORT_EXPORT_MODE_COM_PLUS
        
        If g_objCommandLine.Exist("-verbose") Then
        
            eMode = eMode + IMPORT_EXPORT_VERBOSE
        End If
        If g_objCommandLine.Exist("-SkipIntegrity") Then
        
            eMode = eMode + IMPORT_EXPORT_SKIP_INTEGRITY
        End If
        
        ' Import mode
        If g_objCommandLine.Exist("-SafeMode") Then
        
            eMode = eMode + IMPORT_EXPORT_MODE_SAFE_MODE
        Else
            eMode = eMode + IMPORT_EXPORT_MODE_DEFAULT_MODE
        End If
        
        If g_objCommandLine.Exist("-NoCOM+") Then eMode = eMode - IMPORT_EXPORT_MODE_COM_PLUS
        
        If g_objCommandLine.GetValue("-unittestrollback", False) Then ' Unit test special mode
            
            eMode = eMode + IMPORT_EXPORT_UNIT_TEST_ROLLBACK
        End If
        
        If g_objCommandLine.Exist("-MultiFile") Then
        
            eMode = eMode + IMPORT_EXPORT_MULTI_FILE
        End If
        
        
        i = 1
        Do While i <= g_objCommandLine.Count
            
            Select Case LCase(g_objCommandLine.Item(i))
            
                Case "-testbug":
                
                    booExitCode = Export.TestBug(eMode, Command)
                    booOK = True
              
                   
                Case "-epo":
                
                    If eMode And IMPORT_EXPORT_MULTI_FILE Then
                        
                        booExitCode = Export.ExportProductOfferingMultiFile(g_objCommandLine.GetValue("-path"), g_objCommandLine.GetValue("-epo"), eMode, Command)
                        booOK = True
                    Else
                        If g_objCommandLine.Exist("-file") Then
                            booExitCode = Export.ExportProductOffering(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-epo"), eMode, Command)
                            booOK = True
                        End If
                    End If
                    
                Case "-epl":
                
                    If eMode And IMPORT_EXPORT_MULTI_FILE Then
                        
                        booExitCode = Export.ExportPriceListMultiFile(g_objCommandLine.GetValue("-path"), g_objCommandLine.GetValue("-epl"), eMode, Command)
                        booOK = True
                    Else
                        If g_objCommandLine.Exist("-file") Then
                            booExitCode = Export.ExportPriceList(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-epl"), eMode, Command)
                            booOK = True
                        End If
                    End If
                    
                    
                Case "-ers":
                    If g_objCommandLine.Exist("-file") Then
                        booExitCode = Export.ExportRateSchedule(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-pl"), g_objCommandLine.GetValue("-pait"), eMode, Command)
                        booOK = True
                    End If
                        
                Case "-es":
                    If g_objCommandLine.Exist("-file") Then
                        booExitCode = Export.ExportSubscriptions(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-es"), g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE), eMode, Command, GetGMTDateFromCommandLine())
                        booOK = True
                    End If
                    
                    
                Case "-egs":
                    If g_objCommandLine.Exist("-file") Then
                        booExitCode = Export.ExportGroupSubscriptions(g_objCommandLine.GetValue("-file"), g_objCommandLine.GetValue("-corp"), g_objCommandLine.GetValue("-corpnamespace", ""), g_objCommandLine.GetValue("-groupsubscription"), g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE), eMode, Command, GetGMTDateFromCommandLine())
                        booOK = True
                    End If
                
                
                Case "-ipo":
                
                        If eMode And IMPORT_EXPORT_MULTI_FILE Then
                        
                                booExitCode = Import.ImportProductOfferingMultiFile(eMode, Command, g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE), g_objCommandLine.GetValue("-path"))
                                booOK = True
                            
                        Else
                            If g_objCommandLine.Exist("-file") Then
                                booExitCode = Import.ImportProductOffering(g_objCommandLine.GetValue("-file"), eMode, Command, g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE))
                                booOK = True
                            End If
                        End If
                        
                Case "-is":
                    If g_objCommandLine.Exist("-file") Then
                        booExitCode = Import.ImportSubscriptions(g_objCommandLine.GetValue("-file"), eMode, Command, g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE))
                        booOK = True
                    End If
                    
                Case "-igs":
                    If g_objCommandLine.Exist("-file") Then
                        booExitCode = Import.ImportGroupSubscriptions(g_objCommandLine.GetValue("-file"), eMode, Command, g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE), GetGMTDateFromCommandLine())
                        booOK = True
                    End If
                    
                Case "-ipl":
                
                    If eMode And IMPORT_EXPORT_MULTI_FILE Then
                    
                        booExitCode = Import.ImportPriceListMultiFile(eMode, Command, g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE), g_objCommandLine.GetValue("-path"))
                        booOK = True
                    Else
                        If g_objCommandLine.Exist("-file") Then
                            booExitCode = Import.ImportPriceLists(g_objCommandLine.GetValue("-file"), eMode, Command, g_objCommandLine.GetValue("-username"), g_objCommandLine.GetValue("-password"), g_objCommandLine.GetValue("-namespace", DEFAULT_NAMESPACE))
                            booOK = True
                        End If
                    End If
                    
                Case "-irs":
                    If g_objCommandLine.Exist("-file") Then
                        booExitCode = Import.ImportRateSchedule(g_objCommandLine.GetValue("-file"), eMode, Command)
                        booOK = True
                    End If

                Case "-lp":
                    '+++booExitCode = Export.ListProductOffering()
                    booOK = True
            End Select
            i = i + 1
        Loop
        If Not booOK Then ShowArguments
    End If
    Set m_objImport = Nothing ' For the Transaction Class to be deleted now!
    
    Main2 = True
'    MTGlobal_VB_MSG.TRACE "EXIT Main2", , , LOG_WARNING
    
End Function

Public Function ShowArguments() As Boolean
    Dim strMessage  As String
    Dim objTextFile As New cTextFile
    Dim strHelpFileName As String
    
'    strMessage = "PCImportExport.exe" & vbNewLine
        
    strMessage = strMessage & "PCImportExport " & App.Major & "." & App.Minor & "." & App.Revision & "[CRLF][CRLF]PCImportExport Command Line Syntax[CRLF][CRLF]"
    
    strMessage = strMessage & "Export product offerings:[CRLF]  -epo ""Product-Offering-List-Name"" -file ""XML-File"" [-ExportPriceAbleItemInstanceOnly TRUE] [-ExportDynamicExtendedProperties TRUE] [CRLF][CRLF]"
    strMessage = strMessage & "   PCImportExport -epo ""MyPO"" -file ""c:\temp\myPO.xml"" [CRLF]"
    strMessage = strMessage & "   PCImportExport -epo ""MyPO1,MyPO2"" -file ""c:\temp\myPO.xml"" [CRLF]"
    strMessage = strMessage & "   PCImportExport -epo ""*"" -file ""c:\temp\AllPOs.xml"" [CRLF]"
    strMessage = strMessage & "   PCImportExport -epo ""AudioConf*"" -file ""c:\temp\AllAudioConferencePOs.xml"" [CRLF][CRLF]"
    
    strMessage = strMessage & "Export product offerings multi-files:[CRLF]  -multifile -epo  ""Product-Offering-List-Name"" -path ""Output-Folder"" [-ExportPriceAbleItemInstanceOnly TRUE] [CRLF][CRLF]"
    strMessage = strMessage & "   PCImportExport -multifile -epo ""*"" -path ""c:\temp\MyPO"" [CRLF]"
    
    strMessage = strMessage & "Export subscriptions:[CRLF]  -es ""Product-Offering-List-Name"" -file ""XML-File"" -username MTUserName -password PassWord [-namespace NameSpace] [-date TimeStamp] [CRLF][CRLF]"
    
    strMessage = strMessage & "Export group subscriptions:[CRLF]  -egs -corp ""Corporation"" -corpNameSpace ""CorporationNameSpace"" -groupsubscription ""Group-Subscription-Name"" -file ""XML-File"" -username MTUserName -password PassWord [-namespace NameSpace] [-date TimeStamp] [CRLF][CRLF]"
    strMessage = strMessage & "   PCImportExport -egs -corp ""MyCorp"" -corpNameSpace mt -groupsubscription ""MyGroupSubscriptionName"" -file ""c:\temp\myGS.xml"" [CRLF] -username MyLogin -password MyPassWord -namespace system_user[CRLF]"
    strMessage = strMessage & "   PCImportExport -egs -corp ""MyCorp"" -corpNameSpace mt  -groupsubscription ""*"" -file ""c:\temp\MyCorp_AllGroupSubscription.xml""  -username MyLogin -password MyPassWord [CRLF]"
    strMessage = strMessage & "   PCImportExport -egs -corp ""*"" -groupsubscription ""*"" -file ""c:\temp\AllGroupSubscription.xml""  -username MyLogin -password MyPassWord -namespace system_user[CRLF][CRLF]"
    
    strMessage = strMessage & "Export global group subscriptions:[CRLF]  -egs -corp ""/GLOBAL"" -groupsubscription ""Group-Subscription-Name"" -file ""XML-File"" -username MTUserName -password PassWord [-namespace NameSpace] [-date TimeStamp] [CRLF][CRLF]"
    strMessage = strMessage & "   PCImportExport -egs -corp ""/GLOBAL"" -groupsubscription ""MyGroupSubscriptionName"" -file ""c:\temp\myPO.xml"" [CRLF] -username MyLogin -password MyPassWord -namespace system_user"
    strMessage = strMessage & "   PCImportExport -egs -corp ""/GLOBAL"" -groupsubscription ""GS1,GS2"" -file ""c:\temp\MyCorp_AllGroupSubscription.xml""  -username MyLogin -password MyPassWord [CRLF]"
    strMessage = strMessage & "   PCImportExport -egs -corp ""/GLOBAL"" -groupsubscription ""*"" -file ""c:\temp\AllGroupSubscription.xml""  -username MyLogin -password MyPassWord -namespace system_user[CRLF][CRLF]"
            
    
'booExitCode = Export.ExportGroupSubscriptions(g_objCommandLine.GETVALUE("-file"), g_objCommandLine.GETVALUE("-corp"), g_objCommandLine.GETVALUE("-groupsubscription"), g_objCommandLine.GETVALUE("-username"), g_objCommandLine.GETVALUE("-password"), g_objCommandLine.GETVALUE("-namespace"), eMode, Command)
    
    
    strMessage = strMessage & "Export price lists:[CRLF]  -epl ""Price-List-List-Name"" -file ""XML-File"" -username MTUserName -password PassWord -[namespace NameSpace] [CRLF][CRLF]" '[-date ""Hierarchy-date""]
    strMessage = strMessage & "   PCImportExport -epl ""MyPL"" -file ""c:\temp\myPL.xml""  -username MyLogin -password MyPassWord [-namespace system_user][CRLF]"
    strMessage = strMessage & "   PCImportExport -epl ""*"" -file ""c:\temp\AllPLs.xml""  -username MyLogin -password MyPassWord [-namespace system_user][CRLF]"
    strMessage = strMessage & "   PCImportExport -epl ""AudioConf*"" -file ""c:\temp\AllAudioConferencePOs.xml""  -username MyLogin -password MyPassWord [-namespace system_user][CRLF][CRLF]"
    
    strMessage = strMessage & "Export price lists multi-file:[CRLF]  -epl ""Price-List-List-Name"" -multifile -path ""Output-Folder"" -username MTUserName -password PassWord [-namespace NameSpace] [CRLF][CRLF]"
    strMessage = strMessage & "   PCImportExport -epl ""*"" -multifile -path ""c:\temp""  -username MyLogin -password MyPassWord [-namespace system_user][CRLF]"
    strMessage = strMessage & "[CRLF]Do not export non-shared price list[CRLF][CRLF]"

    strMessage = strMessage & "Import product offerings:[CRLF] -ipo -file ""XML-File""  -username ""USERNAME"" -password ""PASSWORD"" [-namespace ""NAMESPACE""][CRLF][CRLF]"
    strMessage = strMessage & "Import product offerings multi-files:[CRLF] -ipo -multifile -path ""Path-WildCard"" -username ""USERNAME"" -password ""PASSWORD"" [-namespace ""NAMESPACE""][CRLF][CRLF]"
    
    
    strMessage = strMessage & "Import subscriptions:[CRLF]  -is -file ""XML-File"" -username ""USERNAME"" -password ""PASSWORD"" [-namespace ""NAMESPACE""] [-ExportDynamicExtendedProperties TRUE] [CRLF][CRLF]"
    strMessage = strMessage & "Import group subscriptions:[CRLF]  -igs -file ""XML-File"" -username ""USERNAME"" -password ""PASSWORD"" [-namespace ""NAMESPACE""] [-date TimeStamp] [CRLF][CRLF]"
    strMessage = strMessage & "Import price lists:[CRLF]  -ipl -file ""XML-File"" -username ""USERNAME"" -password ""PASSWORD"" [-namespace ""NAMESPACE""][CRLF][CRLF]"
    strMessage = strMessage & "Import price lists multi-files:[CRLF] -ipl -multifile -path ""Path-WildCard"" -username ""USERNAME"" -password ""PASSWORD"" [-namespace ""NAMESPACE""][CRLF][CRLF]"
        
    strMessage = strMessage & "List Product Offering Names:[CRLF] -lp [CRLF][CRLF]"
    
    strMessage = strMessage & "Other options:[CRLF]"
    strMessage = strMessage & "  -SkipIntegrity Skip the integrity validation process"
    strMessage = strMessage & "  -Verbose Log more information[CRLF]"
    strMessage = strMessage & "  -SafeMode Set on the safe mode[CRLF]"
    strMessage = strMessage & "  -NoCOM+ No COM+ Transactions used - Not available yet[CRLF][CRLF]"
    strMessage = strMessage & "  -QAOptions display extra command line option for QA purpose[CRLF][CRLF]"
    
    strMessage = strMessage & "Optional Parameter:[CRLF]"
    strMessage = strMessage & "  -namespace:The default value is system_user[CRLF]"
    strMessage = strMessage & "  -ExportPriceAbleItemInstanceOnly:The default value is FALSE[CRLF][CRLF]"
    strMessage = strMessage & "  -date:The default value GTM MetraTime.[CRLF]"
    strMessage = strMessage & "        For Subscription export the date is used to define which subscriptions are still active.[CRLF]"
    strMessage = strMessage & "        Therefore by default only the active or future subscriptions will be exported. By changing the date it is possible to export past subscriptions.[CRLF]"
    strMessage = strMessage & "        For Group Subscriptions export and import this date is only used to get a snapshot of the Accounts Hierarchy.[CRLF][CRLF]"
        
    If g_objCommandLine.Exist("-QAOptions") Then
    
        strMessage = strMessage & "Reserved for QA:[CRLF]"
        strMessage = strMessage & "Importing Product Offering:[CRLF]"
        strMessage = strMessage & "    [-PropertyBag ""File-Name""][-ProductOfferingIndex 1][-SetCurrency TRUE][-SetDefaultPriceList TRUE][CRLF][CRLF]"
        strMessage = strMessage & "Export rate schedule used by a price list and a price able item template:[CRLF]  -ers -pl ""Price-List-Name"" -pait ""PriceAbleItemTemplate-Name"" -file ""XML-File"" [CRLF][CRLF]"
        strMessage = strMessage & "Import rate schedules:[CRLF]  -irs -file ""XML-File"" [CRLF][CRLF]"
    End If
        
    strHelpFileName = Environ("TEMP") & "\PCImportExport.CommandLine.Txt"
    objTextFile.LogFile strHelpFileName, PreProcess(strMessage, "CRLF", vbNewLine), True
    
    Shell "notepad " & strHelpFileName, vbNormalFocus
    
End Function



Public Function UpdateTestHarnessLogFile(booResult As Boolean, strResultDescription As String) As Boolean
    Dim objUTApi As Object
    
    On Error Resume Next
    Set objUTApi = CreateObject("MTTestAPI.TestAPI")
    If Err.Number = 0 Then
        On Error GoTo 0
        UpdateTestHarnessLogFile = Len(objUTApi.LogResult(App.EXEName, booResult, Now, Now, Replace(strResultDescription, """", "'")))
    End If
    Err.Clear
End Function




Public Property Get Import() As MTPCImportExportExec.CImportWriter
    If Not IsValidObject(m_objImport) Then
        Set m_objImport = CreateObject("MTPCImportExportExec.CImportWriter")
    End If
    Set Import = m_objImport
End Property


Public Property Get Export() As MTPCImportExportExec.CExport
    If Not IsValidObject(m_objExport) Then
        Set m_objExport = CreateObject("MTPCImportExportExec.CExport")
    End If
    Set Export = m_objExport
End Property






