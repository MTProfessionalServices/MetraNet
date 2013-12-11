Attribute VB_Name = "MTXServiceModule"
Attribute VB_Ext_KEY = "RVB_UniqueId" ,"399321CA009B"
Option Explicit



Public g_booReadEnumType  As Boolean ' set to TRUE in MSIXHandler Class_Initialize()
Public static_lngGetUniqueStringID As Long ' Counter used to generated temporary unique id

Public Const SUPER_USER_NAME_SPACE = "system_user"
Public Const SUPER_USER_SERVER_ACCESS_ENTRY = "SuperUser"

Public Enum TRACE_CONSTRUCTOR_DESTRUCTOR_ACTION
    TRACE_CONSTRUCTOR_MODE = 1
    TRACE_DESTRUCTOR_MODE = 2
    TRACE_CLEAR_MODE = 3
    TRACE_INIT_MSIXPROPERTY = 4
    TRACE_MSIXHANDLER_INIT_MSIXPROPERTIES = 5
    TRACE_INIT_MSIXINTERVALID = 6
    TRACE_LOAD_MSIXDEF_FILE = 7
End Enum

Public Const HTML_HEAD_TAG = "<HEAD>"
Public Const HTML_FORM_CLOSE_TAG = "</FORM>"

Public Const MSIXDEF_KEYWORD_DEFINESERVICE = "DEFINESERVICE"
Public Const MSIXDEF_KEYWORD_NAME = "NAME"
Public Const MSIXDEF_KEYWORD_DN = "DN"
Public Const MSIXDEF_KEYWORD_LENGTH = "LENGTH"
Public Const MSIXDEF_KEYWORD_PTYPE = "PTYPE"

Public Const MSIXDEF_TYPE_UNISTRING = "UNISTRING"
Public Const MSIXDEF_TYPE_STRING = "STRING"
Public Const MSIXDEF_TYPE_BOOLEAN = "BOOLEAN"
Public Const MSIXDEF_TYPE_FLOAT = "FLOAT"
Public Const MSIXDEF_TYPE_DOUBLE = "DOUBLE"
Public Const MSIXDEF_TYPE_DECIMAL = "DECIMAL"
Public Const MSIXDEF_TYPE_INT32 = "INT32"
Public Const MSIXDEF_TYPE_TIMESTAMP = "TIMESTAMP"
Public Const MSIXDEF_TYPE_ENUM = "ENUM"
Public Const MSIXDEF_TYPE_OBJECT = "OBJECT"

Public Const MSIXDEF_COMPOUND_PROPERTY_SEPARATOR = "__"

Public Const MDM_TYPE_STRINGID = "STRINGID"
Public Const MDM_TYPE_STRINGID_DEFAULT_CHARS = "_ ABCDEFGHIJKLMNOPQRSTVWUXYZabcdefghijklmnopqrstvwuxyz0123456789"

Public Const MSIXDEF_TYPE_BOOLEAN_TRUE = "T"
Public Const MSIXDEF_TYPE_BOOLEAN_FALSE = "F"

Public Const METRATECH_GLOBAL_NAME_SPACE_NAME = "global"

Public Const METRATECH_DEFAULT_LANGUAGE = "US"

Public Const HTML_RIGHT = "RIGHT"
Public Const HTML_LEFT = "LEFT"

Public Const MSIXDEF_KEYWORD_TYPE = "TYPE"
Public Const MSIXDEF_KEYWORD_ENUM = MSIXDEF_TYPE_ENUM
Public Const MSIXDEF_KEYWORD_REQUIRED = "REQUIRED"
Public Const MSIXDEF_KEYWORD_DEFAULTVALUE = "DEFAULTVALUE"

Public Const MSIXDEF_KEYWORD_ATTRIBUT_USERVISIBLE = "USERVISIBLE"
Public Const MSIXDEF_KEYWORD_ATTRIBUT_EXPORTABLE = "EXPORTABLE"
Public Const MSIXDEF_KEYWORD_ATTRIBUT_FILTERABLE = "FILTERABLE"

Public Const MSIXDEF_KEYWORD_ATTRIBUT_ENUMSPACE = "ENUMSPACE"
Public Const MSIXDEF_KEYWORD_ATTRIBUT_ENUMTYPE = "ENUMTYPE"

