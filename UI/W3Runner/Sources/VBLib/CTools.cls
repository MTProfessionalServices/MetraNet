VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cTool"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
' PREVIOUS HISTORY
' ****************************************************************************************************************************************************
'
'                                           OoVbLib6
'
'                               Object Oriented Visual Basic Library
'
'                                     Visual Basic Version 5
'
'                                TORRES Frederic 1995,1996,1997
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' History :
'
'  From VbLib3 for Visual basic 3
'  From OoVbLib4 For Visual Basic 16b/32b
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME      :
'
' FULLNAME  :
'
' VERSION   :
'
' COMMENT   :
'
' ******************************************************************************************************

Option Explicit

 

 
Public Function dsCote(ByVal v As String) As String
'
' COMMENT   : Replace the simple cote ' in the string by simple cote simple cote ''
'
' IN        :
'
' OUT       :
'
' RETURN    : Return the string with double simple cote
'
    replaceString v, "'", "[cote]": replaceString v, "[cote]", "''"
    dsCote = v
End Function

Public Function getControlFromName(theForm As Object, ByVal controlFieldName As String, retControl As Object, Optional Index As Variant) As Boolean
'
' COMMENT   : Return a ref to a control from the form theForm and the control name controlFieldName...
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim x   As Variant
    'Dim l   As New cLI
    
    getControlFromName = False
    
    controlFieldName = UCase(controlFieldName)
    
    For Each x In theForm.Controls
    
        If UCase(x.Name) = controlFieldName Then
            If IsMissing(Index) Then
                Set retControl = x: getControlFromName = True: Exit Function
            Else
                If x.Index = Index Then
                    Set retControl = x: getControlFromName = True: Exit Function
                End If
            End If
        End If
    Next
End Function

Function getHiWord(dw As Long) As Integer
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    If dw And &H80000000 Then
          getHiWord = (dw \ 65535) - 1
    Else
        getHiWord = dw \ 65535
    End If
End Function

Public Function sCote() As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    sCote = "'"
End Function

