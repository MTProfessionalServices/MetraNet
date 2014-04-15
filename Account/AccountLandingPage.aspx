<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_AccountLandingPage"
   Culture="auto" UICulture="auto" CodeFile="AccountLandingPage.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="../UserControls/Analytics/AccountSummary.ascx" tagname="AccountSummary" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script type="text/javascript">
    // Sometimes when we come back from old MAM or MetraView we may have an extra frame.
    // This code busts out of it.
//    Ext.onReady(function(){
//      if(getFrameMetraNet().MainContentIframe )
//      {
//        if(getFrameMetraNet().MainContentIframe.location != document.location)
//        {
//          getFrameMetraNet().MainContentIframe.location.replace("../StartWorkFlow.aspx?WorkFlowName=GroupSubscriptionsWorkflow");
//        }
//      }
//    });
  </script>

  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script> 
  <script type="text/javascript" src="/Res/JavaScript/Bullet.js"></script>
  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">

  <div class="CaptionBar">
    <asp:Label ID="lblAccount360Title" runat="server" Text="Account 360"></asp:Label>
  </div>
  <div>
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
      Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  </div>

  <style>

.gridster .widget {}

.rounded {
  background-color: rgb(240, 248, 255);
  border: 1px solid rgb(153, 153, 153);
  /*border: solid 1px #ccc;*/
  -moz-box-shadow: 1px 1px 3px rgba(0,0,0,.4);
  -webkit-box-shadow: 1px 1px 3px rgba(0,0,0,.4);
  box-shadow: 1px 1px 4px rgba(0,0,0,.4);
  -moz-border-radius: 4px;
  -webkit-border-radius: 4px;
  border-radius: 4px;
  background: #f1f1f1; 
}

#ctl00_ContentPlaceHolder1_lblAccount360Title {
color: #ddd;
font-size: 150%;
}

.x-panel-header-text {
font-size: 120%;
font-weight: bold;
color: #888;
}

.x-panel-tl .x-panel-icon , .x-window-tl .x-panel-icon {
padding-left: 3px !important ;
}


/*Styles for items displayed in grid rows*/
.ItemName {
  font-weight: bold;
}

.ItemDescription {
  font-style: italic;
  font-size: smaller;
}

#AccountSummaryInformation {
  color: #666;
}
.AccountName {
  font-size: 200%;
}

.AccountIdentifier {
  font-weight: bold;
}

  .bullet
  {
    font: 10px sans-serif;
  }
  .bullet .marker
  {
    stroke: #000;
    stroke-width: 3px;
  }
  .bullet .marker.good
  {
    stroke: Green;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .marker.bad
  {
    stroke: Red;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .marker.past
  {
    stroke: Blue;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .tick line
  {
    stroke: #666;
    stroke-width: .5px;
  }
  .bullet .tick.major line
  {
    stroke: #666;
    stroke-width: .5px;
  }
  .bullet .tick.selected
  {
    font-weight:bolder;
  }
  .bullet .tick.expired
  {
    text-decoration:line-through;
  }
  .bullet .tick.future
  {
    font-style:italic;
  }
  .bullet .domain
  {
    fill: none;
  }
  .bullet .title
  {
    fill: #000;
    display: block;
    font-size: 14px;
    font-weight: bold;
    position: absolute;
    text-anchor: off;
  }
  .bullet .range.s0
  {
    display: block;
    position: absolute;
  }
  .bullet .subtitle
  {
    fill: #999;
    text-anchor: off;
  }
  .bullet .dates
  {
    fill: #000;
    text-anchor: off;
  }
  .bullet .tbutton
  {
    fill:white;
    stroke-width:1;
    stroke:black;
    stroke-opacity:0.05;
  }
  .bullet .notice
  {
    fill:#000;
    font-size: 7px;
    text-anchor: off;
  }
  .bullet .tick
  {
    fill:#000;
  }
.contextmenu {
-moz-border-radius:10px;
-webkit-border-radius:10px;
-khtml-border-radius:10px;
border-radius:10px;
}
.contextmenu li
{
  list-style-type:none;
  padding-left: 20px;
  padding-right: 5px;
}
.contextmenu li:hover
{
  font-weight:bolder;
}
.datepicker {
-moz-border-radius:10px;
-webkit-border-radius:10px;
-khtml-border-radius:10px;
border-radius:10px;
overflow-y:auto;
overflow-x:visible;
max-height: 100px;
}
.datepicker li
{
  list-style-type:none;
  padding-left: 20px;
  padding-right: 5px;
white-space:nowrap;
}
.datepicker li:hover
{
  font-weight:bolder;
}
#MyFormDiv_ctl00_ContentPlaceHolder1_pnlNowCast .x-panel {
  width: 100%;
  height: 100%;
  padding-right: 30px;
  margin-right: 30px;
}
#MyFormDiv_ctl00_ContentPlaceHolder1_billingActivityPanel .mtpanel {
}
#MyFormDiv_ctl00_ContentPlaceHolder1_billingActivityPanel .x-panel {
}

