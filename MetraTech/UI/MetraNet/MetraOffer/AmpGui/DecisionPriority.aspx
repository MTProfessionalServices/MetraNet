<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="DecisionPriority.aspx.cs" Inherits="AmpDecisionPriorityPage" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Decision Interactions" meta:resourcekey="lblTitleResource1" ></asp:Label>
  </div>

  <table style="width: 100%;">
    <tr>
      <td style="width:88px;padding-top:15px;padding-left:8px">
        <asp:Image ID="Image3" runat="server"
          ImageUrl="/Res/Images/icons/decisionPriority.png" />
      </td>
      <td align="left" style="padding-top:15px;">
        <table style="width: 100%">
          <tr>
            <td>
              <h1><asp:Label ID="DecisionPriority" runat="server" Text="Decision Priority" 
                meta:resourcekey="DecisionPriority" />
                <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DECISION_PRIORITY, TEXT_AMPWIZARD_HELP_DECISION_PRIORITY, 400, 140)">
                <asp:Image ID="Image4" runat="server" ImageUrl="/Res/Images/icons/help.png" />
                </span>
              </h1>
            </td>
          </tr>
          <tr>
            <td>
              <table style="width: 100%">
                <tr>
                  <td align="right" width="75px">
                  <asp:Label ID="PriorityLevelLabel" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
                  Font-Size="9pt" Text="Priority Level:" meta:resourcekey="PriorityLevelLabel" />
                  </td>
                  <td style="padding-top:5px;">
                     <ampc:AmpTextboxOrDropdown ID="ctrlValue" runat="server"
                       TextboxIsNumeric="true" AllowDecimalsInTextbox="false" AllowNegativeInTextbox="true" AllowBlankTextbox="false"
                       TextboxMaxValue="2147483647" TextboxMinValue="-2147483647">
                     </ampc:AmpTextboxOrDropdown>
                  </td>
                </tr>
                </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

  <div id="gridDiv" runat="server">
    <MT:MTFilterGrid ID="DecisionPriorityGrid" runat="server" TemplateFileName="AmpWizard.DecisionPriority" ExtensionName="MvmAmp">
    </MT:MTFilterGrid>
  </div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:0.1in;">   
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





  <script type="text/javascript" language="javascript">
    
    // Hide grid when user selects "Get from Param Table Column".
    function HideGrid() {
      mydiv = document.getElementById('<%=gridDiv.ClientID%>');
      mydiv.style.display = "none"; //to hide it
    }

    // Show grid when user selects "Get from Param Table Column".
    function ShowGrid() {
      mydiv = document.getElementById('<%=gridDiv.ClientID%>');
      mydiv.style.display = "block"; //to show it
    }


    Ext.onReady(function () {
      // Record the initial values of the page's controls.
      // (Note:  This is called here, and not on the master page,
      // because the call to document.getElementById() returns null
      // if executed on the master page.)
      MPC_assignInitialValues();

      // Hide priority grid if priority level value is from a PT column.
      var useDropdown = '<%=ctrlValue.UseDropdown%>';
      if (useDropdown.toLowerCase() == 'true') {
        //TBD The call to HideGrid() is commented out until we can implement
        //toggling of the grid in response to changes in ddSourceType selection.
        //HideGrid();
      }
      else {
        ShowGrid();
      }

    });

  </script>
</asp:Content>

