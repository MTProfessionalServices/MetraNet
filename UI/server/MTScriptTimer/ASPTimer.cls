VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ASPTimer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' //==========================================================================
' // Copyright 1998-2001 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //==========================================================================
Option Explicit

'----------------------------------------------------------------------------
' This file contains helpful routines for timing web pages
'----------------------------------------------------------------------------

Private mbInit As Boolean
Private mbStart As Boolean

Private mobjXML As New DOMDocument40
Private mstrScriptName As String

' <mt_script_performance>
'   <application>
'     <id />
'     <session>
'       <id />
'       <results>
'         <result>
'           <script />
'           <date />
'           <execution_time />
'         </result>
'       </results>
'     </session>
'   </application>
' </mt_script_performance>

' <mt_perfmon_config>
'   <application id="">
'     <report_path />
'   </application>
' </mt_perfmon_config>
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub Init(ByVal strXML As String)
  mobjXML.async = False
  
  Call mobjXML.loadXML(strXML)
  
  If mobjXML.parseError Then
    mbInit = False
  Else
    mbInit = True
  End If
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub OnStartPage(objSC As ScriptingContext)
  'Start the timer
  If mbInit Then
    mbStart = True
    Call PerfInit
  End If
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub OnEndPage()
  Dim objResultsNode As IXMLDOMNode
  Dim objResultNode As IXMLDOMNode
  Dim objNode As IXMLDOMNode
  
  'On Error GoTo ErrorHandler
  
  If mbInit And mbStart Then
    'Stop the timer
    Call PerfFinish
    
    mbStart = False
  
    'Write the result
    'Get the results node
    Set objResultsNode = mobjXML.selectSingleNode("/session/results")
    
    If Not objResultsNode Is Nothing Then
      'Create a result node
      Set objResultNode = mobjXML.createElement("result")
      
      'Add the script name
      Set objNode = mobjXML.createElement("script")
      objNode.Text = mstrScriptName
      Call objResultNode.appendChild(objNode)
      
      'Add the date & time
      Set objNode = mobjXML.createElement("date")
      objNode.Text = Date & " " & Time
      Call objResultNode.appendChild(objNode)
      
      'Add the execution mobjSC.Session("PERF_TIMER_XML_DOC")
      Set objNode = mobjXML.createElement("execution_time")
      objNode.Text = PerfElapsed
      Call objResultNode.appendChild(objNode)
      
      'Add the result to the results node
      Call objResultsNode.appendChild(objResultNode)
    End If
  End If
  
ErrorHandler:
  If Err Then
    
  End If
End Sub
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetXML() As String
  GetXML = mobjXML.xml
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Let ScriptName(ByVal strName As String)
  Let mstrScriptName = strName
End Property