#MyFormDiv_ctl00_ContentPlaceHolder1_salesSummaryPanel .x-panel {
  width: 100%;
  height: 100%;
  padding-right: 30px;
  margin-right: 30px;
}


 .widgetpanel { /* Taken from x-panel and x-gridpanel */
   float: left;
   border-bottom-color: #d0d0d0;
   margin: 5px 5px 5px 10px;
   border-color: #ccc;
   -moz-border-radius: 2px;
   -webkit-border-radius: 2px;
   border-radius: 2px;
   background-color: #f1f1f1;
   border: solid 1px #ccc;
   height: 75px;
   color: #666;
 }
 
 .widgetpanel .valueLabel {
  padding-left: 5px;
  text-align: left;
  font-size: smaller;
  color: #a1a1a1;
 }
 
  .widgetpanel .valueHighlighted {
    text-align: center;
    display: block;
    padding-top: 10px;
    font-size: 18px;
 }

 .widgetpanel .positive {
  color: darkgreen;
 }
  .widgetpanel .valueDetail {
    text-align: right;
    padding-right: 5px;
    display: block;
    padding-top: 10px;
    font-size: smaller;
    color: #a1a1a1;
 } 

  .widgetpanel .footer {
    /*position: absolute; */
    bottom: 0; 
 }  
 
  </style>

  <script type="text/javascript">
    //Initialize gridster
//    jQuery(function () {
//      var widgets = $('.widget');

//      var currentDashboard = $(".gridster").gridster({
//        widget_selector: widgets,
//        //jQuery(".gridster ul").gridster({
//        widget_margins: [10, 10],
//        widget_base_dimensions: [100, 100]
//      }).data('gridster');

////      gridster = $(".gridster ul").gridster({
////        widget_base_dimensions: [100, 100],
////        widget_margins: [5, 5],
////        helper: 'clone',
////        resize: { enabled: false },
////        autogrow_cols: true
////      }).data('gridster');

//    });

  </script>
  
  <div class="gridster">
<%--	  <ul>--%>
  <div class="widget" data-row="1" data-col="1" data-sizex="3" data-sizey="1">
  <div id="AccountSummaryInformation" style="padding: 15px;"></div>
  </div>
  
  <div id="AccountStatus" class="widgetpanel" style="width:150px; display:none;">
    <div id="Div1"><span class="valueLabel">Status</span><span class="valueHighlighted positive">N/A</span></div>
  </div>
  
  <div id="BalanceInformation" class="widgetpanel" style="width:150px; display:none;">
    <div><span class="valueLabel">Balance</span><span class="valueHighlighted">$13,569.23</span><span class="valueDetail footer">as of March 1st, 2014</span></div>
  </div>

<%--  <div class="widgetpanel" style="width:150px;">
    <div id="Div2"><span class="valueLabel">Balance</span><span class="valueHighlighted">$13,569.23</span><span class="valueDetail footer">as of March 1st, 2014</span></div>
  </div>--%>

  <div class="widgetpanel" style="width:300px;">
    <div id="Div3" style="float:left;margin-left: 10px;"><span class="valueLabel">LTV</span><span class="valueHighlighted" style='padding-left: 10px;'>$109,569.23</span></div>
    <div id="Div4" style="float:left;margin-left: 10px"><span class="valueLabel">MRR</span><span class="valueHighlighted" style="padding: 10px;">$9,569.23</span></div>
  </div>
  
  <br style="clear: both;" />

<%--  <div class="widgetpanel" style="width:300px; display: none;">
    <div id="AccountBalanceInformation" style="padding: 15px;">Balance Information</div>
  </div>
  
  <MT:MTPanel ID="MTPanel1" runat="server" Collapsed=false Collapsible="False" Visible="false" >
    <div id="AccountBalanceInformation"></div>
  </MT:MTPanel>--%>
  
   <br style="clear: both;" />
  </div>

  <div class="widget" data-row="3" data-col="1" data-sizex="8" data-sizey="1">
