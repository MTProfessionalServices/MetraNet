<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_AccountCreated" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="AccountCreated.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <div class="CaptionBar">
    <asp:Label ID="Label2" runat="server" Text="Account Created" meta:resourcekey="Label2Resource1"></asp:Label>
  </div>
  
  <br />
  <MT:MTPanel Collapsible="false" runat="server" ID="Panel1" Text="Account Created" meta:resourcekey="Label2Resource1">
  <asp:Label ID="Label1" runat="server" Text="The account was created successfully." meta:resourcekey="Label1Resource1"></asp:Label>
  <asp:Label ID="lblFutureAccount" Visible="False" Text="To manage this account set Application Time to {0}" runat="server" meta:resourcekey="lblFutureAccountResource1"></asp:Label>

  </MT:MTPanel> 
  
    <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
    <center>
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
              <MT:MTButton  ID="btnManage" runat="server" Text="Manage Newly Created Account"  meta:resourcekey="btnManageResource1"  OnClientClick="return AccountLoad();" />
          </td>
        </tr>
      </table>  
      </center>   
    </div>
  </div>
  
  
  <script type="text/javascript">
    function AccountLoad() {
      Account.Load(<%= NewAccountId %>);
      return false;
    }
    Ext.onReady(function () {
     // if(Ext.get('<%=btnManage.ClientID %>'))
    //  {
     // Ext.get('<%=btnManage.ClientID %>').on('click', function(e){ Account.Load(<%= NewAccountId %>); }); 
    //  }
  
    });    
  </script>

</asp:Content>

