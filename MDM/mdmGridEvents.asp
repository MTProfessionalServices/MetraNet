<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
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
' NAME		        :   MetraTech Dialog Manager - Grid event and rendering
' VERSION	        :   2.0
' CREATION_DATE   :   03/16/2000
' AUTHOR	        :   F.Torres.
' DESCRIPTION	    :   
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST MDM_GRID_EVENT_ID_DisplayCell          = 0
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayHeaderCell    = 1
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayBegin         = 2
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayEnd           = 3
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayBeginHeader   = 4
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayEndHeader     = 5
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayBeginRow      = 6
PUBLIC CONST MDM_GRID_EVENT_ID_DisplayEndRow        = 7

PUBLIC MDM_GRID_EVENT_STRINGS
MDM_GRID_EVENT_STRINGS = Array("DisplayCell","DisplayHeaderCell","DisplayBegin","DisplayEnd","DisplayBeginHeader","DisplayEndHeader","DisplayBeginRow","DisplayEndRow")

PUBLIC MDM_GRID_EXTENDED_PROPERTIES_COLON

PRIVATE FUNCTION mdm_RenderGrid(EventArg,objMDMGrid) ' As Boolean

    Dim HTMLRendered, lngCol, objCat, i, objProfiler

    If(Not objMDMGrid.Visible)Or(Not IsValidObject(objMDMGrid.Rowset))Then
    
        objMDMGrid.HTMLRendered = Empty
        mdm_RenderGrid          = TRUE
        Exit Function
    End If
    
    MDM_GRID_EXTENDED_PROPERTIES_COLON = mdm_GetDictionary().GetValue("MDM_GRID_EXTENDED_PROPERTIES_COLON",":")    

    Set objCat = CreateObject(CStringConcat)
    
    If(Service.Configuration.ProfilerMode)Then
    
        Set objProfiler = CreateObject(CProfiler)
        objProfiler.Start TRUE, "mdmGridEvents.asp", "mdm_RenderGrid","Rendering grid " & objMDMGrid.Name
    End If
    
    objCat.Init 64000 ' Use a 16Kb buffer
    objCat.AutomaticCRLF = TRUE
    objCat.Concat vbNewLine & "<!-- GRID:" & objMDMGrid.Name & " -->" & vbNewLine
    objCat.Concat vbNewLine & "<INPUT Name='" & objMDMGrid.Name & ".RecordCount' Type='Hidden' Value='" & objMDMGrid.Rowset.RecordCount & "'>" & vbNewLine
    
    Set EventArg.Grid = objMDMGrid ' We store the grid in the eventArg object that the way we share it accross the event

    CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayBegin      , EventArg, objCat
    
    If(objMDMGrid.ShowHeaders)Then
        
        CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayBeginHeader, EventArg, objCat
        
        For i = 1 To  objMDMGrid.Properties.Count ' Call the display cell following selection order
            
            Set objMDMGrid.SelectedProperty = objMDMGrid.Properties.ItemSelected(i)
            If(objMDMGrid.SelectedProperty Is Nothing)Then
                Exit For
            Else
                objMDMGrid.Col = i ' CALL EVENT Form_DisplayCell for the cell  of the product view
                CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayHeaderCell,EventArg,objCat
            End If
        Next        
        CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayEndHeader, EventArg, objCat
    End If
    
    If(objMDMGrid.Rowset.RecordCount) Then 
        If(Not objMDMGrid.RenderCurrentRowOnly)Then 
            objMDMGrid.Rowset.MoveFirst ' Added in mdm 3.5
        End If    
    Else
      objCat.Concat "<tr><td Class=""TableCell"" ColSpan=" & objMDMGrid.Rowset.Count & "><b>" &  mdm_GetMDMLocalizedError("NO_RECORD_USER_MESSAGE") & "</td></tr>"
    End If

    objMDMGrid.Row = 0

    Do While Not objMDMGrid.Rowset.EOF
    
        objMDMGrid.Row = objMDMGrid.Row + 1

        If(objMDMGrid.Row Mod 2)Then
            objMDMGrid.CellClass = objMDMGrid.DefaultCellClass
        Else
            objMDMGrid.CellClass = objMDMGrid.DefaultCellClassAlt
        End If
                
        CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayBeginRow, EventArg, objCat

        For i = 1 To  objMDMGrid.Properties.Count ' Call the display cell following selection order
            
            Set objMDMGrid.SelectedProperty = objMDMGrid.Properties.ItemSelected(i)
            If(objMDMGrid.SelectedProperty Is Nothing)Then
                Exit For
            Else
                objMDMGrid.Col = i ' CALL EVENT Form_DisplayCell for the cell  of the product view
                
                CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayCell, EventArg, objCat
            End If
        Next
        CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayEndRow, EventArg, objCat
        
        If(objMDMGrid.RenderCurrentRowOnly) Then Exit Do ' Added in mdm 3.5
        
        objMDMGrid.Rowset.MoveNext
    Loop
    CallDefaultOrOverRideGridEvent objMDMGrid, MDM_GRID_EVENT_ID_DisplayEnd, EventArg, objCat
    objMDMGrid.HTMLRendered = objCat.GetString()
    Set EventArg.Grid       = Nothing
    Set objProfiler         = Nothing
    mdm_RenderGrid          = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION CallDefaultOrOverRideGridEvent(objMDMGrid,lngEventID,EventArg,objCat) ' As Boolean
    
    Dim strEventName
    
    strEventName          = MDM_GRID_EVENT_STRINGS(lngEventID)
    EventArg.HTMLRendered = Empty
    
    If(objMDMGrid.OverRiddenEvents.Exist(strEventName))Then ' Test if the event is already registered as a custom or default event
    
        If(objMDMGrid.OverRiddenEvents.Item(strEventName).Value="C")Then ' The Event is Customized
        
            On Error Resume Next
            
            CallDefaultOrOverRideGridEvent = Eval(objMDMGrid.Name & "_" & strEventName & "(EventArg)")            
            If(Err.Number)Then  ' An error was raise by the event

                Service.Log Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1013"),"[NAME]",objMDMGrid.Name & "_" & strEventName) &  mdm_GetErrorString() , eLOG_ERROR
            End If                
            On Error Goto 0
        Else    
            CallDefaultOrOverRideGridEvent = CallInheritedEvent(lngEventID,EventArg) ' Fast way to cal the Inherited event
        End If
    Else
    
        On Error Resume Next    
        
        CallDefaultOrOverRideGridEvent = Eval(objMDMGrid.Name & "_" & strEventName & "(EventArg)")
        
        If(Err.Number=13)Then ' If the event does not exist the error is 13 type mismatch, Actually we cannot make the different between the fact that the event does not exist and the fact that the event raised an error 13 type mismatch
        
            Err.Clear
            CallDefaultOrOverRideGridEvent = CallInheritedEvent(lngEventID,EventArg)  ' Fast way to cal the Inherited event
            objMDMGrid.OverRiddenEvents.Add strEventName,"D"                          ' Register the event as default

        ElseIf(Err.Number)Then ' If the event does not exist the error is 13 type mismatch.            

             Service.Log Replace(mdm_GetMDMLocalizedError("MDM_ERROR_1013"),"[NAME]",objMDMGrid.Name & "_" & strEventName) &  mdm_GetErrorString() , eLOG_ERROR
        Else
            objMDMGrid.OverRiddenEvents.Add strEventName,"C" ' Register the event as Customized
        End If        
        On Error Goto 0
    End If
    objCat.Concat EventArg.HTMLRendered ' Begin of grid
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CallInheritedEvent
' PARAMETERS		  :
' DESCRIPTION 		: This procedure is must faster than calling the inherited event with the VBScript function eval()!
' RETURNS		      :
PRIVATE FUNCTION CallInheritedEvent(lngEventID,EventArg) ' As Boolean
    Select Case CLNG(lngEventID)
        Case MDM_GRID_EVENT_ID_DisplayCell          : CallInheritedEvent = inheritedGrid_DisplayCell(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayHeaderCell    : CallInheritedEvent = inheritedGrid_DisplayHeaderCell(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayBegin         : CallInheritedEvent = inheritedGrid_DisplayBegin(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayEnd           : CallInheritedEvent = inheritedGrid_DisplayEnd(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayBeginHeader   : CallInheritedEvent = inheritedGrid_DisplayBeginHeader(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayEndHeader     : CallInheritedEvent = inheritedGrid_DisplayEndHeader(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayBeginRow      : CallInheritedEvent = inheritedGrid_DisplayBeginRow(EventArg)
        Case MDM_GRID_EVENT_ID_DisplayEndRow        : CallInheritedEvent = inheritedGrid_DisplayEndRow(EventArg)
        Case Else            
            CallInheritedEvent = FALSE ' Should log an error
    End Select
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayBegin(EventArg) ' As Boolean
    If(EventArg.Grid.ScrollBars)Then
        EventArg.HTMLRendered = EventArg.HTMLRendered & Service.Tools.PreProcess("<Div class='clsinputbox' Name='Div_[GRID_NAME]' id='Div_[GRID_NAME]' style='width:[WIDTH]px; height:[HEIGHT]px; overflow:auto; background-color:transparent;'>","GRID_NAME",EventArg.Grid.Name,"WIDTH",EventArg.Grid.Width,"HEIGHT",EventArg.Grid.Height) & vbNewLine
    End If
    EventArg.HTMLRendered = EventArg.HTMLRendered & Service.Tools.PreProcess("<Table Name='Table_[GRID_NAME]' id='Table_[GRID_NAME]' border='0' cellpadding='1' cellspacing='0' [WIDTH]>","GRID_NAME",EventArg.Grid.Name,"WIDTH",iif(isEmpty(EventArg.Grid.Width),"","Width='" & EventArg.Grid.Width & "'")) & vbNewLine
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayEnd(EventArg) ' As Boolean
    
    If(EventArg.Grid Is Nothing)Then
        EventArg.HTMLRendered = "</TABLE>"
    ElseIf(EventArg.Grid.ScrollBars)Then
        EventArg.HTMLRendered = "</TABLE></DIV>"
    Else
        EventArg.HTMLRendered = "</TABLE>"
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayBeginHeader(EventArg) ' As Boolean
   EventArg.HTMLRendered = "<TR>" & vbNewLine
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayEndHeader(EventArg) ' As Boolean
   EventArg.HTMLRendered = "</TR>" & vbNewLine
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayBeginRow(EventArg) ' As Boolean
 
'    If(EventArg.Grid.IsMTPropertiesMode())Then ' Support [Extended] MTProperties
 '   
  '      If COMObject.Instance.Properties(CStr(EventArg.Grid.Rowset.value(0))).Attributes("Viewable").Value Then
   '     
    '        Exit Function
     '   End If
'    End If
    
       
    If(IsValidObject(Form.Grid.PropertyID))Then
        EventArg.HTMLRendered =   "<tr id='" & EventArg.Grid.PropertyID.Value & "'>"
    Else
        EventArg.HTMLRendered =   "<tr>"
    End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayEndRow(EventArg) ' As Boolean

    EventArg.HTMLRendered =  "</TR>" & vbNewLine
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayHeaderCell(EventArg) ' As Boolean
    EventArg.HTMLRendered = "<td nowrap class='" & EventArg.Grid.DefaultHeaderClass & "'>&nbsp;" & EventArg.Grid.SelectedProperty.Caption & "&nbsp;</td>" & vbNewLine
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :    
PRIVATE FUNCTION inheritedGrid_DisplayCell(EventArg) ' As Boolean

    Dim strValue, strTemplate, i, objProperty, booEnabled, strMTPropertyName, strSubHTMLTemplate, COMObjectProperty
        
    On Error Goto 0     

    strValue = EventArg.Grid.Rowset.Value(EventArg.Grid.SelectedProperty.Name)
 
    If(EventArg.Grid.IsMTPropertiesMode())Then ' Support [Extended] MTProperties
        
        Select Case EventArg.Grid.Col
            Case 1
            
                If  Not COMObject.Instance.Properties(CStr(EventArg.Grid.Rowset.value(0))).Attributes("Visible").Value Then
                
                    EventArg.HTMLRendered = "<td height='0'></td>"' If the property is visible=false we just render a td with no height
                    Exit Function
                ENd If
                
                strMTPropertyName = strValue
                strValue          = COMObject.Instance.Properties(strMTPropertyName).DisplayName                
                If(Len(strValue)=0)Then strValue = strMTPropertyName ' If there is not display name we display the name
                
                'SECENG: Fixing problems with output encoding
                EventArg.HTMLRendered = Service.Tools.PreProcess("<td NoWrap class='" & EventArg.Grid.CellClass & "'>[VALUE][:]</td>","VALUE",SafeForHtml(strValue),":",MDM_GRID_EXTENDED_PROPERTIES_COLON)
                Exit function
        
            Case 2 ' Column 2 of grid which is a Extended Properties is the value column
            
                Set COMObjectProperty = COMObject.Instance.Properties(CStr(EventArg.Grid.Rowset.value(0)))

                If COMObjectProperty.Attributes("Visible").Value Then
                
                    booEnabled = EventArg.Grid.Enabled
                    
                    If Not COMObject.Instance.Properties(CStr(EventArg.Grid.Rowset.value(0))).Attributes("Editable").Value Then booEnabled = FALSE
                    
                    If (UCase(COMObjectProperty.DataTypeAsString) = "ENUM") Then ' Include the mtproperties of a compound object
                    
                        strSubHTMLTemplate = "<td NoWrap class='[CLASS]'>&nbsp;<SELECT name='[PROPERTY_NAME]' class='clsInputBox' [ENABLED]></SELECT></td>"
                    Elseif (UCase(COMObjectProperty.DataTypeAsString) = "BOOLEAN") Then 
                        strSubHTMLTemplate = "<td NoWrap class='[CLASS]'>&nbsp;<INPUT Type='CheckBox' name='[PROPERTY_NAME]' [ENABLED]>&nbsp;</td>"
                    Else
                        strSubHTMLTemplate = "<td NoWrap class='[CLASS]'>&nbsp;<INPUT Type='Text' name='[PROPERTY_NAME]' class='clsInputBox'  [ENABLED]>&nbsp;</td>"
                    End If                    
                    EventArg.HTMLRendered = Service.Tools.PreProcess(strSubHTMLTemplate,"VALUE", "" & strValue,"PROPERTY_NAME","" & EventArg.Grid.Rowset.Value("Name"),"ENABLED",IIF(booEnabled,""," DISABLED "),"CLASS",EventArg.Grid.CellClass)  
                Else                    
                
                    EventArg.HTMLRendered = "<td height='0'></td>" ' If the property is visible=false we just render a td with no height
                ENd If                
                
                Exit Function
        End Select
    Else
        'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
        'Added HTML encoding
        strValue = SafeForHtml(strValue)
    End If
    
    ' General Case
    If(Len("" & strValue)=0)Then strValue = "&nbsp;"
    
    If Len(EventArg.Grid.SelectedProperty.Format) Then
        'strValue = Service.Tools.Format(strValue, EventArg.Grid.SelectedProperty.Format)
        ' 3.6 - support decimal localization
        strValue = Service.Tools.Format(strValue, FrameWork.Dictionary())
    End If
    
    EventArg.HTMLRendered = "<TD " & IIF(Len(EventArg.Grid.SelectedProperty.Alignment),"Align='" & EventArg.Grid.SelectedProperty.Alignment & "'","") & " Class='[CLASS]'"
    
    If(EventArg.Grid.SelectRowMode)Then ' User can select a row
    
        EventArg.HTMLRendered =  EventArg.HTMLRendered  & " OnClick='mdm_TDOnClick(this.parentNode,""[IDROW]"",""[LABELID]"");' OnMouseOver='mdm_TDMouseOver(this);' OnMouseOut='mdm_TDMouseOut(this,""[CLASS]"")' "
        EventArg.HTMLRendered =  PreProcess(EventArg.HTMLRendered,Array("LABELID",EventArg.Grid.LabelID,"IDROW",EventArg.Grid.PropertyID.Value))
    End If
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & ">" & strValue & "</td>"
    EventArg.HTMLRendered = PreProcess(EventArg.HTMLRendered,Array("CLASS",EventArg.Grid.CellClass))
    
END FUNCTION


'This works for a table named "tableContent" in a div named "divTableBody"
'
'
'    function SizeDiv() {
'      var intHeight;
'      
'      intHeight = document.all.tableContent.scrollHeight;
'      
'      if(intHeight > 200)
'        intHeight = 200;
'
'//      alert(intHeight);      
'      eval('document.all.divTableBody.style.pixelHeight="' + intHeight + '";');
%>

