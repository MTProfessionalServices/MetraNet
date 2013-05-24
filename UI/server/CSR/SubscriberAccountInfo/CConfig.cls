VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Config"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  CLASS        : CPipeLineAccess
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
'**************************************************************************
Option Explicit


Const DEFAULT_PAYMENT_SERVER_NAME = "paymentServer"

' This object is used by the function getMTConfigDir().
' The first time the function is called the object is created and remain
' alive until the class is alive... Because I keep the instance at this level
' we will be able to delete the instance at any moment. If we need it in the future...
Private m_objPipeLine  As PIPELINECONTROLLib.MTPipeline

' ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :   getMTConfigDir
' DESCRIPTION   :   Return the config path. Version 1 used the registry. Version 2 use a componant function call.
' RETURN        :   A String
' VERSION       :   2
'
Public Function getMTConfigDir() As String

'   Old Code for version 1
'
'    Dim objRegistry As New cRegistry
'    If (objRegistry.openSection(objRegistry.HKEY_LOCAL_MACHINE, "software\MetraTech\NetMeter", KEY_READ)) Then
'        getMTConfigDir = objRegistry.getSubVar("ConfigDir")
'    End If
   
    Dim strS            As String
    
    If (m_objPipeLine Is Nothing) Then
    
        Set m_objPipeLine = New PIPELINECONTROLLib.MTPipeline
        'Set m_objPipeLine = CreateObject("MetraPipeline.MTPipeline.1")
    End If
    strS = m_objPipeLine.ConfigurationDirectory
    
    ' The function add a slash at the end. So I remove it because it was part ot the version 1
    If (Right(strS, 1) = "\") Then
    
        strS = Mid(strS, 1, Len(strS) - 1)
    End If
    getMTConfigDir = strS
    
End Function

Public Function getMTInstallDir() As String
    Dim objRegistry As New cRegistry
    If (objRegistry.openSection(objRegistry.HKEY_LOCAL_MACHINE, "software\MetraTech\Install", KEY_READ)) Then
        getMTInstallDir = objRegistry.getSubVar("InstallDir")
        objRegistry.closeSection
    End If
End Function

Public Function ExistFile(ByVal strFileName As String) As Boolean
    Dim objFile As New cTextFile
    ExistFile = objFile.ExistFile(strFileName)
End Function

'  --------------------------------------------------------------------------------
'   FUNCTION      : getEnumTypes()
'
'   DESCRIPTION   : Return a collection of enum type item (MTENUMCONFIGLib.MTEnumerator),
'                   for the name space strNameSpace and the enum type strEnumTypeName.
'                   The function Name return the name of the enum type item.
'                   Generally a enum type item has one value stored which is supposed to be the unic identifier and
'                   it is a string.
'                   The function NumValues of each item in the collection return the number of values
'                   stored.
'                   To read the value call ElementAt(index).
'
'                   The function is not case sensitive.
'
'                   ATTENTION : All the values are returned in lower case.
'   RETURNS       : A reference to a collection of MTENUMCONFIGLib.MTEnumerator or NOTHING if the numspace or
'                   the enum type is not found. The function may raise an error if the componant cannot be created too.
'
'                 F.Torres - 4/13/00
Function getEnumTypes(strNameSpace, strEnumTypeName) As Object

            
        Dim objEnumTypeConfig   'As MTENUMCONFIGLib.EnumConfig
        Dim objEnumSpace        'As MTENUMCONFIGLib.MTEnumSpace
        Dim objEnumType         'As MTENUMCONFIGLib.MTEnumType
        'Dim objEnumTypeItem     'As MTENUMCONFIGLib.MTEnumerator
        
        Set objEnumTypeConfig = CreateObject("Metratech.MTEnumConfig.1")
        objEnumTypeConfig.Initialize
            
        Set objEnumSpace = objEnumTypeConfig.GetEnumSpace(strNameSpace)
        If (objEnumSpace Is Nothing) Then Exit Function
        
        Set objEnumType = objEnumSpace.GetEnumType(strEnumTypeName)
        If (objEnumType Is Nothing) Then Exit Function
        
        Set getEnumTypes = objEnumType.GetEnumerators ' Return the result
        
        '  For Each objEnumTypeItem In objEnumType.GetEnumerators
        '       Debug.Print objEnumTypeItem.Name & " " & objEnumTypeItem.ElementAt(0)
        '  Next

End Function

'  --------------------------------------------------------------------------------
'   FUNCTION      : getEnumType()
'
'   DESCRIPTION   : Return one item of an enum type (MTENUMCONFIGLib.MTEnumerator) form the NameSpace, EnumType and EnumTypeItem name.
'                 : The object returned has the property Name, ElementAt(Index).
'                   The function is not case sensitive.
'
'   RETURNS       : Nothing if the NameSpace, EnumType or Item is not found or if
'                   an error occurs.
'                 F.Torres - 4/13/00
Function getEnumTypeValue(strNameSpace, strEnumTypeName, strEnumTypeItemName) As String

    Dim objEnum         ' As Object
    Dim objEnumItem     ' As Object
    
    getEnumTypeValue = ""
    Set objEnum = getEnumTypes(strNameSpace, strEnumTypeName)           ' As Object
    
    If (Not objEnum Is Nothing) Then
    
        For Each objEnumItem In objEnum
        
            If (UCase(objEnumItem.Name) = UCase(strEnumTypeItemName)) Then
            
                getEnumTypeValue = objEnumItem.ElementAt(0)
                Exit Function
            End If
        Next
    End If
End Function


' --------------------------------------------------------------------------------
' FUNCTION      : GetGMTTime
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Function GetGMTTime() As String

    Dim usrTime As SYSTEMTIME
   
    ' Call the procedure to load the SYSTEMTIME structure.
    GetSystemTime usrTime

    With usrTime
        GetGMTTime = Format(.Year, "0000") & "-" & Format(.Month, "00") & "-" & Format(.Day, "00") & "T" & Format(.Hour, "00") & ":" & Format(.Minute, "00") & ":" & Format(.Second, "00") & "Z"
    End With
    
End Function

' --------------------------------------------------------------------------------
' FUNCTION      : IsPayementServerInstalled
' DESCRIPTION   :
' PARAMETERS    :
' RETURNS       :
Public Function IsPayementServerInstalled(Optional ByVal strServerName As String = DEFAULT_PAYMENT_SERVER_NAME) As Boolean

    On Error GoTo ErrMgr
    
    Dim objServerAccessSet      As New MTServerAccessDataSet
    Dim objServerAccess         As MTServerAccessData

    objServerAccessSet.Initialize
    Set objServerAccess = objServerAccessSet.FindAndReturnObject(strServerName)
    Set objServerAccessSet = Nothing
    IsPayementServerInstalled = Not objServerAccess Is Nothing
    Exit Function
ErrMgr:

End Function

Private Sub Class_Terminate()
    Set m_objPipeLine = Nothing
End Sub



' --------------------------------------------------------------------------------
' FUNCTION      : getLocalizedEnumTypes
' DESCRIPTION   : MTInMemRowset that contains a localized enum type.
'
' PARAMETERS    :
' RETURNS       :
Function getLocalizedEnumTypes(strLanguage As String, strNameSpace As String, strEnumTypeName As String) As Object
          
    Dim myDataAccessor      'As New COMDataAccessor
    Dim myLocaleTranslator  'As New COMLocaleTranslator
    Dim myRowset            'As New MTInMemRowset
    
    ' create the data accessor com object
    Set myDataAccessor = CreateObject("COMDataAccessor.COMDataAccessor.1")
    Set myRowset = CreateObject("MTInMemRowset.MTInMemRowset.1")
         
    ' get the locale translator object
    Set myLocaleTranslator = myDataAccessor.GetLocaleTranslator
    
    ' initialize the locale translator object
    myLocaleTranslator.Init strLanguage
    
    ' put the language code
    myLocaleTranslator.LanguageCode = strLanguage
    
    ' initialize the rowset
    myRowset.Init
    
    ' get the localized strings
    Set getLocalizedEnumTypes = myLocaleTranslator.GetLocaleListForEnumTypes(strLanguage, strNameSpace, strEnumTypeName)
    
'    Do While Not myRowset.EndOfRowset
'
'        Dim myvalue1, myvalue2
'        myvalue1 = myRowset.Value("Value")
'        myvalue2 = myRowset.Value("LocalizedString")
'        Debug.Print myvalue1
'        Debug.Print myvalue2
'        myRowset.MoveNext
'    Loop
End Function



' --------------------------------------------------------------------------------
' FUNCTION      : IsPayementServerInstalled
' DESCRIPTION   : Return a string from a MTInMemRowset that contains a localized enum type.
'                 This purpose of this function is for test and unit testing...
' PARAMETERS    : objLocalizedEnumType as MTInMemRowset
' RETURNS       :
Public Function LocalizedEnumTypeToString(objLocalizedEnumType As Object) As String

    Dim strS As String
    Do While Not objLocalizedEnumType.EOF
    
        strS = strS & objLocalizedEnumType.Value("LocalizedString") & "=" & objLocalizedEnumType.Value("Value") & ";"
        objLocalizedEnumType.MoveNext
    Loop
    LocalizedEnumTypeToString = strS
End Function





' --------------------------------------------------------------------------------
' FUNCTION      : getLocalizedEnumTypes
' DESCRIPTION   : MTInMemRowset that contains a localized enum type.
'
' PARAMETERS    :
' RETURNS       :
Function getCurrencyFormat(dblAmount As Double, strCurrency As String) As String
          
    Dim myDataAccessor      'As New COMDataAccessor
    Dim myLocaleTranslator  'As New COMLocaleTranslator
    Dim myRowset            'As New MTInMemRowset
    
    ' create the data accessor com object
    Set myDataAccessor = CreateObject("COMDataAccessor.COMDataAccessor.1")
    Set myRowset = CreateObject("MTInMemRowset.MTInMemRowset.1")
         
    ' get the locale translator object
    Set myLocaleTranslator = myDataAccessor.GetLocaleTranslator
    
    getCurrencyFormat = myLocaleTranslator.GetCurrency(dblAmount, strCurrency)
End Function

