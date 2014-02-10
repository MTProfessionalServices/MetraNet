<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" Inherits="ApprovalFrameworkManagement_ViewSubscriptionChangeDetails" CodeFile="ViewSubscriptionChangeDetails.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="ContentIndSub" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   
   <MT:MTViewChangeControl ID="SubChangeBasicStartDate" runat="server" Label="Start Date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
   <MT:MTViewChangeControl ID="SubChangeBasicNextStart" runat="server" Label="Next start of payer's billing period after this date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
   <MT:MTViewChangeControl ID="SubChangeBasicEndDate" runat="server" Label="End Date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />
   <MT:MTViewChangeControl ID="SubChangeBasicNextEnd" runat="server" Label="Next end of payer's billing period after this date" AllowBlank="False" meta:resourcekey="lblDisplayNameResource1" ReadOnly="False"  />

   <!--link rel="stylesheet" type="text/css" href="/Res/Styles/xmlverbatim.css" />

  <div class="CaptionBar">
    <asp:Label ID="lblShowChangesSummaryTitle" runat="server" Text="Default Dump Of Change Details From Database"
      meta:resourcekey="lblShowAllChangesSummaryTitleResource1"></asp:Label>
  </div>
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