Public Const MTMSIX_DEFAULT_DECIMAL_SEPARATOR = "."
Public Const MTMSIX_DEFAULT_THOUSAND_SEPARATOR = ","

Public Const MTMSIX_DEFAULT_DECIMAL_MAX_CHAR_SIZE = 18

Public Const MTMSIX_METRATECH_DOT_COM_NAME_SPACE = "metratech.com"
  
Public Const MDM_CONDITIONAL_RENDERING_IF = "#MDMIF"
Public Const MDM_CONDITIONAL_RENDERING_IFNOT = "#MDMNOTIF"
Public Const MDM_CONDITIONAL_RENDERING_ENDIF = "#MDMENDIF"

Public Const MSIX_MAX_STRING_LENGTH = 255

Public Const MTMSIX_DEFAULT_SERVER_NAME_TO_METER = "AccountPipeline"

' Dictionary Entry Names
Public Const MDM_LANGUAGE_META_TAG = "LANGUAGE_META_TAG"

Public Const MDM_CUSTOM_IMAGE_PATH_SEARCH = "CUSTOM_PATH_SEARCH"
Public Const MDM_CUSTOM_IMAGE_PATH_REPLACE = "CUSTOM_PATH_REPLACE"
Public Const MDM_CUSTOM_IMAGE_PATH_REPLACE_FOLDER = "CUSTOM_PATH_REPLACE_FOLDER"

Public Const MDM_DEFAULT_IMAGE_PATH_SEARCH = "DEFAULT_PATH_SEARCH"
Public Const MDM_DEFAULT_IMAGE_PATH_REPLACE = "DEFAULT_PATH_REPLACE"
Public Const MDM_DEFAULT_IMAGE_PATH_REPLACE_FOLDER = "DEFAULT_PATH_REPLACE_FOLDER"
Public Const MDM_STYLES_RELATIVE_PATH = "STYLES_RELATIVE_PATH"

Public Const MDM_VERSION_13 = "1.3"
Public Const MDM_VERSION_20 = "2.0"
Public Const MDM_VERSION_21 = "2.1"


Public Const MDM_JAVASCRIPT_GRID_RENDERING_TEMPLATE = "var [NAME]_Width=[WIDTH];[CRLF]var [NAME]_Height=[HEIGHT];[CRLF]"

Public Const WILDCARD_EXTENSION_XML = "*.xml"
Public Const WILDCARD_EXTENSION_ASP = "*.asp"
Public Const WILDCARD_EXTENSION_CSS = "*.css"

Public Const DB_SQL_COLUMN_PREFIX = "c_"
 
Public Const MDM_UNICODE_2_BIG5_TRANSLATER_CACHE_NAME = "Unicode2Big5Translater"

Public Const MSIX_CHINESE_LANGUAGE = "CN"

Public Const MSIX_BIG5_MDM_RELATIVE_PATH_AND_NAME = "\internal\MDM Unicode to Big5 - windows-950-2000.xml"

Public Const HTML_ATTIBUTE_DISABLED = " Disabled " ' Do not remove the space
Public Const HTML_ATTIBUTE_READ_ONLY = " ReadOnly " ' Do not remove the space
 
' Global strings

Public Const g_strHTMLTemplateUIErrorMessage = "<br><font face='arial' size='2' color='red'><b>[MESSAGE]</b></code>"

Public g_lngMSIXInstanceCreated As Long ' MSIXHandler Instance counter
Public g_lngMSIXInstanceActive  As Long ' MSIXHandler Instance counter created but not deleted

Public MTMSIX_PROFILER_ON As Boolean ' this not thread safe - but it is for debug purpose only and default value is false...

' MDM v2.2
Public Const MDM_FILTER_MODE_ON = -1   ' Must be equal to TRUE(-1) for compatibility reason
Public Const MDM_FILTER_MULTI_COLUMN_MODE_ON = -2

Public Function IsDateHasTime(varExp As Variant) As Boolean

    Dim l As Long
    l = Int(CDbl(varExp))
    
    IsDateHasTime = (l <> CDbl(varExp))
End Function


