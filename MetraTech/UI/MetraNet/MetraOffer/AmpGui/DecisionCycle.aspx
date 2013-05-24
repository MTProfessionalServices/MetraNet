<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master"
  AutoEventWireup="true" CodeFile="DecisionCycle.aspx.cs" Inherits="AmpDecisionCyclePage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc1" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblTitleDecisionCycle" runat="server" Text="Decision Cycle" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
  <table width="100%">
    <tr>
      <td style="width: 5%; padding-top: 15px; padding-left:15px" align="center">
        <asp:Image ID="ImageDecisionCycle" runat="server" ImageUrl="/Res/Images/icons/calendar_days.png" />
      </td>
      <td style="width: 90%">
        <div style="line-height: 20px; padding-top: 10px; padding-left: 10px; vertical-align:top">
          <asp:Label ID="lblDecisionCycle" meta:resourcekey="lblDecisionCycle" runat="server"
            Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" Text="Your Decision Type can aggregate events or usage across different billing intervals or time periods." />
        </div>
        <div style="padding-top: 5px; padding-left: 10px;">
          <span style="color: blue; text-decoration: underline; cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_MORE_DECISION_CYCLE, 450, 90)"
            id="DecisionCycleMoreLink">
            <asp:Literal ID="MoreInfoLiteral" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" />
          </span>
        </div>
      </td>
    </tr>
  </table>
  <table>
    <tr>
      <td style="padding-left: 15px; width: 225px; padding-top: 25px" align="left" valign="top">
        <asp:Label ID="lblUnitOfTime" meta:resourcekey="lblUnitOfTime" runat="server" Font-Bold="False"
          ForeColor="DarkBlue" Font-Size="9pt" Text="Unit of time for the Decision Cycle:" />
      </td>
      <td style="padding-top: 20px; padding-left: 5px">
        <asp:RadioButtonList runat="server" ID="RBL_UnitOfTime" CellSpacing="0">
          <asp:ListItem Value="The Decision Cycle matches the billing interval" meta:resourcekey="rblDecisionCycleBillingInterval"></asp:ListItem>
          <asp:ListItem Value="Days" meta:resourcekey="rblDays"></asp:ListItem>
          <asp:ListItem Value="Weeks" meta:resourcekey="rblWeeks"></asp:ListItem>
          <asp:ListItem Value="Months" meta:resourcekey="rblMonths"></asp:ListItem>
          <asp:ListItem Value="Quarters" meta:resourcekey="rblQuarters"></asp:ListItem>
          <asp:ListItem Value="Years" meta:resourcekey="rblYears"></asp:ListItem>
        </asp:RadioButtonList>
      </td>
    </tr>
  </table>
  <div id="divDecisionCycleBillingInterval">
  <table>
    <tr>
      <td style="padding-left: 15px; width: 225px; padding-top: 29px" valign="top">
        <asp:Label ID="lblNumberOfMonth" meta:resourcekey="lblNumberOfMonth" runat="server"
          Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" Text="Number of month in the Decision Cycle:" />
      </td>
      <td style="padding-top: 20px">
        <ampc1:AmpTextboxOrDropdown ID="numberOfMonth" runat="server" TextboxIsNumeric="true"></ampc1:AmpTextboxOrDropdown>
      </td>
    </tr>
    <tr>
      <td style="padding-left: 15px; width: 225px; padding-top: 29px" valign="top">
        <asp:Label ID="lblNumberMonthBillingInterval" meta:resourcekey="lblNumberMonthBillingInterval" 
          runat="server" Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" Text="Number of month from the beginning of the billing interval to the start of the Decision Cycle:" />
      </td>
     
      <td style="padding-top: 20px">
        <ampc1:AmpTextboxOrDropdown ID="numberMonthBillingInterval" runat="server" TextboxIsNumeric="true"></ampc1:AmpTextboxOrDropdown>
      </td>
    </tr>
  </table>
 </div>
  <div style="padding-left: 15px; padding-top: 20px">
    <asp:Label ID="lblDecisionEffected" runat="server" Font-Bold="False" ForeColor="DarkBlue"
      Font-Size="9pt" meta:resourcekey="lblDecisionEffect" Text="How long should the Decision Type be in effect?"></asp:Label>
  </div>
    <table>
  <tr>
  <td style="padding-left: 9px; padding-top: 5px; vertical-align: top; width:215px">
    <asp:RadioButtonList ID="RBL_DecisionEffect" runat="server" CellSpacing="0" Width="215">
      <asp:ListItem Value="Indefinitely" meta:resourcekey="rblIndefinitely" runat="server"></asp:ListItem>
      <asp:ListItem Value="For a specific number of Decision Cycles:" meta:resourcekey="rblSpecified"
        runat="server"></asp:ListItem>
    </asp:RadioButtonList>
  </td>
  <td style="padding-top: 24px;">
   <ampc1:AmpTextboxOrDropdown ID="decisionCycleCustomized" runat="server" TextboxIsNumeric="true"></ampc1:AmpTextboxOrDropdown>
  </td>
  </tr>
  </table>
  <div style="padding-left: 0.85in; padding-top: 0.3in;">
    <table>
      <col style="width: 190px" />
      <col style="width: 190px" />
      <tr>
        <td align="left">
          <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
            OnClientClick="setLocationHref(ampPreviousPage); return false;" CausesValidation="false"
            TabIndex="230" />
        </td>
        <td align="right">
          <MT:MTButton ID="btnSaveAndContinue" runat="server" OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
            OnClick="btnContinue_Click" CausesValidation="true" TabIndex="240" />
        </td>
      </tr>
    </table>
  </div>


