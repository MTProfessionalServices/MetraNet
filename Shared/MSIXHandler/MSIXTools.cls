VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXTools"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321CA01C7"
'****************************************************************************************************************************************************
'
' Copyright 1998-2000 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
'****************************************************************************************************************************************************
'
' CLASS         : MSIXTools
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   : The purpose of this class is to expose usefull functions for the COM object itself and for any client.
'                 This class may be used directly or through the object MSIXHandler.
'                 A MSIXHandler object allocate the MSIXTools class (property Tools) and share it with its MSIXProperties instance. Then MSIXProperty, MSIXEnumType
'                 can use the MSIXTool instance thanks to their Parent property.
'                 This means that the object DataAccessorObject, PVNameIdLookUpObject, LocaleTranslatorObject and Cache are shared too.
'
' $Date$
' $Author$
' $Revision$
' $Workfile$
'
'
'****************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long

Public InstanceId                       As Long
Public TextFile                         As New cTextFile
Public PreProcessor                     As New CPreProcessor
Public WindowsAPI                       As New cWindows

Private m_objDataAccessor               As COMDBOBJECTSLib.COMDataAccessor
Private m_objLocaleTranslator           As COMDBOBJECTSLib.COMLocaleTranslator
Private m_objPVNameIdLookup             As NAMEIDLib.MTNameID
Private m_objUnicode2Big5Translater     As Unicode2Big5Translater
Private m_objMSIXCache                  As MSIXCache      ' This instance is allocated by the client of this class - Generally one instance is allocated at the application level by the application itself and then give to this class.

Private Const MAX_AMOUNT_STORED_AS_NUMERIC_22_10 As Double = 100000000000#

Private Const DEFAULT_PAYMENT_SERVER_NAME = "paymentServer"

Private Const PASSWORD_LENGTH = 6    ' default password length used by GeneratePassword

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function GetCurrencyFormat(ByVal dblAmount As Double, ByVal strCurrency As String) As String

    On Error GoTo ErrMgr

    GetCurrencyFormat = LocaleTranslatorObject.GetCurrency(dblAmount, strCurrency)
    
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetCurrencyFormat", LOG_ERROR
End Function



' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetMTConfigDir
' DESCRIPTION   : Returns the config folder path of the RMP! Will support concurent development.
' PARAMETERS    :
' RETURNS       :
Public Function GetMTConfigDir() As String

    On Error GoTo ErrMgr


    Dim strS                    As String
    Dim rcd                     As New MTRcd
    Static strMTConfigDir       As String
    
    
    If (Len(strMTConfigDir)) Then
        
    Else
        strS = rcd.ConfigDir
        
        ' The function add a slash at the end. So I remove it because it was part ot the version 1
        If (Right(strS, 1) = "\") Then
        
            strS = Mid$(strS, 1, Len(strS) - 1)
        End If
        strMTConfigDir = strS
    End If
    GetMTConfigDir = strMTConfigDir
    

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetMTConfigDir", LOG_ERROR
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetMTInstallDir
' DESCRIPTION   : Returns the install dir of the RMP. Read from the registry!
' PARAMETERS    :
' RETURNS       :
Public Function GetMTInstallDir() As String

    On Error GoTo ErrMgr


    Dim objRegistry As New cRegistry
    
    If (objRegistry.OpenSection(objRegistry.HKEY_LOCAL_MACHINE, "software\MetraTech\Install", KEY_READ)) Then
    
        GetMTInstallDir = objRegistry.getSubVar("InstallDir")
        objRegistry.CloseSection
    End If

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetMTInstallDir", LOG_ERROR
End Function





' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetDateTimeInGMTFormat
' PARAMETERS    : Returns a date into the GMT Format : yyy-mm-ddThh:mm:ssZ. This function do not convert the date.
' DESCRIPTION   :
' RETURN        :
Public Function GetDateTimeInGMTFormat(ByVal datDate As Variant) As String

    On Error GoTo ErrMgr

    
    If (Not IsDate(datDate)) Then Exit Function
    
    Dim strD As String
    
    strD = strD & Format(datDate, "yyyy") & "-"
    strD = strD & Format(datDate, "mm") & "-"
    strD = strD & Format(datDate, "dd") & "T"
    
    strD = strD & Format(datDate, "Hh") & ":"
    strD = strD & Format(datDate, "Nn") & ":"
    strD = strD & Format(datDate, "Ss") & "Z"
    
    GetDateTimeInGMTFormat = strD

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetDateTimeInGMTFormat", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetCurrentGMTTime
' PARAMETERS    :
' DESCRIPTION   : Returns the current GMT time into a string. String format yyyy/mm/dd hh/mm/ss. This format can be converted into a DATE\VT_DATE
'                 with the function CDate().
' RETURN        :
Public Function GetCurrentGMTTime(Optional ByVal strDateSeparator As String = "/", Optional ByVal strTimeSeparator As String = ":") As Variant

    On Error GoTo ErrMgr

'    Dim usrTime As SYSTEMTIME
'    ' Call the procedure to load the SYSTEMTIME structure.
'    GetSystemTime usrTime
'    With usrTime
'        GetCurrentGMTTime = Format(.Year, "0000") & strDateSeparator & Format(.Month, "00") & strDateSeparator & Format(.Day, "00") & " " & Format(.Hour, "00") & strTimeSeparator & Format(.Minute, "00") & strTimeSeparator & Format(.Second, "00")
'    End With
'
    GetCurrentGMTTime = MTNow()

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetCurrentGMTTime", LOG_ERROR
End Function



Public Function GetMachineCurrentGMTTime(Optional ByVal strDateSeparator As String = "/", Optional ByVal strTimeSeparator As String = ":") As Variant

    On Error GoTo ErrMgr

    Dim usrTime As SYSTEMTIME
    ' Call the procedure to load the SYSTEMTIME structure.
    GetSystemTime usrTime
    With usrTime
        GetMachineCurrentGMTTime = Format(.Year, "0000") & strDateSeparator & Format(.Month, "00") & strDateSeparator & Format(.Day, "00") & " " & Format(.Hour, "00") & strTimeSeparator & Format(.Minute, "00") & strTimeSeparator & Format(.Second, "00")
    End With
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetMachineCurrentGMTTime", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : CheckAmountStoredAsNumeric22_10
' PARAMETERS    :
' DESCRIPTION   : Check if the value dblAmount fit into a numeric 22,10.  All the SQL Table Amounts are stored into numeric 22,10.
' RETURN        :
Public Function CheckAmountStoredAsNumeric22_10(ByVal dblAmount As Double) As Boolean

    On Error GoTo ErrMgr

    CheckAmountStoredAsNumeric22_10 = dblAmount <= MAX_AMOUNT_STORED_AS_NUMERIC_22_10
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "CheckAmountStoredAsNumeric22_10", LOG_ERROR
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : EMailAddressValid
' PARAMETERS    :
' DESCRIPTION   : Returns TRUE if the strEMailAddress contains a valid eMail.
' RETURN        :
Public Function EMailAddressValid(ByVal strEMailAddress As String) As Boolean

    On Error GoTo ErrMgr


    Dim lngPos As Long
    
    lngPos = InStr(strEMailAddress, "@") ' 1 Test if there is a @
    
    If (lngPos) Then
    
        lngPos = InStr(lngPos, strEMailAddress, ".") ' 2 there there is a . after the @
        
        If (CBool(lngPos)) Then
        
            ' 3 Test that the email is not @.
            ' 4 test the the email is not ftorres@media., the char . must not be the last
            EMailAddressValid = CBool(strEMailAddress <> "@.") And (lngPos < Len(strEMailAddress))
        Else
            TRACE Replace(MTMSIX_ERROR_01014, "[EMAIL]", strEMailAddress), "MSIXTools", "EMailAddressValid"
            EMailAddressValid = False
        End If
    End If

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "EMailAddressValid", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Private Function CheckPath(strPath As String) As String

    On Error GoTo ErrMgr


    CheckPath = Replace(strPath, "\\", "\")

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "CheckPath", LOG_ERROR
End Function



' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : MTSQLRowSetToString
' DESCRIPTION   : Returns the MTSQLRowset r content into a string
' PARAMETERS    :
' RETURNS       :
Public Function MTSQLRowSetToString(ByVal r As Variant, Optional booNameValue As Boolean = False) As String 'ROWSETLib.MTSQLRowset

    On Error GoTo ErrMgr

    'r As ROWSETLib.MTSQLRowset
    
    Dim strS As String
    Dim i    As Long
    Dim lngRow As Long
    
    If (Not booNameValue) Then
        For i = 0 To r.Count - 1
        
            strS = strS & r.Name(CLng(i)) & ";"
        Next
    End If
    strS = strS & vbNewLine
    If (r.RecordCount) Then r.MoveFirst
    
    Do While Not r.EOF()
        
        If (booNameValue) Then
        
            lngRow = lngRow + 1
            strS = strS & "[" & Format(lngRow, "00000") & "]"
        End If
        
        For i = 0 To r.Count - 1
        
            If (booNameValue) Then
                strS = strS & r.Name(CLng(i)) & "=" & r.Value(r.Name(CLng(i))) & "; "
                strS = strS & vbNewLine
            Else
                strS = strS & r.Value(r.Name(CLng(i))) & ";"
            End If
            
        Next
        r.MoveNext
        strS = strS & vbNewLine
    Loop
    If (r.RecordCount) Then r.MoveFirst
    MTSQLRowSetToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "MTSQLRowSetToString", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : COMProductViewToString
' DESCRIPTION   : Returns the COMProductView r content into a string
' PARAMETERS    :
' RETURNS       :
Public Function COMProductViewToString(ByVal r As COMDBOBJECTSLib.COMProductView) As String

    On Error GoTo ErrMgr

    'r As ROWSETLib.MTSQLRowset
    
    Dim strS As String
    Dim i    As Long
    
    For i = 0 To r.Count - 1
        strS = strS & r.Name(i) & ";"
    Next
    strS = strS & vbNewLine
    If (r.RecordCount) Then r.MoveFirst
    Do While Not r.EOF()
        
        For i = 0 To r.Count - 1
            strS = strS & r.Value(i) & ";"
        Next
        r.MoveNext
        strS = strS & vbNewLine
    Loop
    If (r.RecordCount) Then r.MoveFirst
    COMProductViewToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "COMProductViewToString", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PropertiesRowSetToString
' DESCRIPTION   : Returns the MSIXProperties content into a string
' PARAMETERS    :
' RETURNS       :
Public Function PropertiesRowSetToString(ByVal objProperties As MSIXProperties, Optional ByVal booHTMLTable As Boolean = False) As String

    On Error GoTo ErrMgr

    'r As ROWSETLib.MTSQLRowset

    Dim strS As String
    Dim objP As MSIXProperty
    
    For Each objP In objProperties
        strS = strS & objP.Name & ";"
    Next
    strS = strS & vbNewLine
    
    If (objProperties.Rowset.RecordCount) Then objProperties.Rowset.MoveFirst
    Do While Not objProperties.Rowset.EOF()
        
        For Each objP In objProperties
            strS = strS & objP.Value & ";"
        Next
        objProperties.Rowset.MoveNext
        strS = strS & vbNewLine
    Loop
    If (objProperties.Rowset.RecordCount) Then objProperties.Rowset.MoveFirst
    PropertiesRowSetToString = strS

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "PropertiesRowSetToString", LOG_ERROR
End Function

'' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
''   FUNCTION      : GetLocalizedEnumTypeValue()
''   DESCRIPTION   : FUNCTION NOT USED ANY MORE
''   RETURNS       :
''                 F.Torres - 5/4/00
'Public Function etLocalizedEnumTypeValue(ByVal strLanguage As String, ByVal strNameSpace As String, ByVal strEnumTypeName As String, ByVal strEnumTypeItemName As String) As String
'
'    On Error GoTo ErrMgr
'
'
'    Dim objLocalizedEnumType     As Object '   As New MTInMemRowset
'    Dim strFQN                   As String
'    Dim strAlmostFQN             As String
'
'
'    strFQN = strNameSpace & "/" & strEnumTypeName & "/" & strEnumTypeItemName
'    strAlmostFQN = strNameSpace & "/" & strEnumTypeName & "/"
'
'    ' Test in cache
'
'    If (Cache.Exist(strFQN)) Then
'
'        etLocalizedEnumTypeValue = Cache(strFQN).Data ' The Item is found in the cache
'        Exit Function
'    End If
'
'    etLocalizedEnumTypeValue = ""
'    Set objLocalizedEnumType = GetLocalizedEnumTypes(strLanguage, strNameSpace, strEnumTypeName)
'
'    ' Find the right value and return it, but load the all localized enum type in the cache...
'    Do While Not objLocalizedEnumType.EOF
'
'        Cache.Add strAlmostFQN & objLocalizedEnumType.Value("LocalizedString"), objLocalizedEnumType.Value("Value")
'        objLocalizedEnumType.MoveNext
'    Loop
'    Set objLocalizedEnumType = Nothing
'
'    ' Get the value recursively NOW!
'    'GetLocalizedEnumTypeValue = GetLocalizedEnumTypeValue(strLanguage, strNameSpace, strEnumTypeName, strEnumTypeItemName)
'
'    Exit Function
'ErrMgr:
'    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetLocalizedEnumTypeValue", LOG_ERROR
'End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetLocalizedEnumTypes
' DESCRIPTION   : Returs a MTInMemRowset that contains a localized enum type.
' PARAMETERS    :
' RETURNS       : A reference to the MTInMemRowset or Raise an error and return nothing
Friend Function GetLocalizedEnumTypes(ByVal strLanguage As String, ByVal strNameSpace As String, ByVal strEnumTypeName As String) As Object

    On Error GoTo ErrMgr

          
    Dim myDataAccessor      'As New COMDataAccessor
    Dim myLocaleTranslator  'As New COMLocaleTranslator
    Dim myRowset            'As New MTInMemRowset
        
    Set GetLocalizedEnumTypes = Nothing
    
    ' create the data accessor com object
    'Set myDataAccessor = CreateObject("COMDataAccessor.COMDataAccessor.1")
    Set myDataAccessor = DataAccessorObject() ' Application static member.
    
    Set myRowset = CreateObject("MTInMemRowset.MTInMemRowset.1")
             
    Set myLocaleTranslator = myDataAccessor.GetLocaleTranslator     ' get the locale translator object
    myLocaleTranslator.Init strLanguage                             ' initialize the locale translator object
    myLocaleTranslator.LanguageCode = strLanguage                   ' put the language code
    myRowset.Init                                                   ' initialize the rowset
    
    Set GetLocalizedEnumTypes = myLocaleTranslator.GetLocaleListForEnumTypes(strLanguage, strNameSpace, strEnumTypeName) ' get the localized strings
    
    ' SAMPLE : How to read the rowset
    ' Value(0) is the localized string
    ' Value(1) is the enum type item id
    'Do While Not myRowset.EndOfRowset
    '    Dim myvalue1, myvalue2
    '    myvalue1 = myRowset.Value(0)
    '    myvalue2 = myRowset.Value(1)
    '    myRowset.MoveNext
    'Loop

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetLocalizedEnumTypes", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "Class_Initialize", LOG_ERROR
End Sub


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    Set m_objDataAccessor = Nothing
    Set m_objLocaleTranslator = Nothing
    Set m_objPVNameIdLookup = Nothing
    Set m_objUnicode2Big5Translater = Nothing
    Set m_objMSIXCache = Nothing
    

    #If LOG_OBJECT_INFO Then
    
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "Class_Terminate", LOG_ERROR
End Sub


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadEnumTypeData
' DESCRIPTION   : Returns the enum type into the objEntries as a CVariables object. Support the Cache object if set.
' PARAMETERS    :
' RETURNS       : TRUE is ok.
Public Function LoadEnumTypeData(ByRef objEntries As MSIXEnumTypeEntries, strLanguage As String, strNameSpace As String, strEnumTypeName As String) As Boolean

    On Error GoTo ErrMgr

    Dim objEnumTypeconfig   'As MTENUMCONFIGLib.EnumConfig
    Dim objEnumSpace        'As MTENUMCONFIGLib.MTEnumSpace
    Dim objEnumType         'As MTENUMCONFIGLib.MTEnumType
    Dim objEnumTypeItem     'As MTENUMCONFIGLib.MTEnumerator
    Dim strError            As String
    Dim strEnumTypeFQN      As String
        
    strEnumTypeFQN = strNameSpace & "/" & strEnumTypeName
    
    'If (Cache.Exist("ENUMTYPE:" & UCase$(strEnumTypeFQN))) Then ' If the enum type is cached
   
    '    Set objEntries = Cache.Item("ENUMTYPE:" & UCase$(strEnumTypeFQN)).Data
    '    LoadEnumTypeData = True
    '    Exit Function
    'End If
    
    Set objEntries = New MSIXEnumTypeEntries
    
'    objEntries.Language = strLanguage
'    objEntries.NameSpace = strNameSpace
'    objEntries.EnumTypeName = strEnumTypeName
'
    ' If the namespace is in the cached
    'If (Cache.Exist("NAMESPACE:" & UCase$(strNameSpace))) Then
    '
    '    Set objEnumSpace = Cache.Item("NAMESPACE:" & strNameSpace).Data
    'Else
    
        Set objEnumTypeconfig = EnumConfigLookUpObject() 'CreateObject("Metratech.MTEnumConfig.1")
                 
        Set objEnumSpace = objEnumTypeconfig.GetEnumSpace(strNameSpace)
        If (objEnumSpace Is Nothing) Then GoTo Error
        
    '    Cache.Add "NAMESPACE:" & UCase$(strNameSpace), objEnumSpace
    'End If
    
    ' Populate the entries
    Set objEnumType = objEnumSpace.GetEnumType(strEnumTypeName)
    If (objEnumType Is Nothing) Then GoTo Error
        
    For Each objEnumTypeItem In objEnumType.GetEnumerators
    
         objEntries.Add objEnumTypeItem.Name, objEnumTypeItem.ElementAt(0)
    Next
    ' Cache the enum type object stored in a cvariables
    ' Cache.Add "ENUMTYPE:" & UCase$(strEnumTypeFQN), objEntries

    LoadEnumTypeData = True
    Exit Function
Error:
    strError = MTMSIX_ERROR_01023
    strError = Replace(strError, "[NAMESPACE]", strNameSpace)
    strError = Replace(strError, "[ENUMTYPE]", strEnumTypeName)
    strError = Replace(strError, "[LANGUAGE]", strLanguage)
    
    TRACE strError, , , LOG_ERROR

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "LoadEnumTypeData", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetLocalizedString
' DESCRIPTION   : Returns the localization of a FQN (Fully Qualified Name)
' PARAMETERS    :
' RETURNS       :
Public Function GetLocalizedString(ByVal strLanguage As String, ByVal strFQN As String, ByRef varLocalizedString As Variant) As Boolean
    
    Dim objLocaleTranslator         As COMLocaleTranslator
    Dim strError                    As String
    Dim objError                    As New CError
    
    
    On Error GoTo ErrMgr
   
    varLocalizedString = Empty
    Set objLocaleTranslator = LocaleTranslatorObject()
    objLocaleTranslator.Init strLanguage ' initialize the locale translator object
    objLocaleTranslator.LanguageCode = strLanguage ' put the language code
    varLocalizedString = objLocaleTranslator.GetLocalizedString(strFQN)
    
    If (Len(varLocalizedString) = 0) Then ' Log a warning
    
        strError = MTMSIX_ERROR_01036
        strError = Replace(strError, "[FQN]", strFQN)
        strError = Replace(strError, "[LANGUAGE]", strLanguage)
        TRACE strError, "MSIXTools.cls", "GetLocalizedString", LOG_DEBUG
        varLocalizedString = Empty
    End If
    GetLocalizedString = CBool(Len(varLocalizedString))
    Exit Function

ErrMgr:
    TRACE MTMSIX_ERROR_01033 & " " & GetVBErrorString(), "MSIXTools.cls", "GetLocalizedString", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ExecSQL
' DESCRIPTION   : Execute a SQL query through a MTSQLRowset.
' PARAMETERS    :
'                  strQueryDir      - Define a relativ path from the Config folder.
'                  strQueryTag      - The QueryTag Name
'                  objMTSQLRowset   - The rowset object that will be populated, must be allocated
'                  SQLParam         - Optional because it a ParamArray allow to define the parameter of the query tag.
'                                     Syntax : ExecSQL "queries\ops\sql","__GET_MAPPING__",objRowSet ,   "ACCOUNT_ID",123,"NAME_SPACE","mt"
' RETURNS       :
Public Function ExecSQL(ByVal strQueryDir As String, ByVal strQueryTag As String, ByVal objMTSQLRowset As MTSQLRowset, ParamArray SQLParam() As Variant) As Boolean

    On Error GoTo ErrMgr

    Dim objProfiler             As New CProfiler
    Dim i                       As Long
    
    objProfiler.Start MTMSIX_PROFILER_ON, "MSIXTools.cls", "ExecSQL", "Query=" & strQueryTag
    
    ''Debug.Assert 0
    
    objMTSQLRowset.Init strQueryDir
    objMTSQLRowset.SetQueryTag strQueryTag
    
    For i = 0 To UBound(SQLParam) Step 2
    
        objMTSQLRowset.AddParam "%%" & SQLParam(i) & "%%", "" & SQLParam(i + 1)
    Next
    
    objMTSQLRowset.Execute
    
    ''Debug.Print MTSQLRowSetToString(objMTSQLRowset, True)
    
    ExecSQL = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "ExecSQL", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : DataAccessorObject
' DESCRIPTION   : Returns the DataAccessor instance of the class.
' PARAMETERS    :
' RETURNS       :
Public Property Get DataAccessorObject() As COMDBOBJECTSLib.COMDataAccessor

    On Error GoTo ErrMgr


    If (Not IsValidObject(m_objDataAccessor)) Then
    
'        If Cache.Exist("DataAccessorObject") Then
'            Set m_objDataAccessor = Cache.Item("DataAccessorObject").Data
'        Else
            Set m_objDataAccessor = New COMDBOBJECTSLib.COMDataAccessor
'            Cache.Add "DataAccessorObject", m_objDataAccessor
'        End If
    End If
    Set DataAccessorObject = m_objDataAccessor

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "DataAccessorObject", LOG_ERROR
End Property


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get PVNameIdLookUpObject() As NAMEIDLib.MTNameID

    On Error GoTo ErrMgr


    If (Not IsValidObject(m_objPVNameIdLookup)) Then
    
'        If Cache.Exist("PVNameIdLookUpObject") Then
'            Set m_objPVNameIdLookup = Cache.Item("PVNameIdLookUpObject").Data
'        Else
            Set m_objPVNameIdLookup = New NAMEIDLib.MTNameID
'            Cache.Add "PVNameIdLookUpObject", m_objPVNameIdLookup
'        End If
    End If
    Set PVNameIdLookUpObject = m_objPVNameIdLookup

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "PVNameIdLookUpObject", LOG_ERROR
End Property


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get LocaleTranslatorObject() As COMDBOBJECTSLib.COMLocaleTranslator

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_objLocaleTranslator)) Then
        
        Set m_objLocaleTranslator = New COMDBOBJECTSLib.COMLocaleTranslator
    End If
    Set LocaleTranslatorObject = m_objLocaleTranslator

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "LocaleTranslatorObject", LOG_ERROR
End Property


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Find
' DESCRIPTION   : Select the first row that match the names/values contained in NameValues.
'                 Syntax:
'                   <code>UIf(objMyRowset.Find("AccountID",123,"ContactType",1))Then</code>
'                 This function apply a AND only operator between the variables.
' PARAMETERS    :
'                   objMTSQLRowset - MTSQLRowset or any compatible interface COM object.
'                   NamesValues    - A Visual Basic ParamArray listing names,values.
' RETURNS       :
Public Function RowSetQuickFind(ByVal objMTSQLRowset As Variant, ParamArray NamesValues() As Variant) As Boolean

    On Error GoTo ErrMgr

    Dim i           As Long
    Dim booExp      As Boolean
    Dim arrNamesValues As Variant
    
    ' When passing a ParamArray to another param array we are losing it. this
    ' solve the problem.
    If (UCase$(TypeName(NamesValues(0))) = "VARIANT()") Then
        arrNamesValues = NamesValues(0)
    Else
        arrNamesValues = NamesValues
    End If

    If (Not IsValidObject(objMTSQLRowset)) Then Exit Function
    
    If (objMTSQLRowset.RecordCount) Then objMTSQLRowset.MoveFirst
    
    Do While Not objMTSQLRowset.EOF()

        booExp = False
        For i = 0 To UBound(arrNamesValues) Step 2

            If (CStr(objMTSQLRowset.Value(CStr(arrNamesValues(i)))) = CStr(arrNamesValues(i + 1))) Then
            
                booExp = True
            Else
                booExp = False
                Exit For ' Perform a AND only
            End If
        Next

        If (booExp) Then
    
            RowSetQuickFind = True
            Exit Function
        End If
        objMTSQLRowset.MoveNext
    Loop
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "RowSetQuickFind", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
'                 3.5 - This function is back because we know now that we need to decode a 1999-01-01T02:00:00Z date
'                 When the data come from an msix def file. THIS IS THE ONLY CASE. The reformating of the date
'                 could be a problem...
'
'
'                 3.0 - This function has been deprecated because the part that was use was the CDate() and the parsing and re formating of
'                 the date was never used and the reformatting of the date pose problem because we hard code the / and format
'                 Fred MDM 3.0
'
'
'
' PARAMETERS    :
' RETURNS       :

