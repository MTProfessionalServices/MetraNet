<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master"
   AutoEventWireup="true" CodeFile="ChangeFailedTransactionStatus.aspx.cs" 
  Inherits="MetraControl_FailedTransactions_ChangeStatus" 
  Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
     <script src="js/AjaxProxy.js" type="text/javascript"></script>
  <asp:Panel ID="PanelEditStatus" runat="server">
    <MT:MTTitle ID="MTTitle1" Text="Change Case / Failed Transaction Status" runat="server"  meta:resourcekey="lblTitleResource1" />
    <br />
    <MT:MTRadioControl ID="radOpen" BoxLabel="<b>Open</b> - This transaction is currently unresolved." Name="r1" Text="N" Value="N" ControlWidth="300" runat="server" meta:resourcekey="radOpenResource1" />
    <MT:MTRadioControl ID="radUnder" BoxLabel="<b>Under Investigation</b> - This transaction is currently unresolved but is being investigated." Name="r1" Text="I" Value="I" ControlWidth="500" runat="server" meta:resourcekey="radUnderResource1" />
    <MT:MTDropDown ID="ddInvestigationReasonCode" LabelWidth="250" Label="Reason Code" AllowBlank="true" runat="server" meta:resourcekey="ddInvestigationReasonCodeResource1" 
    Listeners="{ 'select' : this.onChange_ddInvestigationReasonCode, scope: this }">
    </MT:MTDropDown>
    <MT:MTRadioControl ID="radCorrected" BoxLabel="<b>Corrected</b> - This transaction has been resolved and is ready to be resubmitted." Name="r1" Text="C" Value="C" ControlWidth="500" runat="server"  meta:resourcekey="radCorrectedResource1"/>
    <MT:MTCheckBoxControl ID="cbResubmitNow" LabelWidth="175" BoxLabel="Resubmit Now" runat="server" meta:resourcekey="cbResubmitNowResource1"  />
    <MT:MTRadioControl ID="radDismissed" BoxLabel="<b>Dismissed</b> - This transaction cannot be resolved or it is not cost effective to do so." Name="r1" Text="P" Value="P" ControlWidth="500" runat="server" meta:resourcekey="radDismissedResource1" />
    <MT:MTDropDown ID="ddDismissedReasonCode" LabelWidth="250" Label="Reason Code" AllowBlank="true" runat="server" meta:resourcekey="ddDismissedReasonCodeResource1"
    Listeners="{ 'select' : this.onChange_ddDismissedReasonCode, scope: this }">
    </MT:MTDropDown>
    <br />
    <MT:MTTextArea ID="tbComment" Label="Comment" runat="server" ControlHeight="60" ControlWidth="400" Height="60px" Width="400px" meta:resourcekey="tbCommentResource1" />

    <!-- BUTTONS -->
    <div class="x-panel-btns-ct">
      <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
       <center>
        <table cellspacing="0">
          <tr>
            <td  class="x-panel-btn-td">
              <asp:Button ID="btnOK" class="x-btn-text" Width="50px" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClientClick="startChangeStatus(); return false;" TabIndex="390" />
            </td>
          </tr>
        </table> 
        </center>      
      </div>
    </div>
  </asp:Panel>

  <script type="text/javascript">
    Ext.onReady(function () {
      var checkboxResubmit = Ext.get("<%=cbResubmitNow.ClientID%>").dom,
          commentArea = Ext.get("<%=tbComment.ClientID%>").dom;
      if (checkboxResubmit) {
        checkboxResubmit.onclick = function () {
          var radCorected = Ext.getCmp("<%=radCorrected.ClientID%>");
          radCorected.setValue(true);
        };
      }
      if (commentArea) {
        commentArea.onkeyup = function () {
          if (commentArea.value.trim().length > 0 && /\S/.test(commentArea.value)) {
            commentArea.style.borderColor = "";
            commentArea.style.borderStyle = "";
          }
        };
      }
    });

    function startChangeStatus() {
      var changeStatusModel = getChangeStatusModel();
      if (validationModel(changeStatusModel)) {
        if (parent && typeof (parent.doChangeStatus) == 'function') {
          var changeStatusData = {
            status: changeStatusModel.status,
            reasonCode: changeStatusModel.reasonCode,
            isResubmit: changeStatusModel.isResubmit,
            comment: changeStatusModel.comment,
            gridId: '<%=Request["gridId"]%>'
          };
          parent.doChangeStatus(changeStatusData);
        }
      }
    }

    function getChangeStatusModel() {
      var returnModel = {
        status: "",
        reasonCode: "",
        isResubmit: false,
        comment: ""
      };
      var radOpenRadio = Ext.get("<%=radOpen.ClientID%>").dom,
          radUnderRadio = Ext.get("<%=radUnder.ClientID%>").dom,
          radDessmisedRadio = Ext.get("<%=radDismissed.ClientID%>").dom,
          radCorrectedRadio = Ext.get("<%=radCorrected.ClientID%>").dom,
          commentTb = Ext.get("<%=tbComment.ClientID%>");
      if (commentTb) {
        returnModel.comment = commentTb.getValue();
      }
      if (radOpenRadio && radOpenRadio.checked) {
        returnModel.status = radOpenRadio.value;
        return returnModel;
      } else if (radUnderRadio && radUnderRadio.checked) {
        returnModel.status = radUnderRadio.value;
        var reasonCodeDD = Ext.get("<%=ddInvestigationReasonCode.ClientID %>").dom;
        if (reasonCodeDD) {
          returnModel.reasonCode = reasonCodeDD.value;
        }
        return returnModel;
      } else if (radCorrectedRadio && radCorrectedRadio.checked) {
        returnModel.status = radCorrectedRadio.value;
        var isResubmitNow = Ext.get("<%=cbResubmitNow.ClientID %>").dom;
        if (isResubmitNow && isResubmitNow.checked) {
          returnModel.isResubmit = true;
        }
        return returnModel;
      } else if (radDessmisedRadio && radDessmisedRadio.checked) {
        returnModel.status = radDessmisedRadio.value;
        var radDessmisedReasonCode = Ext.get("<%=ddDismissedReasonCode.ClientID %>").dom;
        if (radDessmisedReasonCode) {
          returnModel.reasonCode = radDessmisedReasonCode.value;
        }
        return returnModel;
      }
  return null;
}

function validationModel(model) {
  var returnValue = false;
  if (model) {
    if (model.comment.trim().length == 0) {
      var commentArea = Ext.get("<%=tbComment.ClientID%>").dom;
          commentArea.style.borderColor = "red";
          commentArea.style.borderStyle = "double";
        }
        else {
          returnValue = true;
        }
      }
      else {
        var title = '<%=GetLocalResourceObject("lblTitleResource1.Text").ToString()%>',
            message = '<%=GetLocalResourceObject("pleaseSelectNewStatusMessage.Text").ToString()%>';
        _showValidationDialog(title, message);
      }
      return returnValue;
    }

    function onChange_ddInvestigationReasonCode(field, newvalue, oldvalue) {
      var radUnder = Ext.getCmp('<%=radUnder.ClientID%>');
      radUnder.setValue(true);
    }

    function onChange_ddDismissedReasonCode(field, newvalue, oldvalue) {
      var radDismissed = Ext.getCmp('<%=radDismissed.ClientID%>');
      radDismissed.setValue(true);
    }

    function _showValidationDialog(title, message) {
      Ext.MessageBox.show({
        title: title,
        msg: message,
        buttons: Ext.MessageBox.OK,
        icon: Ext.MessageBox.WARNING
      });
    }

    // refresh parent grid and close popup window

    function refreshAndClose() {
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

