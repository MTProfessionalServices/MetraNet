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
  background: #fff; 
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
#MyFormDiv_ctl00_ContentPlaceHolder1_billingActivityPanel .x-panel {
  width: 40%;
  height: 100%;
  padding-right: 30px;
  margin-right: 30px;
}

#MyFormDiv_ctl00_ContentPlaceHolder1_salesSummaryPanel .x-panel {
  width: 100%;
  height: 100%;
  padding-right: 30px;
  margin-right: 30px;
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
<%--  
  <div class="x-panel mtpanel-inner">
    <div id="AccountBalanceInformation" style="padding: 15px;">Balance Information</div>
  </div>--%>
  
  <div class="widget" data-row="2" data-col="1" data-sizex="8" data-sizey="1">
    <MT:MTPanel ID="MTPanel1" runat="server" Collapsed=false Collapsible="False" Visible="False" >
      <div id="AccountBalanceInformation"></div>
    </MT:MTPanel>
  </div>

  <div class="widget" data-row="3" data-col="1" data-sizex="8" data-sizey="1">
<%--  <img src="/Res/Images/Mockup/MetangaAccountSummaryAnalytic.png" width="720px;" style="padding: 15px;"/>
    <MT:MTPanel ID="SalesSummaryPanel" runat="server" Text="Sales Summary" >
      <div id="SalesSummaryInformation"></div>
    </MT:MTPanel> --%>
    <MT:MTFilterGrid ID="SalesSummaryGrid" runat="server" TemplateFileName="SalesSummary.xml" ExtensionName="Account" Resizable="False" Title="Sales Summary"></MT:MTFilterGrid>
  </div>

  <div class="widget" data-row="4" data-col="1" data-sizex="3" data-sizey="3">
    <MT:MTPanel ID="billingActivityPanel" runat="server" Text="Billing Activity">
            <div id="billsPaymentsChart"></div>
      <%-- %>img src="/Res/Images/Mockup/Bills-PaymentsMockupSnippet.png" width="720px;" style="padding: 15px;"/--%>
    </MT:MTPanel>
  </div>

  <div class="widget" data-row="4" data-col="4" data-sizex="4" data-sizey="3">
    <MT:MTFilterGrid ID="InvoiceSummaryGrid" runat="server" TemplateFileName="AccountInvoiceSummary.xml" ExtensionName="Account" Resizable="False" Title="Bills & Payments"></MT:MTFilterGrid>
  </div>
<%--  	  </ul>--%>

 
  <div class="widget" data-row="7" data-col="1" data-sizex="8" data-sizey="3">
  <MT:MTFilterGrid ID="SubscriptionSummaryGrid" runat="server" TemplateFileName="AccountSubscriptionSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
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
      '<br><span>Account Status: {AccountStatusValueDisplayName} <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/AccountStateSetup.asp">Change</a></span><br/>',
      '{AccountStartDate}<br/>',
      '<span>Payer {_AccountID} {PayerID} {PayerAccount} </span><br/>',
      //'{Internal.UsageCycleTypeValueDisplayName} {Internal.Currency} {Internal.LanguageValueDisplayName}<br/>',
      //'<span>Balance: $23,345 as of Feb. 15, 2014</span><br/>',
           


//           '<tpl if="this.isNull(Address1) == false">',
//             '{Address1:htmlEncode}<br/>',
//           '</tpl>',

//           '<tpl if="this.isNull(Address2) == false">',
//             '{Address2:htmlEncode}<br/>',
//           '</tpl>',

//           '<tpl if="this.isNull(Address3) == false">',
//             '{Address3:htmlEncode}<br/>',
//           '</tpl>',

//           '<tpl if="this.isNull(City) == false">',
//              '{City:htmlEncode}',
//           '</tpl>',

//           '<tpl if="(this.isNull(City) == false) && (this.isNull(State) == false)">',
//              ', ',
//           '</tpl>',

//           '<tpl if="this.isNull(State) == false">',
//              '{State:htmlEncode}',
//           '</tpl>',

//           '<tpl if="(this.isNull(Zip) == false) && ((this.isNull(City) == false) ||(this.isNull(State) == false)) ">',
//              ' ',
//           '</tpl>',

//           '<tpl if="this.isNull(Zip) == false">',
//              '{Zip:htmlEncode}',
//           '</tpl>',

//           '<tpl if="(this.isNull(City) == false) || (this.isNull(State) == false) || (this.isNull(Zip) == false)">',
//              '<br/>',
//           '</tpl>',

//           '<tpl if="this.isNull(CountryValueDisplayName) == false">',
//              '{CountryValueDisplayName:htmlEncode}<br/>',
//           '</tpl>',

//           '<tpl if="(this.isNull(Email) == false) || (this.isNull(PhoneNumber) == false) || (this.isNull(FacsimileTelephoneNumber) == false)">',
//            '<br/>',
//           '</tpl>',