Public Function UMTDateToCDate(ByVal varUMTDate As Variant) As Date

    Dim objParser   As New CByteSyntaxAnalyser
    Dim lngYear     As Long
    Dim lngMonth    As Long
    Dim lngDay      As Long
    Dim lngHour     As Long
    Dim lngMinute   As Long
    Dim lngSecond   As Long
    Dim strS        As String

    On Error GoTo ErrMgr

    If (VarType(varUMTDate) = vbDate) Then

        UMTDateToCDate = CDate(varUMTDate)
    Else

        varUMTDate = CStr(varUMTDate)
        If (Right(varUMTDate, 1) = "Z") Then

            objParser.Init CStr(varUMTDate) '1999-1-1T02:00:00Z

            If (objParser.GetInteger(lngYear, False) = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetChar("-") = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetInteger(lngMonth, False) = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetChar("-") = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetInteger(lngDay, False) = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetChar("T") = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetInteger(lngHour, False) = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetChar(":") = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetInteger(lngMinute, False) = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetChar(":") = rFAILED) Then GoTo ParsingFailed
            If (objParser.GetInteger(lngSecond, False) = rFAILED) Then GoTo ParsingFailed

            strS = Format(lngMonth, "00") & "/" & Format(lngDay, "00") & "/" & Format(lngYear, "0000") & " " & Format(lngHour, "00") & ":" & Format(lngMinute, "00") & ":" & Format(lngSecond, "00")
            UMTDateToCDate = CDate(strS)
        Else

            UMTDateToCDate = CDate(varUMTDate) ' This guy is going to raise an error
        End If
    End If
    Exit Function
