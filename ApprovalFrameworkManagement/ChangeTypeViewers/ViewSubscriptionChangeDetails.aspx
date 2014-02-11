<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" Inherits="ApprovalFrameworkManagement_ViewSubscriptionChangeDetails" CodeFile="ViewSubscriptionChangeDetails.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="ContentIndSub" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   
  <div class="CaptionBar">
    <asp:Label ID="lblChangesSummaryTitle" runat="server" />
  </div>

  <div>
    <img src='/ImageHandler/images/Account/<%# AccountTypeName %>/account.gif' alt="No image"/>
    <MT:MTLabel ID="LblAccountName" runat="server" />
  </div>
  <div>
    <MT:MTLabel ID="LblPoName" runat="server" />
  </div>
  
  <MT:MTViewChangeControl ID="SubChangeBasicStartDate" runat="server" Label="Start Date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
  <MT:MTViewChangeControl ID="SubChangeBasicNextStart" runat="server" Label="Next start of payer's billing period after this date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
  <MT:MTViewChangeControl ID="SubChangeBasicEndDate" runat="server" Label="End Date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
  <MT:MTViewChangeControl ID="SubChangeBasicNextEnd" runat="server" Label="Next end of payer's billing period after this date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
   
  <MT:MTSection ID="MTSection1" runat="server" Text="Product Offering Recurring Change Metrics" />
  
  <MT:MTSection ID="sectionSubProps" runat="server" Text="Subscription Properies" />
  
   <!--link rel="stylesheet" type="text/css" href="/Res/Styles/xmlverbatim.css" />

  <br />

  <div id='xmlTabs' class='xml-deemphasize-namespace xml-deemphasize-attributes' style='padding:10px;'></div-->

 <!--script language="javascript" type="text/javascript">
   Ext.onReady(function () {
     // basic tabs 1, built from existing content
     var tabs = new Ext.TabPanel({
       renderTo: 'xmlTabs',
       tabPosition: 'bottom',
       padding: '0px 0px 0px 10px',
       bodyStyle: 'background-color:#F0F0F0',
       width: 700,
       height: 400,
       //layout: 'fit',
       //height: 500,
       autoScroll: true,
       //autoHeight: true;
       activeTab: 0,
       frame: true,
       defaults: { autoHeight: true, bodyStyle: 'background-color:#F0F0F0' },
       items: [
            { contentEl: 'xmlPretty', title: 'Formatted' },
            { contentEl: 'xmlRaw', title: 'Raw' }
        ]
     });

   });

</script-->
</asp:Content>