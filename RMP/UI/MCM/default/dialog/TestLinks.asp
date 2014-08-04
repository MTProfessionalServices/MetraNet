<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<html>
<head>
  <LINK rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH")%>/styles/styles.css">
</head>
<body>
<div class="CaptionBar">Test Links</div>

<hr size=1>
<button id="new" onClick="javascript:window.open('ProductviewPropertyPicker.asp?MonoSelect=True&IDColumnName=nm_name', '_blank', 'height=700,width=700,resizable=no,scrollbars=yes'); return false;">
  <img width="16px" height="16px" valign="middle" localized="true" src="/mcm/default/localized/en-us/images/icons/newitem.gif">
  &nbsp;&nbsp;Product View Property Picker
</button>
<div class="clsStandardTitle">Picker Dialogs</div>
<Table width="100%" border="0" cellpadding="3" cellspacing="3">
<TR>
<TD class="clickableHeader"><A HREF="ProductviewPropertyPicker.asp?NextPage=DestinationTestPage.asp&MonoSelect=True&IDColumnName=nm_name">Product View Property Picker</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Picker.asp?NextPage=DestinationTestPage.asp">Priceable Items Picker - ALL</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Picker.asp?Kind=10&NextPage=DestinationTestPage.asp">Picker - Usage</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Picker.asp?Kind=20&NextPage=DestinationTestPage.asp"> Items Picker - Recurring</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Picker.asp?Kind=30&NextPage=DestinationTestPage.asp"> Picker - Non Recurring</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Picker.asp?Kind=40&NextPage=DestinationTestPage.asp"> Picker - Discount</a></TD>
</TR>

<TR>
<TD class="clickableHeader"><A HREF="PriceableItem.Picker.asp?NextPage=DestinationTestPage.asp&MonoSelect=True">Priceable Items Picker - ALL - Mono Selection</a></TD>

</TR>
</table>
<br>
<table border="0" cellpadding="3" cellspacing="3">
<TR>
<TD class="clickableHeader"><A HREF="ProductOffering.Picker.asp?NextPage=DestinationTestPage.asp&Parameters=A|1;B|2">Product Offering Picker</a></TD>
<TD class="clickableHeader"><A HREF="<%=FrameWork.GetDictionary("PRICE_LIST_PICKER_DIALOG")%>?NextPage=DestinationTestPage.asp" target="_blank">Price List Picker</A></TD>
<TD class="clickableHeader"><A HREF="CounterList.Picker.asp?NextPage=DestinationTestPage.asp">Counter List Picker</a></TD>
</TR>
</table>
<br>
<div class="clsStandardTitle">List Dialogs</div>
<table width="100%" border="0" cellpadding="3" cellspacing="3">
<TR>
<TD class="clickableHeader"><A HREF="PriceableItem.List.asp?NextPage=DestinationTestPage.asp">Priceable Items List - ALL</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.List.asp?Kind=10&NextPage=<%=FrameWork.GetDictionary("PRICEABLE_ITEM_USAGE_VIEW_EDIT_DIALOG")%>">Priceable Items List - Usage</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.List.asp?Kind=20&NextPage=DestinationTestPage.asp">Priceable Items List - Recurring</a></TD>
</tr>
<tr>
<TD class="clickableHeader"><A HREF="PriceableItem.List.asp?Kind=30&NextPage=DestinationTestPage.asp">Priceable Items List - Non Recurring</a></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.List.asp?Kind=40&NextPage=DestinationTestPage.asp">Priceable Items List - Discount</a></TD>
</TR>
<TR>
  <TD class="clickableHeader"><A HREF="<%=FrameWork.GetDictionary("PRICE_LIST_LIST_DIALOG")%>?NextPage=DestinationTestPage.asp&Parameters=POBased|False;">Price List List</A></TD>
  <TD class="clickableHeader"><A HREF="Counter.List.asp?NextPage=DestinationTestPage.asp">Counter List</A></TD>
</TR>
</table>
<br>
<div class="clsStandardTitle">Edit/View Dialogs</div>
<table width="100%" border="0" cellpadding="3" cellspacing="3">
<TR>
<TD class="clickableHeader"><A HREF="PriceAbleItem.RecurringCharge.ViewEdit.asp?id=1014">Recurring charge</A></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.NonRecurring.ViewEdit.asp?id=1042">Non Recurring charge</A></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Usage.ViewEdit.asp?id=1015">Usage</A></TD>
<TD class="clickableHeader"><A HREF="PriceableItem.Discount.ViewEdit.asp?id=1020">Discount</A></TD>
<TD class="clickableHeader"><A HREF="Counters.ViewEdit.asp?id=1020">Counter</A></TD></TR>

