<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="DecisionInteractions.aspx.cs" Inherits="AmpDecisionInteractionsPage" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Decision Interactions" meta:resourcekey="lblTitleResource1" ></asp:Label>
  </div>

  <asp:HiddenField ID="origPriorityValue" runat="server" />

  <br />
  <table style="width: 100%">
    <tr>
      <td style="width: 12px">
        &nbsp;</td>
      <td>
        <asp:Label ID="IntroInfo" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" Text="If you have more than one configured Decision, you need to consider how the Decisions may interact." meta:resourcekey="IntroInfo" />
      </td>
    </tr>
  </table>


  <br />
  <table style="width: 100%">
    <tr>
      <td width="149px">
        <asp:Image ID="Image1" runat="server" 
          ImageUrl="/Res/Images/icons/decisionOverlap.png" />
      </td>
      <td align="left" style="padding-top:20px;">
        <h1><asp:Label ID="UsageOverlap" runat="server" Text="Decision Domain" meta:resourcekey="UsageOverlap" />
        <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_USAGE_OVERLAP, TEXT_AMPWIZARD_HELP_USAGE_OVERLAP, 400, 125)()">
        <asp:Image ID="Image2" runat="server" 
          ImageUrl="/Res/Images/icons/help.png" />
        </span>
        </h1>
      </td>
    </tr>
  </table>

  <table style="width: 100%">
    <tr>
      <td width="12px">&nbsp;</td>
      <td>
        <asp:Label ID="DecisionApportionQuestion" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" Text="How should the usage records be apportioned among multiple Decisions?" meta:resourcekey="DecisionApportionQuestion" />
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>
        <asp:RadioButtonList ID="RadioButtonList1" runat="server" 
              meta:resourcekey="RadioButtonList1Resource1" Width="500px" style="color:DarkBlue; font-size:large">
          <asp:ListItem Text="<%$ Resources:ExclusiveAccessToConsumedUsage.Text %>" Value="UsageConsumed"></asp:ListItem>
          <asp:ListItem Text="<%$ Resources:AllDecisionsAccessToUsageRecord.Text %>" Value="UsageNOTConsumed"></asp:ListItem>
        </asp:RadioButtonList>
      </td>
    </tr>
  </table>

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

    Ext.onReady(function () {
      // Record the initial values of the page's controls.
      // (Note:  This is called here, and not on the master page,
      // because the call to document.getElementById() returns null
      // if executed on the master page.)
      MPC_assignInitialValues();

    });

  </script>
</asp:Content>

