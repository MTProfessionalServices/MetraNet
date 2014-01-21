<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ExecutionFrequency.aspx.cs" Inherits="AmpExecutionFrequencyPage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Execution Frequency" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

    <div style="line-height:20px;padding-top:10px;padding-left:10px;">
    <table style="width: 500px">
      <tr>
        <td style="width: 40px">
          <asp:Image ID="Image1" runat="server" Height="32px" 
            ImageUrl="/Res/Images/icons/date_time.png" Width="32px" 
            meta:resourcekey="Image1Resource1" />
        </td>
        <td>
          <asp:Label ID="lblGenInfo" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
          Font-Size="9pt" meta:resourcekey="lblGenInfoResource1" 
          Text="A Decision can be processed by AMP as part of End-of-Period (EOP) processing and/or on a scheduled basis, independent of billing intervals." />
          <br />
        </td>
      </tr>
      <tr>
        <td style="width: 40px">
          &nbsp;</td>
        <td>
          &nbsp;</td>
      </tr>
    </table>
      <table style="width: 100%">
        <tr>
          <td>
            &nbsp;</td>
          <td>
            <asp:Label ID="Label1" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
              Font-Size="9pt" meta:resourcekey="lblGenInfoResource2" 
              Text="What is the execution frequency for this Decision Type?" />
            <br />
            <br />
          </td>
        </tr>
        <tr>
          <td width="40px">
            &nbsp;</td>
          <td>
            <asp:RadioButtonList ID="RadioButtonList1" runat="server" meta:resourcekey="RadioButtonList1Resource1" Width="400px" ForeColor="DarkBlue" Font-Size="9pt">
              <asp:ListItem Text="<%$ Resources:EOPLabelResource.Text %>" Value="EOP"></asp:ListItem>
              <asp:ListItem Text="<%$ Resources:ScheduledLabelResource.Text %>" Value="Scheduled"></asp:ListItem>
              <asp:ListItem Text="<%$ Resources:BothEOPandScheduledLabelResource.Text %>" Value="Both"></asp:ListItem>
            </asp:RadioButtonList>
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
  <div style="padding-left:0.85in; padding-top:2.53in;">   
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

