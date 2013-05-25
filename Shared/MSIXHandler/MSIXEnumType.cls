VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MSIXEnumType"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321CF0387"
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
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
' * *  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
' CLASS         : MSIXEnumType
' AUTHOR        : F.Torres
' CREATION DATE : 08/xx/2000
' VERSION       : 1.0
' DESCRIPTION   :
'                   This object and associated sub-objects implement a full COM Object Model for a MetraTech enum type.
'                   Some of the properties and methods of this object are reserved by the MetraTech Dialog Manager VBScript layer.
'
'                   This object cannot be created directly, but can be created through an instance of the object MSIXHandler as a service
'                   or a product view object. Initializing an MSIXHandler object as a service or a product view automatically loads all the enum types and their localization.
'
'                   Refer to the "Metratech Dialog Manager Programming Guide" for more information.
'
' $Date: 8/2/2002 2:10:20 PM$
' $Author: Frederic Torres$
' $Revision: 64$
' $Workfile: MSIXEnumType.cls$
'**********************************************************************************************************************************************************
Option Explicit

Public TRACE_ID As Long
Public FQName       As String ' The Fully Qualified Name (FQN) of the enum type, initialized by the function <code>SetEnumType()</code>.
Public Name         As String ' The Name of the enum type, initialized by the function <code>SetEnumType()</code>.
Public NameSpace    As String ' The Name Space name of the enum type, initialized by the function <code>SetEnumType()</code>.
Public Entries      As MSIXEnumTypeEntries ' The enum type contents.
Attribute Entries.VB_VarUserMemId = 0
Public Flags        As eMSIX_ENUM_TYPE_FLAG         ' See enum type eMSIX_ENUM_TYPE_FLAG. The default value is eMSIX_ENUM_TYPE_FLAG_NONE.

Public Enum eMSIX_ENUM_TYPE_FLAG

    eMSIX_ENUM_TYPE_FLAG_NONE = 0                                   ' None, default value.
    eMSIX_ENUM_TYPE_FLAG_USE_NAME_IN_HTML_OPTIONS_TAG_AS_INDEX = 1  ' The function GetHTMLOptionTags() return the HTML OPTIONS tag for a comboxbox based on the enum type. By default the value used for the index is the enum type item first value, by setting this flag the  value used for the index will be the enum type item name . The default value is not set.
End Enum

Private m_Parent    As MSIXProperty

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Initialize
' PARAMETERS    :
' DESCRIPTION   : Initialize the object. Must be called first.
' RETURN        : TRUE if ok.
Public Function Initialize() As Boolean ' Documented=no

    On Error GoTo ErrMgr

    Initialize = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "Initialize", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : SetEnumType