<%--  <img src="/Res/Images/Mockup/MetangaAccountSummaryAnalytic.png" width="720px;" style="padding: 15px;"/>
    <MT:MTPanel ID="SalesSummaryPanel" runat="server" Text="Sales Summary" >
      <div id="SalesSummaryInformation"></div>
    </MT:MTPanel>
    <MT:MTFilterGrid ID="SalesSummaryGrid" runat="server" TemplateFileName="SalesSummary.xml" ExtensionName="Account" Resizable="False" Title="Sales Summary"></MT:MTFilterGrid> --%>
  </div>
  
  <table style="width:100%; height:100%;"><tr style="vertical-align:top;"><td style="width:380px; height:336px;">
  <div class="widget" data-row="4" data-col="1" data-sizex="3" data-sizey="3">
    <MT:MTPanel ID="billingActivityPanel" runat="server" Text="Billing Activity" Width="380">
      <div id="billsPaymentsChart" style="width:100%; height:100%;"></div>
    </MT:MTPanel>
  </div>
  </td><td>
  <div class="widget" data-row="4" data-col="4" data-sizex="5" data-sizey="3">
    <MT:MTPanel ID="billingSummaryPanel" runat="server" Text="Invoices & Payments" Width="500">
      <MT:MTFilterGrid ID="BillingSummaryGrid" runat="server" TemplateFileName="AccountBillingSummary.xml" ExtensionName="Account" Resizable="False"></MT:MTFilterGrid>
    </MT:MTPanel>
  </div>
  </td></tr></table>

  <div class="widget" data-row="7" data-col="1" data-sizex="8" data-sizey="3">
  <MT:MTFilterGrid ID="SubscriptionSummaryGrid" runat="server" TemplateFileName="AccountSubscriptionSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
  </div>
  
  <div class="widget" data-row="8" data-col="1" data-sizex="8" data-sizey="3">
  <MT:MTFilterGrid ID="InvoiceSummaryGrid" runat="server" TemplateFileName="AccountInvoiceSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
  </div>
  
  <div class="widget" data-row="9" data-col="1" data-sizex="8" data-sizey="3">
    <MT:MTFilterGrid ID="PaymentGrid" runat="server" TemplateFileName="AccountPaymentSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
  </div>
  
  <div class="widget" data-row="10" data-col="1" data-sizex="8" data-sizey="3">
    <MT:MTPanel ID="pnlNowCast" runat="server" Text="NowCast">
      <div id="NowCast-body"></div>
    </MT:MTPanel>
  </div>
  

<%--  <MT:MTFilterGrid ID="PaymentGrid" runat="server" TemplateFileName="AccountPaymentTransactionList.xml"
    ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
    FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    MultiSelect="False" PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    TotalProperty="TotalRows">
  </MT:MTFilterGrid>
--%>
<%--
  <MT:MTFilterGrid ID="PaysFor" runat="server" TemplateFileName="AccountPaymentTransactionList.xml"
    ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
    FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    MultiSelect="False" PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    TotalProperty="TotalRows">
  </MT:MTFilterGrid>--%>
  
  </div>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  
  <script type="text/javascript">
    
    //MOVE THIS TO GENERIC FUNCTION HANDLER TO BE INCLUDED
    // Event handlers
    function onAddRegularSubscription_<%=SubscriptionSummaryGrid.ClientID %>()
    {
//      //Execute: function(operation, args, callbackMethod)
//      if (checkButtonClickCount() == true) {
//        pageNav.Execute("SubscriptionsEvents_Subscribe_Client", null, null);
//      }    
      document.location.href = "/MetraNet/StartWorkFlow.aspx?WorkflowName=SubscriptionsWorkflow&StartWithStep=AddStep"; 
    }
    
    function onAddAccountToGroupSubscription_<%=SubscriptionSummaryGrid.ClientID %>()
    {
//      //Execute: function(operation, args, callbackMethod)
//      if (checkButtonClickCount() == true) {
//        pageNav.Execute("GroupSubscriptionsEvents_JoinGroupSubscription_Client", null, null);
//      
//      }

      document.location.href = "/MetraNet/StartWorkFlow.aspx?WorkflowName=GroupSubscriptionsWorkflow&StartWithStepGr=JoinStep";
    }

    function caseNumberColRenderer(value, meta, record, rowIndex, colIndex, store) {
      return String.format("<span style='display:inline-block; vertical-align:middle'>&nbsp;<a style='cursor:hand;vertical-align:middle' id='editcase_{0}' title='{1}' href='JavaScript:onEditFailedTransaction(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\");'>{0}&nbsp;<img src='/Res/Images/icons/database_edit.png' alt='{1}' align='middle'/></a></span>", record.data.casenumber, window.TEXT_EDIT_FAILED_TRANSACTION, record.data.failurecompoundsessionid, record.data.compound, store.sm.grid.id);
    }

    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store) {
      var str = "";
      //str += String.format("<span style='display:inline-block; vertical-align:middle'>&nbsp;<a style='cursor:hand;vertical-align:middle' id='viewaudit_{0}' title='{1}' href='JavaScript:onViewFailedTransactionAuditLog(\"{0}\",\"{2}\");'>View Log&nbsp;</a></span>", record.data.subscriptionid, TEXT_VIEW_AUDIT_FAILED_TRANSACTION, record.data.subscriptionid);

      return str;
    }

    function typeColRenderer(value, meta, record, rowIndex, colIndex, store) {
      return String.format("<span style='display:inline-block; vertical-align:middle'><img src='/Res/Images/icons/ProductCatalog_{0}.png' alt='{1}' align='middle'/></span>", record.data.subscriptiontype, value);
 
    }


    function subscritionInformationColRenderer(value, meta, record, rowIndex, colIndex, store) {
      meta.attr = 'style="white-space:normal"';
      var str = "";
  
      if (record.data.subscriptiontype === 'Subscription') {
        str = String.format("<a href='JavaScript:edit({0});' class='ItemName'>{1}</a><br/><span class='ItemDescription'>{2}</span>", record.json.subscriptionid, record.json.productofferingname, (record.json.productofferingdescription || ''));
      } else {
        str = String.format("<span class='ItemName'>{0}</span><br/><span class='ItemDescription'>{1}</span><br /><br /><span class='ItemName'>{2}</span><br/><span class='ItemDescription'>{3}</span>", record.data.productofferingname, (record.json.productofferingdescription || ''), (record.json.groupsubscriptionname  || ''), (record.json.groupsubscriptiondescription || ''));
        //null AS 'GroupSubscriptionDescription')
      }
  
      //return String.format("<span style='display:inline-block; vertical-align:middle'><img src='/Res/Images/icons/ProductCatalog_{0}.png' alt='{1}' align='middle'/></span>{2}", record.data.subscriptiontype, value, str);
      return str;
    }
    
    function edit(n) {
      if (checkButtonClickCount() == true) {
      document.location.href = "/MetraNet/StartWorkFlow.aspx?WorkflowName=SubscriptionsWorkflow&StartWithStep=" + n; 
      }
    }

    // Custom Renderers
    OverrideRenderer_<%= SubscriptionSummaryGrid.ClientID %> = function(cm)
    {  
      cm.setRenderer(cm.getIndexById('subscriptiontype'), typeColRenderer);
      cm.setRenderer(cm.getIndexById('productofferingname'), subscritionInformationColRenderer);
      cm.setRenderer(cm.getIndexById('actions'), actionsColRenderer); 
    };
    
