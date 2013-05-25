Attribute VB_Name = "MTVBExtensionReplace"
' ****************************************************************************************************************************************************
' Copyright 1998, 2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'
' NAME          : MTVBExtensionReplace
' DESCRIPTION   : This module implementation implement a new version of the VB function Replace().
'                 The new function is 4 to 10 time faster...
'                 written by Jost Schwider. Got from the web site www.vbspeed.com
'
'                   In case of problem due to this function just rename the Replace function to Replace_
'                   the Visual Basic default function will be picked up...
'
'
'                   MTLOG.TXT file.
' VERSION       :   1.0.
' AUTHOR        :   F.Torres.
'
' ****************************************************************************************************************************************************

Option Explicit

Public Function Replace(ByRef Text As String, _
    ByRef sOld As String, ByRef sNew As String, _
    Optional ByVal Start As Long = 1, _
    Optional ByVal Count As Long = 2147483647, _
    Optional ByVal Compare As VbCompareMethod = vbBinaryCompare _
  ) As String
' by Jost Schwider, jost@schwider.de, 20001218

  If LenB(sOld) Then

        If Compare = vbBinaryCompare Then
        
          Replace09Bin Replace, Text, Text, sOld, sNew, Start, Count
              
        Else
        
          Replace09Bin Replace, Text, LCase$(Text), LCase$(sOld), sNew, Start, Count
        End If

  Else 'Suchstring ist leer:
    Replace = Text
  End If
End Function

Private Static Sub Replace09Bin(ByRef result As String, _
    ByRef Text As String, ByRef Search As String, _
    ByRef sOld As String, ByRef sNew As String, _
    ByVal Start As Long, ByVal Count As Long _
  )
' by Jost Schwider, jost@schwider.de, 20001218
  Dim TextLen As Long
  Dim OldLen As Long
  Dim NewLen As Long
  Dim ReadPos As Long
  Dim WritePos As Long
  Dim CopyLen As Long
  Dim Buffer As String
  Dim BufferLen As Long
  Dim BufferPosNew As Long
  Dim BufferPosNext As Long
  
  'Ersten Treffer bestimmen:
  If Start < 2 Then
    Start = InStrB(Search, sOld)
  Else
    Start = InStrB(Start + Start - 1, Search, sOld)
  End If
  If Start Then
  
    OldLen = LenB(sOld)
    NewLen = LenB(sNew)
    Select Case NewLen
    Case OldLen 'einfaches Überschreiben:
    
      result = Text
      For Count = 1 To Count
        MidB$(result, Start) = sNew
        Start = InStrB(Start + OldLen, Search, sOld)
        If Start = 0 Then Exit Sub
      Next Count
      Exit Sub
    
    Case Is < OldLen 'Ergebnis wird kürzer:
    
      'Buffer initialisieren:
      TextLen = LenB(Text)
      If TextLen > BufferLen Then
        Buffer = Text
        BufferLen = TextLen
      End If
      
      'Ersetzen:
      ReadPos = 1
      WritePos = 1
      If NewLen Then
      
        'Einzufügenden Text beachten:
        For Count = 1 To Count
          CopyLen = Start - ReadPos
          If CopyLen Then
            BufferPosNew = WritePos + CopyLen
            MidB$(Buffer, WritePos) = MidB$(Text, ReadPos, CopyLen)
            MidB$(Buffer, BufferPosNew) = sNew
            WritePos = BufferPosNew + NewLen
          Else
            MidB$(Buffer, WritePos) = sNew
            WritePos = WritePos + NewLen
          End If
          ReadPos = Start + OldLen
          Start = InStrB(ReadPos, Search, sOld)
          If Start = 0 Then Exit For
        Next Count
      
      Else
      
        'Einzufügenden Text ignorieren (weil leer):
        For Count = 1 To Count
          CopyLen = Start - ReadPos
          If CopyLen Then
            MidB$(Buffer, WritePos) = MidB$(Text, ReadPos, CopyLen)
            WritePos = WritePos + CopyLen
          End If
          ReadPos = Start + OldLen
          Start = InStrB(ReadPos, Search, sOld)
          If Start = 0 Then Exit For
        Next Count
      
      End If
      
      'Ergebnis zusammenbauen:
      If ReadPos > TextLen Then
        result = LeftB$(Buffer, WritePos - 1)
      Else
        MidB$(Buffer, WritePos) = MidB$(Text, ReadPos)
        result = LeftB$(Buffer, WritePos + LenB(Text) - ReadPos)
      End If
      Exit Sub
    
    Case Else 'Ergebnis wird länger:
    
      'Buffer initialisieren:
      TextLen = LenB(Text)
      BufferPosNew = TextLen + NewLen
      If BufferPosNew > BufferLen Then
        Buffer = Space$(BufferPosNew)
        BufferLen = LenB(Buffer)
      End If
      
      'Ersetzung:
      ReadPos = 1
      WritePos = 1
      For Count = 1 To Count
        CopyLen = Start - ReadPos
        If CopyLen Then
          'Positionen berechnen:
          BufferPosNew = WritePos + CopyLen
          BufferPosNext = BufferPosNew + NewLen
          
          'Ggf. Buffer vergrößern:
          If BufferPosNext > BufferLen Then
            Buffer = Buffer & Space$(BufferPosNext)
            BufferLen = LenB(Buffer)
          End If
          
          'String "patchen":
          MidB$(Buffer, WritePos) = MidB$(Text, ReadPos, CopyLen)
          MidB$(Buffer, BufferPosNew) = sNew
        Else
          'Position bestimmen:
          BufferPosNext = WritePos + NewLen
          
          'Ggf. Buffer vergrößern:
          If BufferPosNext > BufferLen Then
            Buffer = Buffer & Space$(BufferPosNext)
            BufferLen = LenB(Buffer)
          End If
          
          'String "patchen":
          MidB$(Buffer, WritePos) = sNew
        End If
        WritePos = BufferPosNext
        ReadPos = Start + OldLen
        Start = InStrB(ReadPos, Search, sOld)
        If Start = 0 Then Exit For
      Next Count
      
      'Ergebnis zusammenbauen:
      If ReadPos > TextLen Then
        result = LeftB$(Buffer, WritePos - 1)
      Else
        BufferPosNext = WritePos + TextLen - ReadPos
        If BufferPosNext < BufferLen Then
          MidB$(Buffer, WritePos) = MidB$(Text, ReadPos)
          result = LeftB$(Buffer, BufferPosNext)
        Else
          result = LeftB$(Buffer, WritePos - 1) & MidB$(Text, ReadPos)
        End If
      End If
      Exit Sub
    
    End Select
  
  Else 'Kein Treffer:
    result = Text
  End If
End Sub



