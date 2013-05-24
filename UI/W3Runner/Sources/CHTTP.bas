Attribute VB_Name = "CHTTPModule"
Option Explicit

Public Const HTTP_PREFIX = "http://"

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function EncodeUrl(ByVal sUrl As String, Optional eFlag As eURL_ENCODE = URL_DONT_SIMPLIFY + URL_ESCAPE_PERCENT) As String

   Dim sUrlEsc As String
   Dim dwSize  As Long
   
   
   If Len(sUrl) > 0 Then
      
      sUrlEsc = Space$(MAX_PATH)
      dwSize = Len(sUrlEsc)
      
      If UrlEscape(sUrl, sUrlEsc, dwSize, eFlag) = ERROR_SUCCESS Then
      
         EncodeUrl = Replace(Left$(sUrlEsc, dwSize), "+", "%2b")
      End If  'If UrlEscape
   End If 'If Len(sUrl) > 0

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Public Function DecodeUrl(ByVal sUrl As String, Optional eFlag As eURL_ENCODE = URL_DONT_SIMPLIFY + URL_ESCAPE_PERCENT, Optional lngMaxStringSize As Long = 4096) As String

   Dim sUrlUnEsc As String
   Dim dwSize As Long
   Dim dwFlags As eURL_ENCODE
   
   If Len(sUrl) > 0 Then
      
      sUrlUnEsc = Space$(lngMaxStringSize)
      dwSize = Len(sUrlUnEsc)
      dwFlags = eFlag
      
      If UrlUnescape(sUrl, sUrlUnEsc, dwSize, dwFlags) = ERROR_SUCCESS Then
                   
         DecodeUrl = Replace(Left$(sUrlUnEsc, dwSize), "+", " ")
      End If  'If UrlUnescape
   End If
End Function
