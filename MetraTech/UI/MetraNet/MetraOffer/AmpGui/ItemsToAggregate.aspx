<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ItemsToAggregate.aspx.cs" Inherits="AmpItemsToAggregatePage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Items to Aggregate" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>

   <div style="line-height:20px;padding-top:10px;padding-left:15px;">
     <asp:Label ID="Label6" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" meta:resourcekey="lblGenInfoResource1" 
          Text="Decisions count monetary amounts, units or number of events. This screen allows the selection of what a decision type will aggregate." />
          <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_USAGE_OVERLAP,TEXT_AMPWIZARD_HELP_ITEMS_TO_AGGREGATE, 400, 125)()">
            <asp:Image ID="Image1" runat="server" 
              ImageUrl="/Res/Images/icons/help.png" />
          </span>
   </div>

  <div style="line-height:20px;padding-top:10px;padding-left:10px;">
    
    <asp:Label ID="Label1" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblGenInfoResource2" 
      Text="Let’s adjust the settings for this Decision Type." />
    
    <br />
    <br />
  </div>

   <div style="line-height:20px;padding-top:10px;padding-left:10px;">
     <table style="width: 500px">
       <tr>
         <td style="width: 40px">
          <asp:Image ID="Image2" runat="server" Height="32px" 
            ImageUrl="/Res/Images/icons/sum_32x32.png" Width="32px" 
             meta:resourcekey="Image2Resource1" />
         </td>
         <td>
          <asp:Label ID="Label2" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
            Font-Size="9pt" meta:resourcekey="lblGenInfoResource3" 
            Text="How should aggregation be done for this Decision Type?" />
          <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AGGREGATION_METHOD, TEXT_AMPWIZARD_HELP_AGGREGATION_METHOD, 300, 130)">
            <img id="Image3" src='/Res/Images/icons/help.png' />
          </span>
         </td>
       </tr>
     </table>
  </div>

  <br/>


  <table style="width: 500px">
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td colspan="2">
      <asp:RadioButton id="radAddUpMonetaryChargeAmounts" runat="server" GroupName="AggregateMethod"
              Text="<%$ Resources:AddUpMonetaryChargeAmountsLabel.BoxLabel %>" ForeColor="DarkBlue" Font-Size="8pt"/>
      </td>
      <td>
        &nbsp;</td>
    </tr>
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td style="width: 20px">
        &nbsp;</td>
      <td>
      <asp:Label ID="Label3" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
        Font-Size="8pt" meta:resourcekey="lblGenInfoResource4" 
        Text="Example: &quot;Apply a discount if there's over $100 in charges.&quot;" />
      </td>
    </tr>
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td colspan="2">
      <asp:RadioButton id="radAddUpUnitsOfUsage" runat="server" GroupName="AggregateMethod"
              Text="<%$ Resources:AddUpUnitsOfUsageLabel.BoxLabel %>" ForeColor="DarkBlue" Font-Size="8pt" />
      </td>
      <td>
        &nbsp;</td>
    </tr>
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td style="width: 20px">
        &nbsp;</td>
      <td>
      <asp:Label ID="Label4" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
        Font-Size="8pt" meta:resourcekey="lblGenInfoResource5" 
        Text="Example: &quot;Use a special rate if over 1000 minutes.&quot;" />
      </td>
    </tr>
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td colspan="2">
      <asp:RadioButton ID="radCountTheNumberOfEvents" runat="server" GroupName="AggregateMethod"
              Text="<%$ Resources:CountTheNumberOfEventsLabel.BoxLabel %>" ForeColor="DarkBlue" Font-Size="8pt"/> 
      </td>
      <td>
        &nbsp;</td>
    </tr>
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td style="width: 20px">
        &nbsp;</td>
      <td>
      <asp:Label ID="Label5" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
        Font-Size="8pt" meta:resourcekey="lblGenInfoResource6" 
        Text="Example: &quot;Apply a discount if over 100 calls were made.&quot;" />
      </td>
    </tr>
    <tr>
      <td style="width: 40px">
        &nbsp;</td>
      <td colspan="2">
      <asp:RadioButton ID="radGetItemAggregatedFromParamTable" runat="server" GroupName="AggregateMethod" 
              Text="<%$ Resources:GetItemAggregatedFromParamTable.BoxLabel %>" ForeColor="DarkBlue" Font-Size="8pt"/> 
      </td>
      <td>
        &nbsp;</td>
    </tr>
  </table>

  <div style="padding-left: 0.75in;">
    <div id="divItemAggregatedFromParamTableDropdownSource" runat="server" >
          <MT:MTDropDown ID="ddItemAggregatedFromParamTableSource" runat="server" ControlWidth="160" ListWidth="200"
            HideLabel="True" AllowBlank="True" Editable="True"/>
            <div style="padding-top:-0.35in;"></div>
    </div>
  </div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:1.35in;">   
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
            <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$Resources:Resource,TEXT_NEXT%>"
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
                         OnClick="btnContinue_Click"
                         CausesValidation="true" TabIndex="240"/>
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_NEXT%>"
                         OnClientClick="MPC_setNeedToConfirm(false);"
                         OnClick="btnContinue_Click"
                         CausesValidation="False" TabIndex="240"/>
          </td>
        </tr>
      </table> 
  </div>

  <script type="text/javascript" language="javascript">
      function ShowHideParamTableDD() {
          var checked = document.getElementById('<%= radGetItemAggregatedFromParamTable.ClientID %>').checked;

          if (checked == true) {
              document.getElementById('<%=divItemAggregatedFromParamTableDropdownSource.ClientID%>').style.display = 'block';
          } else {
              document.getElementById('<%=divItemAggregatedFromParamTableDropdownSource.ClientID%>').style.display = 'none';
          }
          
          return true;
      }
      
      Ext.onReady(function () {
          // Record the initial values of the page's controls.
          // (Note:  This is called here, and not on the master page,
          // because the call to document.getElementById() returns null
          // if executed on the master page.)
          MPC_assignInitialValues();
      });

  </script>

</asp:Content>