//    function onCancel_<%= SubscriptionSummaryGrid.ClientID %>()
//    {
//      //pageNav.Execute("GroupSubscriptionsEvents_Back_ManageGroupSubscriptions_Client", null, null);
//    }

//    function edit(n)
//    {
//      var args = "GroupSubscriptionId=" + n;
//      //pageNav.Execute("GroupSubscriptionsEvents_Edit_Client", args, null);            
//    }

//    function rates(n)
//    {
//      var args = "GroupSubscriptionId=" + n;
//      document.location.href = "/MetraNet/TicketToMAM.aspx?URL=/mam/default/dialog/DefaultDialogRates.asp|id_group=" + n + "**LinkColumnMode=TRUE**NewMetraCare=TRUE";          
//    }
//    
//    function members(n)
//    {   
//      var args = "GroupSubscriptionId=" + n;         
//      pageNav.Execute("GroupSubscriptionsEvents_Members_Client", args, null);
//    }
//       
//    function deleteGroupSub(n)
//    {
//      var args = "GroupSubscriptionId=" + n;      
//      pageNav.Execute("GroupSubscriptionsEvents_Delete_Client", args, null);
//    }
//    
//    function unsubscribeFromGroupSub(n)
//    {
//      var args = "GroupSubscriptionId=" + n;      
//      pageNav.Execute("", args, null);
//    }   
//      
//    function removeGroupSubMembership(n)
//    {
//      var args = "GroupSubscriptionId=" + n;      
//      pageNav.Execute("", args, null);
//    }    
//            
//    function onAdd_<%=SubscriptionSummaryGrid.ClientID %>()
//    {
//      pageNav.Execute("GroupSubscriptionsEvents_Add_Client", null, null);
//    }
//     function onJoin_<%=SubscriptionSummaryGrid.ClientID %>()
//    {
//      pageNav.Execute("GroupSubscriptionsEvents_JoinGroupSubscription_Client", null, null);
//    }
//    
//    
//    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
//    {
//      var str = "";      
//          
//      // Edit Link
//      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
//      {     
//         if(<%=IsCorporate.ToString().ToLower() %>)
//         {
//                //str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.GroupId, value);
//                str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
//         } 
//      }


//     str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
//      
//        // Rates button
//      str += String.format("&nbsp;<a style='cursor:hand;' id='rates' href='javascript:rates({0})'><img src='/Res/Images/icons/money.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_RATES);
//      

//      // Members button
//      if(<%= UI.CoarseCheckCapability("Modify groupsub membership").ToString().ToLower() %>)
//      {
//        str += String.format("&nbsp;<a style='cursor:hand;' id='members' href='javascript:members({0})'><img src='/Res/Images/icons/group_add.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_MEMBERS);
//      }
//      
//      // Delete button
//      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
//      {
//        if(<%=IsCorporate.ToString().ToLower() %>)
//        {
//          str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:deleteGroupSub({0})'><img src='/Res/Images/icons/cross.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_DELETE);
//        }
//      }      
//       

