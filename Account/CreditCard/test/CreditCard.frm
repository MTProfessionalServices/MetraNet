VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   8145
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8535
   LinkTopic       =   "Form1"
   ScaleHeight     =   8145
   ScaleWidth      =   8535
   StartUpPosition =   3  'Windows Default
   Begin VB.ListBox lstIDs 
      Height          =   450
      Left            =   4560
      TabIndex        =   14
      Top             =   6480
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.ListBox ObjectList 
      Height          =   2205
      Left            =   360
      TabIndex        =   13
      Top             =   5640
      Width           =   3855
   End
   Begin VB.CommandButton SaveToXML 
      Caption         =   "Save To XML"
      Height          =   495
      Left            =   6000
      TabIndex        =   12
      Top             =   5040
      Width           =   1815
   End
   Begin VB.CommandButton ShowAllObjects 
      Caption         =   "Show All Objects"
      Height          =   495
      Left            =   360
      TabIndex        =   11
      Top             =   5040
      Width           =   1815
   End
   Begin VB.TextBox Text5 
      Height          =   495
      Left            =   5880
      TabIndex        =   9
      Text            =   "1999"
      Top             =   1560
      Width           =   1215
   End
   Begin VB.TextBox Text4 
      Height          =   495
      Left            =   240
      TabIndex        =   8
      Text            =   "Text4"
      Top             =   3600
      Width           =   7455
   End
   Begin VB.CommandButton Validate 
      Caption         =   "Validate Credit Card"
      Height          =   495
      Left            =   2760
      TabIndex        =   3
      Top             =   2880
      Width           =   1815
   End
   Begin VB.TextBox Text3 
      Height          =   495
      Left            =   3720
      TabIndex        =   2
      Text            =   "9"
      Top             =   1560
      Width           =   1215
   End
   Begin VB.TextBox Text2 
      Height          =   495
      Left            =   1920
      TabIndex        =   1
      Top             =   1560
      Width           =   1455
   End
   Begin VB.TextBox Text1 
      Height          =   495
      Left            =   240
      TabIndex        =   0
      Text            =   "VISA"
      Top             =   1560
      Width           =   1215
   End
   Begin VB.Label Label5 
      Caption         =   "Expiration Date (Year)"
      Height          =   255
      Left            =   5880
      TabIndex        =   10
      Top             =   1200
      Width           =   1695
   End
   Begin VB.Label Label4 
      Caption         =   "Expiration Date (Month)"
      Height          =   255
      Left            =   3720
      TabIndex        =   7
      Top             =   1200
      Width           =   1815
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Credit Card Validation Testing"
      Height          =   255
      Left            =   2760
      TabIndex        =   6
      Top             =   480
      Width           =   2295
   End
   Begin VB.Label Label2 
      Caption         =   "Number"
      Height          =   255
      Left            =   1920
      TabIndex        =   5
      Top             =   1200
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "Type"
      Height          =   255
      Left            =   240
      TabIndex        =   4
      Top             =   1200
      Width           =   735
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()

End Sub

Private Sub SaveToXML_Click()

    Dim query ' as string
    
    Dim rowset ' as object
    Dim tablename ' as object
    
    Dim id As Long
    Dim objectname As String
    
    objectname = ObjectList.List(ObjectList.ListIndex)
    id = lstIDs.List(ObjectList.ListIndex)

    On Error GoTo handler
    
    Dim config As New MTConfig
    Dim propset As New MTConfigPropSet
    
    ' create rowset object
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    
    ' initialize the rowset object
    rowset.Init ("\\Presserver")
    
    ' set the query
    query = "select " & _
        "a.name objectname, " & _
        "b.name columnname, " & _
        "b.xprec prec, " & _
        "b.xscale scale, " & _
        "c.name columntype, " & _
        "b.length length, " & _
        "b.isnullable nullvalue " & _
    "From " & _
        "sysobjects a, " & _
        "syscolumns b, " & _
        "systypes c " & _
    "Where " & _
        "a.id in (select d.id from sysobjects d where type = 'U' and name like 't_pv%1000') and " & _
        "a.id = b.id and " & _
        "b.xtype = c.xtype " & _
    "Order By " & _
        "objectname "
    
    ' set the query
    rowset.SetQueryTag ("__GENERAL_QUERY_2__")
    
    ' add param
    rowset.AddParam "%%ID%%", CStr(id)

    ' execute the query
    rowset.Execute

    ' get the new configuration
    Set propset = config.NewConfiguration("defineservice")
    
    ' insert the object name
    propset.InsertProp "name", PROP_TYPE_STRING, objectname
    
    Do While Not CBool(rowset.EOF)
        tablename = rowset.Value(rowset.Name(0))
        ColumnName = rowset.Value(rowset.Name(1))
        columntype = rowset.Value(rowset.Name(4))
        length = rowset.Value(rowset.Name(5))
        isnullvalue = rowset.Value(rowset.Name(6))
               
        ' create types for specific datatypes
        Dim msixtype As String
        
        Select Case columntype
            
            Case "varchar"
                msixtype = "string"
                    
            Case "int"
                msixtype = "int32"
        
            Case "numeric"
                msixtype = "double"
                
            Case "datetime"
                msixtype = "timestamp"
                
            Case "nvarchar"
            Case "image"
                msixtype = "undefined"
        
        End Select

        ' if isnull value is 0, set to Y else N
        Select Case isnullvalue
            Dim strisnullvalue
    
            Case "0"
                 strisnullvalue = "Y"
                    
            Case "1"
                strisnullvalue = "N"
        
        End Select
        
        Call logMessage("----------------------------")
        Call logMessage("Object name is " & tablename)
        Call logMessage("Column name is " & ColumnName)
        Call logMessage("Column type is " & columntype)
        Call logMessage("Length is " & length)
        Call logMessage("Is null value is " & strisnullvalue)

        If ColumnName <> "id_sess" Then
            
            ' insert the first set
            Dim innerset As New MTConfigPropSet
            Set innerset = propset.InsertSet("ptype")
        
            ' start inserting properties
            Dim propertyname As String
            
            ' take out the c_ if it is in the name
            
            propertyname = Mid(ColumnName, 3)
            innerset.InsertProp "dn", PROP_TYPE_STRING, propertyname
            innerset.InsertProp "type", PROP_TYPE_STRING, msixtype
            If msixtype <> "string" Then
                length = ""
            End If
            innerset.InsertProp "length", PROP_TYPE_STRING, length
            innerset.InsertProp "required", PROP_TYPE_STRING, strisnullvalue
            innerset.InsertProp "defaultvalue", PROP_TYPE_STRING, ""
                
        End If
        
        ' move to next in rowset
        rowset.MoveNext
        
    Loop

    ' write to file
    Dim filelocation As String
    filelocation = "E:\\" & objectname & ".xml"
    propset.Write (filelocation)
    
    ' clear the rowset object
    rowset.Clear
    
    ' display to user that job is done
    MsgBox "Done!"
    
    ' exit
    Exit Sub
    
