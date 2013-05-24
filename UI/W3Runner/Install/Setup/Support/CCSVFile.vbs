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
' NAME        : CCSVFile
' DESCRIPTION : Class which provide a wrapper for a CSV File.
'
' ----------------------------------------------------------------------------------------------------------------------------

CLASS CCSVFile

  Private m_objTextFile
  Private m_booOpened
  Private m_values
  Private m_booCreateMode
  Private m_strCreateModeData
  Private m_booHappendMode
  Private m_booColumnNameMap
  Private m_strColumnNameCSV

  Public  Line
  Public  RowIndex
  Public  Separator
  Public  FileName
  Public  SupportColumnName
  
  PUBLIC PROPERTY GET ColumnNameCSV()
  
    ColumnNameCSV = m_strColumnNameCSV
  END PROPERTY
  
  PUBLIC PROPERTY LET ColumnNameCSV(v)
  
      Dim tmpArr, i
          
      m_strColumnNameCSV = v
      
      Set m_booColumnNameMap  = CreateObject("W3RunnerLib.CVBScriptExtensions").GetNewCollection()
      tmpArr                  = SplitTrim(m_strColumnNameCSV)
      
      For i=0 To UBound(tmpArr)
      
          m_booColumnNameMap.Add i,UCase(tmpArr(i))
      Next
  END PROPERTY
  
  PUBLIC FUNCTION OpenFile(ByVal strFileName) ' As Boolean
      
      OpenFile        = FALSE
      RowIndex        = 0
      FileName        = strFileName
      m_booCreateMode = FALSE
      m_booHappendMode= FALSE

      If(m_objTextFile.OpenFile(strFileName))Then

         ' Read Initialize the columns name description
         If SupportColumnName Then ColumnNameCSV = ReadLn()
         m_booOpened = TRUE
         OpenFile    = TRUE
      End If
  END FUNCTION
  
  PUBLIC FUNCTION DeleteFile(strFileName) ' As Boolean

    DeleteFile = m_objTextFile.DeleteFile(strFileName)
  END FUNCTION

  PUBLIC FUNCTION ReadLn() ' As String

      RowIndex = RowIndex + 1
      Line     = m_objTextFile.ReadLn()
      m_values = SplitTrim(Line)
      ReadLn   = Line
  END FUNCTION
  
  PUBLIC FUNCTION SplitTrim(ByVal strCSV) ' As Variant
      Dim arr 'As Variant
      Dim i   'As Long
      arr = Split(strCSV, Separator)
      For i = 0 To UBound(arr)
          arr(i) = Trim(arr(i))
      Next
      SplitTrim = arr
  END FUNCTION

  PUBLIC PROPERTY GET Count() ' As Long

     If IsEmpty(m_Values) Then

        Count = -1
     Else
        Count = UBound(m_Values) + 1
     End If
  END PROPERTY

  PRIVATE FUNCTION SaveCreateModeData()

      Dim i

      For i=0 To Count-1

          m_strCreateModeData = m_strCreateModeData & Values(i) & ","
      Next
      m_strCreateModeData = Mid(m_strCreateModeData,1,Len(m_strCreateModeData)-1)
      m_strCreateModeData = m_strCreateModeData & vbNewLine
  END FUNCTION

  PUBLIC FUNCTION AddRow(lngMaxColumns) ' As Boolean

      If(RowIndex)Then  SaveCreateModeData

      RowIndex = RowIndex + 1

      Dim varArray
      ReDim varArray(lngMaxColumns-1)

      m_values = varArray
      AddRow = TRUE
  END FUNCTION


  PUBLIC PROPERTY GET Values(ByVal varKey)

      Dim strValue
      
      If (Not IsNumeric(varKey)) And CBool(Len(varKey)) Then varKey = m_booColumnNameMap.Item(UCase(varKey))
      
      If varKey>UBound(m_values) Then

        Value = Empty
        Exit Property
      End If

      strValue = Trim(m_values(varKey))

      If Len(strValue) Then If(Mid(strValue,1,1)="""")Or(Mid(strValue,1,1)="'")Then strValue = Mid(strValue,2)
      If Len(strValue) Then If(Mid(strValue,Len(strValue),1)="""")Or(Mid(strValue,Len(strValue),1)="'")Then strValue = Mid(strValue,1,Len(strValue)-1)

      Values = strValue
  END PROPERTY

  PUBLIC PROPERTY LET Values(ByVal varKey,ByVal varValue)

      Dim strValue
      
      If (Not IsNumeric(varKey)) And CBool(Len(varKey)) Then varKey = m_booColumnNameMap.Item(UCase(varKey))

      If varKey>UBound(m_values) Then

        Value = Empty
        Exit Property
      End If
      m_values(varKey) = varValue
  END PROPERTY

  PUBLIC PROPERTY GET EOF() ' As Boolean

      EOF = m_objTextFile.EOF
  END PROPERTY

  PUBLIC FUNCTION Create(ByVal strFileName) ' As Boolean

      Create          = FALSE

      m_booCreateMode = TRUE
      m_booHappendMode= FALSE
      m_booOpened     = TRUE
      RowIndex        = 0
      FileName        = strFileName
      m_strCreateModeData = Empty

      Create          = TRUE
  END FUNCTION

  PUBLIC FUNCTION Append(ByVal strFileName) ' As Boolean

      Append          = FALSE

      m_booCreateMode = TRUE
      m_booHappendMode= TRUE
      m_booOpened     = TRUE
      RowIndex        = 0
      FileName        = strFileName
      m_strCreateModeData = Empty
      Append          = TRUE
  END FUNCTION

  PUBLIC FUNCTION CloseFile() ' As Boolean

     If(m_booOpened) Then

       If(m_booCreateMode)Then

          SaveCreateModeData
          If Right(m_strCreateModeData,2)=vbNewLine Then m_strCreateModeData = Mid(m_strCreateModeData,1,Len(m_strCreateModeData)-2)
          CloseFile = m_objTextFile.LogFile(FileName,m_strCreateModeData,Not m_booHappendMode) ' Create or Happend
       Else
           m_objTextFile.CloseFile
       End If
       m_booOpened = FALSE
     End If
     CloseFile = TRUE
  END FUNCTION

  PRIVATE SUB Class_Initialize()

      Dim objVBScriptExtensions

      SupportColumnName         = FALSE
      m_booOpened               = FALSE
      Separator                 = ","
      Set m_objTextFile         = CreateObject("W3RunnerLib.CTextFile")
  END SUB

  PRIVATE SUB Class_Terminate()

      CloseFile
      Set m_objTextFile = Nothing
  END SUB


  '
  ' Unit Test
  '
  PUBLIC FUNCTION UnitTest()
      UnitTest = FALSE

      If Not UnitTestReadWithColumnName()   Then Exit Function
      If Not UnitTestWrite()                Then Exit Function
      If Not UnitTestRead()                 Then Exit Function
      UnitTest = TRUE
  END FUNCTION
  
  PRIVATE FUNCTION UnitTestReadWithColumnName()

    Dim strCsvFileName, i
    
    CONST A_CONST_STRING = "Alfred De Musset"

    UnitTestReadWithColumnName  = FALSE
    strCsvFileName              = W3Runner.Environ("TEMP") & "\W3Runner.CCSV.csv"

    If(Create(strCsvFileName))Then

        AddRow 3                ' Add the columns name
        Values(0) = "Date"
        Values(1) = "Timer"
        Values(2) = "Name"
        
        
        For i=1 To 5           ' Add some data
        
          AddRow 3
          Values(0) = Now()
          Values(1) = Timer()
          Values(2) = A_CONST_STRING
        Next        
        If Not CloseFile() Then Exit Function

        ' Active Column Mode before we open the file
        SupportColumnName = TRUE
        If(OpenFile(strCsvFileName))Then
  
          Do While Not EOF
          
              ReadLn
              If W3Runner.FAILED( IsDate    (Values("Date"))          , "Read and check Date column"  ) Then Exit Function
              If W3Runner.FAILED( IsNumeric (Values("Timer"))         , "Read and check Timer column" ) Then Exit Function
              If W3Runner.FAILED( Values("Name")=A_CONST_STRING       , "Read and check Name column"  ) Then Exit Function
          Loop
          UnitTestReadWithColumnName = CloseFile()
        End If
    End If    
  END FUNCTION  

  PRIVATE FUNCTION UnitTestWrite()

    Dim strCsvFileName

    UnitTestWrite = FALSE

    strCsvFileName = W3Runner.Environ("TEMP") & "\W3Runner.CCSV.csv"

    If(Create(strCsvFileName))Then

        AddRow 5
        Values(0) = 1
        Values(1) = 2
        Values(2) = 3
        Values(3) = 4
        Values(4) = 5

        AddRow 6
        Values(0) = "Pete"
        Values(1) = "Paul"
        Values(2) = "John"
        Values(3) = "Ringo"
        Values(4) = "George"
        Values(5) = "Stu"

        AddRow 4
        Values(0) = """Peter"""
        Values(1) = """Phil"""
        Values(2) = """Mik"""
        Values(3) = """Tony"""

        AddRow 4
        Values(0) = "Brian"
        Values(1) = "Freddy"
        Values(2) = "Rod"
        Values(3) = "Ronaldo"

        UnitTestWrite = CloseFile()
    End If
  END FUNCTION

  PRIVATE FUNCTION UnitTestRead()

    Dim strCsvFileName, i

    UnitTestRead = FALSE

    strCsvFileName = W3Runner.Environ("TEMP") & "\W3Runner.CCSV.csv"

    If(OpenFile(strCsvFileName))Then

        Do While Not EOF

            ReadLn ' Force to read a line
            For i=0 To Count-1
               Select Case RowIndex
                   Case 1 : If W3Runner.FAILED((i+1)=CLng(Values(i)),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                   Case 2
                     Select Case i
                        Case 0 : If W3Runner.FAILED("Pete"=Values(i),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                        Case 1 : If W3Runner.FAILED("Paul"=Values(i),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                     End Select
                   Case 3
                     Select Case i
                        Case 0 : If W3Runner.FAILED("Peter"=Values(i),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                        Case 1 : If W3Runner.FAILED("Phil"=Values(i),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                     End Select
                   Case 4
                     Select Case i
                        Case 0 : If W3Runner.FAILED("Brian"=Values(i),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                        Case 1 : If W3Runner.FAILED("Freddy"=Values(i),"CCSVFile.UnitTest Case " & RowIndex & "," & i) Then Exit Function
                     End Select
                   End Select
              Next
        Loop
        UnitTestRead = CloseFile
    End If
  END FUNCTION

  PUBLIC FUNCTION LookUp(strFileName, varKey, varValue)

      LookUp = FALSE

      If(OpenFile(strFileName))Then

          Do While Not EOF

             ReadLn
             If CSTR(Values(varKey))=CSTR(varValue) THen

                LookUp = TRUE
                Exit Do
             End If
          Loop
          CloseFile
      End If
  END FUNCTION

END CLASS

'PUBLIC FUNCTION Main()
'  Dim objCsvFile
'  Set objCsvFile = New CCSVFile
'  objCsvFile.UnitTest
'END FUNCTION