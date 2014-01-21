<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_SessionTimeout" CodeFile="SessionTimeout.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" VaryByCustom="username" shared="true" %>
<script type="text/javascript">
  var SESSION_TIMEOUT_MINUTES = 20;                   // 20 minute timeout
  var WARNING_TIMEOUT_MINUTES = 5;                    // 5 minute warning  
  var SESSION_TIMEOUT = SESSION_TIMEOUT_MINUTES * 60; // calculate timeout seconds  
  var WARNING_TIMEOUT = WARNING_TIMEOUT_MINUTES * 60; // calculate warning seconds
  var counter = SESSION_TIMEOUT;

  resetSessionTimer = function() { 
    counter = SESSION_TIMEOUT;
  }

  onTimeout = function () {
    Ext.UI.Logout();
  }

  alive = function (btn) {
    Ext.Ajax.request({
      url: '/MetraNet/AjaxServices/GetGUID.aspx',
      scope: this,
      disableCaching: true,
      callback: function (options, success, response) {
        var responseJSON = Ext.decode(response.responseText);
        var guid = (responseJSON && responseJSON.GUID) ? responseJSON.GUID : '';
        if (guid == '') onTimeout();
        resetSessionTimer();
      }
    });
  }

  showWarningMsg = function () {
    Ext.MessageBox.show({
      title: '<asp:Localize meta:resourcekey="SessionTimeoutTitle" runat="server">Session Timeout Pending</asp:Localize>',
      msg: '<asp:Localize meta:resourcekey="SessionTimeoutMsg1" runat="server">Your session is about to time out as a security measure.</asp:Localize>'
                + '\n' + String.format('<asp:Localize meta:resourcekey="SessionTimeoutMsg2" runat="server">Your session ends after {0} minutes of inactivity. </asp:Localize>', SESSION_TIMEOUT_MINUTES)
                + '\n' + '<asp:Localize meta:resourcekey="SessionTimeoutMsg3" runat="server">Click OK to keep your session alive.  You have </asp:Localize>'
                + '<span id="timeoutMsg"><asp:Localize meta:resourcekey="SessionTimoutChangingMessage" runat="server">5 minutes and 0 seconds</asp:Localize></span>.',
      buttons: Ext.MessageBox.OK,
      fn: alive,
      icon: Ext.MessageBox.INFO
    });

    var timeoutMsg = Ext.get("timeoutMsg");

    if (timeoutMsg != null) {
      var x = counter;
      var seconds = parseInt(x % 60);
      x = x / 60;
      var minutes = parseInt(x % 60);

      timeoutMsg.dom.innerHTML = minutes + '<asp:Localize meta:resourcekey="SessionTimeoutMinutes" runat="server"> minutes and </asp:Localize>' + seconds + '<asp:Localize meta:resourcekey="SessionTimeoutSeconds" runat="server"> seconds</asp:Localize>';
    }
  }

  var timeoutPoll = {
    run: function () {
      counter -= 1;
      if (counter < WARNING_TIMEOUT) {
        showWarningMsg();
      }
      if (counter < 1) {
        Ext.TaskMgr.stop(timeoutPoll);
        onTimeout();
      }
    },
    interval: 1000
  }

  Ext.onReady(function () {
    Ext.TaskMgr.start(timeoutPoll);
  });
</script>