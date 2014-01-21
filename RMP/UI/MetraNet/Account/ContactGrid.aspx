<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_ContactGrid" Title="MetraNet" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="ContactGrid.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="Label1" runat="server" Text="Update Contacts" meta:resourcekey="Label1Resource1"></asp:Label>
  </div>

  <MT:MTFilterGrid runat="server" ID="MyGrid1" ExtensionName="Account" TemplateFileName="ContactListLayoutTemplate.xml"></MT:MTFilterGrid>

  <br /><br />
        
  <script type="text/javascript">
  
  function onAddContact_<%= MyGrid1.ClientID %>()
  {
    pageNav.Execute("ContactUpdateEvents_AddContact_Client", null, null);
  }

  function onCancel_<%= MyGrid1.ClientID %>()
  {
    pageNav.Execute("ContactUpdateEvents_CancelContactUpdate_Client", null, null);
  }

  function SetSelected(n)
  {
    var args = "ContactType=" + n;
    pageNav.Execute("ContactUpdateEvents_SelectContact_Client", args, null);
  }
  
  // Custom Renderers
  OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  { 
    var colIndex = cm.getIndexById('ContactTypeValueDisplayName');
    cm.setRenderer(colIndex, EditLinkRenderer);
  };
  
  EditLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
    var displayName = record.data.ContactTypeValueDisplayName;
 
    // Edit Link
    str += String.format("<a href='JavaScript:SetSelected({0});'>{1}</a>", record.data.ContactType, displayName);
    return str;
  };  
    
  </script>   

</asp:Content>

