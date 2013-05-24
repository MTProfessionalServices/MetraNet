' ---------------------------------------------------------------------------------------------------------------------------
'
' Copyright 2002 by W3Runner.com.
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND W3Runner.com. MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, W3Runner.com. Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with W3Runner.com.,
' and USER agrees to preserve the same.
'
'
' ---------------------------------------------------------------------------------------------------------------------------
'
' NAME        : CFIFO
' DESCRIPTION : Implement a simple First In, First Out object.
' SAMPLE      : At the end of the file.
'
' ----------------------------------------------------------------------------------------------------------------------------

CLASS CFIFO

  Private m_objTextFile
  Private m_objCollection

  PRIVATE SUB Class_Initialize()

      Set m_objCollection       = CreateObject("W3RunnerLib.CVBScriptExtensions").GetNewCollection()
  END SUB

  PRIVATE SUB Class_Terminate()

      Set m_objCollection = Nothing
  END SUB


  PUBLIC PROPERTY GET Peek()

      Peek = Item(1)
  END PROPERTY


  PUBLIC PROPERTY GET Value()

      Value = Peek
      Remove 1
  END PROPERTY

  PUBLIC PROPERTY LET Value(ByVal varValue)

    m_objCollection.Add varValue
  END PROPERTY

  PUBLIC FUNCTION Remove(lngIndex) ' As Boolean

     m_objCollection.Remove lngIndex
  END FUNCTION

  PUBLIC PROPERTY GET Count() ' As Long

     Count = m_objCollection.Count
  END PROPERTY

  PUBLIC PROPERTY GET Item(lngIndex) ' As Boolean

     Item = m_objCollection.Item(lngIndex)
  END PROPERTY

  PUBLIC SUB Clear()

     Do While Count
        Remove 0
     Loop
     Clear = TRUE
  END SUB

  PUBLIC FUNCTION UnitTest()

    Dim v,i '  As Long

    UnitTest = FALSE

    For i=1 to 10

      Value = i
    Next

    For i=1 to 10

      If Value <> i Then Exit Function
    Next

    UnitTest = TRUE

  END FUNCTION


END CLASS


' STOP
' Dim objFifo , i
' set objFifo = New CFIFO
' objFifo.Value = "1"
' objFifo.Value = "2"
' objFifo.Value = "3"
'
' Do While objFifo.Count
'
'   WSCRIPT.ECHO objFifo.Value()
' Loop

