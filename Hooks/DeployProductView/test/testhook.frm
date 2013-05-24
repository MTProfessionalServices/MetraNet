VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()

    On Error Resume Next
    Set mConfig = CreateObject("MetraTech.MTConfig.1")
    If Err Then
        MsgBox "1: error occurred: " & Err.Description
    Else
        MsgBox "1: Successful"
    End If
    
    
    Rem set aPropSet = mConfig.ReadConfigurationFromString("<xmlconfig><hook>MetraHook.DeployProductView.1</hook></xmlconfig>",false)
    Set aPropSet = mConfig.ReadConfigurationFromString("<deployment><deployment_hooks><hook>MetraHook.DeployProductView.1</hook></deployment_hooks></deployment>", False)
    If Err Then
        MsgBox "2: error occurred: " & Err.Description
    Else
        MsgBox "2: Successful"
    End If
    
    Set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
    If Err Then
        MsgBox "3: error occurred: " & Err.Description
    Else
        MsgBox "3: Successful"
    End If
    
    aHookHandler.Read (aPropSet)
    If Err Then
        MsgBox "4: error occurred: " & Err.Description
    Else
        MsgBox "4: Successful"
    End If
    
    
    aHookHandler.ExecuteAllHooks "", 0
    If Err Then
        MsgBox "5: error occurred: " & Err.Description
    Else
        MsgBox "5: Successful"
    End If
    

End Sub