//           '<tpl if="this.isNull(Email) == false">',
//             '<img border="0" align="top" src="/Res/Images/icons/email.png"/> <a href="mailto:{Email}">{Email:htmlEncode}</a><br/>',
//           '</tpl>',


//           '<tpl if="this.isNull(PhoneNumber) == false">',
//             '<img border="0" align="top" src="/Res/Images/icons/telephone.png"/> {PhoneNumber:htmlEncode}<br/>',
//           '</tpl>',

//           '<tpl if="this.isNull(FacsimileTelephoneNumber) == false">',
//             '<img border="0" align="top" src="/Res/Images/icons/fax.png"/> {FacsimileTelephoneNumber:htmlEncode}<br/>',
//           '</tpl>',

//         '</tpl>',
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
    
      var pBalanceInformation = new Ext.Panel({
        items: [{
            //title: TEXT_APPROVAL_CHANGES_PENDING_YOUR_APPROVAL,
            header: false,
            html: '',
            renderTo: Ext.Element.get('AccountBalanceInformation'),
            listeners: {
              render: function (panel) {
                var balanceInfoTpl = new Ext.XTemplate('<span>Balance {currentbalance} as of {currentbalancedate}</span>');           

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
                      balanceInfoTpl.overwrite(this.body, Ext.decode(response.responseText).Items[0]);
//                      Ext.get("AccountBalanceInformation").fadeIn({
//                        endOpacity: 1, //can be any value between 0 and 1 (e.g. .5)
//                        easing: 'easeOut',
//                        duration: 2
//                      });
                    }

                  },
                  failure: function () {
                  },
                  scope: panel
                });
              }
            }
          }
        ]
      });

    });

  //Ext.get("AccountBalanceInformation").hide(); 
      
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
    var minDate = new Date();
    var maxDate = new Date();
    var currentBalance = 0.0;
		minDate.setMonth(minDate.getYear() + 10);
		Ext.onReady(function () {
		  /*      d3.json("/MetraNet/AjaxServices/VisualizeService.aspx?_" + new Date().getTime() + "&operation=ft30dayaging", function(error, data) {
		  if (error) console.log("Error:" + error.valueOf());
		  else {
		  var item = data.Items;
		  */
		  var items = [
		  /*{ type: 'invoice', interval: 1037107230, id: 5717387, date: '04/30/2013 12:00:00 AM', invoice_amount: 2.400000, balance_amount: 2.400000, payment_amount: 0.000000 },
		  { type: 'invoice', interval: 1039138846, id: 5788222, date: '05/31/2013 12:00:00 AM', invoice_amount: 30.470000, balance_amount: 30.470000, payment_amount: -2.400000 },
		  { type: 'invoice', interval: 1041104926, id: 5848275, date: '06/30/2013 12:00:00 AM', invoice_amount: 26.670000, balance_amount: 57.140000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1043136542, id: 12455498083, date: '07/11/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -26.670000 },
		  { type: 'payment', interval: 1043136542, id: 12455498082, date: '07/11/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -30.470000 },
		  { type: 'invoice', interval: 1043136542, id: 5887673, date: '07/31/2013 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1045168158, id: 12954661780, date: '08/12/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -20.570000 },
		  */{type: 'invoice', interval: 1045168158, id: 5969320, date: '08/31/2013 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1047134238, id: 13478486651, date: '09/10/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -20.570000 },
		  { type: 'invoice', interval: 1047134238, id: 6029698, date: '09/30/2013 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1049165854, id: 13920611033, date: '10/07/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -20.570000 },
		  { type: 'invoice', interval: 1049165854, id: 6092922, date: '10/31/2013 12:00:00 AM', invoice_amount: 21.320000, balance_amount: 21.320000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1051131934, id: 14492323849, date: '11/08/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -21.320000 },
		  { type: 'invoice', interval: 1051131934, id: 6134288, date: '11/30/2013 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1053163550, id: 14981992568, date: '12/09/2013 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -20.570000 },
		  { type: 'invoice', interval: 1053163550, id: 6217232, date: '12/31/2013 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000 },
		  { type: 'payment', interval: 1055195166, id: 15507808798, date: '01/07/2014 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -20.570000 },
		  { type: 'invoice', interval: 1055195166, id: 6267870, date: '01/31/2014 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000 },
		    { type: 'payment', interval: 1057030174, id: 16124826385, date: '02/10/2014 12:00:00 AM', invoice_amount: 0.000000, balance_amount: 0.000000, payment_amount: -20.570000 },
		    { type: 'invoice', interval: 1057030174, id: 6352866, date: '02/28/2014 12:00:00 AM', invoice_amount: 20.570000, balance_amount: 20.570000, payment_amount: 0.000000}];
		  var lastDate;
		  var newItems = [];
		  items.forEach(function (d) {
		    d.invoice_amount = +d.invoice_amount;
		    d.payment_amount = -d.payment_amount;
		    d.balance_amount = +d.balance_amount;
		    d.dd = dateFormat.parse(d.date);
		    d.dd = new Date(d.dd.getUTCFullYear(), d.dd.getUTCMonth(), d.dd.getUTCDate());
		    if (d.dd < minDate) {
		      minDate = d.dd;
		    }
		    console.log("Balance: " + currentBalance);
		    console.log("Tran Date: " + d.dd);
		    console.log("Last Date: " + lastDate);
		    if (lastDate != undefined) {
		      var days = ((d.dd.getTime() - lastDate.getTime()) / (24 * 60 * 60 * 1000));
		      for (i = 1; i < days; i++) {
		        lastDate.setDate(lastDate.getDate() + 1);
		        var nd = new Date(lastDate.getUTCFullYear(), lastDate.getUTCMonth(), lastDate.getUTCDate());
		        console.log(nd);
		        newItems.push({ invoice_amount: 0.0, dd: nd, balance_amount: (currentBalance - 0.0), payment_amount: 0.0 });
		      }
		    }
		    currentBalance += (d.invoice_amount - d.payment_amount);
		    d.balance_amount = currentBalance;
		    lastDate = d.dd;
		    newItems.push(d);
		    // TODO: handle unknown balance until first invoice because payment comes first
		  });
		  var ndx = crossfilter(newItems);
		  var dateDimension = ndx.dimension(function (d) { return d.dd; });
		  var invoiceGroup = dateDimension.group().reduceSum(function (d) { return d.invoice_amount; });
		  var paymentGroup = dateDimension.group().reduceSum(function (d) { return d.payment_amount; });
		  var balanceGroup = dateDimension.group().reduceSum(function (d) {
		    console.log("Date: " + d.dd + " Balance: " + d.balance_amount + " Invoice: " + d.invoice_amount); return d.balance_amount; });
		  var composite = dc.compositeChart("#billsPaymentsChart");
		  composite
		    .margins({ top: 5, right: 5, bottom: 60, left: 5 })
  	    .height(225)
  		  .width(360)
		    .x(d3.time.scale().domain([minDate, maxDate]))
  		  .xUnits(d3.time.day)
		    .elasticY(true)
		    .renderHorizontalGridLines(true)
		    .transitionDuration(0)
		    .legend(dc.legend().x(15).y(175).itemHeight(13).gap(5))
		    .brushOn(false)
		    .title("Balance", function (d) { return dayFormat(d.key) + " Balance: $" + d.value; })
		    .compose([
		  /*		      dc.lineChart(composite)
		  .dimension(dateDimension1)
		  .group(invoiceGroup, "Invoices")
		  .renderDataPoints({ radius: 3, fillOpacity: 0.8, strokeOpacity: 0.8 })
		  .colors('#00B0F0')
		  .title(function (d) { return dayFormat(d.key) + " Invoice[s]: $" + d.value; }),
		  dc.lineChart(composite)
		  .dimension(dateDimension2)
		  .group(paymentGroup, "Payments")
		  .renderDataPoints({ radius: 3, fillOpacity: 0.8, strokeOpacity: 0.8 })
		  .colors('#0070C0')
		  */
		      dc.barChart(composite)
		        .dimension(dateDimension)
		        .group(paymentGroup, "Payments")
		        .stack(invoiceGroup, "Invoices")
		        .title("Invoices", function (d) { return dayFormat(d.key) + " Invoice[s]: $" + d.value; })
		        .title(function (d) { return dayFormat(d.key) + " Payment[s]: $" + d.value; }),
		      dc.lineChart(composite)
		        .dimension(dateDimension)
		        .group(balanceGroup, "Balance")
		        .colors('#148622')
		        .renderDataPoints({ radius: 3, fillOpacity: 0.3, strokeOpacity: 0.6 })
		        .title(function (d) { return dayFormat(d.key) + " Balance: $" + d.value; })
		    ])
		    .renderlet(function (_chart) {

		      function setStyle(selection, keyName) {
		        selection.style("fill", function (d) {
		          if (d[keyName] == "Payments")
		            return "#0070C0";
		          else if (d[keyName] == "Invoices")
		            return "#00B0F0";
		          else if (d[keyName] == "Balance")
		            return "#148622";
		        });
		      }

		      // set the fill attribute for the bars
		      setStyle(_chart
		        .selectAll("g.stack")
		        .selectAll("rect.bar"), "layer"
		      );
		      // set the fill attribute for the legend
		      setStyle(_chart
		        .selectAll("g.dc-legend-item")
		        .selectAll("rect"), "name"
		      );
		    });
		  composite.xAxis().tickSize(0, 0).tickFormat("");
		  composite.yAxis().tickSize(0, 0).tickFormat("");

		  composite.render();

		  dc.renderAll();
		  /*
		  }
		  });
		  */
		});
  </script>

</asp:Content>
