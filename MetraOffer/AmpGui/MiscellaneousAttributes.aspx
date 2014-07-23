<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="MiscellaneousAttributes.aspx.cs" Inherits="AmpMiscellaneousAttributesPage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Miscellaneous Attributes" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
   

  <div id="GeneralInfoDiv" style="padding-left:0.1in; padding-top:0.25in;">  
  <table ID="GeneralInfoTable" runat="server">
  <tr>
  <td width="400px">
      <asp:Label ID="lblGenInfo1" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" meta:resourcekey="lblGenInfoResource1"
          Text="On this page, you can manage miscellaneous Decision Type attributes that are not covered elsewhere in the GUI."
          />
      <br/>
      <asp:Label ID="lblGenInfo2" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" meta:resourcekey="lblGenInfoResource2" 
          Text="Warning: Don't change anything here unless you're very sure of what you're doing!"
          />
  </td>
  <td width="40px" align="right" valign="top">
      <asp:Image ID="AdvancedFeature" runat="server" 
      ToolTip="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" 
      ImageUrl="/Res/Images/icons/cog_error_32x32.png" />
  </td>
  </tr>
  </table>
  </div>
  <br/>
  <br/>
  <MT:MTFilterGrid ID="MiscellanousAttributesGrid" runat="server" TemplateFileName="AmpWizard.MiscellaneousAttributes" ExtensionName="MvmAmp">
  </MT:MTFilterGrid>


  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->

  <div style="padding-left:0.85in; padding-top:0.05in;">   
      <table>
        <col style="width:190px"/>
        <col style="width:190px"/>
        <tr>
          <td align="left">
            <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                         OnClientClick="setLocationHref(ampPreviousPage); return false;"
                         CausesValidation="false" TabIndex="230" />
          </td>
          <td align="right">
            <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$Resources:Resource,TEXT_SAVE_AND_CONTINUE%>"
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
                         OnClick="btnContinue_Click"
                         CausesValidation="true" TabIndex="240"/>
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_CONTINUE%>"
                         OnClientClick="MPC_setNeedToConfirm(false);"
                         OnClick="btnContinue_Click"
                         CausesValidation="False" TabIndex="240"/>
          </td>
        </tr>
      </table> 
  </div>


<script type="text/javascript">

  // Event handler for Add button in MiscellanousAttributesGrid gridlayout
  functiononAdd_<%=MiscellanousAttributesGrid.ClientID %>() {
    var addMiscAttributeWindow = new top.Ext.Window({
      id: 'addMiscAttributeWindow',
      title: TITLE_AMPWIZARD_ADD_MISC_ATTRIBUTE,
      width: 450,
      height: 280,
      minWidth: 450,
      minHeight: 280,
      layout: 'fit',
      plain: true,
      bodyStyle: 'padding:5px;',
      buttonAlign: 'center',
      collapsible: true,
      resizable: false,
      maximizable: false,
      closable: true,
      closeAction: 'close',
      modal: 'true',
      html: '<iframe id="cloneWindow" src="/MetraNet/MetraOffer/AmpGui/AddMiscellaneousAttribute.aspx" width="100%" height="100%" frameborder="0" />'
    });

    addMiscAttributeWindow.show();
    addMiscAttributeWindow.on('close', function() { GridReload(); });
  }

  OverrideRenderer_<%= MiscellanousAttributesGrid.ClientID %> = function(cm) {
    if (cm.getIndexById('Actions') != -1) {
      cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer);
    }
  }

  function actionsColRenderer(value, meta, record, rowIndex, colIndex, store) {
    var str = "";
    str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Edit' title='{1}' href='JavaScript:onEditMiscAttribute(\"{0}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>", record.data.Name, TEXT_EDIT_DECISION_MISC_ATTRIBUTE);
    str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Delete' title='{1}' href='JavaScript:onDeleteMiscAttribute(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>", record.data.Name, TEXT_DELETE_DECISION_MISC_ATTRIBUTE);
    return str;
  }

  function onEditMiscAttribute(name) {
    var editMiscAttributeWindow = new top.Ext.Window({
      id: 'editMiscAttributeWindow',
      title: TITLE_AMPWIZARD_EDIT_MISC_ATTRIBUTE,
      width: 450,
      height: 280,
      minWidth: 450,
      minHeight: 280,
      layout: 'fit',
      plain: true,
      bodyStyle: 'padding:5px;',
      buttonAlign: 'center',
      collapsible: true,
      resizable: false,
      maximizable: false,
      closable: true,
      closeAction: 'close',
      modal: 'true',
      html: '<iframe id="editWindow" src="/MetraNet/MetraOffer/AmpGui/EditMiscellaneousAttribute.aspx?MiscellaneousAttributeName=' + name + '" width="100%" height="100%" frameborder="0" />'
    });

    editMiscAttributeWindow.show();
    editMiscAttributeWindow.on('close', function() { GridReload(); });
  }

  function onDeleteMiscAttribute(name) {
    var deleteMiscAttributeWindow = new top.Ext.Window({
      id: 'deleteMiscAttributeWindow',
      title: TITLE_AMPWIZARD_DELETE_MISC_ATTRIBUTE,
      width: 450,
      height: 180,
      minWidth: 450,
      minHeight: 180,
      layout: 'fit',
      plain: true,
      bodyStyle: 'padding:5px;',
      buttonAlign: 'center',
      collapsible: true,
      resizable: false,
      maximizable: false,
      closable: true,
      closeAction: 'close',
      modal: 'true',
      html: '<iframe id="deleteWindow" src="/MetraNet/MetraOffer/AmpGui/DeleteMiscellaneousAttribute.aspx?MiscellaneousAttributeName=' + name + '" width="100%" height="100%" frameborder="0" />'
    });

    deleteMiscAttributeWindow.show();
    deleteMiscAttributeWindow.on('close', function() { GridReload(); });
  }

  function GridReload() {
    dataStore_<%= MiscellanousAttributesGrid.ClientID %>.reload();
    window.checkFrameLoading();
  }
</script>

</asp:Content>

