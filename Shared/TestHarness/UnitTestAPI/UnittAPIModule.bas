Attribute VB_Name = "UnitTestAPIModule"
Option Explicit


Public Magic                        As String
Public static_TestHarnessMode       As Boolean
Public static_TraceStrings          As New Collection
Public static_TestSessionParameters As New CVariables
Public static_IndentLevel           As Long
Public static_CurrentTest           As String

Public Const MTTESTAPI_ERROR_1000 = "Cannot create Windows Script Hosting object IWshRuntimeLibrary.IWshShell_Class. Cbeck you VBScript installation."
Public Const MTTESTAPI_ERROR_1001 = "Cannot execute program [PRG]."
Public Const MTTESTAPI_ERROR_1002 = "Cannot create object from MTVBLIB.DLL"
