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
  </style>

  <script type="text/javascript">
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
  <div class="widget" data-row="2" data-col="1" data-sizex="8" data-sizey="1">
  <img src="/Res/Images/Mockup/MetangaAccountSummaryAnalytic.png" width="720px;" style="padding: 15px;"/>
  </div>

<%--  <div class="widget" data-row="3" data-col="1" data-sizex="8" data-sizey="3">
  <img src="/Res/Images/Mockup/Bills-PaymentsMockupSnippet.png" width="720px;" style="padding: 15px;"/>
  </div>--%>

<%--  	  </ul>--%>

  
  <div class="widget" data-row="3" data-col="1" data-sizex="8" data-sizey="3">
  <MT:MTFilterGrid ID="SubscriptionSummaryGrid" runat="server" TemplateFileName="AccountSubscriptionSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
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
      //Execute: function(operation, args, callbackMethod)
      if (checkButtonClickCount() == true) {
        pageNav.Execute("SubscriptionsEvents_Subscribe_Client", null, null);
      }    
    }
    
    function onAddAccountToGroupSubscription_<%=SubscriptionSummaryGrid.ClientID %>()
    {
      //Execute: function(operation, args, callbackMethod)
      if (checkButtonClickCount() == true) {
        pageNav.Execute("GroupSubscriptionsEvents_JoinGroupSubscription_Client", null, null);
      }    
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
    str = String.format("<span class='ItemName'>{0}</span><br/><span class='ItemDescription'>{1}</span>", record.json.productofferingname, (record.json.productofferingdescription || ''));
  } else {
    str = String.format("<span class='ItemName'>{0}</span><br/><span class='ItemDescription'>{1}</span><br /><br /><span class='ItemName'>{2}</span><br/><span class='ItemDescription'>{3}</span>", record.data.productofferingname, (record.json.productofferingdescription || ''), (record.json.groupsubscriptionname  || ''), (record.json.groupsubscriptiondescription || ''));
    //null AS 'GroupSubscriptionDescription')
  }
  
  //return String.format("<span style='display:inline-block; vertical-align:middle'><img src='/Res/Images/icons/ProductCatalog_{0}.png' alt='{1}' align='middle'/></span>{2}", record.data.subscriptiontype, value, str);
  return str;
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
      var templateData = baseAccount360Tpl //getFrameMetraNet().accountTemplate;

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
       
    });
  </script>

</asp:Content>
