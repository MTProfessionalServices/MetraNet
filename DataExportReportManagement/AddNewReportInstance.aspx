<%@ Page Title="Show Report Instance" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="AddNewReportInstance.aspx.cs" Inherits="DataExportReportManagement_AddNewReportInstance" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Add New Report Instance" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

<br />


<!-- From Add Parameters Template -->
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" DataBinderInstanceName="MTDataBinder1"></MTCDT:MTGenericForm>
        
       
      <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="150"/>      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="160"/>
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
<MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
   </DataBindingItems>
</MT:MTDataBinder>

<script language="javascript" type="text/javascript">

  //Resolution Rule Drop Downs
  var ddReportDistributionType;
  var tbFTPAccessUser;
  var tbFTPAccessPassword;
  var tbControlFileDeliveryLocation;
  var cbbGenerateControlFile;

  function initializeRequiredControls() {
    ddReportDistributionType = Ext.getCmp("ctl00_ContentPlaceHolder1_ddReportDistributionType");

    //document.getElementById("ctl00_ContentPlaceHolder1_tbInputFixedValue");
    tbFTPAccessUser = document.getElementById("ctl00_ContentPlaceHolder1_tbFTPAccessUser");
    tbFTPAccessPassword = document.getElementById("ctl00_ContentPlaceHolder1_tbFTPAccessPassword");
    tbControlFileDeliveryLocation = document.getElementById("ctl00_ContentPlaceHolder1_tbControlFileDeliveryLocation");
    cbbGenerateControlFile = document.getElementById("ctl00_ContentPlaceHolder1_cbbGenerateControlFile");

    ddReportDistributionTypeSelected();

  }

  //Add some functions to control DD behavior

  function ddReportDistributionTypeSelected() {

    switch (ddReportDistributionType.value.toLowerCase()) {


      case "disk":
        tbFTPAccessUser.readOnly = true;
        tbFTPAccessPassword.readOnly = true;
        tbControlFileDeliveryLocation.readOnly = true;
        cbbGenerateControlFile.disabled = true;

        break;

      case "ftp":
        tbFTPAccessUser.readOnly = false;
        tbFTPAccessPassword.readOnly = false;
        tbControlFileDeliveryLocation.readOnly = false;
        cbbGenerateControlFile.disabled = false;
        break;

      default:
        tbFTPAccessUser.readOnly = false;
        tbFTPAccessPassword.readOnly = false;
        tbControlFileDeliveryLocation.readOnly = false;
        cbbGenerateControlFile.disabled = false;
        return;

    }

  }

  Ext.onReady(function () { initializeRequiredControls(); });
  
  </script>
</asp:Content>