</TABLE>
<br>
<div class="clsStandardTitle">Rates</div>
<Table border="0" cellpadding="3" cellspacing="3">
<TR><TD class="clickableHeader"><A HREF="PriceAbleItem.List.asp?kind=10&NextPage=PriceableItem.ParamTable.ViewEdit.asp&Title=TEXT_SERVICE_RATE_PRICEABLE_ITEM_LIST&LinkColumnMode=TRUE">Pricelist Rate Navigation</A></TD></TR>
</TABLE>
<br>
<div class="clsStandardTitle">Wizard Test Links</div>
<Table border="0" cellpadding="3" cellspacing="3">
<TR><TD class="clickableHeader"><A HREF="wizard/CreatePO/wizardstart.asp?Path=/mcm/default/dialog/wizard/CreatePO&PageID=start">New Product Offering Wizard</A></TD></TR>
<TR><TD class="clickableHeader"><A HREF="wizard/AddUsage/wizardstart.asp?Path=/mcm/default/dialog/wizard/AddUsage&PageID=start">Add Usage Based Priceable Item Wizard</A></TD></TR>
<TR><TD class="clickableHeader"><A HREF="wizard/AddRecurringCharge/wizardstart.asp?Path=/mcm/default/dialog/wizard/AddRecurringCharge&PageID=start">Add Recurring Charge Wizard</A></TD></TR>
<TR><TD class="clickableHeader"><A HREF="wizard/CreatePriceList/wizardstart.asp?Path=/mcm/default/dialog/wizard/CreatePriceList&PageID=start">Create Price List</A></TD></TR>
</TABLE>
<BR><BR>
<button id="new" onClick="javascript:window.open('wizard/CreatePO/Wizard.asp?Path=/mcm/default/dialog/wizard/CreatePO&PageID=start', '_blank', 'height=400,width=600,resizable=no,scrollbars=yes'); return false;">
  <img width="16px" height="16px" valign="middle" localized="true" src="/mcm/default/localized/en-us/images/icons/newitem.gif">
  &nbsp;&nbsp;Create New Product Offering
</button>
<BR><BR>
<button id="new" onClick="javascript:window.open('wizard/CreatePriceList/wizardstart.asp?Path=/mcm/default/dialog/wizard/CreatePriceList&PageID=start', '_blank', 'height=400,width=600,resizable=no,scrollbars=yes'); return false;">
  <img width="16px" height="16px" valign="middle" localized="true" src="/mcm/default/localized/en-us/images/icons/newitem.gif">
  &nbsp;&nbsp;Create New Price List
</button>
<BR><BR>
<button id="new" onClick="javascript:window.open('wizard/AddRecurringCharge/wizardstart.asp?Path=/mcm/default/dialog/wizard/AddRecurringCharge&PageID=NewType&CREATENEW=TRUE', '_blank', 'height=400,width=600,resizable=no,scrollbars=yes'); return false;">
  <img width="16px" height="16px" valign="middle" localized="true" src="/mcm/default/localized/en-us/images/icons/newitem.gif">
  &nbsp;&nbsp;Create New Recurring Charge
</button>
<BR><BR>
<button id="new" onClick="javascript:window.open('wizard/AddNonRecurringCharge/wizard.asp?Path=/mcm/default/dialog/wizard/AddNonRecurringCharge&PageID=start', '_blank', 'height=400,width=600,resizable=no,scrollbars=yes'); return false;">
  <img width="16px" height="16px" valign="middle" localized="true" src="/mcm/default/localized/en-us/images/icons/newitem.gif">
  &nbsp;&nbsp;Create New Non Recurring Charge
</button>
<BR><BR>
<button id="new" onClick="javascript:window.open('wizard/AddDiscount/wizard.asp?Path=/mcm/default/dialog/wizard/AddDiscount&PageID=start', '_blank', 'height=400,width=600,resizable=no,scrollbars=yes'); return false;">
  <img width="16px" height="16px" valign="middle" localized="true" src="/mcm/default/localized/en-us/images/icons/newitem.gif">
  &nbsp;&nbsp;Create New Discount
</button><BR>
            <button
                style="vertical-align: middle;"
                onclick="window.open('/mcm/default/dialog/ProductOffering.Picker.asp?NextPage=Welcome.asp&MonoSelect=TRUE&OptionalColumn=nm_name&Parameters=POMode|source','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes'); return false;">
                Select A Product Offering
                &nbsp;<IMG align=middle alt="" border=0 src="/mcm/default/localized/en-us/images/icons/arrowSelect.gif">
            </button>
<br>
<button  onClick="javascript:window.open('ProductOffering.Picker.asp?NextPage=DestinationTestPage.asp&Parameters=A|1;B|2', '_blank', 'height=400,width=600,resizable=no,scrollbars=yes'); return false;">
Product Offering Picker
</button>
</body>
</html>
