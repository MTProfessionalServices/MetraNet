VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CTDBInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public InitializationCount As Long
Public FolderInitializationCount As Long
Public LoadDatabaseTime    As Long
Public GetDirCount      As Long
Public ValidateInterityTime    As Long

Public DictionaryEntryCount As Long

Public TestInitializationCounter As Long
Public TestSessionInitializationCounter As Long

Public StaticFileInitializationCounter As Long

Public Function Reset()
    FolderInitializationCount = 0
    InitializationCount = 0
    GetDirCount = 0
    LoadDatabaseTime = GetTickCount
End Function

Public Function Show() As Boolean
    Dim strS As String
    strS = strS & "DTDBItem Test Initialization Count " & Me.TestInitializationCounter & vbNewLine
    strS = strS & "DTDBItem Test Session Initialization Count " & Me.TestSessionInitializationCounter & vbNewLine
    strS = strS & "DTDBItem Folder Initialization Count " & Me.FolderInitializationCount & vbNewLine
    strS = strS & "DTDBItem Static File Initialization Count " & Me.StaticFileInitializationCounter & vbNewLine
    
    strS = strS & vbNewLine
    
    strS = strS & "DTDBItem Initialization Count " & Me.InitializationCount & vbNewLine
    strS = strS & "DTDBItem Loading Time " & Me.LoadDatabaseTime & vbNewLine
    strS = strS & "DTDBItem Integrity Validation Time " & Me.ValidateInterityTime & vbNewLine
    strS = strS & "Directory Count " & Me.GetDirCount & vbNewLine
    strS = strS & "DictionaryEntryCount " & DictionaryEntryCount & vbNewLine
            
    MsgBox strS
End Function


