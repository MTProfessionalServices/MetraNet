<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="GenericUpdateAccount" Title="MetraNet" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" CodeFile="GenericUpdateAccount.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script language="javascript" type="text/javascript">
  /// Parses account display value and returns account identifier
  function getIdFromAccStr(accStr) {
    return accStr.substring(accStr.lastIndexOf('(') + 1, accStr.lastIndexOf(')'));
  }

  /// Collection contains all available account properties with matched client-side controls
  var ctlMap = Ext.util.JSON.decode("<%=JSControlMapping%>");

  /// Contains references to all available Ext.ComboBox objects. It needed to use correct methods to get/set their values and fire appropriate events. 
  var cBoxes = {};

  /// Reads template data returned by AJAX service. Set values from template to appropriate controls on page and then disable them.
  function processTemplate(tmplData) {
    for (var id in ctlMap) {
      var obj = Ext.getCmp(ctlMap[id]);
      if (obj != null) { obj.enable(); }
    }
    for (var el in tmplData) {
      if (ctlMap[el] != null && typeof (ctlMap[el]) != "undefined") {
          var ctl = Ext.get(ctlMap[el]);
          if (ctl != null) {
            var cb = cBoxes[ctlMap[el]];
            if (typeof (cb) != 'undefined') {
              cb.setValue(tmplData[el]);
              cb.fireEvent('select');
            }
            else {
              ctl.dom.value = tmplData[el];
            }
            var cmp = Ext.getCmp(ctlMap[el]);
            if (cmp != null) { cmp.disable(); }
        }
      }
    }
  }

  /// Sends AJAX request to get template data for account if available.
  function getTemplateData() {
    var parentId = 1;
    Ext.Ajax.request({
      url: '<%=GetVirtualFolder()%>/AjaxServices/LoadDataFromAccTemplate.aspx',
      params: {
        AccountID: '<%=Account._AccountID%>',
        ParentID: '<%=Account.AncestorAccountID %>',
        AccType: '<%=Account.AccountType%>'
      },
      timeout: 10000,
      success: function (response) {
        processTemplate(Ext.util.JSON.decode(response.responseText));
      },
      failure: function (response) {
      }
    });
  }

  /// onSelected event handler to handle changes in account ancestor field
  function ancestorChange(e, t) {
    getTemplateData();
  }

  /// Enables all controls, which were disabled by template settings before submitting data
  function enableCtrls() {
    for (var id in ctlMap) {
      var obj = Ext.getCmp(ctlMap[id]);
      if (obj != null) { obj.enable(); }
    }
  }

  /// Add all neccessary event listeners for account template activity
  function addTemplateEvents() {
  }
</script>

<MT:MTTitle ID="MTTitle1" Text="Update Account" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
<div style="width:810px">
  <div id="divLblMessage" runat="server" visible="false" >
    <b>
    <div class="InfoMessage" style="margin-left:120px;width:400px;">
      <asp:Label ID="lblMessage" runat="server" meta:resourcekey="lblMessageResource1"></asp:Label>
    </div>
    </b>
  </div>

  <!-- BILLING INFORMATION --> 
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" DataBinderInstanceName="MTDataBinder1" meta:resourcekey="MTGenericForm1Resource1"></MTCDT:MTGenericForm>

  <MT:MTCheckBoxControl ID="cbApplyTemplate" runat="server" BoxLabel="Apply Template"
    Text="template" Value="template" TabIndex="95" ControlWidth="200" AllowBlank="False"
    Checked="False" Visible="false" HideLabel="True" LabelSeparator=":" Listeners="{}" meta:resourcekey="cbApplyTemplateResource1"
    Name="cbApplyTemplate" OptionalExtConfig="boxLabel:'Apply Template',&#13;&#10;inputValue:'template',&#13;&#10;checked:false"
    ReadOnly="False" XType="Checkbox" XTypeNameSpace="form" />  
        
  <!-- BUTTONS -->
  <center>
  <div class="Buttons">
     <br />       
     <asp:Button CssClass="button" ID="btnOK" OnClientClick="return ValidateForm();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="100" />&nbsp;&nbsp;&nbsp;
     <asp:Button CssClass="button" ID="btnCancel" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" OnClick="btnCancel_Click" TabIndex="110" />
     <br />       
  </div>
  </center>

</div>
  
<br />

<MT:MTDataBinder ID="MTDataBinder1" runat="server"></MT:MTDataBinder>
  <script type="text/javascript" language="javascript">
    Ext.onReady(function () {
      addTemplateEvents();
      getTemplateData();
    });
  </script>

</asp:Content>