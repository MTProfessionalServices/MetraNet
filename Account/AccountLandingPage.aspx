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

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>

  <div class="CaptionBar">
    <asp:Label ID="lblAccount360Title" runat="server" Text="Account 360"></asp:Label>
  </div>
  <br />
  <div>
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
      Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  </div>

  <div id="AccountSummaryInformation" style="padding: 15px;"></div>

  <img src="/Res/Images/Mockup/MetangaAccountSummaryAnalytic.png" width="720px;" style="padding: 15px;"/>

  <br />

  <img src="/Res/Images/Mockup/Bills-PaymentsMockupSnippet.png" width="720px;" style="padding: 15px;"/>



  <MT:MTFilterGrid ID="GroupSubGrid" runat="server" TemplateFileName="AccountSubscriptionSummary.xml"
    ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
    FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    MultiSelect="False" PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    TotalProperty="TotalRows">
  </MT:MTFilterGrid>
  
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

  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  
  <script type="text/javascript">
//    // Custom Renderers
//    OverrideRenderer_<%= GroupSubGrid.ClientID %> = function(cm)
//    {   
//      //cm.setRenderer(cm.getIndexById('Name'), EditLinkRenderer);
////      cm.setRenderer(cm.getIndexById('SubscriptionSpan#StartDate'), DateRenderer); 
////      cm.setRenderer(cm.getIndexById('SubscriptionSpan#EndDate'), DateRenderer); 
////      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
//    };
    
//    function onCancel_<%= GroupSubGrid.ClientID %>()
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
//    function onAdd_<%=GroupSubGrid.ClientID %>()
//    {
//      pageNav.Execute("GroupSubscriptionsEvents_Add_Client", null, null);
//    }
//     function onJoin_<%=GroupSubGrid.ClientID %>()
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


      // str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
      
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
           '<tpl if="this.isNull(Company) == false">',
             '<span class="AccountName">{Company:htmlEncode}</span><br/>',
           '</tpl>',
           '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == false)">',
              '<span class="AccountName">{FirstName:htmlEncode} {LastName:htmlEncode}</span><br/>',
           '</tpl>',
           '<tpl if="(this.isNull(FirstName) == true) && (this.isNull(LastName) == false)">',
              '<span class="AccountName">{LastName:htmlEncode}</span><br/>',
           '</tpl>',
           '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == true)">',
              '<span class="AccountName">{FirstName:htmlEncode}</span><br/>',
           '</tpl>',
         '</tpl>',
       '</tpl>',
       '<b>{UserName} ({_AccountID})</b><br/>',
           


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
