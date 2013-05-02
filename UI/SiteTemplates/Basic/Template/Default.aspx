<%@ Page Language="C#" MasterPageFile="~/MasterPages/MetraViewExt.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" Title="MetraView" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Register Src="UserControls/ServerDescription.ascx" TagName="ServerDescription"
  TagPrefix="uc1" %>
<%@ Register src="UserControls/UsageGraph.ascx" tagname="UsageGraph" tagprefix="uc2" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script type="text/javascript">

//  Ext.onReady(function() {
//    events = new Ext.util.Observable();
//    events.addEvents('INFO_MESSAGE', 'TIME_MESSAGE');
//    var XMPP = new Ext.ux.XMPP("<%=JabberId%>", "<%=JabberToken%>", "<%=JabberServer%>");
//    XMPP.init();
//  });    

//// Show Toast Message
//function toast(titleMsg, msg) {
//  new Ext.ux.Notification({
//    iconCls: 'x-icon-error',
//    title: titleMsg,
//    html: msg,
//    autoDestroy: true,
//    hideDelay: 6000,
//    listeners: {
//      'beforerender': function() {
//        Sound.enable();
//        Sound.play('js/notify.wav');
//        Sound.disable();
//      }
//    }
//  }).show(document);
//}
  
</script>

<MT:Dashboard ID="Dashboard1" Name="MainDashboard" runat="server" />

<div class="clearer">
      <!--important-->
    </div>


</asp:Content>

