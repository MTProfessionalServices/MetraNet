Attribute VB_Name = "FredModule"
Option Explicit

'Public Const INFINITE = -1&
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Public Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Public Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hWnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Public Const APP_EXE_NAME = "W3Runner.exe"
Public Const APP_TITLE = "W3Runner Setup"
Public Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Public Declare Function IsWindow Lib "user32" (ByVal hWnd As Long) As Long


Public Const CUST_MSG_0001 = "Before installing, you must uninstall the previous version."

Public Const CUST_MSG_0003 = "Setup will install W3Runner in the following folder.[CR]To install into a different folder, click Browse, and select another folder."
'Public Const CUST_MSG_0004 = "Enter the name of the Program Manager group to add W3Runner icons to:"
Public Const CUST_MSG_0004 = "Copying Files"
Public Const CUST_MSG_0005 = "License Agreement"
Public Const CUST_MSG_0006 = "Do you agree ?"
Public Const CUST_MSG_0007 = "Setup Program is complete."
Public Const CUST_MSG_0008 = "Execute Program"

Public Const CUST_MSG_0010 = "Carefully read the following license agreement. Press PAGE DOWN key to see the rest of the agreement"

    Public Const CUST_MSG_0011 = "W3Runner Trial Version Setup"
    Public Const CUST_MSG_0002 = "[CR][CR]Welcome to W3Runner Trial Version Setup.[CR][CR][CR]We recommend that you close any applications you may be running.[CR]"


Public m_strInstallPath  As String
Public m_strFlogViewerExeFileName  As String

Public Function RunAppInstallMode() As Boolean

    On Error Resume Next
    
    If (Len(m_strFlogViewerExeFileName)) Then
        
        Shell m_strFlogViewerExeFileName
    End If
End Function




Public Sub SetObjectsPos(f As Form, strmessage As String)

    On Error Resume Next
    f.txtmessage.BackColor = f.BackColor
    f.txtmessage.BorderStyle = 0
    
    Set f.Picture1.Picture = frmWelcome.Picture1.Picture
    
    SetFormFont f
    f.Caption = CUST_MSG_0011 & " " & App.Major & "." & App.Minor & "." & App.Revision

    'CenterForm f
    f.txtmessage.Text = Replace(strmessage, "[CR]", vbNewLine)
    f.txtmessage.Locked = True
    
    Draw3DLine f
    f.cmdOK.SetFocus
    
End Sub






Public Function xecFile(aFile As String, Optional order As String = "Open", Optional param As String, Optional hw As Long = 0, Optional showMode As VbAppWinStyle = vbNormalFocus, Optional booSynchronus As Boolean = False) As Boolean

    Dim lngProcessID    As Long
    Dim hProcess        As Long
    Dim nRet            As Long
    Dim lngWinHWND      As Long

    If booSynchronus Then
    
        On Error Resume Next
        lngProcessID = ShellExecute(hw, "Open", aFile, param, App.Path, showMode)
        DoEvents
        Sleep 100
        DoEvents
        
        lngWinHWND = FindWindow(vbNullString, vbNullString)
        
        Do While IsWindow(lngWinHWND)
            Sleep 500
            DoEvents
        Loop

    Else
        
        xecFile = ShellExecute(hw, "Open", aFile, param, App.Path, showMode) >= 32
    End If
End Function

Private Function addline(txt As TextBox, s As String)
    txt.Text = txt.Text & s & vbNewLine
End Function