ParsingFailed:
    strS = Replace(MTMSIX_ERROR_01039, "[DATE]", CStr(varUMTDate))
    TRACE Replace(MTMSIX_ERROR_01039, "[DATE]", CStr(varUMTDate)), "MSIXTools.cls", "UMTDateToCDate", LOG_ERROR
    RaiseError strS, , , LOG_APPLICATION_ERROR
ErrMgr:
    strS = GetVBErrorString
    strS = Replace(MTMSIX_ERROR_01039, "[DATE]", CStr(varUMTDate)) & " " & strS
    TRACE strS, "MSIXTools.cls", "UMTDateToCDate", LOG_ERROR
    RaiseError strS, , , LOG_APPLICATION_ERROR
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Cache
' DESCRIPTION   : If the cache is not set, returns a new temporary one. It is very important
'                 to understand that this new cache is just here, to allow the different classes
'                 to use the cache property even if the main client app did not set one. But since the new
'                 temporary cache is deleted just after it is used! There is no cache!
'                 A global cache can be set with the property cache!
'
' PARAMETERS    :
' RETURNS       :
Public Property Get Cache() As MSIXCache

    On Error GoTo ErrMgr


    If (IsValidObject(m_objMSIXCache)) Then
    
        Set Cache = m_objMSIXCache ' Return the global cache
    Else
        Set Cache = New MSIXCache ' Create a new use less one
    End If

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "Cache", LOG_ERROR
End Property

Public Property Set Cache(objCache As MSIXCache)

    On Error GoTo ErrMgr


    Set m_objMSIXCache = objCache

    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "Cache", LOG_ERROR