<script language="javascript" type="text/javascript">
  Ext.onReady(function () {
    // Record the initial values of the page's controls.
    // (Note:  This is called here, and not on the master page,
    // because the call to document.getElementById() returns null
    // if executed on the master page.)
    MPC_assignInitialValues();

    InitDictionary();
    SetDisabledDecisionEffectState();
    DecisionCycleControlShow(showDivDecisionCycle);
  });

  var dictUnitOfTimes = {};
  var dictBillingInterval = {};
  var showDivDecisionCycle = <%=ShowDivDecisionCycle.ToString().ToLower() %> ;

  function InitDictionary() {
    dictUnitOfTimes["Days"] = '<%=GetLocalResourceObject("lblNumberOfDays.Text")%>';
    dictUnitOfTimes["Weeks"] = '<%=GetLocalResourceObject("lblNumberOfWeeks.Text")%>';
    dictUnitOfTimes["Months"] = '<%=GetLocalResourceObject("lblNumberOfMonth.Text")%>';
    dictUnitOfTimes["Quarters"] = '<%=GetLocalResourceObject("lblNumberOfQuarters.Text")%>';
    dictUnitOfTimes["Years"] = '<%=GetLocalResourceObject("lblNumberOfYears.Text")%>';

    dictBillingInterval["Days"] = '<%=GetLocalResourceObject("lblNumberDaysBillingInterval.Text")%>';
    dictBillingInterval["Weeks"] = '<%=GetLocalResourceObject("lblNumberWeeksBillingInterval.Text")%>';
    dictBillingInterval["Months"] = '<%=GetLocalResourceObject("lblNumberMonthBillingInterval.Text")%>';
    dictBillingInterval["Quarters"] = '<%=GetLocalResourceObject("lblNumberQuartersBillingInterval.Text")%>';
    dictBillingInterval["Years"] = '<%=GetLocalResourceObject("lblNumberYearsBillingInterval.Text")%>';
    
  }

  function DecisionCycleUnitOfTimeChanged(unitOfTime) {
    document.getElementById('<%=lblNumberOfMonth.ClientID%>').innerHTML = dictUnitOfTimes[unitOfTime];
    document.getElementById('<%=lblNumberMonthBillingInterval.ClientID%>').innerHTML = dictBillingInterval[unitOfTime];
    DecisionCycleControlShow(true);
  }

  function DecisionCycleControlShow(show) {
    document.getElementById('divDecisionCycleBillingInterval').style.display = show ? '' : 'none';
  }

  function ChangeDecisionCycleEffectState(enabled, ampControlID) {
    eval('ChangeControlStateAction_' + ampControlID + '(' + enabled + ')');
  }

  function SetDisabledDecisionEffectState() {
    var rblEffect = document.getElementById('<%=RBL_DecisionEffect.ClientID%>');
    var rblEffectitems = rblEffect.getElementsByTagName("input");
    var custUserControl = document.getElementById('<%=decisionCycleCustomized.ClientID%>_ddSourceType');

    // If 'indefinitely' is selected but we're in View mode, then decisionCycleCustomized is already invisible,
    // so don't try to disable it here.
    if (rblEffectitems[0].checked && (custUserControl != null))
    {
         eval('DisabledControl_<%=decisionCycleCustomized.ClientID %>()');
    }
  }

</script>
</asp:Content>