Public Function SetLicenseText(txt As TextBox) As Boolean

    Dim strText As String
    
        addline txt, ""
        
        addline txt, "W3Runner END USER LICENSE AGREEMENT"
        addline txt, ""
        addline txt, "CAREFULLY READ THE FOLLOWING LICENSE AGREEMENT. YOU ACCEPT AND AGREE TO"
        addline txt, "BE BOUND BY THIS LICENSE AGREEMENT BY CLICKING THE BUTTON LABELED"
        addline txt, "I ACCEPT THAT IS DISPLAYED BELOW."
        addline txt, "IF YOU DO NOT AGREE TO THIS LICENSE, CLICK THE BUTTON LABELED ""CANCEL""."
        addline txt, ""
        addline txt, "LICENSE GRANT"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "You means the person or company who is being licensed to use the"
        addline txt, "Software or Documentation. ""We"", ""us"" and ""our"" means W3Runner.com."
        addline txt, ""
        addline txt, "We hereby grant you a nonexclusive license to use one copy of the"
        addline txt, "Software on any single computer, provided the Software is in use on,"
        addline txt, "only one computer at any time. The Software is ""in use"" on a computer"
        addline txt, "when it is loaded into temporary memory (RAM) or installed into the"
        addline txt, "permanent memory of a computer--for example, a hard disk, CD-ROM or"
        addline txt, "other storage device."
        addline txt, ""
        addline txt, "TITLE"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "We remain the owner of all right, title and interest in the Software,"
        addline txt, "and related explanatory written materials (""Documentation"")."
        addline txt, ""
        addline txt, ""
        addline txt, "TRIAL VERSION"
        addline txt, "_______________________________________________________________________"
        addline txt, "We grants you a non-exclusive license to use the Trial Version free of"
        addline txt, "charge if your use of the Software is for the purpose of evaluating whether"
        addline txt, "to purchase an ongoing license to the Software."
        addline txt, ""
        addline txt, "The W3Runner trial version contains 2 limitations:"
        addline txt, ""
        addline txt, "(1) The number of calls of the property Page.Controls() and HTTP.Execute() are"
        addline txt, "limited to 50 per session. When the number maximun of calls is reached the"
        addline txt, "program will stop. You can start W3Runner again. Scripts written with the trial "
        addline txt, "version will work with the registered version."
        addline txt, ""
        addline txt, "(2) Using W3Runner through the command line is not available."
        addline txt, ""
        addline txt, "The W3Runner trial version contains the following features:"
        addline txt, ""
        addline txt, "Usage Information."
        addline txt, "  Each time you start W3Runner trial version, the program calls the W3Runner,"
        addline txt, "  WebServer and communicate the following information: The time, the W3Runner,"
        addline txt, "  current version, the number of executions, the country name and the install ID."
        addline txt, "  The WebServer returns the following information: The last version of W3Runner"
        addline txt, "  available, an update mode status and an optional message. The install ID is a,"
        addline txt, "  GUID, set at install time, that identifies you as an anonymous W3Runner trial"
        addline txt, "  version user. The Information is not crypted and can be checked with an Packet"
        addline txt, "  Sniffer program. If the call fails the program continues."
        addline txt, ""
        addline txt, "Upgrade."
        addline txt, " If you are using the trial version you may be forced to upgrade to a new trial"
        addline txt, " version from time to time."
        addline txt, ""
        addline txt, "Welcome Page."
        addline txt, " When the trial version starts, it try to download the WebService Welcome page,"
        addline txt, " from the W3Runner WebServer. If the call fails, the local page is downloaded,"
        addline txt, " instead."
        addline txt, ""
        addline txt, "Once you purchased a license and set the serial number and serial number name"
        addline txt, "the usage information, upgrade function are no more executed."
        addline txt, "The Welcome page is optional."
        addline txt, ""
        addline txt, "DISCLAIMER OF WARRANTY: Trial Version Software is provided on an ""AS IS"""
        addline txt, "basis, without warranty of any kind, including without limitation the warranties"
        addline txt, "that the Software is free of defects, merchantable, fit for a particular purpose or"
        addline txt, "non-infringing. The entire risk as to the quality and performance of the Software is"
        addline txt, "borne by you. Should the Software prove defective in any respect, you and not us,"
        addline txt, "assume the entire cost of any service and repair. In addition, the security mechanisms,"
        addline txt, "implemented by the Software have inherent limitations, and you must determine that the,"
        addline txt, "Software sufficiently meets your requirements. This disclaimer of warranty constitutes"
        addline txt, "an essential part of this Agreement. No use of the Software without payment of license fees"
        addline txt, "to us is authorized hereunder except under this Disclaimer."
        addline txt, ""
        addline txt, "SUPPORT"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "W3Runner.com only supports the software through eMails (support@w3runner.com)"
        addline txt, "and the web site help and FAQ pages. If you purchased a license, supply your order id, "
        addline txt, "your eMail will be processed more rapidly."
        addline txt, ""
        addline txt, "LIMITED WARRANTY,"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "We warrant that for a period of 30 of days after delivery of this copy,"
        addline txt, "of the Software to you:"
        addline txt, ""
        addline txt, "• the media on which this copy of the Software is provided to you will,"
        addline txt, "be free from defects in materials and workmanship under normal use, and"
        addline txt, ""
        addline txt, "• the Software will perform in substantial accordance with the,"
        addline txt, "Documentation."
        addline txt, ""
        addline txt, "To the extent permitted by applicable law, THE FOREGOING LIMITED,"
        addline txt, "WARRANTY IS IN LIEU OF ALL OTHER WARRANTIES OR CONDITIONS, EXPRESS OR,"
        addline txt, "IMPLIED, AND WE DISCLAIM ANY AND ALL IMPLIED WARRANTIES OR CONDITIONS,"
        addline txt, "INCLUDING ANY IMPLIED WARRANTY OF TITLE, NONINFRINGEMENT,"
        addline txt, "MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, regardless of,"
        addline txt, "whether we know or had reason to know of your particular needs. No"
        addline txt, "employee, agent, dealer or distributor of ours is authorized to modify"
        addline txt, "this limited warranty, nor to make any additional warranties."
        addline txt, ""
        addline txt, "SOME STATES DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR"
        addline txt, "INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION MAY NOT,"
        addline txt, "APPLY TO YOU."
        addline txt, ""
        addline txt, "ARCHIVAL OR BACKUP COPIES"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "You may copy the Software for back-up and archival purposes, provided,"
        addline txt, "that the original and each copy is kept in your possession and that"
        addline txt, "your installation and use of the Software does not exceed that allowed"
        addline txt, "in the ""License Grant"" section above."
        addline txt, ""
        addline txt, "TRANSFERS"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "You may transfer all your rights to use the Software and Documentation"
        addline txt, "to another person or legal entity provided you transfer this Agreement"
        addline txt, "the Software and Documentation, including all copies, update and prior"
        addline txt, "versions to such person or entity and that you retain no copies"
        addline txt, "including copies stored on computer."
        addline txt, ""
        addline txt, "LIMITED REMEDY"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "Our entire liability and your exclusive remedy for breach of the"
        addline txt, "foregoing warranty shall be, at our option, to either:"
        addline txt, ""
        addline txt, "• return the price you paid, or,"
        addline txt, ""
        addline txt, "• replace the media that does not meet the"
        addline txt, "foregoing warranty if it is returned to us with a copy of your receipt."
        addline txt, ""
        addline txt, "IN NO EVENT WILL WE BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY,"
        addline txt, "LOST PROFITS, LOST SAVINGS, OR OTHER INCIDENTAL OR CONSEQUENTIAL"
        addline txt, "DAMAGES ARISING FROM THE USE OR THE INABILITY TO USE THE SOFTWARE (EVEN"
        addline txt, "IF WE OR AN AUTHORIZED DEALER OR DISTRIBUTOR HAS BEEN ADVISED OF THE"
        addline txt, "POSSIBILITY OF THESE DAMAGES), OR FOR ANY CLAIM BY ANY OTHER PARTY."
        addline txt, ""
        addline txt, "SOME STATES DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR,"
        addline txt, "INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION MAY NOT"
        addline txt, "APPLY TO YOU."
        addline txt, ""
        addline txt, "TERM AND TERMINATION,"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "This license agreement takes effect upon your use of the software and,"
        addline txt, "remains effective until terminated. You may terminate it at any time by,"
        addline txt, "destroying all copies of the Software and Documentation in your,"
        addline txt, "possession. It will also automatically terminate if you fail to comply,"
        addline txt, "with any term or condition of this license agreement. You agree on,"
        addline txt, "termination of this license to destroy all copies of the Software and,"
        addline txt, "Documentation in your possession."
        addline txt, ""
        addline txt, "CONFIDENTIALITY"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "The Software contains trade secrets and proprietary know-how that"
        addline txt, "belong to us and it is being made available to you in strict"
        addline txt, "confidence. ANY USE OR DISCLOSURE OF THE SOFTWARE, OR OF ITS,"
        addline txt, "ALGORITHMS, PROTOCOLS OR INTERFACES, OTHER THAN IN STRICT ACCORDANCE"
        addline txt, "WITH THIS LICENSE AGREEMENT, MAY BE ACTIONABLE AS A VIOLATION OF OUR,"
        addline txt, "TRADE SECRET RIGHTS."
        addline txt, ""
        addline txt, "THINGS YOU MAY NOT DO"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "The Software and Documentation are protected by United States copyright"
        addline txt, "laws and international treaties. You must treat the Software and"
        addline txt, "Documentation like any other copyrighted material--for example a book."
        addline txt, "You may not:"
        addline txt, ""
        addline txt, "• copy the Documentation"
        addline txt, ""
        addline txt, "• copy the Software except to make archival or backup copies as"
        addline txt, "provided above"
        addline txt, ""
        addline txt, "• modify or adapt the Software or merge it into another program"
        addline txt, ""
        addline txt, "• reverse engineer, disassemble, decompile or make any attempt to"
        addline txt, "discover the source code of the Software"
        addline txt, ""
        addline txt, "• place the Software onto a server so that it is accessible via a pubic"
        addline txt, "network such as the Internet, or,"
        addline txt, ""
        addline txt, "• sublicense, rent, lease or lend any portion of the Software or"
        addline txt, "Documentation."
        addline txt, ""
        addline txt, "GENERAL PROVISIONS"
        addline txt, "_______________________________________________________________________"
        addline txt, ""
        addline txt, "1. This written license agreement is the exclusive agreement between"
        addline txt, "you and us concerning the Software and Documentation and supersedes any"
        addline txt, "prior purchase order, communication, advertising or representation"
        addline txt, "concerning the Software."
        addline txt, ""
        addline txt, "2. This license agreement may be modified only by a writing signed by"
        addline txt, "you and us."
        addline txt, ""
        addline txt, "3. In the event of litigation between you and us concerning the"
        addline txt, "Software or Documentation, the prevailing party in the litigation will,"
        addline txt, "be entitled to recover attorney fees and expenses from the other party."
        addline txt, ""
        addline txt, "4. This license agreement is governed by the laws of the state of,"
        addline txt, "Massachusetts."
        addline txt, ""
        addline txt, "5. You agree that the Software will not be shipped, transferred or"
        addline txt, "exported into any country or used in any manner prohibited by the,"
        addline txt, "United States Export Administration Act or any other export laws,"
        addline txt, "restrictions or regulations."
        
        addline txt, "Should you have any questions concerning this License Agreement,"
        addline txt, "please send an email to the support@w3runner.com."

    
End Function


Public Function Draw3DLine(f As Form) As Boolean
    Const ETCHED_LINE_STEP = 10
    EtchedLine f, (ETCHED_LINE_STEP * Screen.TwipsPerPixelX), f.cmdOK.Top - f.cmdOK.Height \ 2, f.Width - (3 * ETCHED_LINE_STEP * Screen.TwipsPerPixelX)
End Function



Public Function LoadFile(ByVal strFilename As String, ByRef strText As String) As String

    Dim lngHandle   As Long
    
    
    On Error GoTo ErrMgr
    
    lngHandle = FreeFile()
    Open strFilename For Input As lngHandle
    strText = Input(LOF(lngHandle), lngHandle)
    Close #lngHandle
    LoadFile = CBool(Len(strText))
    Exit Function
ErrMgr:
    
End Function
