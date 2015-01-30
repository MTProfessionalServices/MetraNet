<%@ Page Title="Update Monthly Report Schedule" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="UpdateScheduleReportInstanceMonthly.aspx.cs" Inherits="DataExportReportManagement_UpdateScheduleReportInstanceMonthly" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <script src="JavaScript/DataExport.js" type="text/javascript"></script>

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Update Monthly Report Schedule" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

<br />


<!-- From Add Parameters Template -->
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" 
    DataBinderInstanceName="MTDataBinder1" 
    meta:resourcekey="MTGenericForm1Resource1" EnableChrome="True">
  </MTCDT:MTGenericForm>
         
      <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="150" 
              meta:resourcekey="btnOKResource1" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
<MT:MTDataBinder ID="MTDataBinder1" runat="server"></MT:MTDataBinder>

<script type="text/javascript" language="javascript">
  Ext.onReady(function () {

    var exDayCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_tbExecuteDay');
    var exDayRBCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteDay');
    var exFirstCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteFirstDayMonth');
    var exLastCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteLastDayMonth');

    if (exFirstCtrl.checked || exLastCtrl.checked) {
      exDayCtrl.disable();
    }
    else {
      exDayCtrl.enable();
      exDayRBCtrl.setValue(true);
    }

    exFirstCtrl.setValue(exFirstCtrl.checked);
    exLastCtrl.setValue(exLastCtrl.checked);


  });
</script>

</asp:Content>