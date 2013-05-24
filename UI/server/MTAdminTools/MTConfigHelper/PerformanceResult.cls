VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PerformanceResult"
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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' MTConfigHelper.PerformanceResult                                          '
'                                                                           '
' Description:  Counter definition for priceable item types.                '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private mstrName As String
Private mstrResultPath As String
Private mcollComputedResults As Collection

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ComputeResults()                                            '
' Description : Compute the results for this particular test.               '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ComputeResults(Optional ByVal strAppID As String = "", _
                               Optional ByVal strSessionID As String = "")
  Dim objXML As New DOMDocument40
  Dim strScript As String
  Dim objResult As ComputedResult
  Dim strQuery As String
  
  'Reset the collection of results
  Set mcollComputedResults = Nothing
  Set mcollComputedResults = New Collection
  
  'Load the XML
  objXML.async = False
  Call objXML.Load(mstrResultPath)
  
  If objXML.parseError Then
  
  Else
    'Set the query to get results specified by the AppID and the SessionID
    If Len(strAppID) > 0 Then
      strQuery = "/mt_script_performance/applicaion[id = '" & strAppID & "']"
    Else
      strQuery = "/mt_script_performance/application"
    End If
    
    If Len(strSessionID) > 0 Then
      strQuery = strQuery & "/session[id = '" & strSessionID & "']/results/result"
    Else
      strQuery = strQuery & "/session/results/result"
    End If
    
    
    'Get the next Script (i.e. ShwoReport.asp) to analyze
    strScript = GetNextScript(objXML, strQuery)
  
    'Loop while there are results to compute
    Do While Len(strScript) > 0
      Set objResult = ComputeSingleResult(strScript, objXML.selectNodes(strQuery & "[script='" & strScript & "']/execution_time"))
      
      If Not objResult Is Nothing Then
        Call mcollComputedResults.Add(objResult)
      End If
      
      'Get the next script
      strScript = GetNextScript(objXML, strQuery)
    Loop
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ComputeSingleResult(strScript, objNodeList)                 '
' Description : Based on the input set, compute a single result.            '
' Inputs      : strScript -- Name of the script                             '
' Outputs     : objNodeList -- List of execution times.                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function ComputeSingleResult(ByVal strScript As String, ByRef objNodeList As IXMLDOMNodeList)
  Dim objNode As IXMLDOMNode
  Dim objResult As New ComputedResult
  
  Dim dblTotal As Double
  Dim dblMin As Double
  Dim dblMax As Double
  Dim dblTime As Double
  Dim dblTemp As Double
  
  dblMin = 0
  dblMax = 0
  dblTotal = 0
  dblTemp = 0
  
  'Make sure there is some data
  If objNodeList.Length = 0 Then
    Set ComputeSingleResult = Nothing
  Else
    'Set properties
    objResult.Num = objNodeList.Length
    objResult.ScriptName = strScript
    
    For Each objNode In objNodeList
      If IsNumeric(objNode.Text) Then
        
        'Get the time
        dblTime = CDbl(objNode.Text)
        
        'Check for new max
        If dblTime > dblMax Then
          dblMax = dblTime
        End If
        
        'Check for new min
        If dblTime < dblMin Or dblMin = 0 Then
          dblMin = dblTime
        End If
        
        'Update total
        dblTotal = dblTotal + dblTime
      End If
    Next
    
    'Compute the totals
    If dblTotal > 0 Then
      
      'Compute average
      objResult.Avg = dblTotal / objResult.Num
      objResult.Max = dblMax
      objResult.Min = dblMin
    
      'Compute standard deviation
      'Sum of square of difference from mean
      For Each objNode In objNodeList
        If IsNumeric(objNode.Text) Then
          
          dblTime = CDbl(objNode.Text)
                  
          dblTemp = dblTemp + ((objResult.Avg - dblTime) * (objResult.Avg - dblTime))
                  
        End If
      Next
      
      'Get the standard error
      objResult.StdDev = Sqr(dblTemp / objResult.Num)
      
      
      Set ComputeSingleResult = objResult
      
    Else
      Set ComputeSingleResult = Nothing
    End If
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : GetNextScript(objXML)                                       '
' Description : Get the name of the next script to analyze                  '
' Inputs      : XML Doc containing data                                     '
' Outputs     : Name of the next script                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function GetNextScript(ByRef objXML As DOMDocument40, ByVal strQuery As String) As String
  Dim objTempXML As New DOMDocument40
  Dim objResultList As IXMLDOMNodeList
  Dim objResultNode As IXMLDOMNode
  Dim objComputedResult As ComputedResult
  Dim strScriptQuery As String
  
  objTempXML.async = False
  Call objTempXML.loadXML(objXML.xml)
  
  'Get the list of nodes, and remove all those that have been accounted for
  For Each objComputedResult In mcollComputedResults
    strScriptQuery = strQuery & "[script='" & objComputedResult.ScriptName & "']"
    
    Set objResultList = objTempXML.selectNodes(strScriptQuery)
    
    For Each objResultNode In objResultList
      Call objResultNode.parentNode.removeChild(objResultNode)
    Next
  Next
  
  'Now the already included nodes are removed....
  'Get the next existing result node (select single node returns the first match)
  Set objResultNode = objTempXML.selectSingleNode(strQuery)
  
  If Not objResultNode Is Nothing Then
    GetNextScript = objResultNode.selectSingleNode("script").Text
  Else
    GetNextScript = ""
  End If
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetComputedResults() As Collection
  Set GetComputedResults = mcollComputedResults
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get Name() As String
  Let Name = mstrName
End Property

Public Property Let Name(ByVal strName As String)
  Let mstrName = strName
End Property
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Property Get ResultPath() As String
  Let ResultPath = mstrResultPath
End Property

Public Property Let ResultPath(ByVal strResultPath As String)
  Let mstrResultPath = strResultPath
End Property

  
