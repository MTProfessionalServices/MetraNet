<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_TemplateSummary" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="TemplateSummary.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <script type="text/javascript">
    // Sometimes when we come back from old MAM we may have an extra frame.
    // This code hides it.
    Ext.onReady(function () {      
      if(getFrameMetraNet().MainContentIframe )
      {
        if(getFrameMetraNet().MainContentIframe.location != document.location)
        {
          if(getFrameMetraNet().MainContentIframe.document.getElementById("ctl00_PanelActiveAccount"))
          {
            getFrameMetraNet().MainContentIframe.document.getElementById("ctl00_PanelActiveAccount").style.display = "none";
          }
        }
      }
    });
  </script>
  
  <MT:MTTitle ID="MTTitle1" Text="Account Templates" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
  <div id="panelMessage" style="padding:10px;display:<%= HideMessage %>"></div>
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" TemplateFileName="AccountTemplateDef" ExtensionName="Account" ></MT:MTFilterGrid>
  
  <script type="text/javascript">

    // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };
    
    // Event handlers
    function onEdit(n, accountType) {
      if (checkButtonClickCount() == true) {
        var args = "SelectedAccountType=" + accountType;
        pageNav.Execute("TemplateEvents_Edit_Client", args, null);
      }
    }

    function onApply(n, accountType) {
      if (checkButtonClickCount() == true) {
        var args = "SelectedAccountType=" + accountType;
        pageNav.Execute("TemplateEvents_Apply_Client", args, null);
      }
    }

    function onDelete(n, accountType)
    {
      top.Ext.MessageBox.show({
               title: TEXT_DELETE,
               msg: String.format(TEXT_DELETE_TEMPLATE_MESSAGE, String.escape(accountType)),
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok') {
                   if (checkButtonClickCount() == true) {
                     var args = "SelectedAccountType=" + accountType;
                     pageNav.Execute("TemplateEvents_Delete_Client", args, deleteResult);
                   }
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
    }
   
    function deleteResult(responseText)
    {
      //refresh grid
      dataStore_<%= MTFilterGrid1.ClientID %>.reload();
    }
   
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = ""

      // Edit Template
      str += String.format("&nbsp;<a style='cursor:hand;' id='edit' href='javascript:onEdit({0}, \"{1}\")'><img src='/Res/Images/icons/vcard_edit.png' title='{2}' alt='{2}'/></a>", record.data.TemplateId, String.escape(record.data.AccountType), String.escape(TEXT_EDIT_TEMPLATE));
  
      // Apply Template
      str += String.format("&nbsp;<a style='cursor:hand;' id='apply' href='javascript:onApply({0}, \"{1}\")'><img src='/Res/Images/icons/vcard_add.png' title='{2}' alt='{2}'/></a>", record.data.TemplateId, String.escape(record.data.AccountType), String.escape(TEXT_APPLY_TEMPLATE));
      
      // Delete button
      str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:onDelete({0}, \"{1}\")'><img src='/Res/Images/icons/cross.png' title='{2}' alt='{2}'/></a>", record.data.TemplateId, String.escape(record.data.AccountType), String.escape(TEXT_DELETE));
      return str;
    };    

    function onNewTemplate_<%=MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("TemplateEvents_Add_Client", null, null);
      }
    }

    function onViewHistory_<%=MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("TemplateEvents_ViewHistory_Client", null, null);
      }
    }

    function onCancel_<%= MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("TemplateEvents_CancelTemplateSummary_Client", null, null);
      }
    }

    // Remove Pager
    GetBottomBar_<%= MTFilterGrid1.ClientID %> = function()
    {
      var bbar = null;
      return bbar;
    };

<%= HideMovedAccountTypes %>

  </script>
</asp:Content>
