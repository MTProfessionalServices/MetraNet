<!-- #INCLUDE FILE="../../auth.asp" --> 
<%
on error resume next

sub writePeriodSectionHeader(sName)
          %>
            <table class="clsDialogEditTable" style="border:thin solid #007AE5;" width="100%" border="0" cellpadding="1" cellspacing="0">
               <tr class='TableHeader'>
                  <td align='left' colspan='5'>
                  </td>
               </tr>
               <tr class='TableHeader'>
                  <td colspan='4' class='TableHeader2' align="left">
                     &nbsp;<span style='font-size:14px;font-weight:bold;font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif;'><%=sName%></span>
                  </td>
               </tr>
          <%
end sub

sub writePeriodSectionEnd
          %>
          </table><br>
          <%
end sub

sub writeEventSectionHeader(sName)
          %>
               <tr class='TableSubHeader'>
                  <td class='TableSubHeader' width="20" align="left">
                     &nbsp;
                  </td>
                  <td colspan='3' class='TableSubHeader' align='left'>
                     <%=sName%>
                  </td>

               </tr>
          <%
end sub

sub writeGroupBreak
            %>
            <tr bgcolor="#5273B5" height="2">
              <td colspan="3"></td>
            </TR>
            <%
end sub

function displayGroups(objEventSet)

        dim objGroupSet
        dim intGroupId
        
        intGroupId=0
        Set objGroupSet = objEventSet.NextSetWithName("group")
        if objGroupSet Is Nothing Then
          response.write("No Group Set found in Event set<BR>")
          displayGroups = false
        else
              
          Do While Not objGroupSet Is Nothing
            intGroupId=intGroupId+1
            
            if intGroupId>0 then
              writeGroupBreak
            end if
            
            Set objAdapterSet = objGroupSet.NextSetWithName("adapter_set")
            
            if objAdapterSet Is Nothing Then
              response.write("No Adapter Set found in group<BR>")
            else
              'response.write("Adapter Set")
            end if
            
            Do While Not objAdapterSet Is Nothing
              sAdapter = objAdapterSet.NextStringWithName("adapter")
              sAdapterName = objAdapterSet.NextStringWithName("adapter_name")
              sConfigFile = objAdapterSet.NextStringWithName("config_file")
              if objAdapterSet.NextMatches("description", 4) then
                sDescription = objAdapterSet.NextStringWithName("description")
              else
                sDescription = ""
              end if
              
              
              'response.write("Adapter [" & sAdapter & "]<BR>")
              'response.write("&nbsp;&nbsp;&nbsp;&nbsp;Name [" & sAdapterName & "]<BR>")
              'response.write("&nbsp;&nbsp;&nbsp;&nbsp;Config File [" & sConfigFile & "]<BR>")
              dim sToolTip
              sToolTip = "Component: " & sAdapter & vbCRLF & "Config File: " & sConfigFile & vbCRLF '& "Description: " & sDescription
              
              %>
                  <tr class='TableDetailCell' title='<%=SafeForHtmlAttr(sToolTip)%>'>
                    <td valign="top">
                       <input type="checkbox" name="RunAdapterSelect" value="<%=SafeForHtmlAttr(sAdapter & "~" & sAdapterName & "~" & sConfigFile)%>">
                    </td>
                    <td>
                       <img alt="<%=SafeForHtmlAttr(sToolTip)%>" border="0" height="16" src= "../localized/en-us/images/adapter.gif" align="absmiddle" width="16">&nbsp;<strong><%=SafeForHtml(sAdapterName)%></strong>
                       <%
                       if len(sDescription) then
                        response.write("<BR>" & SafeForHtml(sDescription))
                       end if
                       %>
                    </td>
                    <td>
                       
                    </td>
                 </tr>
              <%
  
              
              Set objAdapterSet = objGroupSet.NextSetWithName("adapter_set")
            Loop
  
            Set objGroupSet = objEventSet.NextSetWithName("group")
          Loop
  
          displayGroups = true
        end if
end function

sub DisplayListOfAdapters(sIntervalType)

    dim bCheckSum
    dim sFileName
    
    dim objConfig
    dim objPropSet
    	
    Dim objTools
    set objTools = CreateObject("MTMSIX.MSIXTOOLS")
    sFileName = objTools.GetMTConfigDir() & "\"
    sFileName= sFileName & "usageserver\recurring_event.xml"
	
    Set objConfig = CreateObject("Metratech.MTConfig.1")
    Set objPropSet = objConfig.ReadConfiguration(sFileName,(bCheckSum))
    
    Set objPeriodSet = objPropSet.NextSetWithName("billing_period")
    
    if objPeriodSet is nothing then
      response.write("no billing_period")
      response.end
    end if
    
    dim objEventSet
    dim objGroupSet
        
    Do While Not objPeriodSet Is Nothing
    
      'response.write("Type name " & typename(objPeriodSet) & "<BR>")
      'Set objPeriodAttrib = objPeriodSet.AttribSet
      sPeriod = objPeriodSet.AttribSet.AttrValue("uct")
      'response.write("Debug: The period is [" & sPeriod & "]. This interval is [" & sIntervalType & "].<BR>")
     
      if lcase(sPeriod)=lcase(sIntervalType) or lcase(sPeriod)="default" then
        writePeriodSectionHeader sPeriod
        
        '// Look for soft_close_events
        Set objEventSet = objPeriodSet.NextSetWithName("soft_close_events")
        
        if objEventSet is nothing then
          'response.write("no hard_close_events")
          'response.end
        else
          writeEventSectionHeader "Soft Close Events"        
          displayGroups objEventSet
        End If  
  
        '// Look for hard_close_events
        Set objEventSet = objPeriodSet.NextSetWithName("hard_close_events")
        
        if objEventSet is nothing then
          'response.write("no hard_close_events")
          'response.end
        else
          writeEventSectionHeader "Hard Close Events"        
          displayGroups objEventSet
        End If  
        
        writePeriodSectionEnd
      End If
      
      Set objPeriodSet = objPropSet.NextSetWithName("billing_period")
    Loop
 
 End Sub   
  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
   <head>
      <title>
         Run Adapters For Interval
      </title>
      <link rel='STYLESHEET' type='text/css' href=
      '/mom/default/localized/en-us/styles/DialogStyles.css'>
      <link rel='STYLESHEET' type='text/css' href=
      '/mom/default/localized/en-us/styles/MenuStyles.css'>
      <link rel='STYLESHEET' type='text/css' href=
      '/mom/default/localized/en-us/styles/styles.css'>
   </head>
   <body class="clsInnerBody">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
         <tr>
            <td class="CaptionBar" nowrap>
               Run Adapters For Interval
            </td>
         </tr>
      </table>
      <br>
       
      <div align="center">
         <form name="frmAdapterList" action="defaultDialogIntervalRunAdapter.asp" method="post">
         <input name='IntervalId' value='<%=Request("IntervalId")%>' type='hidden'>
               
             <%
              DisplayListOfAdapters Request("IntervalType")
             %>
            </table>
            <BR>
            
            
            
            <button class='clsButtonBlueXLarge' name='EditMapping' onclick="form.submit();">
            Run Selected</button>&nbsp;
            
            <!--
            <button class='clsButtonBlueXLarge' name='EditMapping' onclick=
            "window.open('protoIntervalManagement.asp?','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')">
            Run Selected</button>&nbsp;-->
         </form>
      </div>
   </body>
</html>