End Property


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function Format(vExpression As Variant, vFormat As Variant, Optional firstdayofweek As VbDayOfWeek = vbSunday, Optional firstweekofyear As VbFirstWeekOfYear = vbFirstJan1) As Variant

    On Error GoTo ErrMgr

      Select Case VarType(vFormat)
        Case vbString
          Format = VBA.Format(vExpression, vFormat, firstdayofweek, firstweekofyear)
        
        Case Else
          
          'Dictionary was passed in to get Format strings
          'specifically to support decimal localization at the end of 3.6
          Dim dict As Dictionary
          Set dict = vFormat
          Select Case VarType(vExpression)
            Case vbDecimal
                  vExpression = VBA.Format(vExpression, dict.Item("AMOUNT_FORMAT").Value)
                  vExpression = Replace(CStr(vExpression), ".", dict.Item("DECIMAL_SEPARATOR").Value)
                  Format = vExpression
            Case Else
                Format = MTXServiceModule.FormatDataLocalized(vExpression, dict)
          End Select
     
     End Select

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "Format", LOG_ERROR
End Function


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LoadEnumTypeData
' PARAMETERS    :
' DESCRIPTION   : Load a Localized enum type into objVariables (CVariables). DOE NOT Support the cache object!
' RETURN        :
Public Function LoadLocalizedEnumTypeData(objVariables As CVariables, strLanguage As String, ByVal strNameSpace As String, ByVal strEnumTypeName As String) As Boolean
          
    Dim myDataAccessor              'As New COMDataAccessor
    Dim myLocaleTranslator          'As New COMLocaleTranslator
    Dim objLocalizedEnumTypeRowSet  'As
    Dim strError                    As String
    Dim objError                    As New CError
    Dim strEnumTypeFQN              As String
        
    Set objVariables = New CVariables
    
    LocaleTranslatorObject.Init strLanguage             ' initialize the locale translator object
    LocaleTranslatorObject.LanguageCode = strLanguage   ' put the language code
    
    On Error Resume Next
    Set objLocalizedEnumTypeRowSet = LocaleTranslatorObject.GetLocaleListForEnumTypes(strLanguage, strNameSpace, strEnumTypeName)
    If (Err.Number) Then
    
        objError.Save Err.Number, Err.Description, Err.Source, , "MSIXEnumType.cls", "LoadEnumTypeData"
        Err.Clear
        On Error GoTo 0
                
        strError = MTMSIX_ERROR_01023
        strError = Replace(strError, "[NAMESPACE]", strNameSpace)
        strError = Replace(strError, "[ENUMTYPE]", strEnumTypeName)
        strError = Replace(strError, "[LANGUAGE]", strLanguage)
        objError.UserMessage = strError
        TRACE objError.ToString, , , LOG_ERROR
        
    Else
        On Error GoTo 0
        
        If (Len(Trim(objLocalizedEnumTypeRowSet.Value(CLng(0)))) = 0) Then
            ' Fail because of boris...
            Exit Function
        End If
        
        Do While Not objLocalizedEnumTypeRowSet.EOF
        
            objVariables.Add objLocalizedEnumTypeRowSet.Value(CLng(0)), objLocalizedEnumTypeRowSet.Value(CLng(1))
            objLocalizedEnumTypeRowSet.MoveNext
        Loop
        
        LoadLocalizedEnumTypeData = True
    End If
    
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : BooleanValue
' DESCRIPTION   : Knows how to convert : TRUE, FALSE, T, F, Y, N into a boolean
' PARAMETERS    :
' RETURNS       : A Boolean
Public Function BooleanValue(ByVal varValue As Variant) As Boolean

    On Error GoTo ErrMgr


    ' Numeric boolean
    If (IsNumeric(varValue)) Then
        BooleanValue = Not (varValue = 0)
        Exit Function
    End If

    ' String boolean
    Select Case UCase$("" & varValue) ' Support NULL, NULL is false
    
        Case MSIXDEF_TYPE_BOOLEAN_TRUE, "Y", "TRUE", "ON": BooleanValue = True
        Case MSIXDEF_TYPE_BOOLEAN_FALSE, "N", "FALSE", "": BooleanValue = False
        Case "EOF()": BooleanValue = False ' support EOF() to avoid some function to crash when they try to convert EOF() into a boolean...
        Case Else
            RaiseError MTMSIX_ERROR_01024, "value=" & varValue, , LOG_APPLICATION_ERROR
    End Select

    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "BooleanValue", LOG_ERROR
End Function


