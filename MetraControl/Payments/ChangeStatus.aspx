<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="ChangeStatus.aspx.cs" Inherits="MetraControl_Payments_ChangeStatus" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <asp:Panel ID="PanelEditStatus" runat="server">
    <MT:MTTitle ID="MTTitle1" Text="Change Payment Transaction Status" 
      runat="server" meta:resourcekey="MTTitle1Resource1" />
    <br />
    
    <MT:MTRadioControl ID="radManualPending" 
      BoxLabel="<b>Pending</b> - The transactions will be manually set to pending." 
      Name="r1" Text="P" Value="P" ControlWidth="500" runat="server" 
      AllowBlank="False" Checked="False" HideLabel="False" LabelSeparator=":" 
      Listeners="{}" meta:resourcekey="radManualPendingResource1" ReadOnly="False" 
      XType="TextField" XTypeNameSpace="form" />
    <% if (UI.CoarseCheckCapability("Manual override"))
       {%>
    
      <MT:MTRadioControl ID="radManualReversed" 
      BoxLabel="<b>Reversed</b> - The transactions is will be manually set to reversed." 
      Name="r1" Text="R" Value="R" ControlWidth="500" runat="server" 
      AllowBlank="False" Checked="False" HideLabel="False" LabelSeparator=":" 
      Listeners="{}" meta:resourcekey="radManualReversedResource1" ReadOnly="False" 
      XType="TextField" XTypeNameSpace="form" />
    
    <br />
    <% } %>
    <MT:MTTextArea ID="tbComment" Label="Comment" runat="server" ControlHeight="60" 
      ControlWidth="400" Height="60px" Width="400px" AllowBlank="False" 
      HideLabel="False" LabelSeparator=":" Listeners="{}" MaxLength="-1" 
      meta:resourcekey="tbCommentResource1" MinLength="0" ReadOnly="False" 
      ValidationRegex="null" XType="TextField" XTypeNameSpace="form" />

    <!-- BUTTONS -->
    <div class="x-panel-btns-ct">
      <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
       <center>
        <table cellspacing="0">
          <tr>
            <td  class="x-panel-btn-td">
              <asp:Button ID="btnOK" class="x-btn-text" Width="50px" runat="server" 
                Text="<%$ Resources:Resource,TEXT_OK %>" OnClientClick="return ValidateForm();" 
                OnClick="btnOK_Click" TabIndex="390" />
            </td>
          </tr>
        </table> 
        </center>      
      </div>
    </div>
  </asp:Panel>

  <script type="text/javascript">

    // Check rerun isComplete progress via ajax
    function checkProgress(id) {
      Ext.UI.startLoading(document.body, '<asp:Localize runat="server">' + TEXT_RESUBMIT_FAILED + '</asp:Localize>');
      
      // add delay for loading...
     setTimeout("finishCheckProgress(" + id + ");", 1000);
    }

    function finishCheckProgress(id) {
      Ext.Ajax.request({
        url: 'AjaxServices/CheckRerunComplete.aspx',
        params: { id: id },
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
          var responseJSON = Ext.decode(response.responseText);
          if (responseJSON) {
            if (responseJSON.Success = true) {
              Ext.UI.doneLoading(document.body);
              refreshAndClose();
            }
          }
          else {
            setTimeout("checkProgress(" + id + ");", 1000);
          }
        }
      });
    }

    // refresh parent grid and close popup window
    function refreshAndClose() {
      //if (parent.grid_ctl00_ContentPlaceHolder1_FailedTransactionList!=null)
      //  parent.grid_ctl00_ContentPlaceHolder1_FailedTransactionList.store.reload();
      if (parent.winGridToRefresh != null)
        parent.winGridToRefresh.store.reload();

      parent.win.hide();

      if (document.documentMode == 7 || document.documentMode == 8) {
        parent.document.location.href = parent.document.location.href;
      }
    }

    //Hacky work around for IE javascript Ext.Fly not an object error
    Ext.override(Ext.EventObjectImpl, {
      getTarget: function (selector, maxDepth, returnEl) {
        var targetElement;

        try {
          targetElement = selector ? Ext.fly(this.target).findParent(selector, maxDepth, returnEl) : this.target;
        } catch (e) {
          targetElement = this.target;
        }

        return targetElement;
      }
    });

  </script>
  <asp:Literal ID="jsCheckProgress" runat="server"></asp:Literal>
</asp:Content>

