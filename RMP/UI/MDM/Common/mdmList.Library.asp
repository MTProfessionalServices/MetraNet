<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2000 by MetraTech Corporation
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME		        : MCM - Picker Library - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE   : 4/11/2001
' AUTHOR	        : Some body called Fred!
' DESCRIPTION	    : The MCM define the following utility dialogs:
'                   ProductOffering.Picker.asp
'                   PriceableItem.Picker.asp
'                   PriceList.Picker.asp
'                   More To Come.
'
'                   These dialog implements the same pattern. There a couple
'                   of event that shared.So I grouped them in this file...
'
' DPENDENCY       : MDM Includes.
'
' ----------------------------------------------------------------------------------------------------------------------------------------


PUBLIC MDMListDialog ' Global Instance...
Set MDMListDialog = New CMDMListDialog


'List_Initialize MDMListDialog.Initialize


CLASS CMDMListDialog

    Private m_objMSIXTools    ' as MTMSIX.Tools  
    Private m_objPreProcessor ' as MTVBLIB.CPreProcessor
    
    PUBLIC PROPERTY Get Tools()
        If(IsEmpty(m_objMSIXTools))Then Set m_objMSIXTools = mdm_CreateObject(MSIXTools)
        Set Tools = m_objMSIXTools        
    END PROPERTY
    
    PUBLIC PROPERTY Get PreProcessor()
        If(IsEmpty(m_objPreProcessor))Then Set m_objPreProcessor = mdm_CreateObject(CPreProcessor)
        Set PreProcessor = m_objPreProcessor
    END PROPERTY    
   
    PUBLIC FUNCTION Initialize(EventArg) ' As Boolean
            
        'MDMListDialog.PreProcessor
    
        Form("NextPage")              = Request.QueryString("NextPage")           ' Save the value in a form variables
        Form("Kind")                  = Request.QueryString("Kind")               ' Save the value in a form variables        
        Form("LinkColumnMode")        = Request.QueryString("LinkColumnMode")     ' Save the value in a form variables    
        Form("Parameters")        	  = Request.QueryString("Parameters")         ' Save the value in a form variables    
        Form("IDColumnName")          = Request.QueryString("IDColumnName")       ' Column name to use for ID  - default is id_prop
            	
        ProductView.Properties.Flags  = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW         ' Tell the product view object to behave like real MT Product View based on the data in the rowset    
        Form.Page.MaxRow              = mdm_GetDictionary().GetValue("MAX_ROW_PER_LIST_PAGE",16)
        Form.Grid.FilterMode          = TRUE
    
        If(Len(Request.QueryString("Title")))Then
            mdm_GetDictionary().Add "MCM_LIST_TITLE", mdm_GetDictionary().Item(Request.QueryString("Title")).Value
        Else
            mdm_GetDictionary().Add "MCM_LIST_TITLE", ""
        End If        
        
    	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    	  Initialize = TRUE    
    END FUNCTION

    PRIVATE FUNCTION ProcessParameter()
        Dim strParameter
        If(IsEmpty(Form("Parameters")))Then
              PreProcessor.Add "PARAMETERS"  , ""
        Else
           strParameter = Replace(Form("Parameters"),"|","=")
           strParameter = Replace(strParameter,";","&")
           PreProcessor.Add "PARAMETERS"  , "&" & strParameter
        End If
    END FUNCTION
    
    PUBLIC FUNCTION PreProcess(strHTML)
        ProcessParameter
        PreProcess = PreProcessor.Process(strHTML)
    END FUNCTION
    
    ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 		    : 
    ' PARAMETERS		  :
    ' DESCRIPTION 		:
    ' RETURNS		      : Return Column Name    
    PUBLIC FUNCTION GetIDColumnName()
      
      If Len(Form("IDColumnName")) Then
        GetIDColumnName = Form("IDColumnName")
      Else
        GetIDColumnName = "id_prop" 
      End If  
    END FUNCTION
    
END CLASS    

' ************ EVENT CANNOT BE PART OF THE CLASS, SO THEY CAN BE OVER RIDDENT ************
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: ViewEditMode_DisplayCell
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION ViewEditMode_DisplayCell(EventArg) ' As Boolean

    Dim HTML_LINK_EDIT
    
    Select Case Form.Grid.Col
    
        Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='40'>"
            ' The tag [PARAMETERS] must be at the end of the query string                                                            
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<A Name='Edit[ID]' HREF='[ASP_PAGE]?ID=[ID]&EditMode=True&MDMReload=True[PARAMETERS]'><img Alt='[ALT_EDIT]' src='[IMAGE_EDIT]' Border='0'></A>&nbsp;"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<A Name='View[ID]' HREF='[ASP_PAGE]?ID=[ID]&EditMode=False&MDMReload=True[PARAMETERS]'><img Alt='[ALT_VIEW]' src='[IMAGE_VIEW]' Border='0'></A>"
            HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
            
            MDMListDialog.PreProcessor.Clear
          
            MDMListDialog.PreProcessor.Add "ID"          , ProductView.Properties.Rowset.Value(MDMListDialog.GetIDColumnName())
            MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
            MDMListDialog.PreProcessor.Add "ASP_PAGE"    , Form("NextPage")
            MDMListDialog.PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
            MDMListDialog.PreProcessor.Add "IMAGE_VIEW"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/view.gif"
            MDMListDialog.PreProcessor.Add "ALT_VIEW"    , mdm_GetDictionary().Item("TEXT_VIEW").Value
            MDMListDialog.PreProcessor.Add "ALT_EDIT"    , mdm_GetDictionary().Item("TEXT_EDIT").Value
            
            EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
            ViewEditMode_DisplayCell        = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
            
        Case Else
        
           ViewEditMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: LinkColumnMode_DisplayCell
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION LinkColumnMode_DisplayCell(EventArg) ' As Boolean

    Dim m_objPP, HTML_LINK_EDIT , strValue , strFormat, lngPos, strParameter 

    Select Case Form.Grid.Col
    
        Case 1,2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
        Case 3
            Inherited("Form_DisplayCell()")
            lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
            EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered,"<A Name='Link[ID]' HREF='[URL]?ID=[ID][PARAMETERS]'>",lngPos+1) ' Insert after >
            EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
            
            MDMListDialog.PreProcessor.Clear
            MDMListDialog.PreProcessor.Add "URL" , Form("NextPage")
            MDMListDialog.PreProcessor.Add "ID"  , ProductView.Properties.Rowset.Value(MDMListDialog.GetIDColumnName())

            EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)
			
        Case Else
           LinkColumnMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_DisplayCell
' PARAMETERS	:
' DESCRIPTION : I implement this event so i can customize the 1 col which
'               is the action column, where i put my link!
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    If(Form("LinkColumnMode"))Then
        Form_DisplayCell  = LinkColumnMode_DisplayCell(EventArg)
    Else
        Form_DisplayCell  = ViewEditMode_DisplayCell(EventArg)
    End If
END FUNCTION    

%>
