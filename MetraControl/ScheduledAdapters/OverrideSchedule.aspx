<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="OverrideSchedule.aspx.cs" Inherits="OverrideSchedule" Title="MetraNet" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script type="text/javascript">
  if (getFrameMetraNet() && getFrameMetraNet().MainContentIframe) {
    if (getFrameMetraNet().MainContentIframe.location != document.location) {
      getFrameMetraNet().MainContentIframe.location.replace(document.location);
    }

    function onCheck() {
    }

    function validate() {
      if (Ext.get("<%=radOverride.ClientID %>").dom.checked) {
        if (Ext.get("<%=tbStartDate.ClientID %>").dom.value == '') {
          Ext.Msg.show({
            title: TEXT_ERROR_MSG,
            msg: TEXT_INVALID_START_DATE,
            buttons: Ext.Msg.OK,
            icon: Ext.MessageBox.INFO
          });
          return false;          
        }
        else if (Ext.get("<%=tbStartTime.ClientID %>").dom.value == '') {
          Ext.Msg.show({
            title: TEXT_ERROR_MSG,
            msg: TEXT_INVALID_START_TIME,
            buttons: Ext.Msg.OK,
            icon: Ext.MessageBox.INFO
          });
          return false; 
        }
      }     
    }
  }
  </script>

 <MT:MTTitle ID="PageTitle" Text="Override Schedule" runat="server" meta:resourcekey="TitleResource1" /><br />

  <MT:MTLiteralControl ID="CurrentScheduleLiteral" runat="server" Label="Current Schedule" meta:resourcekey="CurrentScheduleLiteralResource1"/><br />
  
  <MT:MTPanel ID="NextRunPanel" runat="server" meta:resourcekey="NextRunPanelResource1" Text="Next Run" Width="600">
   <MT:MTRadioControl ID="radOnSchedule" meta:resourcekey="OnScheduleBoxLabelResource1"
        Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }" runat="server"
        BoxLabel="On Schedule" Name="r1" Text="OnSchedule" Value="OnSchedule" Checked="true" TabIndex="100" ControlWidth="400"/>
    
    <MT:MTRadioControl ID="radSkipOne" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
        runat="server" BoxLabel="German" meta:resourcekey="SkipOneBoxLabelResource1"
        Name="r1" Text="Skip" Value="Skip Once - Run on" TabIndex="110"  ControlWidth="400"  />
        
    <MT:MTRadioControl ID="radPause" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
        runat="server" BoxLabel="Pause" meta:resourcekey="PauseLabelResource1"
        Name="r1" Text="Pause" Value="Pause" TabIndex="120" ControlWidth="400" />
    <MT:MTRadioControl ID="radOverride" meta:resourcekey="OverrideBoxLabelResource1"
        Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }" runat="server"
        BoxLabel="Override" Name="r1" Text="Override" Value="Override" TabIndex="130" ControlWidth="400" />  
    <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="True" Label="Execution Date"
         ControlWidth="100" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="" Listeners="{}" meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;altFormats:DATE_TIME_FORMAT"
        ReadOnly="False" XType="DateField" XTypeNameSpace="form" Visible="true" TabIndex="140"/> 
    <MT:MTTextBoxControl ID="tbStartTime" runat="server" AllowBlank="True" Label="Execution Time (in UTC)"
        TabIndex="150" ControlWidth="60" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="" Listeners="{}" meta:resourcekey="tbStartTimeResource1" ReadOnly="False"
        XType="TextField" XTypeNameSpace="form" Visible="true" />     
  </MT:MTPanel>  

  <!-- BUTTONS -->
  <div  class="x-panel-btns-ct">
    <div style="width:600px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnSave" runat="server" Text="<%$ Resources:Resource,TEXT_SAVE %>" OnClick="btnSave_Click" OnClientClick="return validate();" TabIndex="160"/>      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>"  OnClick="btnCancel_Click" CausesValidation="False" TabIndex="170"/>
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>

 
</asp:Content>

