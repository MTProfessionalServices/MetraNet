<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Metraflow_Step_Log" Title="<%$Resources:Resource,TEXT_TITLE_METRACONTROL%>" CodeFile="MetraflowStepLog.aspx.cs" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="<%$Resources:FileManagementResources,DETAIL_TITLE %>" runat="server"/><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    
    <div style="margin-left:10px">
<MT:MTFilterGrid ID="MyGrid1" runat="Server" ExtensionName="Core" TemplateFileName="Core.FileLandingService.MetraflowStepLog.xml"></MT:MTFilterGrid>
    <br />
  

  <!-- BUTTONS -->

  <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>      
         <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" Text="<%$Resources:Resource,TEXT_CANCEL%>" OnClick="btnCancel_Click" CausesValidation="False" TabIndex="160" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
 </div>
</div> 
</asp:Content>

