<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="QueueAdHocReports.aspx.cs" Inherits="DataExportReportManagement_QueueAdHocReports" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="Execute AdHoc Report" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

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

    <MT:MTPanel ID="MTPanel1" runat="server"  
    meta:resourcekey="MTSection2Resource1" Collapsible="False" 
    Text="Set Parameters for Adhoc Report" Collapsed="False" EnableChrome="True">
    
     <MT:MTTextBoxControl ID="tbMTParam1" runat="server" AllowBlank="True" Label="Parameter 1"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbMTParam1Resource1" ReadOnly="False" 
      ControlHeight="18" LabelSeparator=":" Listeners="{}" MaxLength="-1" 
      MinLength="0" ValidationRegex="null" XType="TextField" XTypeNameSpace="form" />
     
    <MT:MTTextBoxControl ID="tbMTParam2" runat="server" AllowBlank="True" Label="Parameter 2"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbMTParam2Resource1" ReadOnly="False" ControlHeight="18" 
      LabelSeparator=":" Listeners="{}" MaxLength="-1" MinLength="0" 
      ValidationRegex="null" XType="TextField" XTypeNameSpace="form"/>

       <MT:MTTextBoxControl ID="tbMTParam3" runat="server" AllowBlank="True" Label="Parameter 3"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbMTParam3Resource1" ReadOnly="False" 
      ControlHeight="18" LabelSeparator=":" Listeners="{}" MaxLength="-1" 
      MinLength="0" ValidationRegex="null" XType="TextField" XTypeNameSpace="form" />
     
    <MT:MTTextBoxControl ID="tbMTParam4" runat="server" AllowBlank="True" Label="Parameter 4"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbMTParam4Resource1" ReadOnly="False" ControlHeight="18" 
      LabelSeparator=":" Listeners="{}" MaxLength="-1" MinLength="0" 
      ValidationRegex="null" XType="TextField" XTypeNameSpace="form"/>

       <MT:MTTextBoxControl ID="tbMTParam5" runat="server" AllowBlank="True" Label="Parameter 5"
      TabIndex="10" ControlWidth="200" OptionalExtConfig="minLength:0,
                              maxLength:Number.MAX_VALUE,
                              regex:null,maxLength:50"
       HideLabel="False" LabelWidth="120"   
     meta:resourcekey="tbMTParam5Resource1" ReadOnly="False" 
      ControlHeight="18" LabelSeparator=":" Listeners="{}" MaxLength="-1" 
      MinLength="0" ValidationRegex="null" XType="TextField" XTypeNameSpace="form" />
     
    <div style="clear:both"></div>
   </MT:MTPanel>

    
      <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="MTButton1"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_OK %>" OnClick="btnOK_Click" TabIndex="150" 
              meta:resourcekey="btnOKResource1" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="MTButton2" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="160" meta:resourcekey="btnCancelResource1" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>

<MT:MTDataBinder ID="MTDataBinder1" runat="server">
<DataBindingItems>
      <MT:MTDataBindingItem ID="MTDataBindingItem1" runat="server" BindingSource="queueadhocreports" 
        BindingSourceMember="AdhocReportDistributionType" BindingProperty="SelectedValue" ControlId="ddDistributionType" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem2" runat="server" BindingSource="queueadhocreports"
        BindingSourceMember="AdhocReportDestination" ControlId="tbReportDestination" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem3" runat="server" BindingSource="queueadhocreports"
        BindingSourceMember="AdhocFTPAccessUser" ControlId="tbFTPUser" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem4" runat="server" BindingSource="queueadhocreports" BindingSourceMember="AdhocFTPAccessPassword"
        ControlId="pmFTPPassword" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem5" runat="server" BindingProperty="Checked"
        BindingSource="queueadhocreports" BindingSourceMember="bAdhocGenerateControlFile" ControlId="chkGenerateControlFile"
        ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem6" runat="server" BindingSource="queueadhocreports"
        BindingSourceMember="AdhocControlFileDeliveryLocation" ControlId="tbControlFileLocation" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem7" runat="server" BindingSource="queueadhocreports" BindingSourceMember="ParameterValue1" 
      ControlId="tbMTParam1" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem8" runat="server" BindingSource="queueadhocreports" BindingSourceMember="ParameterValue2" 
      ControlId="tbMTParam2" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem9" runat="server" BindingSource="queueadhocreports" BindingSourceMember="ParameterValue3" 
      ControlId="tbMTParam3" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem10" runat="server" BindingSource="queueadhocreports" BindingSourceMember="ParameterValue4" 
      ControlId="tbMTParam4" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
      <MT:MTDataBindingItem ID="MTDataBindingItem11" runat="server" BindingSource="queueadhocreports" BindingSourceMember="ParameterValue5" 
      ControlId="tbMTParam5" ErrorMessageLocation="None">
      </MT:MTDataBindingItem>
   </DataBindingItems>
</MT:MTDataBinder>
</asp:Content>