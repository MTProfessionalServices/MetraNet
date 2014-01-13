<%
' THIS IS NOT THE REAL FRAMEWORK, IT IS ONLY AN EMULATOR FOR THE DICTIONARY 

PUBLIC FrameWork                
Set FrameWork = New CFrameWork  


CLASS CFrameWork ' -- The FrameWork Class --

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION GetDictionary(strName) ' As String
    
    	  GetDictionary = Session("objMAM").Dictionary(strName)
    END FUNCTION

END CLASS

%>