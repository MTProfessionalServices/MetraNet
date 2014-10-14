<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="Notifications.aspx.cs" Inherits="Notifications" Title="Notifications" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  
  <script type="text/javascript">

    Ext.onReady(function () {
      Ext.Ajax.request({
        url: 'AjaxServices/GetNotifications.aspx',
        timeout: 10000,
        callback: function (options, success, response) {
          var responseJSON = Ext.decode(response.responseText);
          if (responseJSON) {
            alert(String.format("{0} {1} ", responseJSON.Items[0]["notificationType"], responseJSON.Items[0]["id_acc"]));
          }
        }
      });
    });
    
  </script>
</asp:Content>
