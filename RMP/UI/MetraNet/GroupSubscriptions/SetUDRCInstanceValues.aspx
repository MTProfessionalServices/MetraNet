<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GroupSubscriptions_SetUDRCInstanceValues"
  Title="<%$Resources:Resource,TEXT_TITLE%>" Culture="auto" UICulture="auto" CodeFile="SetUDRCInstanceValues.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <!-- Title Bar -->
  <div class="CaptionBar">
    <asp:Label ID="lblUDRCValueTitle" runat="server" Text="UDRC Values" meta:resourcekey="lblUDRCValueTitleResource1"></asp:Label>
  </div>
  <br />
  <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
    Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  <MT:MTFilterGrid ID="UDRCValueGrid" runat="server" TemplateFileName="GroupSubscriptionUDRCValueTemplate"
    ExtensionName="Account">
  </MT:MTFilterGrid>

  <div class="x-panel-btns-ct">
    <div style="width: 500px" class="x-panel-btns x-panel-btns-center">
      <center>
      <table cellspacing="0">
        <tr>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>"
             OnClick="btnOK_Click" TabIndex="390" />
          </td>
          <td class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>"
              CausesValidation="False" TabIndex="400" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table>
       </center>
    </div>
  </div>
 
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>

  <script type="text/javascript">
    
    // Custom Renderers
   OverrideRenderer_<%= UDRCValueGrid.ClientID %> = function(cm)
   {    
      cm.setRenderer(cm.getIndexById('StartDate'), DateRenderer);
      cm.setRenderer(cm.getIndexById('EndDate'), DateRenderer);         
   };  
    
    function onAdd_<%= UDRCValueGrid.ClientID %>()
    {
      pageNav.Execute("GroupSubscriptionsEvents_Set_UDRCInstanceValue_Client", null, null);
    }    
    
  </script>

</asp:Content>
