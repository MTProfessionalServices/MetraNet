<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="SaveBillSoftOverride.aspx.cs" Inherits="Tax_SaveBillSoftOverride" meta:resourcekey="PageResource1" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<MT:MTPanel ID="MTPanel1" runat="server"
    Collapsed="False" Collapsible="True" EnableChrome="True" Text="Create BillSoft Override" meta:resourcekey="MTPanel1Resource1" >
  
    <MT:MTNumberField ID="tbIdAcc" runat="server" 
      TabIndex="100" ControlHeight="18" ControlWidth="200" 
      AllowDecimals="False" AllowNegative="False" AllowBlank="False" ReadOnly="False" 
      meta:resourcekey="tbIdAccResource1" LabelWidth="120" LabelSeparator=":" HideLabel="False" 
      MaxLength="-1" MaxValue="79228162514264337593543950335" 
      MinLength="0" MinValue="0" 
      ValidationRegex="null" XType="LargeNumberField" XTypeNameSpace="ux.form" Listeners="{}" />

    <MT:MTCheckBoxControl ID="cbApplyDescendents" runat="server" 
      TabIndex="120" ControlWidth="200" Checked="False" ReadOnly="False"
      meta:resourcekey="cbApplyDescendentsResource1" BoxLabel="Apply" HideLabel="False" 
      XType="Checkbox" XTypeNameSpace="form" Listeners="{}" Name="cbApplyDescendents" 
      /> 
    
    <div class="x-panel-btns-ct">
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
    </MT:MTPanel>
</asp:Content>

