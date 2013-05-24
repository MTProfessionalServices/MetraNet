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
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command3 
      Caption         =   "Count email"
      Default         =   -1  'True
      Height          =   555
      Left            =   1560
      TabIndex        =   2
      Top             =   720
      Width           =   1215
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Receive"
      Height          =   555
      Left            =   1560
      TabIndex        =   0
      Top             =   1560
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Send"
      Height          =   555
      Left            =   1560
      TabIndex        =   1
      Top             =   2520
      Width           =   1215
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()
    Dim e As Object
    Set e = CreateObject("W3RunnerLib.EMail")
    MsgBox e.htmlTest()
    'MsgBox e.TextTest()
End Sub


Private Sub Command2_Click()
    Dim e As Object
    Set e = CreateObject("W3RunnerLib.pop")
    e.test
End Sub

Private Sub Command3_Click()
  Dim e As Object
    Set e = CreateObject("W3RunnerLib.pop")
    e.TestCount
End Sub

'Return-Path: <SiteAngel_Ecare@bmc.com>
'Delivered-To: frederictorres.com%moi@frederictorres.com
'Received: (cpmta 15390 invoked from network); 29 Dec 2001 04:14:51 -0800
'Received: from 207.189.69.206 (HELO sjc-sawb-02.bmc.com)
'  by smtp.c001.snv.cp.net (209.228.32.108) with SMTP; 29 Dec 2001 04:14:51 -0800
'X-Received: 29 Dec 2001 12:14:51 GMT
'Received: from sjc-saap-03 ([192.168.6.214]) by sjc-sawb-02.bmc.com  with Microsoft SMTPSVC(5.5.1877.197.19);
'     Sat, 29 Dec 2001 12:14:50 +0000
'From: SiteAngel <SiteAngel_Ecare@bmc.com>
'Reply-To: SiteAngel <SiteAngel_Ecare@bmc.com>
'To: moi@frederictorres.com
'Subject: SiteAngel Update daily report for Dec 28, 2001
'Content-Type: text/html;charset=iso-8859-1
'Return-Path: SiteAngel_Ecare@bmc.com
'Message-ID: <007015014121dc1SJC-SAWB-02@sjc-sawb-02.bmc.com>
'Date: 29 Dec 2001 12:14:50 +0000
'Status: U
'x -UIDL: PC2zu9HkIGw8HwE
'
'<html><head><link rel="stylesheet" href="http://siteangel.bmc.com/siteangel/stylesheets/siteangelstyleb.css" type="text/css"></head><body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0"><table cellpadding="0" cellspacing="0" border="0" width="102%"><tr><td align="left" width="100%"><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr class=headertopcolor1><td align="left"><img src="http://siteangel.bmc.com/siteangel/images/bmclogo_onblue3.gif"></td><td align="right"><img src="http://siteangel.bmc.com/siteangel/images/siteangelpoweredby.gif"><img src="http://siteangel.bmc.com/siteangel/images/dot.gif" width="25" border="0"></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0" height="2" class=headertopheight2><tr class=headertopcolor2><td><img src="http://siteangel.bmc.com/siteangel/images/dot.gif" border="0"></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0" height="7" class=headertopheight3><tr class=headertopcolor3><td><i
'g src="http://siteangel.bmc.com/siteangel/images/dot.gif" border="0"></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0" height="7" class=headertopheight4><tr class=headertopcolor4><td align="center"><img src="http://siteangel.bmc.com/siteangel/images/dot.gif" border="0"></td></tr></table></td></tr></table><table width="400" cellpadding="0" cellspacing="0"><tr><td>&nbsp;</td><td colspan="3"><span class="sectionheading">For Dec 28, 2001 for frederictorres:</span></td></tr><tr><td>&nbsp;</td><td colspan="3"><p>
'Click <a href="http://siteangel.bmc.com/active/reporthome?sacid=Z00000cvitve9vZlgvsjc5465Zp5i">here</a> to view additional reports on your web site's performance and availability.</a></p></td></tr><tr><td>&nbsp;</td><td colspan="3"><br>

Private Sub Form_Load()

End Sub