Public Function FormatDataLocalized(ByVal varExp As Variant, ByVal Dic As Dictionary) As String

  If IsNull(varExp) Then
    FormatDataLocalized = ""
    Exit Function
  End If

  Select Case VarType(varExp)
    Case vbDate
      If IsDateHasTime(varExp) Then
        FormatDataLocalized = VBA.Format(varExp, Dic.Item("DATE_TIME_FORMAT").Value)
      Else
        FormatDataLocalized = VBA.Format(varExp, Dic.Item("DATE_FORMAT").Value)
      End If

    Case vbDecimal
      FormatDataLocalized = Replace(CStr(varExp), ".", Dic.Item("DECIMAL_SEPARATOR").Value)

    Case Else
      If IsDate(varExp) Then
        If InStr(UCase(varExp), "AM") Or InStr(UCase(varExp), "PM") Then
          FormatDataLocalized = MyFormatDateTime(varExp, Dic.Item("DATE_TIME_FORMAT").Value)
        Else
          FormatDataLocalized = VBA.Format(varExp, Dic.Item("DATE_FORMAT").Value)
        End If
      Else
        FormatDataLocalized = "" & varExp
      End If
  End Select

End Function

Public Function MyFormatDateTime(varExp As Variant, strFormat As String) As String

  Dim str As String
  str = CStr(varExp)
  If (IsNull(varExp)) Then

    MyFormatDateTime = ""
    Exit Function
  End If
  Dim Day, Month, Year, H, M, s, ampm As String
  Dim formatparts() As String
  formatparts = Split(strFormat, "/")
  Dim parts() As String
  parts = Split(str, "/")
  Month = parts(0)
  Day = parts(1)
  Dim Rest As String
  Rest = parts(2)
  Year = Left(Rest, 4)
  Rest = Right(Rest, Len(Rest) - 5) 'accounting for #32;
  parts = Split(Rest, ":")
  H = parts(0)
  Dim origH As String
  origH = H
  M = parts(1)
  Rest = parts(2)
  s = Left(Rest, 2)
  ampm = Right(Rest, 2)
  If (StrComp(Trim(ampm), "PM") = 0) Then
    On Error GoTo Err
    H = CStr((CByte(Trim(H)) + 12))
  End If

  If (Len(strFormat)) Then
    If ((StrComp(formatparts(0), "d") = 0) Or (StrComp(formatparts(0), "dd") = 0)) Then
      If (StrComp(UCase(Right(strFormat, 4)), "AMPM") = 0) Then
        MyFormatDateTime = Day & "/" & Month & "/" & Year & " " & origH & ":" & M & ":" & s & " " & ampm
      Else
        MyFormatDateTime = Day & "/" & Month & "/" & Year & " " & H & ":" & M & ":" & s
      End If
    Else
      If (StrComp(UCase(Right(strFormat, 4)), "AMPM") = 0) Then
        MyFormatDateTime = Month & "/" & Day & "/" & Year & " " & origH & ":" & M & ":" & s & " " & ampm
      Else
        MyFormatDateTime = Month & "/" & Day & "/" & Year & " " & H & ":" & M & ":" & s
      End If
    End If
  Else
    MyFormatDateTime = varExp
  End If
  Exit Function
Err:
  MyFormatDateTime = "error happened in casting hour to int"
End Function
Public Function FormatData(varExp As Variant, strFormat As String) As Variant
    
    If (IsNull(varExp)) Then
    
        FormatData = ""
        Exit Function
    End If
    
    If (Len(strFormat)) Then
    
        FormatData = VBA.Format(varExp, strFormat)
    Else
        FormatData = varExp
    End If
End Function

' -------------------------------------------------------------------------------
' FUNCTION      : IsAsianLanguage
' DESCRIPTION   :
' PARAMETERS    :
' RETURN        :
Public Function IsAsianLanguage(ByVal strLanguage As String) As Boolean

    IsAsianLanguage = CBool(MSIX_CHINESE_LANGUAGE = UCase$(strLanguage))
End Function