handler:
    Err.Clear
    Call logMessage("Error occurred : " & Err.Description)
    Set rowset = Nothing
    
End Sub


Private Sub ShowAllObjects_Click()
    
    Dim query ' as string
    
    Dim rowset ' as object
    Dim tablename ' as object

    On Error GoTo handler
    
    Dim config As New MTConfig
    Dim propset As New MTConfigPropSet
    
    ' create rowset object
    Set rowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    
    ' initialize the rowset object
    rowset.Init ("\\Presserver")
        
    ' set the query
    rowset.SetQueryTag ("__GENERAL_QUERY_1__")

    ' execute the query
    rowset.Execute

    ' get the new configuration
    Set propset = config.NewConfiguration("defineservice")
    
    Do While Not CBool(rowset.EOF)
        objectname = rowset.Value(rowset.Name(0))
        id = rowset.Value(rowset.Name(1))
       
        'Call logMessage("----------------------------")
        'Call logMessage("Object name is " & objectname)
        'Call logMessage("ID is " & id)
        
        ObjectList.AddItem (objectname)
        lstIDs.AddItem (id)
        
        ' move to next in rowset
        rowset.MoveNext
        
    Loop
    
    ' clear the rowset object
    rowset.Clear
    
    ' exit
    Exit Sub
    
handler:
    Err.Clear
    Call logMessage("Error occurred : " & Err.Description)
    Set rowset = Nothing
    
End Sub

Private Sub Validate_Click()

    Dim cc As New MTCreditCard
    
    If Text1.Text = "visa" Then
        cc.CardType = MT_VISA
    ElseIf Text1.Text = "master" Then
        cc.CardType = MT_MASTERCARD
    ElseIf Text1.Text = "amex" Then
        cc.CardType = MT_AMERICAN_EXPRESS
    ElseIf Text1.Text = "discover" Then
        cc.CardType = MT_DISCOVER
    End If
    
    cc.CardNumber = Text2.Text
    cc.ExpirationDateMonth = CLng(Text3.Text)
    cc.ExpirationDateYear = CLng(Text5.Text)
    cc.UseAVS = 0
    
    On Error GoTo handler
    
    ' Validate
    ccerror = cc.Validate
    
    If (ccerror <> 0) Then
    
        Select Case CInt(ccerror)
        Case 1
            Text4 = "The credit card number you entered has an incorrect number of digits for the type specified."
        Case 2, 4
            Text4 = "Invalid credit card number.  Please check for typos."
        Case 3
            Text4 = "The credit card type does not match the entered card number."
        Case 5
            Text4 = "You have entered invalid expiration date."
        Case 6
            Text4 = "The credit card you have entered has expired."
        Case 7
            Text4 = "Your credit card has been declined."
        Case 9
            Text4 = "You must enter Address1, Zip, and Country for credit card address verification."
        Case Else
            Text4 = "An unknown error has occurred."
        End Select
        
        Else
        Text4 = "Success"
    End If

    ' Set credit card to nothing
    Set cc = Nothing
    
    Exit Sub
    
handler:
        Text4 = "Error Occured " & Err.Description
End Sub

