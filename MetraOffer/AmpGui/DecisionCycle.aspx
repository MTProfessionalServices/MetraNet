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
          <div>
            <div style="line-height: 20px; padding-top: 10px; padding-left: 10px; float: left">
              <asp:Label ID="lblDecisionCycle" meta:resourcekey="lblDecisionCycle" runat="server"
                Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" Text="Your Decision Type can aggregate events or usage across different billing intervals or time periods." />
            </div>
            <div style="padding-top: 5px; padding-left: 10px; fit-position: right;" align="left">
                    <span style="color:blue;text-decoration:underline;cursor:pointer;horiz-align: left" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_MORE_DECISION_CYCLE, TEXT_AMPWIZARD_MORE_DECISION_CYCLE, 450, 90)">
                      <img id="Img1" src='/Res/Images/icons/help.png' />
                    </span>
            </div>
          </div>
      </td>
    </tr>
  </table>
  <table>
    <tr>
    <td style="padding-left: 15px;padding-top: 25px" align="left" valign="top">
        <asp:Label ID="lblUnitOfTime"  runat="server" Font-Bold="False"
          ForeColor="DarkBlue" Font-Size="9pt" Text="<%$ Resources: lblUnitOfTime.Label%>"  />
      
        <MT:MTDropDown ID="ddTimeCycleUnit" runat="server" HideLabel="True" Label="Select parameter table:"  ControlWidth="160" ListWidth="200" AllowBlank="True" Editable="True"/>
        </td>
        </tr>
  </table>
           <div id="divUnitOfTimeFromParamTableDropdownSource" >
            <table>
                <tr>
                    <td style="padding-left: 15px; width: 225px; padding-top: 29px" valign="top">
                        <asp:Label ID="Label1"  runat="server" Font-Bold="False"
                            ForeColor="DarkBlue" Font-Size="9pt" Text="<%$ Resources : rblUnitOfTimeFromParamTable.Label %>" meta:resourcekey="rblUnitOfTimeFromParamTable" />
                        
                    </td>
                    <td style="padding-left: 15px; width: 225px; padding-top: 29px" valign="top">
                        <MT:MTDropDown ID="ddUnitOfTimeFromParamTableSource" runat="server" HideLabel="True" Label="Select parameter table:" meta:resourcekey="rblUnitOfTimeFromParamTable" ControlWidth="160" ListWidth="200" AllowBlank="True" Editable="True"/>
                    </td>
                </tr>
            </table>     
         </div>
    

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
          <MT:MTButton ID="btnSaveAndContinue" runat="server" OnClientClick="if(!ValidateBoxes()){return false;} else if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
            OnClick="btnContinue_Click" CausesValidation="true" TabIndex="240" />
        </td>
      </tr>
    </table>
  </div>


<script language="javascript" type="text/javascript">
  var dictUnitOfTimes = [];
  var dictBillingInterval = {};
  var showDivDecisionCycle = <%=ShowDivDecisionCycle.ToString().ToLower() %> ;
  var showDivParamTable = <%=ShowDivParamTable.ToString().ToLower() %> ;
  Ext.onReady(function () {
    // Record the initial values of the page's controls.
    // (Note:  This is called here, and not on the master page,
    // because the call to document.getElementById() returns null
    // if executed on the master page.)
    MPC_assignInitialValues();
    InitDictionary();
    SetDisabledDecisionEffectState();
    DecisionCycleControlShow(showDivDecisionCycle);
    ParamTableDivShow(showDivParamTable);
  });

  function ValidateBoxes() {
      var ddval = document.getElementById("ctl00_ContentPlaceHolder1_numberOfMonth_ddSourceType").value;
      var zero = '<%=GetGlobalResourceObject("AmpWizard", "TEXT_FIXED_VALUE")%>';
      if (ddval.toString() == zero.toString()) {
          var boxval = document.getElementById("ctl00_ContentPlaceHolder1_numberOfMonth_tbNumericSource").value.toString();
          if (boxval == "") {
              alert('<%=GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_UNIT_OF_TIME")%>');
              return false;
          }
      }
      ddval = document.getElementById("ctl00_ContentPlaceHolder1_numberMonthBillingInterval_ddSourceType").value;
      if (ddval.toString() == zero.toString()) {
          boxval = document.getElementById("ctl00_ContentPlaceHolder1_numberMonthBillingInterval_tbNumericSource").value.toString();
          if (boxval == "") {
            alert('<%=GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_UNIT_OF_TIME_INTERVAL")%>');
            return false;
          }
      }
      return true;
  }

  function InitDictionary() {
    
      
      var str = '<%=GetLocalResourceObject("LIST_DD_TIME_CYCLE_UNIT")%>';
      dictUnitOfTimes = str.split(",");
      var basestr = '<%=GetLocalResourceObject("lblNumberXBillingInterval.Text")%>';
      for (var i = 0; i < dictUnitOfTimes.length; i++) {
          if(i != dictUnitOfTimes.length -1)
            dictBillingInterval[i] = String.format(basestr,(dictUnitOfTimes[i]+"s").toLowerCase());
          else
            dictBillingInterval[i] = '<%=GetLocalResourceObject("lblNumberTimeUnitsBillingInterval.Text")%>';
      }
  
  }

  function DecisionCycleUnitOfTimeChanged() {
    var unitOfTime = document.getElementById('<%=ddTimeCycleUnit.ClientID%>').value;
    var basestr = '<%=GetLocalResourceObject("lblNumberOfX.Text")%>';
    document.getElementById('<%=lblNumberOfMonth.ClientID%>').innerHTML = String.format(basestr, (dictUnitOfTimes[unitOfTime]+"s").toLowerCase());
    var dd1 = Ext.getCmp('<%=ddUnitOfTimeFromParamTableSource.ClientID %>');

    document.getElementById('<%=lblNumberMonthBillingInterval.ClientID%>').innerHTML = dictBillingInterval[unitOfTime.toString()];
    if (unitOfTime.toString()=="6") {
        document.getElementById('<%=lblNumberOfMonth.ClientID%>').innerHTML = '<%=GetLocalResourceObject("lblNumberOfTimeUnits.Text")%>';
        dd1.enable();
        ParamTableDivShow(true);
        DecisionCycleControlShow(true);
    }
    else{
        dd1.disable();
        DecisionCycleControlShow(true);
        ParamTableDivShow(false);
    }
  }

  function DecisionCycleUnitOfTimeInitialState() {
      DecisionCycleUnitOfTimeChanged();
  }
  function ParamTableDivShow(show) {
    document.getElementById('divUnitOfTimeFromParamTableDropdownSource').style.display = show ? '' : 'none';
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