' --------------------------------------------------------------------------------
' FUNCTION      : GetLocalizedEnumType
' PARAMETERS    :
'                  strLanguage  - The language
'                  strNameSpace - The name Space
'                  strName      - The enum type name
'                  objEntries   - The Output parameter, just a simple variant
'                  objCache     - If a MSIXCache object is defined at the application scope you can use it to speed the function.
' DESCRIPTION   : Returns in the Variant entries the localized enum type in a CVariables object (name/value collection).
' RETURNS       : A Boolean
Public Function GetLocalizedEnumType(ByVal strLanguage As String, ByVal strNameSpace As String, ByVal strName As String, ByRef objEntries As Variant, Optional ByVal objCache As MSIXCache) As Boolean

    On Error GoTo ErrMgr


    Dim objService As New MSIXHandler
    Const TmpPropertyName = "TmpProperty"
    
    If (objService.Initialize(, , strLanguage, , , objCache)) Then
        
        If IsValidObject(objService.Properties.Add(TmpPropertyName, MSIXDEF_TYPE_ENUM, 0, False, Empty, eMSIX_PROPERTY_FLAG_NONE, strNameSpace, strName)) Then
        
            Set objEntries = objService.Properties(TmpPropertyName).EnumType.Entries
            GetLocalizedEnumType = True
        End If
    End If

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetLocalizedEnumType", "MSIXTools.cls", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetMSIXDEFFullPathAndFileName
' PARAMETERS    :
' DESCRIPTION   : Returns the full path + file name using Concurent Development convention. If the function fails or no file is found
'                 the function log all the detail and
' RETURN        :
Public Function GetRCDFullPathAndFileName(ByVal strQueryStartFolder As String, ByVal strQueryFileName As String, ByRef strFullPathAndFileName As String, ByVal strExtensionFolderName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim objRCDFiles     As RCDLib.MTRcdFileList
    Dim strRCDQuery     As String
    Dim objRCD          As RCDLib.MTRcd
    Dim v               As Variant
    
    Set objRCD = RCDObject()
    strRCDQuery = strQueryStartFolder & "\" & strQueryFileName
    
    If Len(strExtensionFolderName) Then

        Set objRCDFiles = objRCD.RunQueryInAlternateFolder(strRCDQuery, True, objRCD.ExtensionDir & "\" & strExtensionFolderName)
    Else
        Set objRCDFiles = objRCD.RunQuery(strRCDQuery, True)
    End If
        
    If (IsValidObject(objRCDFiles)) Then
    
        If (objRCDFiles.Count = 1) Then
        
            strFullPathAndFileName = objRCDFiles.Item(0)
            GetRCDFullPathAndFileName = True
            
        ElseIf (objRCDFiles.Count > 1) Then ' If we have more that one file try to find the one that match the query...
 
            For Each v In objRCDFiles
            
                If LCase$(Mid(v, Len(v) - Len(strQueryFileName) + 1)) = LCase$(strQueryFileName) Then
                
                    strFullPathAndFileName = v
                    GetRCDFullPathAndFileName = True
                    Exit Function
                End If
            Next
            TRACE PreProcess(MTMSIX_ERROR_01051, "STARTFOLDER", strQueryStartFolder, "QUERY", strRCDQuery, "EXTENSION", strExtensionFolderName), "MSIXHandler.cls", "GetMSIXDEFFullPathAndFileName", LOG_ERROR
        Else
            TRACE PreProcess(MTMSIX_ERROR_01052, "STARTFOLDER", strQueryStartFolder, "QUERY", strRCDQuery, "EXTENSION", strExtensionFolderName), "MSIXHandler.cls", "GetMSIXDEFFullPathAndFileName", LOG_ERROR
        End If
    Else
        TRACE MTMSIX_ERROR_01051, "MSIXHandler.cls", "GetRCDFullPathAndFileName", LOG_ERROR
    End If

'    Set objRCDFiles = objRCD.RunQuery(strRCDQuery, True)
'
'        If (IsValidObject(objRCDFiles)) Then
'
'            If (objRCDFiles.Count) Then
'
'                strFullPathAndFileName = objRCDFiles.Item(0)
'                GetRCDFullPathAndFileName = True
'            Else
'                TRACE Replace(MTMSIX_ERROR_01052, "[QUERY]", strRCDQuery), "MSIXHandler.cls", "GetMSIXDEFFullPathAndFileName", LOG_ERROR
'            End If
'        Else
'            TRACE MTMSIX_ERROR_01051, "MSIXHandler.cls", "GetRCDFullPathAndFileName", LOG_ERROR
'        End If

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetRCDFullPathAndFileName", "MSIXTools.cls", LOG_ERROR
End Function



Public Function GetMSIXDEFFullPathName(ByRef strXMLFileName As String, Optional strServiceProductViewFolder As String = "service", Optional strExtension As String) As Boolean

    On Error GoTo ErrMgr


    Dim objTextFile As New cTextFile

    GetMSIXDEFFullPathName = False
    
    If (objTextFile.ExistFile(strXMLFileName)) Then
            
    Else

        If (GetRCDFullPathAndFileName("config\" & strServiceProductViewFolder, strXMLFileName, strXMLFileName, strExtension)) Then
        
            GetMSIXDEFFullPathName = True
        Else
            TRACE Replace(MTMSIX_ERROR_01054, "[FILE]", strXMLFileName), "MSIXTools.cls", "GetMSIXDEFFullPathName", LOG_ERROR
        End If
    End If

    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetMSIXDEFFullPathName", "MSIXTools.cls", LOG_ERROR
End Function



' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GeneratePassword
' PARAMETERS    : PasswordLength as optional long, LowerCaseOnly as optional boolean
' DESCRIPTION   : Returns a random password
' RETURN        : password as string
Public Function GeneratePassword(Optional ByVal PasswordLength As Long = PASSWORD_LENGTH, Optional ByVal LowerCaseOnly As Boolean = False) As String
    Dim Count As Long
    Dim randomNumber As Long

    GeneratePassword = ""
    Count = 0
    Randomize
    
    While Count < PasswordLength
    
        randomNumber = (Rnd * 1000) Mod 128
        
        If ((randomNumber >= 48) And (randomNumber <= 57)) Or _
           ((randomNumber >= 65) And (randomNumber <= 90)) Or _
           ((randomNumber >= 97) And (randomNumber <= 122)) Then
           
           Count = Count + 1
           GeneratePassword = GeneratePassword & Chr$(randomNumber)
        End If
    Wend
    
    If (LowerCaseOnly) Then
    
      GeneratePassword = LCase$(GeneratePassword)
    End If
    Exit Function
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetMSIXDEFFullPathName", "MSIXTools.cls", LOG_ERROR
End Function

' useless
Public Function ProcessHTMLSpecialChars_(ByVal strS As String) As String

    On Error GoTo ErrMgr
    
'    strS = Replace(strS, "&", "&amp;")
'    strS = Replace(strS, "<", "&lt;")
'    strS = Replace(strS, """", "&rdquo;")
'    strS = Replace(strS, "'", "&rsquo;")
'    strS = Replace(strS, ">", "&gt;")
'    strS = Replace(strS, "|", "&brvbar;")
    
    ProcessHTMLSpecialChars_ = strS
    
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "ProcessHTMLSpecialChars", "MSIXTools.cls", LOG_ERROR
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : GetEnumValueByID
' DESCRIPTION   : Get Enum value from ID
' PARAMETERS    :
' RETURNS       :
Public Function GetEnumValueByID(ByVal nID As Long) As String
    Dim objEnumTypeconfig As New EnumConfig
    
    On Error GoTo ErrMgr
    
    GetEnumValueByID = objEnumTypeconfig.GetEnumeratorValueByID(nID)
    
    Exit Function
    
    
ErrMgr:
If Err.Number = -2147467261 Then
    Dim strError
    strError = Replace(MTMSIX_ERROR_01082, "[VALUE]", CStr(nID))
    TRACE strError & GetVBErrorString(), "GetEnumValueByID", "MSIXTools.cls", LOG_DEBUG
    GetEnumValueByID = "0"
Else
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetEnumValueByID", "MSIXTools.cls", LOG_ERROR
End If
End Function


' --------------------------------------------------------------------------------
' FUNCTION      : GetEnumValueByFQN
' DESCRIPTION   : Get Enum value from FQN
' PARAMETERS    :
' RETURNS       :
Public Function GetEnumValueByFQN(ByVal FQN As String) As String
    Dim objEnumTypeconfig As New EnumConfig
    Dim objNameID As New NAMEIDLib.MTNameID
    Dim strFQN As String
    
    On Error GoTo ErrMgr
    
    GetEnumValueByFQN = objEnumTypeconfig.GetEnumeratorValueByID(objNameID.GetNameID(FQN))

    Exit Function
    

ErrMgr:
If Err.Number = -2147024809 Then
    Dim strError
    strError = Replace(MTMSIX_ERROR_01082, "[VALUE]", FQN)
    TRACE strError & GetVBErrorString(), "GetEnumValueByFQN", "MSIXTools.cls", LOG_DEBUG
    GetEnumValueByFQN = "0"
Else
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetEnumValueByFQN", "MSIXTools.cls", LOG_ERROR
End If
End Function


' --------------------------------------------------------------------------------
' FUNCTION      : GetEnumIDFromValue
' DESCRIPTION   : Get enum ID from value
' PARAMETERS    :
' RETURNS       :
Public Function GetEnumIDFromValue(ByVal strSpace As String, ByVal strType As String, ByVal strValue As String) As Long
    Dim objEnumTypeconfig As New EnumConfig
    Dim objNameID As New NAMEIDLib.MTNameID
    Dim strFQN As String
    
    strFQN = objEnumTypeconfig.GetFQN(strSpace, strType, strValue)
    GetEnumIDFromValue = objNameID.GetNameID(strFQN)
End Function
    

' --------------------------------------------------------------------------------
' FUNCTION      : CallByName
' DESCRIPTION   : Export the Visual Basic function Property CallByName, so it become available
'                 in VBScript.
' PARAMETERS    :
' RETURNS       :
Public Property Get CallByName(objObject As Variant, strPropertyName As Variant) As Variant
    CallByName = VBA.CallByName(objObject, strPropertyName, VbGet)
End Property


' --------------------------------------------------------------------------------
' FUNCTION      : CallByName
' DESCRIPTION   : See property Get.
' PARAMETERS    :
' RETURNS       :
Public Property Let CallByName(objObject As Variant, strPropertyName As Variant, ByVal vNewValue As Variant)
    VBA.CallByName(objObject, strPropertyName, VbLet) = vNewValue
End Property


' --------------------------------------------------------------------------------
' FUNCTION      : StringConvertUniCode2Big5
' DESCRIPTION   : For asian text, convert the strUniCode string into a big5 string, so HTML browser can print the string.
'                 The MTMSIX.Unicode2Big5Translater instance is created and stored in the cache object. When the object
'                 is created it load the file MDM\Internal\Unicode2big5.xml.
' PARAMETERS    :
' RETURNS       : A Boolean
Public Function StringConvertUniCode2Big5(ByVal strUniCode As String) As String
    
    On Error GoTo ErrMgr
    
    If (m_objUnicode2Big5Translater Is Nothing) Then
    
        If (Cache.Exist("Unicode2Big5Translater")) Then ' Get the object from the cache
            
            Set m_objUnicode2Big5Translater = Cache(MDM_UNICODE_2_BIG5_TRANSLATER_CACHE_NAME).Data
            StringConvertUniCode2Big5 = m_objUnicode2Big5Translater.UnitCode2Big5(strUniCode)
        Else
            ' Create the Unicode2Big5Translater, load the unicode to big5 table and store this object in the cache...
            Set m_objUnicode2Big5Translater = New Unicode2Big5Translater
            m_objUnicode2Big5Translater.Initialize GetUnicode2Big5FileName()
            Cache.Add "Unicode2Big5Translater", m_objUnicode2Big5Translater
        End If
    End If
    
    If (InStr(UCase$(strUniCode), "(CN)")) Or (InStr(UCase$(strUniCode), "{NL}")) Then    ' MetraTech convetion to tell the string is not translated in chinese yet, or not localized at all
    
        StringConvertUniCode2Big5 = strUniCode
    Else
        StringConvertUniCode2Big5 = m_objUnicode2Big5Translater.UnitCode2Big5(strUniCode)
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "StringConvertUniCode2Big5", "MSIXTools.cls", LOG_ERROR
End Function

Private Function GetUnicode2Big5FileName() As String

    If (IsValidObject(Cache)) Then
    
        If (Cache.Exist("MDM_FOLDER")) Then
        
            GetUnicode2Big5FileName = Cache("MDM_FOLDER") & MSIX_BIG5_MDM_RELATIVE_PATH_AND_NAME
        End If
    End If
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : EnumConfigLookUpObject
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get EnumConfigLookUpObject() As MTENUMCONFIGLib.EnumConfig

    On Error GoTo ErrMgr
    
    Dim objPVNameIdLookup As MTENUMCONFIGLib.EnumConfig

    If Cache.Exist("EnumConfigLookUpObject") Then
    
        Set objPVNameIdLookup = Cache.Item("EnumConfigLookUpObject").Data
    Else
    
        Set objPVNameIdLookup = New MTENUMCONFIGLib.EnumConfig
        Cache.Add "EnumConfigLookUpObject", objPVNameIdLookup
    End If
    Set EnumConfigLookUpObject = objPVNameIdLookup
    Exit Property
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "EnumConfigLookUpObject", LOG_ERROR
End Property


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : EnumConfigLookUpObject
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Property Get RCDObject() As RCDLib.MTRcd

    On Error GoTo ErrMgr
    
    Dim objRCD  As RCDLib.MTRcd

    If Cache.Exist("RCDbject") Then
    
        Set objRCD = Cache.Item("RCDbject").Data
    Else
    
        Set objRCD = New RCDLib.MTRcd
        Cache.Add "RCDbject", objRCD
    End If
    Set RCDObject = objRCD
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "RCDObject", LOG_ERROR
End Property



' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : EnumConfigLookUpObject
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function IsPaymentServerMachine() As Boolean

    On Error GoTo ErrMgr
    
    Dim objMTServerAccessData As MTServerAccessData
    Dim objWinApi             As New cWindows
    Dim strComputerName       As String
    Dim strError              As String
    
    Set objMTServerAccessData = GetMTServer(DEFAULT_PAYMENT_SERVER_NAME)
    
    If (Not IsValidObject(objMTServerAccessData)) Then Exit Function
    
    strComputerName = UCase$(objWinApi.ComputerName)
    
    strError = Replace(MTMSIX_ERROR_01076, "[PAYMENTSERVERNAME]", objMTServerAccessData.ServerName) ' Log a debug string
    strError = Replace(strError, "[COMPUTERNAME]", strComputerName)
    TRACE strError, "MSIXTools.cls", "IsPaymentServerMachine", LOG_DEBUG
    
    If (objMTServerAccessData.ServerName = "127.0.0.1") Or (UCase$(objMTServerAccessData.ServerName) = "LOCALHOST") Then
    
        IsPaymentServerMachine = True
        Exit Function
    End If
    
    If (UCase$(objMTServerAccessData.ServerName) = strComputerName) Then
    
        IsPaymentServerMachine = True
        Exit Function
    End If
    
    strError = Replace(MTMSIX_ERROR_01075, "[PAYMENTSERVERNAME]", objMTServerAccessData.ServerName)
    strError = Replace(strError, "[COMPUTER]", strComputerName)
    TRACE strError, "MSIXTools.cls", "IsPaymentServerMachine", LOG_DEBUG
    
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "IsPaymentServerMachine", LOG_ERROR
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function GetMTServer(ByVal strServerName As String) As MTServerAccessData

    On Error GoTo ErrMgr

    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData
    
    objServerAccessSet.Initialize
    
    On Error Resume Next
    Set GetMTServer = objServerAccessSet.FindAndReturnObject(strServerName)
    On Error GoTo 0
    
    Set objServerAccessSet = Nothing

    Exit Function
ErrMgr:
    Set GetMTServer = Nothing
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "GetMTServer", LOG_ERROR
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsPayementServerInstalled
' DESCRIPTION   : Returns TRUE is the payment server is installed. The method used is to read the the config\server\serveraccess.xml file and check
'                 for the paymentServer server name!
' PARAMETERS    :
' RETURNS       :
Public Function IsPayementServerInstalled(Optional ByVal strServerName As String = DEFAULT_PAYMENT_SERVER_NAME) As Boolean

    On Error GoTo ErrMgr

    Dim objMTServerAccessData As MTServerAccessData
    
    Set objMTServerAccessData = GetMTServer(strServerName)
    
    IsPayementServerInstalled = IsValidObject(objMTServerAccessData)
    
    Exit Function

ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "IsPayementServerInstalled", LOG_ERROR
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : GetMTErrorMessage
' PARAMETERS    :
' DESCRIPTION   : Return the Metratech Error message for the error. The function returns TRUE is a message was found.
' RETURN        :
Public Function GetMTErrorMessage(ByVal lngError As Long, ByRef strErrorMessage As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim objRCD As New RCDLib.MTRcd
        
    'Set objRCD = RCDObject()
        
    strErrorMessage = objRCD.ErrorMessage(lngError)
    GetMTErrorMessage = Len(strErrorMessage)
    
    Exit Function
ErrMgr:
    TRACE Replace(MTMSIX_ERROR_01080, "[ERROR]", CStr(lngError)) & GetVBErrorString(), "GetMTErrorMessage", "MSIXTools.cls", LOG_WARNING
End Function

' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : IsValidDecimal
' PARAMETERS    :
'                   lngPrecision - The decimal scale.
'                   lngScale - the decimal precision.
'                   strDecimalSeparator - The decimal separator.
'                   strThousandSeparator - The thousand separator.
'
' DESCRIPTION   : Returns TRUE if varDecValue is a valid decimal value according to lngPrecision and lngScale. MetraTech uses only
'                 decimal(22,10). (22,10) means 12 digits before the decimal separator and 10 digits after the decimal separator.
' RETURN        :
Public Function IsValidDecimal(ByVal varDecValue As Variant, Optional ByVal lngPrecision As Long = 22, Optional ByVal lngScale As Long = 10, Optional ByVal strDecimalSeparator As String = ".", Optional ByVal strThousandSeparator As String = ",") As Boolean

    Dim strDecValue         As String
    Dim lngDecSeparatorPos  As Long
       
    On Error GoTo ErrMgr
        
    
    strDecValue = varDecValue
    strDecValue = Replace(strDecValue, strThousandSeparator, "") ' Remove the thousand separator...
    
    IsValidDecimal = False
    
    lngDecSeparatorPos = InStr(strDecValue, strDecimalSeparator)
    
    If (lngDecSeparatorPos) Then ' If we have a decimal separator
    
        If (lngDecSeparatorPos - 1 <= lngPrecision - lngScale) Then ' Test the number of digits before the .
            
            If (Len(strDecValue) - lngDecSeparatorPos <= lngScale) Then ' Test the number of digits after the .
            
                IsValidDecimal = True
            End If
        End If
    Else
        If (Len(strDecValue) <= lngPrecision - lngScale) Then ' Test the number of digits before the .
        
            IsValidDecimal = True
        End If
    End If
Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "IsValidDecimal", LOG_ERROR
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Environ
' DESCRIPTION   : Return the value of an environment variable.
' PARAMETERS    :
'                   varEnvironmentVariable - Name of the environment variable.
' RETURNS       :
Public Function Environ(ByVal varEnvironmentVariable As Variant) As String
    Environ = VBA.Environ$(varEnvironmentVariable)
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : RowSetToXML
' DESCRIPTION   : Return the value of an environment variable.
' PARAMETERS    :
'                   varEnvironmentVariable - Name of the environment variable.
' RETURNS       :
' VERSION       : MDM V2
Public Function RowSetToXML(ByVal objRowset As Variant, Optional ByVal strId As String) As String

    On Error GoTo ErrMgr
    
    Dim objConcat   As New cStringConcat
    Dim i           As Long
    Dim lngRowCount As Long
    
'    'Debug.Assert 0
    objConcat.Init 64000
    
    If (objRowset.RecordCount) Then
        objRowset.MoveFirst
    End If
    
    If Len(strId) Then
        objConcat.Concat PreProcess("<rowset id='[ID]'>", "ID", strId) & vbNewLine
    Else
        objConcat.Concat "<rowset>" & vbNewLine
    End If
    
    objConcat.Concat "  <columns type='collection'>" & vbNewLine
    
    For i = 0 To objRowset.Count - 1
    
        objConcat.Concat PreProcess("    <column id='[COLNAME]'><type>[TYPE]</type></column>", "COLNAME", objRowset.Name(CLng(i)), "TYPE", objRowset.Type(CLng(i))) & vbNewLine
    Next
    objConcat.Concat "  </columns>" & vbNewLine
    objConcat.Concat "  <rows>" & vbNewLine
    
    Do While Not objRowset.EOF()
    
        objConcat.Concat PreProcess("    <rows id='[INDEX]'>", "INDEX", lngRowCount) & vbNewLine
        
        For i = 0 To objRowset.Count - 1
        
            objConcat.Concat PreProcess("    <columns id='[INDEX]'><value>[VALUE]</value></columns>", "VALUE", objRowset.Value(CLng(i)), "INDEX", i) & vbNewLine
        Next
        objConcat.Concat PreProcess("    </rows>") & vbNewLine
        objRowset.MoveNext
    Loop
    objConcat.Concat "  </rows>" & vbNewLine
    objConcat.Concat "</rowset>" & vbNewLine
    RowSetToXML = objConcat.GetString()
Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "RowSetToXML", LOG_ERROR
End Function


' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : PreProcess
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
' VERSION       : MDM V2
Public Function PreProcess(ByVal strMessage As String, ParamArray defines() As Variant) As String

    On Error GoTo ErrMgr
    
    Dim i As Long
    
    For i = 0 To UBound(defines()) Step 2
    
        strMessage = Replace(strMessage, "[" & defines(i) & "]", CStr(defines(i + 1)))
    Next
    PreProcess = strMessage
Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "PreProcess", LOG_ERROR
End Function

' ----------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : VBLike
' DESCRIPTION   : Expose the VBLike operator.
' PARAMETERS    :
' RETURNS       :
' VERSION       : MDM V2
Public Function VBLike(ByVal strString As String, ByVal strPattern As String) As Boolean

     VBLike = UCase$(Trim(strString)) Like UCase(strPattern)
End Function


' ------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function InsertAStringAt(ByVal strSourceString As String, ByVal strInsertString As String, ByVal lngPos As Long) As String

    On Error GoTo ErrMgr

    InsertAStringAt = Mid$(strSourceString, 1, lngPos - 1) & strInsertString & Mid$(strSourceString, lngPos)
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXTools.cls", "InsertAStringAt", LOG_ERROR
End Function


Friend Function MTPropertiesExist(objMTCOMObject As Variant, strName As String) As Boolean

    Dim objProperty As Object
    
    For Each objProperty In objMTCOMObject.Properties
    
        If (UCase$(objProperty.Name) = UCase$(strName)) Then
        
            MTPropertiesExist = True
            Exit Function
        End If
    Next
End Function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ConvertToGMT(ByVal dt As Variant, Optional TimeZoneId As Long = 18) As Variant
 On Error GoTo ErrMgr
    Const cPROCNAME = "ConvertToGMT"
    Dim uc As Object
    
    If IsNull(dt) Or IsEmpty(dt) Or Trim(dt) = "" Then
        TRACE MTMSIX_WARNING_01200, "MSIXTools.cls", "ConvertFromGMT", LOG_WARNING
        Exit Function
    End If

    Set uc = CreateObject("MTUserCalendar.MTUserCalendar.1")
    
    ConvertToGMT = CDate(uc.LocalTimeToGMT(CDate(dt), CLng(TimeZoneId)))
    Exit Function

ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString() & " dt=[" & dt & "] type=" & TypeName(dt), "MSIXTools.cls", "ConvertToGMT", LOG_ERROR

End Function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ConvertFromGMT(ByVal dt As Variant, Optional TimeZoneId As Long = 18) As Variant

 On Error GoTo ErrMgr
    Const cPROCNAME = "ConvertFromGMT"
    Dim uc As Object
    
    If IsNull(dt) Or IsEmpty(dt) Or Trim(dt) = "" Then
        TRACE MTMSIX_WARNING_01200, "MSIXTools.cls", "ConvertFromGMT", LOG_WARNING
        Exit Function
    End If

    Set uc = CreateObject("MTUserCalendar.MTUserCalendar.1")
    
    ConvertFromGMT = CDate(uc.GMTToLocalTime(CDate(dt), CLng(TimeZoneId)))
    Exit Function

ErrMgr:
TRACE MTMSIX_ERROR_01033 & GetVBErrorString() & " dt=[" & dt & "] type=" & TypeName(dt), "MSIXTools.cls", "ConvertFromGMT", LOG_ERROR

End Function

Public Function MakeItUserVisibleMTCOMError(ByVal lngNumber As Long) As Long
    MakeItUserVisibleMTCOMError = MTGlobal_VB_MSG.MakeItUserVisibleMTCOMError(lngNumber)
End Function

Public Function UnMakeItUserVisibleMTCOMError(lngNumber As Long) As Long
    UnMakeItUserVisibleMTCOMError = MTGlobal_VB_MSG.MakeItUserVisibleMTCOMError(lngNumber)
End Function


Public Function GetEnumTypeInternalDBID(ByVal strNameSpace As String, ByVal strName As String, ByVal strValue As String) As Long

    Dim objEnumTypeconfig As Object
    
    Set objEnumTypeconfig = CreateObject("Metratech.MTEnumConfig.1") ' create the object and add it to the cache...
    GetEnumTypeInternalDBID = objEnumTypeconfig.GetID(strNameSpace, strName, strValue)
End Function

Public Function GetEnumTypeEnumeratorFromInternalDBID(ByVal v As Long) As String

    Dim objEnumTypeconfig  As Object
    
    Set objEnumTypeconfig = CreateObject("Metratech.MTEnumConfig.1") ' create the object and add it to the cache...
    GetEnumTypeEnumeratorFromInternalDBID = objEnumTypeconfig.GetEnumeratorValueByID(v)
End Function

 
Public Function SplitTrim(ByVal strCSV As String, ByVal strSeparator As String) As Variant
    Dim arr As Variant
    Dim i   As Long
    arr = Split(strCSV, strSeparator)
    For i = 0 To UBound(arr)
        arr(i) = Trim(arr(i))
    Next
    SplitTrim = arr
End Function

' Support DoubleQuote and trim the values
Public Function SmartSplit(ByVal strCSV As String, ByVal strSeparator As String) As Variant

    Dim Parser          As New CByteSyntaxAnalyser
    Dim TmpCol          As New Collection
    Dim strText         As String
    Dim i               As Long
    Dim StringArray()   As String
    
    Parser.Init strCSV
    Parser.booKillSpaceOnly = True ' TAB is <> char than space
    Do While Parser.EOS <> rTRUE
    
        If Parser.GetChar("""") = rSUCCEED Then
            Parser.lngBytesIndex = Parser.lngBytesIndex - 1
            If Parser.GetString(strText, """") <> rSUCCEED Then Exit Function
        Else
            If Parser.GetUpToChar(strSeparator, strText) <> rSUCCEED Then Exit Function
        End If
        TmpCol.Add Trim(strText)
        If Parser.GetChar(strSeparator) = rFAILED Then Exit Do
    Loop
    ReDim StringArray(TmpCol.Count - 1)
    For i = 1 To TmpCol.Count
        StringArray(i - 1) = TmpCol(i)
    Next
    SmartSplit = StringArray
End Function

Public Function CDecimal(ByVal strValue As String) As Variant
    CDecimal = CDec(strValue)
End Function

Public Function GetObjPtr(ByVal o As Object) As Long
    GetObjPtr = ObjPtr(o)
End Function


'Public Function FormatDataLocalized(ByVal varExp As Variant, ByVal Dic As Dictionary) As String
'    FormatDataLocalized = MTXServiceModule.FormatDataLocalized(varExp, Dic)
'End Function
