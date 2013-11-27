<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="RunErrorCheckDecision.aspx.cs" Inherits="AmpRunErrorCheckDecisionPage" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <br />

  <div id="ConfigurationErrorsFoundDiv" style="display:none" >
  <table style="width: 100%">
    <tr>
      <td width="40px" align="center">
        <asp:Image ID="ErrorImage" runat="server" ImageUrl="/Res/Images/icons/cross_22x22.png"/>
      </td>
      <td align="left">
        <asp:Label ID="ErrorLabel" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" Text="Your Decision Type contains configuration errors:" meta:resourcekey="ErrorLabel" />
        </td>
    </tr>
  </table>
  <br />
  <MT:MTFilterGrid ID="DecisionValidationErrorsGrid" runat="server" TemplateFileName="AmpWizard.ValidationErrors" ExtensionName="MvmAmp" ShowColumnHeaders="True">
  </MT:MTFilterGrid>
  <br />
  <table style="width: 100%">
    <tr>
      <td width="10px" align="center">
        &nbsp;
      </td>
      <td align="left">
        <asp:Label ID="NavigateLabel" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" Text="Navigate back to the appropriate pages to correct your errors. Then redo the Error Check." meta:resourcekey="NavigateLabel" />
      </td>
    </tr>
  </table>
  </div>

  <div id="NoConfigurationErrorsFoundDiv" style="display: none">
    <table style="width: 100%">
    <tr>
      <td width="40px" align="center">
        <asp:Image ID="CheckMarkImage" runat="server" ImageUrl="/Res/Images/icons/checkmark.png"/>
      </td>
      <td align="left">
        <asp:Label ID="CheckMarkLabel" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" Text="No configuration errors were detected." meta:resourcekey="CheckMarkLabel" />
        </td>
    </tr>
  </table>
  </div>

  <br />
  <div style="clear: both;">
    <div style="padding-left: 2.0in; padding-top: 0.0in;">  
      <MT:MTButton ID="btnOK" runat="server" 
                   Text="<%$ Resources:Resource,TEXT_OK %>"   
                   OnClick="btnOK_Click"
                   TabIndex="240" />
    </div>
  </div>


<script language="javascript" type="text/javascript">


    function closeWindow() {
      top.Ext.getCmp('errorCheckWin').close();
    }

  OverrideRenderer_<%= DecisionValidationErrorsGrid.ClientID %> = function(cm)
  {
    if (cm.getIndexById('ValidationErrorSeverity') != -1) {
      cm.setRenderer(cm.getIndexById('ValidationErrorSeverity'), validationErrorSeverityColRenderer);
      } 
  }

  function validationErrorSeverityColRenderer(value, meta, record, rowIndex, colIndex, store) 
  {
    if ((value + '').toLowerCase() == 'error') {
      return String.format("<img id='activeImg{0}' border=\'0\' src=\'/Res/Images/Icons/cross.png\'>", rowIndex);
    }

    return '';
  }

  function ShowErrors() {
        document.getElementById('ConfigurationErrorsFoundDiv').style.display = "block"; // to show it
        document.getElementById('NoConfigurationErrorsFoundDiv').style.display = "none"; // to hide it
  }

  function HideErrors() {
        document.getElementById('ConfigurationErrorsFoundDiv').style.display = "none"; // to hide it
        document.getElementById('NoConfigurationErrorsFoundDiv').style.display = "block"; // to show it
  }

   Ext.onReady(function () {

      dataStore_<%= DecisionValidationErrorsGrid.ClientID %>.on("load", 
          function (store, records, options) {
           
            if (store.getCount() == 0) {
              HideErrors();
            }
            else {
              ShowErrors();
            }
          });
    });




</script>
</asp:Content>

