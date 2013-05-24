<%@ Page Title="Show Report Instance" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ShowReportInstanceDetails.aspx.cs" Inherits="DataExportReportManagement_ShowReportInstanceDetails" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Update Report Instance" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

<br />


<!-- From Add Parameters Template -->
  <MTCDT:MTGenericForm ID="MTGenericForm1" runat="server" 
    DataBinderInstanceName="MTDataBinder1" 
    meta:resourcekey="MTGenericForm1Resource1" EnableChrome="True">
  </MTCDT:MTGenericForm>

    <!-- FTP Related Information -->
    <MT:MTPanel ID="ftpPanel" runat="server"  
    meta:resourcekey="MTSection2Resource1" Collapsible="False" 
    Text="Output File Delivery Details" Collapsed="False" EnableChrome="True">
  <div id="leftColumn" class="LeftColumn">

<asp:DropDownList ID="ddDistributionType" runat="server" AutoPostBack="True"  
onselectedindexchanged="ddDistributionType_SelectedIndexChanged" 
      meta:resourcekey="ddDistributionTypeResource1"></asp:DropDownList>

    <MT:MTTextBoxControl ID="tbReportDestination" runat="server" AllowBlank="True" Label="Report Destination"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbReportDestinationResource1" ReadOnly="False" 
      ControlHeight="18" LabelSeparator=":" Listeners="{}" MaxLength="-1" 
      MinLength="0" ValidationRegex="null" XType="TextField" XTypeNameSpace="form" />
     
    <MT:MTTextBoxControl ID="tbFTPUser" runat="server" AllowBlank="True" Label="FTP Access User"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbFTPUserResource1" ReadOnly="False" ControlHeight="18" 
      LabelSeparator=":" Listeners="{}" MaxLength="-1" MinLength="0" 
      ValidationRegex="null" XType="TextField" XTypeNameSpace="form"/>

    <MT:MTPasswordMeter ID="pmFTPPassword" runat="server" AllowBlank="True" Label="FTP Access Password"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="pmFTPPasswordResource1" ReadOnly="False" ControlHeight="18" 
      LabelSeparator=":" Listeners="{}" XType="PasswordMeter" XTypeNameSpace="ux"/>

    <MT:MTCheckBoxControl ID="chkGenerateControlFile" runat="server" 
      AllowBlank="True"  BoxLabel="Generate Control File"
      TabIndex="5" meta:resourcekey="chkGenerateControlFileResource1" 
      ReadOnly="False" Checked="False" HideLabel="False" Listeners="{}" 
      Name="chkGenerateControlFile" OptionalExtConfig="boxLabel:'Generate Control File',
                                            inputValue:'',
                                            checked:false" XType="Checkbox" 
      XTypeNameSpace="form"></MT:MTCheckBoxControl>  
    
    <MT:MTTextBoxControl ID="tbControlFileLocation" runat="server" 
      AllowBlank="True" Label="Control File Location"
      TabIndex="20" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"  ControlHeight="18" 
      HideLabel="False" LabelWidth="120"    
      meta:resourcekey="tbControlFileLocationResource1" ReadOnly="False"  
      XTypeNameSpace="form" LabelSeparator=":" Listeners="{}" MaxLength="-1" 
      MinLength="0" ValidationRegex="null" XType="TextField" />
   </div> 
     
  <div style="clear:both"></div>
   </MT:MTPanel>
            
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
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnManageInstanceParameterValues" runat="server" 
              Text="Manage Instance Parameter Values" OnClick="btnManageInstanceParameterValues_Click" 
              CausesValidation="False" TabIndex="160" meta:resourcekey="btnManageInstanceParameterValuesResource1" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
<MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="exportreportinstance" 
        BindingSourceMember="ReportDistributionType" ControlId="ddDistributionType" BindingProperty="SelectedValue" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="exportreportinstance"
        BindingSourceMember="ReportDestination" ControlId="tbReportDestination" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="exportreportinstance"
        BindingSourceMember="FTPAccessUser" ControlId="tbFTPUser" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem4" runat="server" BindingSource="exportreportinstance" BindingSourceMember="FTPAccessPassword"
        ControlId="pmFTPPassword" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem5" runat="server" BindingProperty="Checked"
        BindingSource="exportreportinstance" BindingSourceMember="bGenerateControlFile" ControlId="chkGenerateControlFile"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem6" runat="server" BindingSource="exportreportinstance"
        BindingSourceMember="ControlFileDeliveryLocation" ControlId="tbControlFileLocation" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
   </DataBindingItems>
  </MT:MTDataBinder>

  
  </script>


</asp:Content>