//      return str;
//    };    

//    EditLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
//    {
//      var str = "";
//      
//      // Edit Link
//      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
//      {     
//         if(<%=IsCorporate.ToString().ToLower() %>)
//         {
//                str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.GroupId, value);
//         }
//         else
//         {
//            str += value;
//         }  
//      }
//      
//      
//      return str;
//    };


    // Account 360 Properties Template - TODO: Move to Account360Templates.js once closer to done
    var baseAccount360Tpl = new Ext.XTemplate(
      '<div>',
      '<tpl if="this.hasLDAP([values])">',

      '<tpl for="LDAP">',
      '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == false)">',
      '<span class="AccountName">{FirstName:htmlEncode} {LastName:htmlEncode}</span><br/>',
      '</tpl>',
//      '<tpl if="this.isNull(Company) == false">',
//        '<span class="{[false == true  ? "AccountName" : "AccountCompanyName"]}">{Company:htmlEncode}</span><br/>',
//      '</tpl>',
      '<tpl if="this.isNull(Company) == false">',
      '<tpl if="(this.isNull(LastName) == false)">',
      '<span>{Company:htmlEncode}</span><br/>',
      '</tpl>',
      '<tpl if="(this.isNull(LastName) == true)">', //ELSE
      '<span class="AccountName">{Company:htmlEncode}</span><br/>',
      '</tpl>',      
      '</tpl>',      
      '<tpl if="(this.isNull(FirstName) == true) && (this.isNull(LastName) == false)">',
      '<span class="AccountName">{LastName:htmlEncode}</span><br/>',
      '</tpl>',
      '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == true)">',
      '<span>{FirstName:htmlEncode}</span><br/>',
      '</tpl>',
      '</tpl>',
      '</tpl>',
      '<span class="AccountIdentifier">{UserName} ({_AccountID})</span><br/>',
      '<br />',
      '<tpl for="Internal">',      
      //'{UsageCycleTypeValueDisplayName} {Currency} {LanguageValueDisplayName}<br/>',
      //'{UsageCycleTypeDisplayName}: {UsageCycleTypeValueDisplayName}<br/>', 
      '<span>{UsageCycleTypeValueDisplayName}<span><br/>',           
      '</tpl>',     
      '<br><span>Account Status: {AccountStatusValueDisplayName} <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/AccountStateSetup.asp">Change</a></span><br/>',
      '<tpl for="Internal">',      
      //'{UsageCycleTypeValueDisplayName} {Currency} {LanguageValueDisplayName}<br/>',
      //'{UsageCycleTypeDisplayName}: {UsageCycleTypeValueDisplayName}<br/>',      
      '</tpl>',          
      //'{Internal.UsageCycleTypeDisplayName}: {Internal.UsageCycleTypeValueDisplayName}<br/>',      
      //'{AccountStartDate}<br/>',
      //'<span>Payer {_AccountID} {PayerID} {PayerAccount} </span><br/>',
      '<tpl if="(_AccountID == PayerID)">',
      '<span>This account pays for itself</span> <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/PayerSetupHistory.asp">Change</a></span><br/>',
      '</tpl>', 
      '<tpl if="(_AccountID != PayerID)">',
      //'<span>This account is paid for by <img alt="" src="/ImageHandler/images/Account/CorporateAccount/account.gif?Payees=0&amp;State=AC&amp;Folder=TRUE&amp;FolderOpen=FALSE" /><a href="/MetraNet/ManageAccount.aspx?id=946270527">{PayerAccount}</a></span> <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/PayerSetupHistory.asp">Change</a></span><br/>',
      '<span>This account is paid for by <a href="/MetraNet/ManageAccount.aspx?id={PayerID}">{PayerAccount} ({PayerID})</a></span> <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/PayerSetupHistory.asp">Change</a></span><br/>',
     '</tpl>',  
   
 
      '</tpl>',

      '', {
        isNull: function (inputstring) {
          var res = false;
          if ((inputstring == null) || (inputstring == '') || (inputstring == 'null')) {
            res = true;
          }
          return res;
        }
        ,
        hasLDAP: function (accObj) {
          if (accObj == undefined) {
            return false;
          }
          if (accObj[0] == undefined) {
            return false;
          }

          if (accObj[0].LDAP == undefined) {
            return false;
          }

          return true;
        }
      }
    );

    var CoreSubscriberTpl = baseTpl;
    var CorporateAccountTpl = baseTpl;
    var SystemAccountTpl = baseTpl;
    var IndependentAccountTpl = baseTpl;
    var DepartmentAccountTpl = baseTpl;
    var Tpl = baseTpl;   

    Ext.onReady(function(){


      var jsonData = getFrameMetraNet().accountJSON;
      var templateData = baseAccount360Tpl; //getFrameMetraNet().accountTemplate;

      if (jsonData === undefined)
        return;

      //Refresh accountSummaryPanel
      var accSummaryDiv = document.getElementById('AccountSummaryInformation');
      if (accSummaryDiv != null) {
        if (jsonData != null || jsonData != "") {
          try {
            if (templateData && templateData != "") {
              templateData.overwrite(accSummaryDiv, jsonData);
            }
          }
          catch (e) {
            getFrameMetraNet().Ext.UI.msg("Error1", e.message);
          }
        }
      }
       
//    });
    
//      var pBalanceInformation = new Ext.Panel({
//        items: [{
//            title: 'Balance',
//            header: false,
//            html: '',
//            renderTo: 'AccountBalanceInformation',
//            listeners: {
//              render: function (panel) {
//                var balanceInfoTpl = new Ext.XTemplate('<span>Balance {currentbalance} as of {currentbalancedate}</span>');           

//                Ext.Ajax.request({
//                  url: '/MetraNet/AjaxServices/ManagedAccount.aspx?operation=balancesummary',
//                  timeout: 10000,
//                  params: {},
//                  success: function (response) {
//                    if (response.responseText == '[]' || Ext.decode(response.responseText).Items[0] == null) {
//                      //Nothing to show, hide the panel
//                      //pBalanceInformation.hide();
//                      //Ext.get("AccountBalanceInformation").hide();
//                    }
//                    else {
//                      balanceInfoTpl.overwrite(this.body, Ext.decode(response.responseText).Items[0]);
//                      
////                      Ext.get("AccountBalanceInformation").fadeIn({
////                        endOpacity: 1, //can be any value between 0 and 1 (e.g. .5)
////                        easing: 'easeOut',
////                        duration: 2
////                      });
//                    }

//                  },
//                  failure: function () {
//                  },
//                  scope: panel
//                });
//              }
//            }
//          }
//        ]
//      });

//    });
//Ext.get("AccountBalanceInformation").hide(); 

    
                var balanceInfoTpl = new Ext.XTemplate('<span class="valueLabel">Balance</span><span class="valueHighlighted">{currentbalance} </span><span class="valueDetail footer">as of {currentbalancedate:date("F j, Y")}</span>',
                    {
                        formatCurrency: function(value, currency) {
                            return value.toFixed(4); //TODO: Deepali currency formatting
                        }
                    }
                );
                
                var wBalanceInformation = Ext.get('BalanceInformation');
                
                if (wBalanceInformation !=null)
                {
                  Ext.Ajax.request({
                    url: '/MetraNet/AjaxServices/ManagedAccount.aspx?operation=balancesummary',
                    timeout: 10000,
                    params: {},
                    success: function (response) {
                      if (response.responseText == '[]' || Ext.decode(response.responseText).Items[0] == null) {
                        //Nothing to show, hide the panel
                        //pBalanceInformation.hide();
                        //Ext.get("AccountBalanceInformation").hide();
                      }
                      else {
                        balanceInfoTpl.overwrite(wBalanceInformation, Ext.decode(response.responseText).Items[0]);
                        wBalanceInformation.show();
                      }

                    },
                    failure: function () {
                    }
                   });
              }   
                
              var accountStatusTpl = new Ext.XTemplate('<span class="valueLabel">Status</span><span class="valueHighlighted">{AccountStatusValueDisplayName} </span>');
              var wAccountStatus = Ext.get('AccountStatus');

              if (wAccountStatus != null && (jsonData !== undefined)) {
                accountStatusTpl.overwrite(wAccountStatus, jsonData);
                wAccountStatus.show();
              }
                
    });
                
  </script>
  
  <script>

    function populateDatePicker(id) {
      clearDatePickers();
      var dp = document.getElementById(id);
      var old = dp.innerHTML;
      dp.innerHTML = "";
      var div = d3.select("#" + id);
      div.on("click", null);
      div.style("overflow-y", "auto");
      div.style("overflow-x", "visible");
      var ul = div.append("ul").style("margin-left", "0px").style("margin-right", "10px").style("padding-left", "0px");
      ul.append("li").style("background", "url(/Res/images/icons/ui_radio_button.png) left center no-repeat").attr("datepickerid", id).attr("interval", div.attr("interval")).attr("title", "Interval " + div.attr("interval")).attr("selected", "true").on("click", function () { var ul = d3.select(this); /*console.log("" + ul.text() + " " + ul.attr("datepickerid"));*/document.getElementById(ul.attr("datepickerid")).innerHTML = ul.text(); d3.select("#" + ul.attr("datepickerid")).style("overflow", "hidden").attr("title", "Interval " + ul.attr("interval")).attr("interval", ul.attr("interval")).on("click", function () { populateDatePicker(ul.attr("datepickerid")); }); d3.event.preventDefault(); d3.event.stopPropagation(); }).text(old);
      //    ul.append("li").style("background", "url(/Res/images/icons/ui_radio_button_uncheck.png) left center no-repeat").attr("datepickerid", id).attr("interval", 90133432).attr("title", "Interval 90133432").on("click", function () { var ul = d3.select(this); console.log("" + ul.text() + " " + ul.attr("datepickerid")); document.getElementById(ul.attr("datepickerid")).innerHTML = ul.text(); d3.select("#" + ul.attr("datepickerid")).on("click", function () { populateDatePicker(ul.attr("datepickerid")); }); d3.event.preventDefault(); d3.event.stopPropagation(); }).text("February 28, 2012 - February 27, 2013");
      d3.event.preventDefault();
    }

    function selectDatePicker() {
    }

    function clearDatePickers() {
      d3.selectAll(".datepicker").each(function (d, i) {
        var div = d3.select(this);
        var ul = div.select("ul");
        if (!ul.empty()) {
          var sel = ul.select("li[selected='true']");
          if (!sel.empty()) {
            var txt = sel.text();
            div.text(txt).attr("title", "Interval 97773432").style("right", "0px").style("text-anchor", "end");
            div.style("overflow", "hidden");
          }
          div.on("click", function () { populateDatePicker(div.attr("id")); });
        }
      });

    }

    Ext.onReady(function() {

      var margin = { top: 25, right: 55, bottom: 20, left: 25 },
      width = document.getElementById("NowCast-body").clientWidth - margin.left - margin.right,
      height = 70 - margin.top - margin.bottom;

      var chart = d3.bullet()
        .width(width)
        .height(height);

      d3.json("/MetraNet/AjaxServices/DecisionService.aspx?_=" + new Date().getTime(), function(error, data) {
        var svg = d3.select("#NowCast-body").selectAll("svg")
          .data(data)
          .enter().append("svg")
          .attr("class", "bullet")
          .attr("width", "100%")
          .attr("height", height + margin.top + margin.bottom + 35);
        svg.style("background-color", "white");
        svg.style("margin-bottom", "5px");
        svg.append("rect").attr("width", width + margin.right - 10).attr("height", height + margin.top + margin.bottom + 30).attr("fill", "white").attr("fill-opacity", 0);
        svg
          .on("contextmenu", function(d, i) {
            d3.selectAll(".bullet .contextmenu").attr("display", "none");
            var cm = d3.select("#contextmenu" + 0)
              .style("display", "block")
              .style("left", d3.event.pageX + "px")
              .style("top", d3.event.pageY + "px");
            d3.event.preventDefault();
            return false;
          });
        svg = svg.append("g")
          .attr("transform", "translate(" + margin.left + "," + (margin.top + 20) + ")")
          .call(chart);

        var title = svg.append("g")
          .attr("transform", "translate(-6," + 1.35 * -height + ")");

        title.append("text")
          .attr("class", "title")
          .attr("dx", "-1em")
          .text(function(d) { return d.title; });

        title.append("text")
          .attr("class", "subtitle")
          .attr("dx", "-1em")
          .attr("dy", "1.2em")
          .text(function(d) { return d.subtitle; });

        title.append("text")
          .attr("class", "notice")
          .attr("x", width + margin.left)
          .attr("y", 3.4 * height)
          .attr("text-anchor", "end")
          .text("right click for options");

        var svgd = svg.data();
        if ((typeof svgd === 'undefined') || svgd === undefined || svgd == null) {
          d3.select("#NowCast-body").append("text").text("No Transactions Found for the Current Interval");
          return;
        }

        var cnt = 0;
        if (title != null && title.length > 0) {
          cnt = title[0].length;
        }
        title.each(function(d, i) {
          var bdy = document.getElementById("NowCast-body");
          var rect = bdy.getBoundingClientRect();
          var span = d3.select("#NowCast-body").append("span").style("position", "relative");
          span.style("top", -((cnt * 100) + 11) + "px");
          span.style("right", "-480px");
          var button = span.append("div");
          button.attr("class", "datepicker").style("white-space", "nowrap").style("display", "inline-block").attr("id", "datepicker" + i).style("width", "auto").style("position", "absolute").style("background-color", "#fff").style("border", "dotted").style("border-width", "1px").style("border-color", "#aaa").style("padding", "0px").style("padding-left", "2px").style("padding-right", "2px").style("margin", "0px");
          if (i == 0) {
            //        button.style("top", -((cnt * 100) + 41) + "px"); //.style("right", "-300px");
            button.style("top", ((i * 108) - 25) + "px"); //.style("right", "-300px");
          } else {
            button.style("top", ((i * 108) - 25) + "px"); //.style("right", "-300px");
          }
          button.attr("interval", d.intervalId);
          button.text(d.datesLabel).attr("title", "Interval " + d.intervalId).style("right", "0px").style("text-anchor", "end");
          span.on("contextmenu", function(d, i) {
            d3.selectAll(".bullet .contextmenu").attr("display", "none");
            var cm = d3.select("#contextmenu" + 0)
              .style("display", "block")
              .style("left", d3.event.pageX + "px")
              .style("top", d3.event.pageY + "px");
            d3.event.preventDefault();
            return false;
          });
        });

        d3.selectAll(".datepicker").on("click", function(d, i) {
          populateDatePicker("datepicker" + i);
        });

        var divs = d3.select("#NowCast-body").append("div").attr("id", function(d, i) { return "contextmenu" + i; }).attr("class", "contextmenu").style("display", "none").style("top", "150px").style("left", "400px").style("position", "absolute").style("background-color", "#fff").style("border", "solid").style("border-width", "3px").style("padding", "2px");
        var ul = divs.append("ul").attr("class", "contextmenulist").style("margin-left", "0px").style("padding-left", "0px");
        //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/checkbox_yes.png) left center no-repeat").text("Include Previous Results");
        //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/checkbox_no.png) left center no-repeat").text("Include Projected Results");
        //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/arrow_redo.png) left center no-repeat").text("Redraw").on('click', function () { console.log("redraw"); svg.call(chart); });
        ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/arrow_refresh_small.png) left center no-repeat").text("Refresh").on('click', function() {
          d3.json("/MetraNet/AjaxServices/DecisionService.aspx?_=" + new Date().getTime(), function(error, data) {
            var svg = d3.select("#NowCast-body").selectAll("svg")
              .data(data);
            svg.call(chart);
          });
        });

        d3.select("body").on('click', function(d, i) {
          d3.selectAll(".contextmenu").style("display", "none");
          d3.selectAll(".bullet .tbutton").attr("height", 13);
        });
        d3.select("body").on('contextmenu', function(d, i) { clearDatePickers(); });
        //    d3.selectAll("button").on("click", function () {
        //      svg.datum(randomize).call(chart.duration(1000)); // TODO automatic transition
        //    });
      });
    });
  </script>
  <script type="text/javascript">
    var dateFormat = d3.time.format("%m/%d/%Y %I:%M:%S %p");
    var dayFormat = d3.time.format("%B %e, %Y");
    Ext.onReady(function () {
      d3.json("/MetraNet/AjaxServices/ManagedAccount.aspx?_" + new Date().getTime() + "&operation=billingsummary", function (error, data) {
        if (error) console.log("Error:" + error.valueOf());
        else {
          var items = [];
          data.Items.forEach(function (d) {
            d.n_order = +d.n_order;
            d.n_invoice_amount = +d.n_invoice_amount;
            d.n_mrr_amount = +d.n_mrr_amount;
            d.n_payment_amount = -d.n_payment_amount;
            d.n_balance_amount = +d.n_balance_amount;
            d.n_adj_amount = +d.n_adj_amount;
            d.dd = dateFormat.parse(d.dt_transaction);
            d.dd = new Date(d.dd.getUTCFullYear(), d.dd.getUTCMonth(), d.dd.getUTCDate());
            if (d.nm_type == 'Invoice') {
              items.push(d);
            }
          });
          var ndx = crossfilter(items);
          var dateDimension = ndx.dimension(function (d) { return d.n_order; });
          var invoiceGroup = dateDimension.group().reduceSum(function (d) { return d.n_invoice_amount; });
          var mrrGroup = dateDimension.group().reduceSum(function (d) { return d.n_mrr_amount; });
          var composite = dc.compositeChart("#billsPaymentsChart");
          composite
        .margins({ top: 5, right: 5, bottom: 60, left: 5 })
        .height(289)
        .width(360)
        .x(d3.scale.linear().domain([0.5, 12]))
        .elasticY(true)
        .renderHorizontalGridLines(true)
        .transitionDuration(0)
        .legend(dc.legend().x(15).y(245).itemHeight(13).gap(5))
        .brushOn(false)
        .title("MRR", function (d) { return dayFormat(items[d.key - 1].dd) + " Monthly Recurring Revenue: $" + d.value; })
        .compose([
          dc.barChart(composite)
            .dimension(dateDimension)
            .group(invoiceGroup, "Invoice")
            .centerBar(true)
            .colors('#0070C0')
            .title(function (d) { return dayFormat(items[d.key - 1].dd) + " Invoice: $" + d.value; }),
          dc.lineChart(composite)
            .dimension(dateDimension)
            .group(mrrGroup, "MRR")
            .colors('#00B0F0')
            .renderDataPoints({ radius: 4, fillOpacity: 0.5, strokeOpacity: 0.8 })
            .title(function (d) { return dayFormat(items[d.key - 1].dd) + " Monthly Recurring Revenue: $" + d.value; })
        ]);
          composite.xAxis().tickSize(0, 0).tickFormat("");
          composite.yAxis().tickSize(0, 0).tickFormat("");

          composite.render();

          dc.renderAll();
        }
      });
    });
  </script>

</asp:Content>
