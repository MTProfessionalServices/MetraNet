VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Authenticator"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Public Function getInstance() As Authenticator
    
    Set getInstance = Me
    
End Function
Public Sub setPassword(login As String, password As String)


End Sub
Public Function isAuthentic(myCredentials As Object) _
                            As Boolean
                            
    Dim login As String
    Dim pwd As String
    Dim namespace As String

    login = myCredentials.loginID
    pwd = myCredentials.pwd
    namespace = myCredentials.name_space
    
    isAuthentic = True
    
End Function
Public Function checkbug(foo As Variant) _
                         As Boolean

    Dim login As String
    Dim pwd As String
    Dim namespace As String

    'login = foo.loginID
    'pwd = foo.pwd
    'namespace = foo.name_space

    checkbug = True
        
End Function
Public Function addUser(login As String, _
                        password As String, _
                        namespace As String) As Boolean
    
    addUser = True

End Function
Private Sub Class_Initialize()

    'Dim cnn1 As ADODB.Connection
    
    ' Open a connection without using a Data Source Name (DSN).
    'Set cnn1 = New ADODB.Connection
    'cnn1.ConnectionString = "driver={SQL Server};" & _
    '   "server=MATTA;uid=sa;pwd=pwd;database=netmeter"
    'cnn1.ConnectionTimeout = 30
    'cnn1.Open
    'MsgBox "helo world"

End Sub
