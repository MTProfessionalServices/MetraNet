<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="ConfigureFileManagementGlobals" Title="<%$Resources:Resource,TEXT_TITLE_METRACONTROL%>" Culture="auto" UICulture="auto" CodeFile="ConfigureFileManagementGlobals.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <!-- Title Bar -->
  <MT:MTTitle ID="MTTitle1" Text="<%$ Resources:FileManagementResources,GLOBAL_TITLE %>" runat="server" /><br />

  <!-- Main Form -->
  <div style="width:400px">
    <br />
    

    <div style="margin-left:10px">
<MT:MTPanel Collapsible="False" Text="<%$ Resources:FileManagementResources,GLOBAL_PANEL_TITLE %>" Width="650px" ID="MyPanel1" runat="Server" Collapsed="False">    
    <br />

    <MT:MTTextBoxControl ID="tbIncomingDirectory" runat="server" AllowBlank="False" Label="<%$Resources:FileManagementResources,GLOBAL_INCOMING_DIR %>" TabIndex="100" ControlWidth="440" ControlHeight="18" HideLabel="False" LabelWidth="145" Listeners="{}" meta:resourcekey="tbIncomingDirectoryResource1" ReadOnly="False" XType="TextField" XTypeNameSpace="form" />
  <MT:MTMessage ID="MTHelp" runat="Server" Text="<%$Resources:FileManagementResources,GLOBAL_INCOMING_DIR_HELP %>"
    meta:resourcekey="lblHelp" WarningLevel="Info" Width="595">
  </MT:MTMessage>



 </MT:MTPanel>

  <%if (isConfirmVisible) { %>
    <div style="width:630px">
    <center>  
<%= confirmationMsg %>
    </center>
    </div>
  <%} %>
  <!-- BUTTONS -->

  <div  class="x-panel-btns-ct">
    <div style="width:630px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK"  OnClientClick="return ValidateForm();" runat="server" 
              Text="<%$ Resources:Resource,TEXT_SAVE %>" OnClick="btnOK_Click" TabIndex="150" 
            />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" 
              Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClick="btnCancel_Click" 
              CausesValidation="False" TabIndex="160" />
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
 </div>
</div> 
</asp:Content>

