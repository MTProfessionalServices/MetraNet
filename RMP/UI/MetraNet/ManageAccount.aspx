<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="ManageAccount" Title="MetraNet" CodeFile="ManageAccount.aspx.cs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <script type="text/javascript">
    Ext.onReady(function(){
      try
      {    
        // Templates are defined in templates.js
        var Template;
        try
        {
          Template = <%=AccountTypeTpl%>;
        }
        catch(e)
        {
          Template = Tpl; // default template from template.js
        }
        // Store account json and the template in Account.js source, this way we can load the tabs on click.
        getFrameMetraNet().accountJSON = <%=AccountJson%>;
        getFrameMetraNet().accountTemplate = Template;
        getFrameMetraNet().Account.Manage("<%=Url%>");
        
      }
      catch(e)
      {
        getFrameMetraNet().Ext.UI.msg(TEXT_ERROR, TEXT_ERROR_LOADING_ACCOUNT);
      }
    });
  </script>

</asp:Content>
