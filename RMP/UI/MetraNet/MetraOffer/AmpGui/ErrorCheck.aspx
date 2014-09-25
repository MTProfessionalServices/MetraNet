<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="ErrorCheck.aspx.cs" Inherits="AmpErrorCheckPage" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Error Check" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

  <br />
  <table style="width: 100%">
    <tr>
      <td width="50">
        &nbsp;</td>
      <td width="50" align="left">
        <asp:Image ID="CheckMarkBig" runat="server" Height="32px" 
            ImageUrl="/Res/Images/icons/checkmark_in_circle.png" Width="32px" />
        </td>
      <td>
        <asp:Label ID="CheckForErrors" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" 
          Text="Here's your chance to check your Decision Type for configuration errors." meta:resourcekey="CheckForErrorsLabel"></asp:Label></td>
    </tr>
    <tr>
      <td>
        &nbsp;</td>
      <td>
        &nbsp;</td>
      <td>
        <MT:MTButton ID="MTButtonCheckForErrors" runat="server" Text="<%$ Resources:TEXT_CHECK_FOR_ERRORS %>"
          CausesValidation="False" TabIndex="100" 
          OnClientClick="onErrorCheck()"
          />
      </td>
    </tr>
  </table>
  <br />
  <br />
  
      <div id="ActivateDecisionButtonDiv" runat="server">
        <table style="width: 100%">
          <tr>
            <td width="50">&nbsp;</td>
            <td width="50" align="left">
              <asp:Image ID="Switch1" runat="server" Height="32px" ImageUrl="/Res/Images/icons/switch_32x32.png" Width="32px" />
            </td>
            <td>
              <asp:Label ID="ActivateDecision" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" 
              Text="Do you want to activate your Decision Type now, making it eligible for processing by the AMP engine?" meta:resourcekey="ActivateDecisionLabel"></asp:Label>
            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>
              <MT:MTButton ID="MTButtonActivateDecision" runat="server" Text="<%$ Resources:TEXT_ACTIVATE_DECISION %>"
              CausesValidation="False" TabIndex="150" 
              OnClick="btnActivateDecision_Click" />
            </td>
          </tr>
        </table>
      </div>  
      <div id="DeactivateDecisionButtonDiv" runat="server">
        <table style="width: 100%">
          <tr>
            <td width="50">&nbsp;</td>
            <td width="50" align="left">
              <asp:Image ID="Switch2" runat="server" Height="32px" ImageUrl="/Res/Images/icons/switch_32x32.png" Width="32px" />
            </td>
            <td>
              <asp:Label ID="DeactivateDecision" style="line-height:20px;" runat="server" Font-Bold="False" ForeColor="DarkBlue" Font-Size="9pt" 
              Text="Your Decision Type is currently active. Do you want to deactivate your Decision Type now, making it ineligible for processing by the AMP engine?" meta:resourcekey="DeactivateDecisionLabel"></asp:Label>
            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>
              <MT:MTButton ID="MTButton1" runat="server" Text="<%$ Resources:TEXT_DEACTIVATE_DECISION %>"
              CausesValidation="False" TabIndex="150" 
              OnClick="btnDeactivateDecision_Click" />
            </td>
          </tr>
        </table>
      </div>

  <br />
  <div id="spacerDiv" runat="server" style="padding-left:0.85in; padding-top:0.66in;"></div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:2.4in;">   
      <table>
        <col style="width:190px"/>
        <col style="width:190px"/>
        <tr>
          <td align="left">
            <MT:MTButton ID="btnBack" runat="server" Text="<%$ Resources:Resource,TEXT_BACK %>"
                         OnClientClick="setLocationHref(ampPreviousPage); return false;"
                         CausesValidation="False" TabIndex="230" 
              meta:resourcekey="btnBackResource1" />
          </td>
          <td align="right">
            <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$ Resources:Resource,TEXT_SAVE_AND_CONTINUE %>"
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); setLocationHref(ampNextPage); } else { MPC_setNeedToConfirm(true); setLocationHref(ampNextPage); return false; }"
                         TabIndex="240" 
              meta:resourcekey="btnSaveAndContinueResource1"/>
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$ Resources:Resource,TEXT_CONTINUE %>"
                         OnClientClick="MPC_setNeedToConfirm(false); setLocationHref(ampNextPage);"
                         TabIndex="240" 
              meta:resourcekey="btnContinueResource1"/>
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

    function onErrorCheck() {
      var errorCheckWindow = new top.Ext.Window({
        title: window.TITLE_AMPWIZARD_ERROR_CHECK_RESULTS,
        id: 'errorCheckWin',
        width: 450,
        height: 300,
        minWidth: 450,
        minHeight: 300,
        layout: 'fit',
        plain: true,
        bodyStyle: 'padding:5px;',
        buttonAlign: 'center',
        collapsible: true,
        resizable: false,
        maximizable: false,
        closable: true,
        closeAction: 'close',
        html: '<iframe id="errorCheckWindow" src="/MetraNet/MetraOffer/AmpGui/RunErrorCheckDecision.aspx" width="100%" height="100%" frameborder="0" />'
      });

      errorCheckWindow.show();
      errorCheckWindow.on('close', function() { window.checkFrameLoading(); });
    }

    function onActivateDecision() {
    var activateWindow = new top.Ext.Window({
          title: TITLE_AMPWIZARD_ACTIVATION_RESULTS,
          id: 'activateWin',
          width: 450,
          height: 200,
          minWidth: 450,
          minHeight: 200,
          layout: 'fit',
          plain: true,
          bodyStyle: 'padding:5px;',
          buttonAlign: 'center',
          collapsible: true,
          resizable: false,
          maximizable: false,
          closable: true,
          closeAction: 'close',  
          modal: 'true',
          html: '<iframe id="activateWindow" src="/MetraNet/MetraOffer/AmpGui/ActivateDecision.aspx" width="100%" height="100%" frameborder="0" />'
        });

        activateWindow.show();
  }
  </script>
</asp:Content>

