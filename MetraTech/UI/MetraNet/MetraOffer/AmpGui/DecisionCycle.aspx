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
        <asp:RadioButton id="RadioButtonDecisionCycleBillingInterval" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblDecisionCycleBillingInterval.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <br/>
        <asp:RadioButton id="RadioButtonDays" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblDays.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <br/>
        <asp:RadioButton id="RadioButtonWeeks" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblWeeks.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <br/>
        <asp:RadioButton id="RadioButtonMonths" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblMonths.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <br/>
        <asp:RadioButton id="RadioButtonQuarters" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblQuarters.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <br/>
        <asp:RadioButton id="RadioButtonYears" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblYears.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <br/>
        <asp:RadioButton id="RadioButtonUnitOfTimeFromParamTable" runat="server" GroupName="RBL_UnitOfTime" Text="<%$ Resources:rblUnitOfTimeFromParamTable.Text %>" ForeColor="DarkBlue" Font-Size="8pt"/>
        <div style="margin-top: -0.15in; padding-left: 257px;">
            <div id="divUnitOfTimeFromParamTableDropdownSource" runat="server" >
                <MT:MTDropDown ID="ddUnitOfTimeFromParamTableSource" runat="server" ControlWidth="160" ListWidth="200" HideLabel="True" AllowBlank="True" Editable="True"/>
            </div>
        </div>
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
    dictUnitOfTimes["<%=RadioButtonDays.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberOfDays.Text")%>';
    dictUnitOfTimes["<%=RadioButtonWeeks.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberOfWeeks.Text")%>';
    dictUnitOfTimes["<%=RadioButtonMonths.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberOfMonth.Text")%>';
    dictUnitOfTimes["<%=RadioButtonQuarters.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberOfQuarters.Text")%>';
    dictUnitOfTimes["<%=RadioButtonYears.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberOfYears.Text")%>';
    dictUnitOfTimes["<%=RadioButtonUnitOfTimeFromParamTable.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberOfTimeUnits.Text")%>';

    dictBillingInterval["<%=RadioButtonDays.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberDaysBillingInterval.Text")%>';
    dictBillingInterval["<%=RadioButtonWeeks.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberWeeksBillingInterval.Text")%>';
    dictBillingInterval["<%=RadioButtonMonths.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberMonthBillingInterval.Text")%>';
    dictBillingInterval["<%=RadioButtonQuarters.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberQuartersBillingInterval.Text")%>';
    dictBillingInterval["<%=RadioButtonYears.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberYearsBillingInterval.Text")%>';
    dictBillingInterval["<%=RadioButtonUnitOfTimeFromParamTable.ClientID%>"] = '<%=GetLocalResourceObject("lblNumberTimeUnitsBillingInterval.Text")%>';
  }

  function DecisionCycleUnitOfTimeChanged(unitOfTime) {
    document.getElementById('<%=lblNumberOfMonth.ClientID%>').innerHTML = dictUnitOfTimes[unitOfTime];
    document.getElementById('<%=lblNumberMonthBillingInterval.ClientID%>').innerHTML = dictBillingInterval[unitOfTime];
    if (unitOfTime == '<%=RadioButtonUnitOfTimeFromParamTable.ClientID%>') { 
        var dd1 = Ext.getCmp('<%=ddUnitOfTimeFromParamTableSource.ClientID %>');
        dd1.enable();
    }
    else {
        var dd2 = Ext.getCmp('<%=ddUnitOfTimeFromParamTableSource.ClientID %>');
        dd2.disable();
    }
      

    DecisionCycleControlShow(true);
  }

  function DecisionCycleUnitOfTimeInitialState() {
    var dd2 = Ext.getCmp('<%=ddUnitOfTimeFromParamTableSource.ClientID %>');
        dd2.disable();

    DecisionCycleControlShow(false);
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
