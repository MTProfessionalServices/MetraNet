Attribute VB_Name = "modWriteSQL"
'**************************************************
'© 2005 by MetraTech Corp.
'
'Author: Michael Ross
'MSIXDEF parsing by Simon Morton
'Last Update: 08-08-05
'
'Sorry, no time to comment this code yet...
'**************************************************

Option Explicit

Public ParentKey As String
Private strSQLTable As String
Private intF As Integer
Private od As Integer
Private OldsID() As String

Public Sub subWriteSQL(stext As String, sLength As String, Optional sType As String, Optional blReqd As Boolean)
On Error Resume Next

   If InStr(stext, "Loading") > 0 Then Exit Sub
   If InStr(stext, "\") > 0 Then Exit Sub
   If InStr(stext, "/") > 0 Then Exit Sub
   If InStr(stext, "properties found") > 0 Then Exit Sub
   
   Dim TableName As String
   Dim colon As Integer
   Dim svar As String
   Dim sID As String
   Dim blConfig As Boolean
   Dim CP As String
   Dim DL As String
   Dim i As Integer
   Dim os As Integer
   Dim blDontWrite As Boolean
   Dim blWritten As Boolean
   
   blConfig = True
      
   If blFirst = True Then
      With form1
         If blMultiple = False Then
            fnameonly = Right$(.txMSIX, Len(.txMSIX) - InStrRev(.txMSIX, "\"))
            fpathonly = Left$(.txMSIX, Len(.txMSIX) - Len(fnameonly))
            fnameonly = Left$(fnameonly, Len(fnameonly) - (Len(fnameonly) - InStrRev(fnameonly, ".")) - 1)
         Else
            fnameonly = Right$(CurrentFile, Len(CurrentFile) - InStrRev(CurrentFile, "\"))
            fnameonly = Left$(fnameonly, Len(fnameonly) - (Len(fnameonly) - InStrRev(fnameonly, ".")) - 1)
            CurrentFile = fnameonly
         End If
      End With
      
      ChDir fpathonly
   
      strSQLTable = fnameonly + ".sql"
      
      If FileExists(strSQLTable) Then
         Kill strSQLTable
      End If
   End If

'   intFTable = FreeFile
   intF = FreeFile
   Open strSQLTable For Append Access Write As #intF
   
   If Len(stext) > 0 Then

      If blControlCols = False Then
         colon = InStr(stext, ": ")
         sID = Trim$(Left$(stext, colon - 1))
         svar = Trim$(Right$(stext, Len(stext) - colon))
         
         ReDim Preserve OldsID(od)
         OldsID(od) = sID
         od = od + 1
         
      Else     'only for Control Columns
      
         If blParent Then
            sID = stext
            svar = sType
         End If
         
      End If
      
   End If
   
   If Len(sLength) > 0 Then
      DL = "(" + sLength + ")"
   Else
      DL = "(255)"
   End If
      
   If Len(ColumnPrefix) > 0 Then
      CP = "     [" + ColumnPrefix
   Else
      CP = "     [c_"
   End If
   
   If blFirst = True Then
            
      If Len(TablePrefix) > 0 Then
      
         If blUseParent And blParent Then
            ParentKey = TablePrefix + fnameonly
         End If
         TableName = TablePrefix + fnameonly
               
      Else
      
         TableName = "MT_" + fnameonly
                  
      End If
      
      If blParent And blMultiple Then
         Print #intF, "-- Note: You cannot drop the parent table if a child table exists."
         Print #intF, "-- You will need to drop the child tables first."
         Print #intF, ""
      End If
      
      Print #intF, "if exists (select * from dbo.sysobjects where id = object_id(N'[" + TableName + "]')" _
                   + "and OBJECTPROPERTY(id, N'IsUserTable') = 1)"
      Print #intF, "drop table " + "[" + TableName + "]"
      Print #intF, "GO"
      Print #intF, ""
      
      Print #intF, "CREATE TABLE [" + TableName + "] ("
      
   Else
   
'      If blUseParent Then       'this give precedence to config properties
'         For i = 0 To UBound(PrimaryKey)
'            If sID = PrimaryKey(i) Then
'               GoTo errlog                'skip if PK column is also a service def property
'            End If
'         Next
'      End If

'      If blParent = False Then
'         Call ColumnBody(sID, svar, CP, DL, blReqd)
'      End If
      
      If blCheckParentKeys Then
         If Len(sID) > 0 Then
            'Eliminate duplicate SIDs in MSIXDEF - parsing error can cause this
'            For os = 0 To UBound(OldsID)
'               If sID = OldsID(os) Then
'                  Exit Sub
'               End If
'            Next
            'Now eliminate duplicate columns in config file - use the msixdef properties
             For i = 0 To UBound(PrimaryKey)
               For os = 0 To UBound(OldsID)
                  If PrimaryKey(i) = OldsID(os) Then
                     blDontWrite = True
                     Exit For
                  End If
               Next
               If blDontWrite = False Then
                  sID = PrimaryKey(i)
                  If Len(KeyLength(i)) > 0 Then
                     DL = "(" + KeyLength(i) + ")"
                  Else
                     DL = "(255)"
                  End If
                  svar = KeyType(i)
                  Call ColumnBody(sID, svar, CP, DL, blReqd)   'only writes the primary key
                  blWritten = True
               Else
                  blWritten = False
                  blDontWrite = False
               End If
            Next
            If blParent Then
               Close #intF
               Exit Sub
            End If
         End If
      End If
   End If
   
   If blWritten = False Then
      Call ColumnBody(sID, svar, CP, DL, blReqd)
   End If
   
   If blLast = True Then
      If blUseParent = False Then
         Print #intF, ")"
         Print #intF, "GO"
      ElseIf Len(PrimaryKey(0)) = 0 Then
         Print #intF, ")"
         Print #intF, "GO"
      Else
         Dim PKs As String
         For i = 0 To UBound(PrimaryKey)
            If i < UBound(PrimaryKey) Then
               PKs = PKs + "[" + ColumnPrefix + PrimaryKey(i) + "], "
            Else
               PKs = PKs + "[" + ColumnPrefix + PrimaryKey(i) + "]"
            End If
         Next
         If blParent Then
            Print #intF, "     CONSTRAINT [PK_" + TablePrefix + fnameonly + "] PRIMARY KEY CLUSTERED"
            Print #intF, "     ("
            Print #intF, "           " + PKs
            Print #intF, "     ) "
            Print #intF, ")  "
            Print #intF, "GO"
         Else
            Print #intF, "     CONSTRAINT [FK_" + TablePrefix + fnameonly + "] FOREIGN KEY"
            Print #intF, "     ("
            Print #intF, "           " + PKs
            Print #intF, "     ) REFERENCES " + "[" + ParentKey + "] ("
            Print #intF, "           " + PKs
            Print #intF, "     ) "
            Print #intF, ")  "
            Print #intF, "GO"
         End If
      End If
   End If

errlog:
   Close #intF
      
   If blLast = True Then
      blLast = False
      
      If form1.ckOpen.Value = 1 Then
         Dim sh As New Shell
         sh.Open fpathonly + strSQLTable
      End If
      
      If blMultiple = False Then
         MsgBox "Generated: " + vbNewLine + fpathonly + strSQLTable, vbInformation
      End If
      
   End If
   
  If Err.Number > 0 Then
     MsgBox Err.Description
  End If
  subErrLog ("subWriteSQL")
End Sub
 
Private Sub ColumnBody(sID As String, svar As String, CP As String, DL As String, NN As Boolean)
On Error GoTo errlog

Dim sn As String

   If NN = True Then
      sn = " NOT NULL ,"
   Else
      sn = " NULL ,"
   End If
      
   Select Case LCase$(svar)
   
      Case "string"
      
         Print #intF, CP + sID + "] " + "[nvarchar] " + DL + " COLLATE SQL_Latin1_General_CP1_CI_AS" + sn
           

      Case "timestamp"
      
         Print #intF, CP + sID + "] [datetime]" + sn
         
   
      Case "decimal"
      
         DL = "(22,10)"
      
         Print #intF, CP + sID + "] " + "[numeric] " + DL + sn
      
      
      Case "boolean"
      
         Print #intF, CP + sID + "] " + "[varchar] " + "(5)" + sn
      
      
      Case "int32"
      
         Print #intF, CP; sID + "] " + "[int]" + sn
      
      
      Case "enum"
      
         Print #intF, CP + sID + "] " + "[varchar] " + "(255)" + " COLLATE SQL_Latin1_General_CP1_CI_AS" + sn

      Case Else
      
   End Select
   
errlog:
   subErrLog ("ColumnBody")
End Sub


