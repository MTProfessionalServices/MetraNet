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
            <asp:Image runat="server" 
              ImageUrl="/Res/Images/icons/help.png" />
          </span>
   </div>
    <br />
    <br />
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
            Text="How should usage be aggregated?" />
          <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AGGREGATION_METHOD, TEXT_AMPWIZARD_HELP_AGGREGATION_METHOD, 300, 130)">
            <img id="Image3" src='/Res/Images/icons/help.png' />
          </span>
         </td>
       </tr>
     </table>
  </div>

  <br/>

  <div style="line-height:20px;padding-top:10px;padding-left:70px;">
      <asp:RadioButton id="radAddUpMonetaryChargeAmounts" runat="server" GroupName="AggregateMethod"
              Text="<%$ Resources:AddUpMonetaryChargeAmountsLabel.BoxLabel %>" ForeColor="DarkBlue" Font-Size="9pt"/>
       <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AGGREGATION_METHOD, TEXT_AMPWIZARD_HELP_AGGREGATION_METHOD_ADD_UP_MONETARY_CHARGE , 300, 130)">
            <img id="Img1" src='/Res/Images/icons/help.png' />
       </span>
      <br />
      <asp:RadioButton id="radAddUpUnitsOfUsage" runat="server" GroupName="AggregateMethod"
              Text="<%$ Resources:AddUpUnitsOfUsageLabel.BoxLabel %>" ForeColor="DarkBlue" Font-Size="9pt" />
      <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AGGREGATION_METHOD, TEXT_AMPWIZARD_HELP_AGGREGATION_METHOD_ADD_UP_UNIT_OF_USAGE , 300, 130)">
            <img id="Img2" src='/Res/Images/icons/help.png' />
      </span>
      <br />
       <asp:RadioButton ID="radCountTheNumberOfEvents" runat="server" GroupName="AggregateMethod"
              Text="<%$ Resources:CountTheNumberOfEventsLabel.BoxLabel %>" ForeColor="DarkBlue" Font-Size="9pt"/>
      <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AGGREGATION_METHOD, TEXT_AMPWIZARD_HELP_AGGREGATION_METHOD_COUNT_NUMBER_OF_EVENTS , 300, 130)">
            <img id="Img3" src='/Res/Images/icons/help.png' />
      </span>
      <br />
      <asp:RadioButton ID="radGetItemAggregatedFromParamTable" runat="server" GroupName="AggregateMethod" 
              Text="<%$ Resources:GetItemAggregatedFromParamTable.BoxLabel %>" ForeColor="DarkBlue" Font-Size="9pt"/> 
      <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_AGGREGATION_METHOD, TEXT_AMPWIZARD_HELP_AGGREGATION_METHOD_FROM_PARAMETER_TABLE , 300, 130)">
            <img id="Img4" src='/Res/Images/icons/help.png' />
      </span>
      <br />
      <div style="padding-left: 7px;">
        <div id="divItemAggregatedFromParamTableDropdownSource" runat="server">
              <MT:MTDropDown ID="ddItemAggregatedFromParamTableSource" runat="server" ControlWidth="160" ListWidth="200"
                HideLabel="True" AllowBlank="True" Editable="True"/>
        </div>
      </div>
  </div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:10px; padding-top:1.35in;">   
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

