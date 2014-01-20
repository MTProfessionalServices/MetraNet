<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="ApprovalFrameworkManagement_DefaultViewChangeDetails"
  Title="Account Change Details" Culture="auto" UICulture="auto" CodeFile="DefaultViewChangeDetails.aspx.cs" meta:resourcekey="PageResource1" %>
  <%@ Import Namespace="MetraTech.UI.Tools" %>
  <%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
   
  <link rel="stylesheet" type="text/css" href="/Res/Styles/xmlverbatim.css" />

  <div class="CaptionBar">
    <asp:Label ID="lblShowChangesSummaryTitle" runat="server" Text="Default Dump Of Change Details From Database"
      meta:resourcekey="lblShowAllChangesSummaryTitleResource1"></asp:Label>
  </div>
  <br />

  <div id='xmlTabs' class='xml-deemphasize-namespace xml-deemphasize-attributes' style='padding:10px;'></div>



 <script language="javascript" type="text/javascript">
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



</script>
</asp:Content>