' PARAMETERS    :
'                   strLanguage     - The language US, CN, SP.
'                   strNameSpace    - The name space.
'                   strName         - The enum type name
'
' DESCRIPTION   :   Loads an enum type. For each enum type item we have a name, a value, and a caption (localization).
'                   The localization supports Asian language (big5 format).
'
' RETURN        :   TRUE if ok.
Public Function SetEnumType(ByVal strLanguage As String, ByVal strNameSpace As String, ByVal strName As String) As Boolean

    On Error GoTo ErrMgr
    
    Dim strEnumTypeFQN          As String
    Dim objLocalizedEntries     As CVariables
    Dim objLocalizedEntrie      As CVariable
    Dim objMSIXEnumTypeEntry    As MSIXEnumTypeEntry
    Dim varCaption              As Variant
    Dim strError                As String

    NameSpace = strNameSpace
    Name = strName
    FQName = Replace(UCase$(strNameSpace) & "/" & UCase$(strName), "\", "/")
    strEnumTypeFQN = UCase$(strLanguage & "/" & strNameSpace & "/" & strName)
    
'    If (Parent.Parent.Tools.Cache.Exist("LOCALIZEDENUMTYPE:" & strEnumTypeFQN)) Then ' If the enum type is cached
'
'        Set Entries = Parent.Parent.Tools.Cache.Item("LOCALIZEDENUMTYPE:" & strEnumTypeFQN).Data
'        Exit Function
'    End If

    ' 1 - I load in Entrie the EnumType info : Enum Type Id and Value
    If (Parent.Parent.Tools.LoadEnumTypeData(Entries, strLanguage, strNameSpace, strName)) Then
    
        ' 2 Localize each entry
            For Each objMSIXEnumTypeEntry In Me.Entries
            
                If (Parent.Parent.Tools.GetLocalizedString(strLanguage, strNameSpace & "/" & strName & "/" & objMSIXEnumTypeEntry.Name, varCaption)) Then
                    
                    '
                    ' ASIAN LANGUAGE CONVERTION
                    '
                    If (IsAsianLanguage(strLanguage)) Then
                    
                        objMSIXEnumTypeEntry.Caption = Me.Parent.Parent.Tools.StringConvertUniCode2Big5(varCaption)
                    Else
                        objMSIXEnumTypeEntry.Caption = varCaption
                    End If
                Else
                    objMSIXEnumTypeEntry.Caption = "{NL}" & objMSIXEnumTypeEntry.Name
                End If
            Next
    Else
        ' Enum type failed
        strError = Replace(MTMSIX_ERROR_01053, "[NAMESPACE]", strNameSpace)
        strError = Replace(strError, "[ENUMTYPE]", strName)
        TRACE strError, "MSIXEnumType", "SetEnumType", LOG_ERROR
        Exit Function
    End If
    
    'Parent.Parent.Tools.Cache.Add "LOCALIZEDENUMTYPE:" & strEnumTypeFQN, Entries ' Add the object in the cache
    SetEnumType = True
    
    'CreateXMLLocalizationFile
    'CreateXMLEnumTypeFile
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "SetEnumType", LOG_ERROR
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : GetHTMLOptionTags
' PARAMETERS    :
' DESCRIPTION   :   For the current enum type, this method returns the HTML source code that will populate a HTML combo box.
'                   It returns the HTML OPTION tag only, not the HTML SELECT tag. The MSIXProperty object parent value
'                   is used to determine if the combo box has a selected item
' RETURN        :
Public Function GetHTMLOptionTags() As String

    On Error GoTo ErrMgr

    Dim objEntry            As MSIXEnumTypeEntry
    Dim strSelected         As String
    Dim strHTMLTemplate     As String
    Dim objPP               As New CPreProcessor: objPP.standardVar
    Dim objCat              As New cStringConcat
    Dim strParentValue      As String
    Dim strIndexValue       As String
    Dim booIsSelected       As Boolean
        
    strParentValue = UCase$("" & Parent.Value)
    
    If (UCase(Parent.Name) = "MDMINTERVALID") Then
        strParentValue = UCase$("" & Parent.NonLocalizedValue)
    End If
    
    objCat.Init 8000
    
    objCat.Concat vbNewLine & "<!-- " & IIf(Len(Me.FQName) = 0, "Valid List Of Values", "Enum Type") & " " & Parent.Name & " PropertyValue=" & strParentValue & " -->"
    
    
    ' MDM 3.0 - If not required add a blank entry
    If Not Me.Parent.Required Then
        If Len("" & Me.Parent.Value) = 0 Then
            objCat.Concat "<OPTION Value="""""" SELECTED></OPTION>"
        Else
            objCat.Concat "<OPTION Value=""""""></OPTION>"
        End If
    End If
            
    For Each objEntry In Entries
        
        ' Support to build the combo box index on the enum type item value or enum type item name...
        If (Me.Flags And eMSIX_ENUM_TYPE_FLAG_USE_NAME_IN_HTML_OPTIONS_TAG_AS_INDEX) Then
            strIndexValue = objEntry.Name
        Else
            strIndexValue = objEntry.Value
        End If
        
        ' New MDM 3.5 behavior support both the name or the value to find the selected value
        booIsSelected = False
        If (strParentValue = UCase$(strIndexValue)) Then ' Compare against the name
            booIsSelected = True
        Else
            If (strParentValue = UCase$(objEntry.Value)) Then ' Compare against the value
                booIsSelected = True
            End If
        End If
        
        If booIsSelected Then
        
            objCat.Concat "<OPTION Value=""" & strIndexValue & """ SELECTED>" & objEntry.Caption & "</OPTION>"
        Else
            objCat.Concat "<OPTION Value=""" & strIndexValue & """>" & objEntry.Caption & "</OPTION>"
        End If
    Next

    GetHTMLOptionTags = objCat.GetString()
    
    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "GetHTMLOptionTags", LOG_ERROR
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LocalizedValue
' PARAMETERS    :
'                   varIDValue - The value that identify an enum type item.
'
' DESCRIPTION   : Returns the localized value of an enum type item based on the value. If the enum type is a Boolean, there is no localized value, therefore the property LocalizedValue returns the value.
' RETURN        :
Public Property Get LocalizedValue(ByVal varIDValue As Variant) As Variant

    On Error GoTo ErrMgr
    
    Dim objEnumTypeEntry As MSIXEnumTypeEntry
    Dim strError         As String
    
    If (IsEmpty(varIDValue) Or IsNull(varIDValue)) Then ' Support Empty and NULL
    
        Exit Property
    End If
    
    If (Me.Parent.PropertyType = MSIXDEF_TYPE_BOOLEAN) Then ' There is no localization for an enum type boolean, we just return the value
    
        varIDValue = Me.Parent.Parent.Tools.BooleanValue(varIDValue)
    End If
    
    Set objEnumTypeEntry = Entries.ItemByValue(varIDValue) ' let us find the enum type item
    If (IsValidObject(objEnumTypeEntry)) Then
    
        LocalizedValue = Entries.ItemByValue(varIDValue).Caption ' OK
    Else
        ' Here the value given is not in the collection of enum type item
        ' We going to match the value and the name because with mt enum type : enum type name and value can be used as the same (for instance while metering...)
        ' if we do not find we will raise an error
        If (Entries.Exist(varIDValue)) Then ' Here the value is actually the name that's ok
        
            LocalizedValue = Entries.Item(varIDValue).Caption
        Else
            strError = PreProcess(MTMSIX_ERROR_01056, "VALUE", CStr(varIDValue), "FQN", Me.FQName, "PROPERTYNAME", Me.Parent.Name, "NAME", Me.Name)
            RaiseError strError, "File=MSIXEnumType.cls Function=LocalizedValue()", , LOG_WARNING
        End If
    End If
    Exit Property
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "LocalizedValue", LOG_WARNING
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Delete
' PARAMETERS    :
' DESCRIPTION   : Internal Delete function called by the parent object when the parent is about to be deleted.
'                 The purpose of this function is to free the parent ref from the child so the parent can be deleted.
'                 This deals with the COM problem of circular reference.
'                 This function cannot be called from the out side (Friend)!
' RETURN        :
Friend Function Delete() As Boolean

    On Error GoTo ErrMgr

    ' Free the parent
    Set Parent = Nothing
    
    Delete = True

    Exit Function
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "LocalizedValue", LOG_ERROR
End Function

Private Sub Class_Initialize()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "Class_Initialize", LOG_ERROR
End Sub

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Terminate()

    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "Class_Terminate", LOG_ERROR
End Sub


Public Sub CreateXMLEnumTypeFile() 'documented=no

    On Error GoTo ErrMgr

    
    Dim objV    As CVariable
    Dim strS    As String
    Dim objTextFile As New cTextFile
    Dim lngCount As Long
    
    
    
    Const DCOTE = """"
    
    lngCount = 1
    strS = ""
    strS = strS & "<enum name=" & DCOTE & LCase(Me.FQName) & DCOTE & ">" & vbNewLine
    strS = strS & "    <description></description>" & vbNewLine
    strS = strS & "      <entries>" & vbNewLine
        
    For Each objV In Entries
    
         strS = strS & "           <entry name=" & DCOTE & objV.Name & DCOTE & "><value>" & objV.Value & "</value></entry>" & vbNewLine
    Next
    strS = strS & "      </entries>" & vbNewLine
    strS = strS & "</enum>" & vbNewLine
    
    objTextFile.LogFile "c:\temp\enum\" & Replace(Me.FQName, "\", "_") & ".xml", strS, True
    

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "CreateXMLEnumTypeFile", LOG_ERROR
End Sub



Public Sub CreateXMLLocalizationFile() 'documented=no
    On Error GoTo ErrMgr
    
    Dim objV            As MSIXEnumTypeEntry
    Dim strS            As String
    Dim objTextFile     As New cTextFile
    Dim lngCount        As Long
    
    Const DCOTE = """"
    
    lngCount = 1
    
    strS = ""
        
    For Each objV In Entries
         strS = strS & "<locale_entry>" & vbNewLine
         strS = strS & "    <Name>" & Replace(LCase(Me.FQName), "\", "/") & "/" & objV.Name & "</Name>" & vbNewLine
         strS = strS & "    <Value>" & objV.Caption & "</Value>" & vbNewLine
         strS = strS & "</locale_entry>" & vbNewLine
    Next
    
    objTextFile.LogFileUniCode "c:\temp\localized\" & Replace(Me.FQName, "/", "_") & ".xml", strS, True
    

    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MSIXEnumType.cls", "CreateXMLEnumTypeFile", LOG_ERROR
End Sub



' -------------------------------------------------------------------------------
' FUNCTION      : Parent
' PARAMETERS    :
' DESCRIPTION   : This method references the MSIXProperty parent instance.
' RETURN        :
Public Property Get Parent() As MSIXProperty

    On Error GoTo ErrMgr

    If (Not IsValidObject(m_Parent)) Then
        RaiseError Replace(MTMSIX_ERROR_01055, "[NAME]", Me.Name), , , LOG_APPLICATION_ERROR
        
    End If
    Set Parent = m_Parent

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXEnumType.cls", LOG_ERROR
End Property

' -------------------------------------------------------------------------------
' FUNCTION      : Parent
' PARAMETERS    :
' DESCRIPTION   : See Get property.
' RETURN        :
Public Property Set Parent(ByVal vNewValue As MSIXProperty)

    On Error GoTo ErrMgr

    Set m_Parent = vNewValue

    Exit Property
ErrMgr:
        TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "Parent", "MSIXEnumType.cls", LOG_ERROR
End Property


' -------------------------------------------------------------------------------
' FUNCTION      : GetDatabaseInternalID
' PARAMETERS    :
'                   strEnumTypeItemName - The enum type item name, also called the enumerator.
'
' DESCRIPTION   : This method gets the internal enum type item database ID for the current enum type and the strEnumTypeItemName. This function uses the object Metratech.MTEnumConfig.1 stored in the cache.
' RETURN        : Returns -1 if the function fails else the ID.
Public Function GetDatabaseInternalID(ByVal strEnumTypeItemName As String) As Long

    On Error GoTo ErrMgr
    
    Dim objEnumTypeconfig   As Object
    
    Const CACHE_NAME = "ENUMCONFIG:GetDatabaseInternalID:"
     
    If (Parent.Parent.Tools.Cache.Exist(CACHE_NAME)) Then ' If the enum type is cached
    
        Set objEnumTypeconfig = Parent.Parent.Tools.Cache.Item(CACHE_NAME).Data
    Else
        Set objEnumTypeconfig = CreateObject("Metratech.MTEnumConfig.1") ' create the object and add it to the cache...
        Parent.Parent.Tools.Cache.Add CACHE_NAME, objEnumTypeconfig
    End If
    
    ' Do the job
    GetDatabaseInternalID = objEnumTypeconfig.GetID(Me.NameSpace, Me.Name, strEnumTypeItemName)
    
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "GetDatabaseInternalID", "MSIXEnumType.cls", LOG_ERROR
    GetDatabaseInternalID = -1
End Function
