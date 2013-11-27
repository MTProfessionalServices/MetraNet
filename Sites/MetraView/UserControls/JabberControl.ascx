<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_JabberControl" CodeFile="JabberControl.ascx.cs" %>

<script type="text/javascript">

  Ext.onReady(function() {
    events = new Ext.util.Observable();
    events.addEvents('INFO_MESSAGE', 'TIME_MESSAGE');
    var XMPP = new Ext.ux.XMPP("<%=JabberId%>", "<%=JabberToken%>", "<%=JabberServer%>");
    XMPP.init();
  });    

  // Show Toast Message
  function toast(titleMsg, msg) {
    new Ext.ux.Notification({
      iconCls: 'x-icon-error',
      title: titleMsg,
      html: msg,
      autoDestroy: true,
      hideDelay: 6000,
      listeners: {
        'beforerender': function() {
          Sound.enable();
          Sound.play('<%=Request.ApplicationPath%>/JavaScript/notify.wav');
          Sound.disable();
        }
      }
    }).show(document);
  }
  
</script>