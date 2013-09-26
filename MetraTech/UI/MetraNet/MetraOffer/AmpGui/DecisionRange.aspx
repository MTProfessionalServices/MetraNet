<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master"
    AutoEventWireup="true" CodeFile="DecisionRange.aspx.cs" Inherits="AmpDecisionRangePage" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc1" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc2" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<div class="CaptionBar">
    <asp:Label ID="lblTitleDecisionRange" runat="server" Text="Range" meta:resourcekey="lblTitleResource1"></asp:Label>
</div>

<div style="line-height: 20px; padding-top: 10px; padding-left: 10px">
    <div style="float:left">
        <asp:Label ID="lblDecisionRange" meta:resourcekey="lblDecisionRange" runat="server" Font-Bold="False" ForeColor="Black" Font-Size="9pt" Text="The aggregate value for the Decision Type has a range of values within which the Decision Type is applicable." />
    </div>
    <div style="fit-position: right;" align="left">
        <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DECISION_RANGE, TEXT_AMPWIZARD_MORE_DECISION_RANGE, 450, 70)">
            <img id="Img1" src='/Res/Images/icons/help.png' align="left" />
        </span>
    </div>
</div>
<div style="clear: both" />
<br/>

<div style="margin-left:0.85in;">
    <div style="float:left;">
        <asp:Label ID="lblStartOfRange" meta:resourcekey="lblStartOfRange" runat="server"
            Font-Bold="False" ForeColor="Black" Font-Size="9pt"
            Text="Start of range:" />
    </div>
    <div>
        <ampc1:AmpTextboxOrDropdown ID="startRange" runat="server" TextboxIsNumeric="true"></ampc1:AmpTextboxOrDropdown>
    </div>
</div>
<div style="clear: both" />
<br/>

<div style="margin-left:0.85in;">
    <div style="float:left;">
        <asp:Label ID="lblEndOfRange" meta:resourcekey="lblEndOfRange" runat="server"
            Font-Bold="False" ForeColor="Black" Font-Size="9pt"
            Text="End of range:" />
    </div>
    <div>
        <ampc2:AmpTextboxOrDropdown ID="endRange" runat="server" TextboxIsNumeric="true"></ampc2:AmpTextboxOrDropdown>
    </div>
</div>
<div style="clear: both" />
<br/>
     
<div style="line-height: 20px; padding-top: 10px; padding-left: 10px">
    <div style="float:left">
        <asp:Label ID="Label2" runat="server" Font-Bold="False" ForeColor="Black" Font-Size="9pt" Text="<%$ Resources: lblDecisionRangeRestart.Text%>"  />
    </div>
    <div style="fit-position: right;" align="left">
        <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_RESTART_RANGE, TEXT_AMPWIZARD_HELP_DECISION_RANGE, 450, 70)">
            <img id="ImageHelp" src='/Res/Images/icons/help.png' />
        </span>
    </div>
</div>
<br/>
<table>
    <tr>
        <td>
            <MT:MTDropDown ID="ddDecisionRangeRestart" runat="server" HideLabel="True" Label="Prorate at start?"  ControlWidth="160" ListWidth="200" AllowBlank="False" Editable="True"/>
        </td>
        <td>
            <div id="divRestartFromParamTableDropdownSource">
                <MT:MTDropDown ID="ddRangeRestartFromParamTableSource" runat="server" HideLabel="True" ControlWidth="160" ListWidth="200" AllowBlank="True" Editable="True"/>
            </div>
        </td>
    </tr>
</table>

<br/>
<div class="clearer" />
<div style="line-height: 20px; padding-top: 10px; padding-left: 10px">
    <div style="float:left">
        <asp:Label ID="LabelProrate"  runat="server" Font-Bold="False" ForeColor="Black" Font-Size="9pt" Text="<%$ Resources: lblProrate.Text%>"  />
    </div>
