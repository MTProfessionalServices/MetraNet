<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Session("HelpContext") = "AdvancedDialog.hlp.htm"
%>
<html>
<head>
  <LINK rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH")%>/styles/styles.css">
</head>
<body>
<div class="CaptionBar"><%=FrameWork.GetDictionary("TEXT_ADVANCED_DIALOG")%></div>
<br>
<div class="clsStandardTitle"><%=FrameWork.GetDictionary("TEXT_ADVANCED_DIALOG_DESCRIPTION")%>
</div>
<br><br>
<table cellspacing="5" cellpadding="5">
  <!--<tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butPriceListDialog" id="butPriceListDialog" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("PRICELIST_LIST_DIALOG")%>?NextPage=Pricelist.Edit.asp'">
  				<%=FrameWork.GetDictionary("TEXT_EDIT_PRICELIST") %>
				</button>
			</div>
		</td>
    <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_EDIT_PRICELIST_DESCRIPTION") %>
    </td>
	</tr>-->
  <!-- SCOPED for 3.5
  <tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butPriceListDialog" id="butPriceListDialog" onClick="JavaScript:document.location.href='ManageDiscountCounters.asp'">
  				Manage Counter Parameters
				</button>
			</div>
		</td>
    <td class="clsLargeText" width="300">
       Add new Counter Parameters and edit their descriptions, property mappings, and predicate logic. 
    </td>
	</tr> -->

  <tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butManageCalendars" id="butManageCalendars" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("ADVANCED_MANAGE_CALENDARS_DIALOG")%>'">
   				<%=FrameWork.GetDictionary("TEXT_MANAGE_CALENDARS") %>
				</button>
			</div>
		</td>
    <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_MANAGE_CALENDARS_DESCRIPTION") %>
    </td>
	</tr>	

  <!-- View All Rates SCOPED for 3.5 -->
	<!-- *** Delete this line to re-enable View All Rates ***

  <tr>
    <td>
      <div style="margin:3">
      	<button class="clsButtonBlueXXXLarge" name="butViewAllRates" id="butViewAllRates" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("VIEW_ALL_RATES_DIALOG")%>'">
          <%=FrameWork.GetDictionary("TEXT_VIEW_ALL_RATES")%>
      	</button>
      </div>    
    </td>
    <td class="clsLargeText" width="300">
        <%=FrameWork.GetDictionary("TEXT_VIEW_ALL_RATES_DESCRIPTION")%>
    </td>
 </tr>
 <tr>
    <td>
      <div style="margin:3">
      	<button class="clsButtonBlueXXXLarge" name="butViewAllRatesByPriceableItem id="butViewAllRatesByPriceableItem" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("VIEW_ALL_RATES_BY_PRICEABLE_ITEM_TYPE_DIALOG")%>'">
          <%=FrameWork.GetDictionary("TEXT_VIEW_ALL_RATES_BY_PRICEABLE_ITEM_TYPE")%>
      	</button>
      </div>
    </td>
    <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_VIEW_ALL_RATES_BY_PRICEABLE_ITEM_TYPE_DESCRIPTION")%>
    </td>
  </tr> <!-- -->

	<tr>
		<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butBulkSubscription" id="butBulkSubscription" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("BULK_SUBSCRIPTION_CHANGE_DIALOG")%>'">
			  	<%=FrameWork.GetDictionary("TEXT_BULK_SUBSCRIPTION_CHANGE") %>
				</button>
 			</div>
		</td>
	  <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_BULK_SUBSCRIPTION_CHANGE_DESCRIPTION") %>
    </td> 
  </tr>

  <tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butAuditListDialog" id="butAuditListDialog" onClick="JavaScript:document.location.href='AuditLog.List.asp'">
   				<%=FrameWork.GetDictionary("TEXT_VIEW_AUDIT_LOG") %>
				</button>
        <!-- Test link to open audit log in separate window -->
        <img src="../localized/en-us/images/spacer.gif" width="10" height="10" border="0" alt="Open Audit Log In Separate Window"  onClick="javascript:window.open('AuditLog.List.asp', '_blank', 'height=100,width=100, resizable=yes, scrollbars=yes,'); return false;"></i>
        <!--<A href="javascript:window.open('AuditLog.List.asp', '_blank', 'height=100,width=100, resizable=yes, scrollbars=yes,'); return false;" alt="Open Audit Log In Separate Window">&nbsp;</a>-->
			</div>
		</td>
    <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_AUDIT_LOG_DESCRIPTION") %>
    </td>
	</tr>
  
  <!--
  <tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butManageReasonCodes" id="butManageCalendars" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("VIEW_ADJUSTMENT_REASON_CODE_DIALOG")%>'">
   				<%=FrameWork.GetDictionary("TEXT_MANAGE_ADJUSTMENT_REASON_CODES") %>
				</button>
			</div>
		</td>
    <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_MANAGE_ADJUSTMENT_REASON_CODES_DESCRIPTION") %>
    </td>
	</tr>	
-->
  <tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butManageHiddenPOs" id="butManageHiddenPOs" onClick="JavaScript:document.location.href='<%=FrameWork.GetDictionary("VIEW_HIDDEN_POS_DIALOG")%>'">
   				<%=FrameWork.GetDictionary("TEXT_MANAGE_HIDDEN_POS") %>
				</button>
			</div>
		</td>
    <td class="clsLargeText" width="300">
       <%=FrameWork.GetDictionary("TEXT_MANAGE_HIDDEN_POS_DESCRIPTION") %>
    </td>
	</tr>	
  
	
  <!--
  <tr>
  	<td>
			<div style="margin:3">
				<button class="clsButtonBlueXXXLarge" name="butPriceListDialog" id="butPriceListDialog" onClick="javascript:window.open('AuditLog.List.asp', '_blank', 'height=100,width=100, resizable=yes, scrollbars=yes,'); return false;">View Audit Log In Separate Window
				</button>
			</div>
		</td>
    <td class="clsLargeText" width="300">
       Audit Log Test Window
    </td>
	</tr>
  -->
  
</table>
<br>
</body>
</html>