Public Function dCote() As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    : Return the char '"'
'
    dCote = """"
End Function




Public Function getDirFileNames(path As String, mask As String, files As Collection) As Boolean
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    On Error GoTo errmgr
    
    Dim MyName      As String
    
    MyName = Dir(path & "\" & mask, vbArchive)      ' Retrieve the first entry.
    Do While MyName <> ""   ' Start the loop.
        If MyName <> "." And MyName <> ".." Then
            If Not ((GetAttr(path & "\" & MyName) And vbDirectory) = vbDirectory) Then
                files.Add MyName
            End If
        End If
        MyName = Dir    ' Get next entry.
    Loop
    getDirFileNames = True
    Exit Function
errmgr:
    Err.Clear
End Function
Public Function setCPrinter(printerName As String) As Boolean
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim x As Printer
    Dim r As Boolean
    
    For Each x In Printers
      If x.DeviceName = printerName Then
        Set Printer = x
        setCPrinter = True
        Exit Function
      End If
    Next
    setCPrinter = False
End Function
Public Function getUserOpenFile(CommonDialog1 As Variant, title As String, mask As String, Optional saveAs As Boolean = False, Optional cPath As String = "") As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
  Dim t As New cTool
  
  On Error Resume Next
  getUserOpenFile = ""
  CommonDialog1.CancelError = True
  CommonDialog1.Filter = mask
  If title <> "" Then CommonDialog1.DialogTitle = title
  If cPath <> "" Then CommonDialog1.InitDir = cPath
  
  
  If saveAs Then
    CommonDialog1.ShowSave
  Else
    CommonDialog1.ShowOpen
  End If
  'CommonDialog1.Action = IIf(IsMissing(saveAs), 1, 2)
  
  If Err.Number = 0 Then
    getUserOpenFile = CommonDialog1.FileName
  Else
    'MsgBox "getUserOpenFile (" & Err.Number & " " & Err.Description & ")"
  End If
End Function
Public Function isParameter(s As String) As Boolean
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
  isParameter = CBool(InStr(UCase(Command), UCase(s)))
End Function
Function replaceString(s As String, ByVal sSearch As String, ByVal sReplace As String, Optional caseSensitive As Boolean = True) As String
'
' COMMENT   : Replace sSearch by sReplace in s. Return the result and update s too.
'             Case sensitiv is the default mode...
'             Update with vb6 replace built-in function in 01/04/99...
' IN        :
'
' OUT       :
'
' RETURN    : Return the string modified
'
  Dim C             As Long
  Dim s1            As String
  Dim s2            As String
  Dim z             As Long
  Dim startSeach    As Long: startSeach = 1
  
  If Trim(sSearch) = "" Then Exit Function
'  Do
'    If Not caseSensitive Then
'      c = InStr(startSeach, UCase(s), UCase(sSearch))
'    Else
'      c = InStr(startSeach, s, sSearch)
'    End If
'    If c <> 0 Then
'      startSeach = c + 1
'      s1 = Mid(s, 1, c - 1)
'      s2 = Mid(s, c + Len(sSearch))
'      s = s1 + sReplace + s2
'    End If
'  Loop Until c = 0

  If Not caseSensitive Then
    s = Replace(s, sSearch, sReplace, , , vbTextCompare)
  Else
    s = Replace(s, sSearch, sReplace, , , vbBinaryCompare)
  End If
 
  replaceString = s
 
End Function
Public Function execPrg(ByVal prgName As String, Optional param As Variant, Optional style As Variant) As Boolean
'
' COMMENT   : The shell function return a error code though the application has been lanched!
'             Only in win 95.
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    On Error Resume Next

    Dim ShellCode       As Integer
    Dim wStyle          As Integer
    Dim s               As String
    
    Err.Clear
        
    If IsMissing(style) Then
      wStyle = vbNormalFocus
    Else
      wStyle = style
    End If
        
    s = prgName
    If Not IsMissing(param) Then s = s & " " & param
    
    ShellCode = Shell(s, wStyle)
        
    Let execPrg = Err.Number = 0
    
End Function
Function execPrgSyncrone(prgName As String, Optional param As Variant, Optional s As VbAppWinStyle = vbNormalFocus) As Boolean

    On Error GoTo errmgr

    Dim lPid As Long
    Dim lHnd As Long
    Dim lRet As Long

    If (IsMissing(param)) Then param = Empty
    
    lPid = Shell(Trim(prgName & " " & param), s)
    If lPid <> 0 Then
        lHnd = OpenProcess(SYNCHRONIZE, 0, lPid) 'Get a handle to the shelled process. If successful, wait for the application to end and close the handle.
        If lHnd <> 0 Then
            lRet = WaitForSingleObject(lHnd, INFINITE)
            CloseHandle (lHnd)
            execPrgSyncrone = True
        End If
    End If
    Exit Function
errmgr:
    execPrgSyncrone = False
End Function

Public Function IsDate(DateValue As String) As Boolean
    Dim booOk As Boolean
    
    If IsDate(DateValue) Then
        '   test value for valid Y2K compliant date
        If StrComp(Format$(DateValue, "m/d/yyyy"), DateValue) = 0 Then
            booOk = True
        ElseIf StrComp(Format$(DateValue, "mm/dd/yyyy"), DateValue) = 0 Then
            booOk = True
        ElseIf StrComp(Format$(DateValue, "m/dd/yyyy"), DateValue) = 0 Then
            booOk = True
        ElseIf StrComp(Format$(DateValue, "mm/d/yyyy"), DateValue) = 0 Then
            booOk = True
        End If
    End If
    IsDate = booOk
End Function

 



 
 

 Public Function getControlIndex(x As Variant) As String
'
' COMMENT   : Return the index of the control
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    On Error Resume Next
    
    
    getControlIndex = "" & x.Index
    If Err.Number <> 0 Then
        Err.Clear
        getControlIndex = ""
    End If
    
End Function

 
 
Public Function msgboxYesNo(m As String) As Boolean
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    msgboxYesNo = MsgBox(m, vbYesNo + vbQuestion) = vbYes
    

    
End Function

Public Function getOptionalValue(defaultValue As Variant, Optional v As Variant) As Variant
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    If IsMissing(v) Then
        getOptionalValue = defaultValue
    Else
        getOptionalValue = v
    End If
End Function

    

Public Sub resizeControlFromControl(setC As Variant, modeleC As Variant)
'
' COMMENT   : Set the position and size of a control form another control
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    On Error Resume Next
    
    setC.Left = modeleC.Left
    setC.Top = modeleC.Top
    setC.Width = modeleC.Width
    setC.Height = modeleC.Height
    setC.Visible = True
    
    Err.Clear
End Sub

Public Function errmgr(Optional UserMsg As String, Optional module As String, Optional proc As String, Optional showErrAnayWay As Boolean = False, Optional sqlText As String) As Boolean
'
' COMMENT   : Application Error Manager.
'             Test if and vb error occur and : Show the error message :
'               UserMsg, vb module name, function name, sql text, sysMsg
'
'           If showErrAnayWay   is TRUE the function show the error even if there is not vb error
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim s             As String
    Dim returnString  As Boolean
    Dim f             As New cTextFile
    Dim LogFileName   As String
    Dim r             As Long
     
    If (Err.Number <> 0) Or (showErrAnayWay) Then
    
        s = UserMsg & vbCrLf & String(64, "_") & vbCrLf
        s = s & "VB Error:" & Err.Number & " " & Err.Description & " " & Err.Source & vbCrLf
        s = s & " Module=" & module & ";" & " Proc=" & proc & ";"
        If sqlText <> "" Then s = s & " Sql=" & sqlText & ";"
        MsgBox s, vbOKOnly + vbCritical
        f.LogFile LogErrorFileName(), s, "E"  ' Error mode
        errmgr = True
        Err.Clear
    Else
        errmgr = False
    End If
End Function


Public Function createActiveXDll(Name As String, o As Object, Optional ShowError As Boolean = False) As Boolean
'
' COMMENT   : Create the activex dll name in o!
'
' IN        : name, showError
'
' OUT       : o
'
' RETURN    : True, if no error!
'
    Dim t As New cTool
    On Error Resume Next
    Set o = CreateObject(Name)
    If Err.Number <> 0 Then
        createActiveXDll = False
        Set o = Nothing
        If ShowError Then
            t.errmgr "Can't create ActiveX " & Name, "cTool.cls", "createActiveXDll", , True
        End If
    Else
        createActiveXDll = True
    End If
End Function
Public Function GetUserFont(CommonDialog1 As Object, clsFont As Object) As Boolean

    'Dim t As New cTool
    
    On Error Resume Next
    
    CommonDialog1.CancelError = True
    
    'If title <> "" Then CommonDialog1.DialogTitle = title
    
    'CommonDialog1.Flags = cdlCFScreenFonts
    CommonDialog1.FontBold = clsFont.Bold
    CommonDialog1.FontItalic = clsFont.Italic
    CommonDialog1.FontName = clsFont.Name
    CommonDialog1.FontSize = clsFont.Size
    
    CommonDialog1.ShowFont
    
    If (Err.Number = 0) Then
        clsFont.Bold = CommonDialog1.FontBold
        clsFont.Italic = CommonDialog1.FontItalic
        clsFont.Name = CommonDialog1.FontName
        clsFont.Size = CommonDialog1.FontSize
        GetUserFont = True
    End If
    
End Function

Public Sub userWait(Wait As Boolean, Optional theForm As Variant, Optional arrowHourGlass As Boolean = False)
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    If Wait Then
        Screen.MousePointer = IIf(arrowHourGlass, 13, 11)
        If Not IsMissing(theForm) Then
            theForm.MousePointer = IIf(arrowHourGlass, 13, 11)
            theForm.Refresh
        End If
        DoEvents
    Else
        Screen.MousePointer = 0
        If Not IsMissing(theForm) Then
            theForm.MousePointer = 0
            theForm.Refresh
        End If
        DoEvents
    End If
    
End Sub

 
Public Function RunningInIDE() As Boolean
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    'Assume running as EXE for now
    RunningInIDE = False
    'Trap errors
    On Error GoTo RunningInIDEErr
    'Divide by zero (fails within IDE)
    Debug.Print 1 / 0
    'Exit if no error
    Exit Function
RunningInIDEErr:
    'We get error if Debug.Print was
    'evaluated (i.e. running in the VB IDE)
    RunningInIDE = True
End Function

 
 

Public Function getUniqName() As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim s   As String
 
    s = "" & Date$ & "" & Time$ & "-" & GetTickCount()
    replaceString s, "/", ""
    replaceString s, "-", ""
    replaceString s, ":", ""
    getUniqName = Left(s, 30)
End Function
 
Public Sub resizeCtrl2Form(theForm As Object, C As Object, x As Long, Y As Long)
'
' COMMENT   : Set the size of a control according a window...
'             x and y decrement the size of the control from the size of the window
'
'             Sample In the resize event : resizeCtrl2Form Me , ListBox1, 32,32
'                  Private Sub Form_Resize()
'                       If Me.WindowState <> 1 Then
'                            resizeCtrl2Form Me, 44, 8
'                   End If
'       End Sub
' IN        :
'
' OUT       :
'
' RETURN    :
'
    If theForm.WindowState <> 1 Then
        C.Left = 0
        C.Top = 0
        C.Width = theForm.Width - (x * Screen.TwipsPerPixelX)
        C.Height = theForm.Height - (Y * Screen.TwipsPerPixelY)
    End If
End Sub



Public Function stringSize(ByVal s As String, Size As Long) As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    s = Mid(s, 1, Size)
    If Len(s) < Size Then s = s & Space(Size - Len(s))
    stringSize = s
End Function

Public Sub setEnableAllCommandButton(theForm As Object, state As Boolean)
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim x As Variant
    For Each x In theForm.Controls
        If TypeOf x Is CommandButton Then
            x.Enabled = state
        End If
    Next
End Sub

Public Function appVersion(objApp As Variant) As String
'
' COMMENT   : Return the version of build version of WorldZoom
'
' IN        :
'
' OUT       :
'
' RETURN    : Return a string
'
    appVersion = objApp.Major & "." & objApp.Minor & "." & objApp.Revision
End Function

 

Public Function existInCollection(col As Collection, Item As String, Optional exactMatch As Boolean = True, Optional retValue_ As Variant, Optional useSet As Boolean = False) As Boolean
'
' COMMENT   : Search item in the collection : can do an exact match or instr search, return the instance found...
'             Manage object collection too with to parameter useSet
'
' IN        :
'
' OUT       :
'
' RETURN    : Return true if the item was found!
'
    Dim v           As Variant
    Dim t           As New cTool
    Dim x           As Variant

    On Error GoTo errmgr
    
    If exactMatch Then
        On Error Resume Next
        If useSet Then
            Set v = col(Item)
        Else
            v = col(Item)
        End If
        existInCollection = Err.Number = 0
        If useSet Then
            If Not IsMissing(retValue_) Then Set retValue_ = col(Item)
        Else
            If Not IsMissing(retValue_) Then retValue_ = col(Item)
        End If
        Err.Clear
    Else
        Dim i As Long
        For i = 1 To col.Count
            x = col(i)
            If InStr(UCase(x), UCase(Item)) <> 0 Then
                If Not IsMissing(retValue_) Then
                    If useSet Then
                        Set retValue_ = x
                    Else
                        retValue_ = x
                    End If
                    existInCollection = True
                    Exit Function
                End If
            End If
        Next
    End If
    Exit Function
errmgr:
    Err.Clear
End Function
Public Function minLong(l1 As Long, l2 As Long) As Long
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    minLong = IIf(l1 < l2, l1, l2)
End Function

Public Function maxLong(l1 As Long, l2 As Long) As Long
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    maxLong = IIf(l1 > l2, l1, l2)
End Function




 

 
 
Public Sub progressBarForStatusBarShow(pb As Object, sb As Object, panelIndex As Integer)
'
' COMMENT   : set and resize a progress bar in a status bar panel
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    pb.Top = sb.Top + (2 * Screen.TwipsPerPixelY)
    pb.Height = sb.Height - (2 * Screen.TwipsPerPixelY)
    pb.Left = sb.Panels(panelIndex).Left
    pb.Width = sb.Panels(panelIndex).Width
    pb.Visible = True
    pb.Value = pb.Min
End Sub

Public Sub clearCollection(C As Collection)
'
' COMMENT   : Clear any collection
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim v As Variant
    
    Do While C.Count > 0
        C.Remove 1
    Loop
End Sub



Public Sub setForm2VgaSize(f As Object)
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    If f.WindowState = 0 Then
        If f.Width < 640 * Screen.TwipsPerPixelX Then f.Width = 640 * Screen.TwipsPerPixelX
        If f.Height < 480 * Screen.TwipsPerPixelY Then f.Height = 480 * Screen.TwipsPerPixelY
    End If
End Sub

Public Function loadBmp(FileName As String, p As Variant) As Boolean
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    Dim f As New cTextFile
    If f.ExistFile(FileName) Then
        Set p = LoadPicture(FileName)
        loadBmp = True
    Else
        loadBmp = False
    End If
End Function



 
 

Public Sub setStatusBar(st As Object, m As String, Optional p As Long = 1, Optional doRefresh As Boolean)
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    
    st.Panels(p) = m
    If doRefresh Then st.Refresh
End Sub

Public Function makeString(s As String, Size As Long, Optional trunc As Boolean) As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    If Len(s) > Size Then
        If trunc Then
            makeString = Mid(s, 1, Size)
        Else
            makeString = s
        End If
    Else
        makeString = s & Space(Size - (Len(s)))
    End If
End Function





Public Function printDialogYesNo(cm As Object) As Boolean 'CommonDialog
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    On Error Resume Next
    
    cm.CancelError = True
    cm.ShowPrinter
    printDialogYesNo = Err.Number = 0
    Err.Clear
    
End Function

 





Public Function LogErrorFileName() As String
'
' COMMENT   : Return the current log file name...
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    LogErrorFileName = App.path & "\error.Log"
End Function

 
Public Function SetBit(ByVal Value As Long, theBit As Long, state As Boolean) As Long
    If state Then
        If (Value And (2 ^ theBit)) = 0 Then
            SetBit = Value + (2 ^ (theBit))
        Else
            SetBit = Value
        End If
    Else
        If (Value And (2 ^ theBit)) = (2 ^ theBit) Then
            SetBit = Value - (2 ^ (theBit))
        Else
            SetBit = Value
        End If
    End If
End Function

Public Function testAndAddExtension2File(ByVal fn As String, ByVal ext As String) As String
'
' COMMENT   :
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    
    Dim p As Long
    
    Const cmpTextNoCaseSensitive = 1
        
    p = InStr(UCase(fn), UCase(ext))
    
    If p = 0 Then
        testAndAddExtension2File = fn & IIf(Left(ext, 1) = ".", ext, "." & ext)
    Else
        testAndAddExtension2File = fn
    End If
    
    
End Function

 

 

Public Function helpRun(cm As Object, cmd As Variant, Optional id As Long = -1, Optional ByVal helpFile As String = "", Optional keyWord As String = "") As Boolean
'
' COMMENT   : cmd is HelpCommandValues
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    cm.CancelError = True
    cm.HelpCommand = cmd
    If id <> -1 Then cm.HelpContext = id
    
    If helpFile = "" Then helpFile = App.helpFile
    cm.helpFile = helpFile
    
    If cmd = cdlHelpKey Then cm.HelpKey = keyWord
    cm.showHelp
    

'cdlHelpCommand  '&H102&  Executes a Help macro.
'cdlHelpContents '&H3&    Displays the Help contents topic as defined by the Contents option in the [OPTION] section of the .hpj file.
'cdlHelpContext  '&H1&    Displays Help for a particular context. When using this setting, you must also specify a context using the HelpContext property.
'
'cdlHelpContextPopup '&H8&    Displays in a pop-up window a particular Help topic identified by a context number defined in the [MAP] section of the .hpj file.
'cdlHelpForceFile    '&H9&    Ensures WinHelp displays the correct Help file. If the correct Help file is currently displayed, no action occurs. If the incorrect Help file is displayed, WinHelp opens the correct file.
'cdlHelpHelpOnHelp   '&H4&    Displays Help for using the Help application itself.
'cdlHelpIndex   ' &H3&    Displays the index of the specified Help file. An application should use this value only for a Help file with a single index.
'cdlHelpKey  '&H101&  Displays Help for a particular keyword. When using this setting, you must also specify a keyword using the HelpKey property.
'cdlHelpPartialKey   '&H105&  Displays the topic found in the keyword list that matches the keyword passed in the dwData parameter if there is one exact match. If more than one match exists, the Search dialog box with the topics found listed in the Go To list box is displayed. If no match exists, the Search dialog box is displayed. To bring up the Search dialog box without passing a keyword, use a long pointer to an empty string.
'cdlHelpQuit '&H2&    Notifies the Help application that the specified Help file is no longer in use.
'cdlHelpSetContents  '&H5&    Determines which contents topic is displayed when a user presses the F1 key.
'cdlHelpSetIndex '
    
    
End Function



 
Public Function hasTabIndexProperty(ByVal x As Object) As Boolean
'
' COMMENT   : Return true is x control a a tabindex property
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    On Error Resume Next
    
    Dim i As Long
    i = x.TabIndex
    hasTabIndexProperty = Err.Number = 0
    Err.Clear
End Function

Public Function LoadAPicture(FileName As String) As Variant
    On Error GoTo errmgr
    Set LoadAPicture = LoadPicture(FileName)
    Exit Function
errmgr:
    LoadAPicture = Empty
End Function

Public Function getIcoFromStdFolder(FileName As String, Optional returnExistance As Boolean = False) As Variant
'
' COMMENT   : Shoud be improved...
'
' IN        :
'
' OUT       :
'
' RETURN    :
'

    Dim f   As String
    Dim ff  As New cTextFile
    
    f = App.path & "\" & FileName
    If ff.ExistFile(f) Then
        If returnExistance Then
            getIcoFromStdFolder = True
        Else
            Set getIcoFromStdFolder = Me.LoadAPicture(f)
        End If
        Exit Function
    End If
    
    f = App.path & "\..\Icon\" & FileName
    If ff.ExistFile(f) Then
        If returnExistance Then
            getIcoFromStdFolder = True
        Else
            Set getIcoFromStdFolder = Me.LoadAPicture(f)
        End If
        Exit Function
    End If
    ClipBoard.SetText f
    Me.errmgr "Ico file " & FileName & " not found in the current folder " & App.path & " and in the icon folder " & App.path & "\..\Icon\" & FileName, "cTool", "getIcoFromStdFolder", False, True
    getIcoFromStdFolder = Empty
End Function

Public Function ExecFile(aFile As String, Optional order As String = "Open", Optional param As String, Optional hw As Long = 0, Optional showMode As VbAppWinStyle = vbNormalFocus, Optional booSynchronus As Boolean = False) As Boolean

    Dim lngProcessID    As Long
    Dim hProcess        As Long
    Dim nRet            As Long
    Dim lngWinHWND      As Long

    If booSynchronus Then
    
        On Error Resume Next
        lngProcessID = ShellExecute(hw, "Open", aFile, param, App.path, showMode)
        DoEvents
        Sleep 100
        DoEvents
        
        lngWinHWND = FindWindow(vbNullString, vbNullString)
        
        Do While IsWindow(lngWinHWND)
            Sleep 500
            DoEvents
        Loop

    Else
        
        ExecFile = ShellExecute(hw, "Open", aFile, param, App.path, showMode) >= 32
    End If
End Function

Public Function vbStringType(ByVal typ As Long) As String
'
' COMMENT   : Return a vb type in a string from vb typ in long
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    Dim s       As String
    Dim isArr   As Boolean
    
    If typ > vbArray Then
        typ = typ - vbArray
        isArr = True
    End If
    
    Select Case typ
        Case vbEmpty: s = "vbEmpty"
        Case vbNull: s = "vbNull"
        Case vbInteger: s = "vbInteger"
        Case vbLong: s = "vbLong"
        Case vbSingle: s = "vbSingle"
        Case vbDouble: s = "vbDouble"
        Case vbCurrency: s = "vbCurrency"
        Case vbDate: s = "vbDate"
        Case vbString: s = "vbString"
        Case vbObject: s = "vbObject"
        Case vbError: s = "vbError"
        Case vbBoolean: s = "vbBoolean"
        Case vbVariant: s = "vbVariant"
        Case vbDataObject: s = "vbDataObject"
        Case vbDecimal: s = "vbDecimal"
        Case vbByte: s = "vbByte"
        Case vbUserDefinedType: s = "vbUserDefinedType"
        
        Case vbComHResult: s = "HRESULT"
        Case vbComULong: s = "ulong"
        Case vbComUInt: s = "uint"
        Case vbComwORD: s = "WORD"

        Case Else
            s = "Unknown"
    End Select
    If isArr Then
        s = s & "()"
    End If
    vbStringType = s

End Function

Public Function TRACE(theData As String, Optional mode As String = " ") As String
    Dim f As New cTextFile
    f.LogFile LogTraceFileName(), theData
End Function

Public Function LogTraceFileName() As String
'
' COMMENT   : Return the current log file name...
'
' IN        :
'
' OUT       :
'
' RETURN    :
'
    LogTraceFileName = App.path & "\trace.Log"
End Function

Public Sub LB_Log(lb As Object, s As String)
    lb.AddItem s
    lb.ListIndex = lb.NewIndex
    lb.Refresh
End Sub

Public Sub setVgaSize(f As Object)
    f.Width = 640 * Screen.TwipsPerPixelX
    f.Height = 480 * Screen.TwipsPerPixelY
End Sub

 
 

Public Function Long2Word(v As Long) As Integer
        Long2Word = (v And &H7FFF&) - (v And &H8000&)
End Function


Public Function Word2Long(v As Integer) As Long
    Word2Long = v And &H7FFF&
End Function

Public Function Version() As String
    Version = Me.appVersion(App)
End Function

Public Function CopyFont(objSource As Variant, objDest As Variant) As Boolean

    'Dim f As StdFont
        
    objDest.Font.Bold = objSource.Font.Bold
    objDest.Font.Italic = objSource.Font.Italic
    objDest.Font.Name = objSource.Font.Name
    objDest.Font.Size = objSource.Font.Size
    
    objDest.Font.Strikethrough = objSource.Font.Strikethrough
    objDest.Font.Underline = objSource.Font.Underline
    objDest.Font.Weight = objSource.Font.Weight
    
    CopyFont = True
End Function