</div>
<br/><br/>
<table>
    <tr>
        <td>
            <MT:MTDropDown ID="ddProrate" runat="server" HideLabel="True" ControlWidth="300" ListWidth="300" AllowBlank="False" Editable="True"/>
        </td>
        <td>
            <div id="divProrateFromParamTableDropdownSource" >
                <MT:MTDropDown ID="ddProrateFromParamTableDropdownSource" runat="server" HideLabel="True" ControlWidth="160" ListWidth="200" AllowBlank="True" Editable="True"/>
            </div>
        </td>
    </tr>
</table> 
           
<div class="clearer" />
<div style="padding-left: 0.85in; padding-top: 0.2in;">
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

    <script type="text/javascript" language="javascript">
      var showDivRestartParamTable = <%=showDivRestartParamTable.ToString().ToLower() %> ;
      var showDivProrateParamTable = <%=showDivProrateParamTable.ToString().ToLower() %> ;
      
      ParamTableDivShow('divRestartFromParamTableDropdownSource', showDivRestartParamTable);
      ParamTableDivShow('divProrateFromParamTableDropdownSource', showDivProrateParamTable);
      
      function ChangeControlState(textBoxControl, dropDownControl, disabledTextBox) {
          var txb = Ext.getCmp(textBoxControl);
          var cmb = Ext.getCmp(dropDownControl);

          if (disabledTextBox) {
              cmb.enable();
              txb.disable();
              txb.setValue('');
          } else {
              cmb.disable();
              cmb.setValue('');
              txb.enable();
          }

          ParamTableDivShow('divRestartFromParamTableDropdownSource', showDivRestartParamTable);
          ParamTableDivShow('divProrateStartFromParamTableDropdownSource', showDivProrateStartParamTable);
          ParamTableDivShow('divProrateEndFromParamTableDropdownSource', showDivProrateEndParamTable);
          ParamTableDivShow('divProrateFromParamTableDropdownSource', showDivProrateParamTable);
      }

      function ddDecisionRangeRestartChanged()
      {
          var restart = document.getElementById('<%=ddDecisionRangeRestart.ClientID%>').value;
          if (restart == '<%=Resources.Resource.TEXT_FROM_PARAMETER_TABLE %>') {
              showDivRestartParamTable = true;
          } else {
              showDivRestartParamTable = false;
          }
          ParamTableDivShow('divRestartFromParamTableDropdownSource', showDivRestartParamTable);
      }
      
      function ddDecisionRangeRestartInitialState() {
          ddDecisionRangeRestartChanged();
      }
      
      function ddProrateChanged()
      {
          var restart = document.getElementById('<%=ddProrate.ClientID%>').value;
          if (restart == '<%=Resources.Resource.TEXT_FROM_PARAMETER_TABLE %>') {
              showDivProrateParamTable = true;
          } else {
              showDivProrateParamTable = false;
          }
          ParamTableDivShow('divProrateFromParamTableDropdownSource', showDivProrateParamTable);
      }
      
      function ddProrateInitialState() {
          ddProrateChanged();
      }
      
      Ext.onReady(function () {
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        MPC_assignInitialValues();
      });

    function ParamTableDivShow(controlName, show) {
        document.getElementById(controlName).style.display = show ? '' : 'none';
    }


    function ValidateBoxes() {
        var ddval = document.getElementById("<%=startRange.ClientID%>"+"_ddSourceType").value;
        var zero = '<%=GetGlobalResourceObject("AmpWizard", "TEXT_FIXED_VALUE")%>';
        if (ddval.toString() == zero.toString()) {
            var boxval = document.getElementById("<%=startRange.ClientID%>"+"_tbNumericSource").value.toString();
            if (boxval == "") {
                alert('<%=GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_START_RANGE")%>');
                return false;
            }
        }
        ddval = document.getElementById("<%=endRange.ClientID%>"+"_ddSourceType").value;
        if (ddval.toString() == zero.toString()) {
            boxval = document.getElementById("<%=endRange.ClientID%>"+"_tbNumericSource").value.toString();
            if (boxval == "") {
                alert('<%=GetLocalResourceObject("TEXT_ERROR_NO_VALUE_FOR_END_RANGE")%>');
                return false;
            }
        }
        return true;
    }

    </script>
</asp:Content>
