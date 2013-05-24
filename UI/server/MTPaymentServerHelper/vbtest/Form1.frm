VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3165
   ClientLeft      =   60
   ClientTop       =   375
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3165
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   735
      Left            =   1320
      TabIndex        =   0
      Top             =   600
      Width           =   1695
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()

    Dim objPS As New PaymentServer
    Dim objRS As MTXMLRowset
    
    Set objRS = objPS.GetPaymentServerGenericRowset("__GET_PRODUCT_VIEW__", "ACCOUNT_ID", 123, "INTERVAL_ID", 1000, "PV_NAME", "t_pv_ps_cc_credit_1")
    
    'Set objRS = objPS.GetPaymentServerRowset("__SELECT_ALL_CC_PAYMENT_METHODS__", 123)
    
    'Set objRS = objPS.GetPaymentServerRowset("__GET_PRODUCT_VIEW__", 123)
    
End Sub
