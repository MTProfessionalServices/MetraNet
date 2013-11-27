<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="FileManagementDetailReport" Title="<%$Resources:Resource,TEXT_TITLE_METRACONTROL%>" Culture="auto" UICulture="auto" CodeFile="FileManagementDetailReport.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="<%$Resources:FileManagementResources,DETAIL_TITLE %>" runat="server"/><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    
    <div style="margin-left:10px">
<MT:MTPanel Collapsible="false" Text="<%$Resources:FileManagementResources,DETAIL_TITLE %>" Width="880" ID="MyPanel1" runat="Server">    
    <br />
   
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,JOB_CONTROL_NUMBER %>" ReadOnly="true" ID="tbControlNumber" LabelWidth="140" runat="server" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,DETAIL_TARGET %>" ReadOnly="true" ID="tbTarget" LabelWidth="140" runat="server" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,JOB_BATCH_ID %>" ReadOnly="true" ID="tbBatchID" LabelWidth="140" runat="server" ControlWidth="720" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,JOB_TRACKING_ID %>" ReadOnly="true" ID="tbTrackingID" LabelWidth="140" runat="server" ControlWidth="720" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,DETAIL_FILES %>" ReadOnly="true" ID="tbFile" LabelWidth="140" runat="server" ControlWidth="720" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,DETAIL_CURRENT_STATE %>" ReadOnly="true" ID="tbState" LabelWidth="140" runat="server" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,DETAIL_CURRENT_ERROR_CODE %>" ReadOnly="true" ID="tbErrorCode" LabelWidth="140" runat="server" />
    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,DETAIL_CURRENT_ERROR_MESSAGE %>" ReadOnly="true" ID="tbErrorMessage" LabelWidth="140" runat="server" ControlWidth="0" />
    <asp:TextBox ID="TextBoxErrorMessage" runat="server" Rows="10" Height="58px" 
        ReadOnly="True" TextMode="MultiLine" Width="860px"></asp:TextBox>

    <MT:MTTextBoxControl Label="<%$Resources:FileManagementResources,DETAIL_COMMAND %>" ReadOnly="true" ID="tbCommand" LabelWidth="140" runat="server" ControlWidth="0" />
  <asp:TextBox ID="tbCommand2" runat="server" Rows="10" Height="58px" 
      ReadOnly="True" TextMode="MultiLine" Width="860px"></asp:TextBox>
  </MT:MTPanel>
     
    <%=stateHistoryDetails %>   
    
  <!-- BUTTONS -->

  <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
        <!--
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="150" meta:resourcekey="btnOKResource1" />      
          </td>
          -->
          
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160"/>
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
 </div>
</div> 
</asp:Content>

