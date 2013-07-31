<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="SelectDecisionAction.aspx.cs" Inherits="AmpSelectDecisionActionPage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc1" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc2" %>
<%@ Register src="~/UserControls/AmpTextboxOrDropdown.ascx" tagName="AmpTextboxOrDropdown" tagPrefix="ampc3" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Decision Action" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

  <div style="line-height:20px;padding-top:10px;padding-left:15px;">
    <asp:Label ID="lblIncrementalOrBulk" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblIncrementalOrBulkResource1" 
      Text="How should the Decision Type process the records?" ></asp:Label>
    <span id="HelpLinkBulkDescription" style="color:blue;text-decoration:underline;cursor:pointer" 
          onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_INCREMENTAL_OR_BULK, TEXT_AMPWIZARD_HELP_INCREMENTAL_OR_BULK, 450, 100)">
       <img id="Img1" src='/Res/Images/icons/help.png' />
    </span>
  </div>
  <div style="padding-left:45px;padding-top:5px;">
    <table cellpadding="0" cellspacing="0" style="width:100%;">
    <tr> <!-- Row 1 -->
      <td style="width:180px;padding-top:15px;" valign="top">
      <asp:RadioButton ID="multiBucket" runat="server" GroupName="BucketRadioButtons" 
              Text="Multi-Bucket" meta:resourcekey="rblIncrementallyResource1" ForeColor="Black"/>       
        <span style="color:blue;text-decoration:underline;cursor:pointer" 
            onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_MULTIBUCKET, TEXT_AMPWIZARD_HELP_MULTIBUCKET, 450, 100)">
          <img id="Img2" src='/Res/Images/icons/help.png' />
        </span>
      </td>
	</tr>
	<tr> <!-- Row 2 -->
      <td style="width:180px;padding-top:15px;" valign="top">
      <asp:RadioButton ID="singleBucket" runat="server" GroupName="BucketRadioButtons" 
              Text="Single-Bucket" meta:resourcekey="rblInBulkResource1" ForeColor="Black"/>       
        <span style="color:blue;text-decoration:underline;cursor:pointer" 
            onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_SINGLEBUCKET, TEXT_AMPWIZARD_HELP_SINGLEBUCKET, 450, 100)">
          <img id="Img2" src='/Res/Images/icons/help.png' />
        </span>
      </td>
	</tr>
	</table>
  </div>

  <div style="line-height:20px;padding-top:20px;padding-left:15px;">
    <asp:Label ID="lblDecisionAction" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblDecisionActionResource1" 
      Text="What action should the Decision Type take?" ></asp:Label>
  </div>
  <div style="padding-left:45px;padding-top:0px;">
  <table cellpadding="0" cellspacing="0" style="width:100%;">
    <tr> <!-- Row 1 -->
      <td style="width:180px;padding-top:15px;" valign="top">
        <asp:RadioButton ID="radUnitRate" runat="server" GroupName="DecisionActionRadioButtons" 
              Text="Apply a new rate for units" meta:resourcekey="radUnitRateResource1" ForeColor="Black"/>       
        <span style="color:blue;text-decoration:underline;cursor:pointer" 
            onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_UNIT_RATE, TEXT_AMPWIZARD_HELP_UNIT_RATE, 450, 100)">
          <img id="Img2" src='/Res/Images/icons/help.png' />
        </span>
      </td>
      <td style="padding-top:10px">
        <!-- Hardcoded value vs. Param Table field -->
        <ampc1:AmpTextboxOrDropdown ID="unitRate" runat="server" TextboxIsNumeric="true"></ampc1:AmpTextboxOrDropdown>
      </td>
    </tr>
    <tr> <!-- Row 2 -->
      <td style="width:180px;padding-top:15px;" valign="top">
        <asp:RadioButton id="radEventRate" runat="server" GroupName="DecisionActionRadioButtons"
              Text="Apply a new rate for events" meta:resourcekey="radEventRateResource1" ForeColor="Black"/>
        <span style="color:blue;text-decoration:underline;cursor:pointer" 
            onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_EVENT_RATE, TEXT_AMPWIZARD_HELP_EVENT_RATE, 450, 100)">
          <img id="Img3" src='/Res/Images/icons/help.png' />
        </span>
      </td>
      <td style="padding-top:10px">
        <!-- Hardcoded value vs. Param Table field -->
        <ampc2:AmpTextboxOrDropdown ID="eventRate" runat="server" TextboxIsNumeric="true"></ampc2:AmpTextboxOrDropdown>
      </td>
    </tr>
    <tr> <!-- Row 3 -->
      <td style="width:180px;padding-top:15px;" valign="top">
        <asp:RadioButton id="radDiscount" runat="server" GroupName="DecisionActionRadioButtons"
              Text="Apply a percentage discount" meta:resourcekey="radDiscountResource1" ForeColor="Black"/>
        <span style="color:blue;text-decoration:underline;cursor:pointer" 
            onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_DISCOUNT, TEXT_AMPWIZARD_HELP_DISCOUNT, 450, 150)">
          <img id="Img4" src='/Res/Images/icons/help.png' />
        </span>
      </td>
      <td style="padding-top:10px;width:260px;">
        <!-- Hardcoded value vs. Param Table field -->
        <ampc3:AmpTextboxOrDropdown ID="discount" runat="server" TextboxIsNumeric="true"></ampc3:AmpTextboxOrDropdown>
      </td>
      <td style="padding-top:11px;" align="left" valign="middle">
        <span style="color:Black; font-size:x-small"><asp:Literal ID="Literal1" Text="%" runat="server"></asp:Literal></span>
      </td>
    </tr>
    <tr> <!-- Row 4 -->
      <td colspan="2" style="padding-top:15px;" valign="top">
        <div style="float:left;">
        <asp:RadioButton id="radGenCharge" runat="server" GroupName="DecisionActionRadioButtons"
              Text="Generate a new Charge/Credit" meta:resourcekey="radGenChargeResource1" ForeColor="Black"/>
        <span style="color:blue;text-decoration:underline;cursor:pointer;" 
            onclick=" displayInfoMultiple(TITLE_AMPWIZARD_HELP_GENERATED_CHARGE, TEXT_AMPWIZARD_HELP_GENERATED_CHARGE, 450, 70)">
          <img id="Img5" src='/Res/Images/icons/help.png' />
        </span>
        </div>
        <div style="padding-top:0px;">
          <img id="Img6" src='/Res/Images/icons/cog_error.png' runat="server" title="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" />
        </div>
      </td>
    </tr>
  </table>
  </div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:0.3in;">   
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
          </td>
        </tr>
      </table> 
  </div>


  <script type="text/javascript" language="javascript">

    // Enable or disable the fixed-value-or-PT-col controls (ctrlDiscount, ctrlUnitRate, ctrlEventRate).
    // The state of ampControlID1 and ampControlID2 is set to bEnabled,
    // and the state of AmpControlID3 depends on whether radGenCharge is checked.
    function EnableAppropriateUserControls(bEnabled, ampControlID1, ampControlID2, ampControlID3) {

      var radGenCharge = document.getElementById('<%=radGenCharge.ClientID%>');

      eval('ChangeControlStateAction_' + ampControlID1 + '(' + bEnabled + ')');
      eval('ChangeControlStateAction_' + ampControlID2 + '(' + bEnabled + ')');
      
      if (radGenCharge.checked) {
        eval('ChangeControlStateAction_' + ampControlID3 + '(' + bEnabled + ')');
      }
      else {
        eval('ChangeControlStateAction_' + ampControlID3 + '(' + !bEnabled + ')');
      }
    }
        
    // Disable user controls based on radio button selection.
    function DisableAppropriateUserControls() {
      var radUnitRate = document.getElementById('<%=radUnitRate.ClientID%>');
      var radDiscount = document.getElementById('<%=radDiscount.ClientID%>');
      var radEventRate = document.getElementById('<%=radEventRate.ClientID%>');
      var radGenCharge = document.getElementById('<%=radGenCharge.ClientID%>');

      // Must check for null user controls.  Can't disable them if they're invisible (not on the page).
      var unitRateUserControl = document.getElementById('<%=unitRate.ClientID%>_ddSourceType');
      var eventRateUserControl = document.getElementById('<%=eventRate.ClientID%>_ddSourceType');
      var discountUserControl = document.getElementById('<%=discount.ClientID%>_ddSourceType');

      if ((radEventRate.checked || radDiscount.checked || radGenCharge.checked) && (unitRateUserControl != null))
      {
        eval('DisabledControl_<%=unitRate.ClientID %>()');
      }
      if ((radUnitRate.checked || radDiscount.checked || radGenCharge.checked) && (eventRateUserControl != null))
      {
        eval('DisabledControl_<%=eventRate.ClientID %>()');
      }
      if ((radUnitRate.checked || radEventRate.checked || radGenCharge.checked) && (discountUserControl != null))
      {
        eval('DisabledControl_<%=discount.ClientID %>()');
      }
    }


    Ext.onReady(function () {
        DisableAppropriateUserControls();

        //JCTBD
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        MPC_assignInitialValues();

    });  // Ext.onReady
    
  </script>


</asp:Content>