Public Function TRACE_CONSTRUCTOR_DESTRUCTOR(obj As Object, eMode As TRACE_CONSTRUCTOR_DESTRUCTOR_ACTION, Optional strMessage As String) As Boolean

    #If LOG_OBJECT_INFO Then
    
        Dim strM        As String
        Dim lngTRACE_ID As Long
        
        Select Case eMode
        
            Case TRACE_CONSTRUCTOR_MODE:
            
            strM = strM & "CONSTRUCTOR"
                                                    ' Set the trace Id
                    On Error Resume Next            ' Support the fact that the object does not have the TRACE_ID Property though it should...
                    obj.TRACE_ID = GetTickCount()   ' I need an id because the pointer of the object is not enough...
                    On Error GoTo 0
                    
                    
            Case TRACE_DESTRUCTOR_MODE:
            
                    strM = strM & "DESTRUCTOR"
                    
                    'If TypeName(obj) = "Dictionary" Then
                    '    'Debug.Assert 0
                    'End If
                    
            Case TRACE_CLEAR_MODE:                      strM = strM & "CLEAR"
            Case TRACE_INIT_MSIXPROPERTY:               strM = strM & "MSIXPROPERTY_INITIALIZE"
            Case TRACE_MSIXHANDLER_INIT_MSIXPROPERTIES: strM = strM & "MSIXHANDLER_INIT_MSIXPROPERTIES"
            Case TRACE_INIT_MSIXINTERVALID:             strM = strM & "MSIXHANDLER_INIT_MSIXINTERVALID"
            Case TRACE_LOAD_MSIXDEF_FILE:               strM = strM & "LOAD MSIXDEF FILE"
        End Select
        
        On Error Resume Next            ' Get the trace ID - Support the fact that the object does not have the TRACE_ID Property though it should...
        lngTRACE_ID = obj.TRACE_ID
        On Error GoTo 0
        
        strM = strM & " [" & TypeName(obj) & " " & ObjPtr(obj) & "-" & lngTRACE_ID & "] " & strMessage
        
        TRACE strM, , , LOG_DEBUG
        
    #End If
    
    TRACE_CONSTRUCTOR_DESTRUCTOR = True
    
End Function

Public Function CheckCoarseCapability(m_objPolicy As Object, m_objSecurityContext As Object, strCapabilities As String, strCapabilityParameters As String) As Boolean

    Dim objCapabilityInstance As Object
    Dim strCapability As Variant
    
    For Each strCapability In Split(strCapabilities, ",")
    
        On Error Resume Next
        Set objCapabilityInstance = m_objPolicy.GetCapabilityTypeByName("" & strCapability).CreateInstance()
        If Err.Number Then
        
            On Error GoTo ErrMgr
            TRACE PreProcess(MTMSIX_ERROR_01092, "CAPABILITY", strCapability), "XMenu.cls", "IsSecure", LOG_ERROR
            Exit Function
        Else
        
            On Error GoTo ErrMgr
            If Not m_objSecurityContext.CoarseHasAccess(objCapabilityInstance) Then Exit Function
        End If
    Next
    CheckCoarseCapability = True
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "XMenu.cls", "CheckCoarseCapability", LOG_ERROR
End Function



Public Function InTag(strTag As String, strValue As String, Optional strSpace As String) As String
    InTag = strSpace & "<" & strTag & ">" & strValue & "</" & strTag & ">" & vbNewLine
End Function

Public Function GetUniqueStringID() As String
    static_lngGetUniqueStringID = static_lngGetUniqueStringID + 1
    GetUniqueStringID = "TID" & static_lngGetUniqueStringID
End Function

Public Function GetMSIXTypeStringFromSessionTypeID(lngID As Long) As String

    Dim s As String

    Select Case lngID

        Case SESSION_PROPERTY_TYPE_DATE: s = MSIXDEF_TYPE_TIMESTAMP
        Case SESSION_PROPERTY_TYPE_TIME: s = MSIXDEF_TYPE_TIMESTAMP
        Case SESSION_PROPERTY_TYPE_STRING: s = MSIXDEF_TYPE_STRING
        Case SESSION_PROPERTY_TYPE_LONG: s = MSIXDEF_TYPE_INT32
        Case SESSION_PROPERTY_TYPE_DOUBLE: s = MSIXDEF_TYPE_DOUBLE
        Case SESSION_PROPERTY_TYPE_BOOLEAN: s = MSIXDEF_TYPE_BOOLEAN
        Case SESSION_PROPERTY_TYPE_ENUM: s = MSIXDEF_TYPE_ENUM
        Case SESSION_PROPERTY_TYPE_DECIMAL: s = MSIXDEF_TYPE_DECIMAL
    End Select
    GetMSIXTypeStringFromSessionTypeID = s
End Function

