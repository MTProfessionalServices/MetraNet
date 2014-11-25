<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ScheduleDaily.aspx.cs" Inherits="ScheduleDaily" Title="MetraNet" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script type="text/javascript">

    Ext.onReady(function () {
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        var el = document.getElementById("ctl00_PanelActiveAccount");
        if (el != null)
            el.style.display = 'none';
    });

  function goBack() {
    window.getFrameMetraNet().MainContentIframe.location.href = 'ScheduledAdaptersList.aspx';
    return false;
  }

  function onCheck() {
  }
  </script>

  
   <MT:MTPanel ID="RecurrencePatternPanel" runat="server" meta:resourcekey="RecurrencePatternPanelResource1" Text="Recurrence Pattern" Width="600" >
       <MT:MTLiteralControl ID="RecurEveryLiteral" runat="server" Label="Recur every" LabelWidth="170" LabelSeparator="" meta:resourcekey="RecurEveryLiteralResource1"/>        
       <MT:MTTextBoxControl ID="tbDays" runat="server" AllowBlank="False" Label="Day(s)"
        TabIndex="200" ControlWidth="60" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="140" Listeners="{}" meta:resourcekey="tbDaysResource1" ReadOnly="False"
        XType="TextField" XTypeNameSpace="form" />         
        <MT:MTTextBoxControl ID="tbStartTime" runat="server" AllowBlank="False" Label="Execution Times(in UTC)"
        TabIndex="210" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="140" Listeners="{}" ReadOnly="False" meta:resourcekey="tbStartTimeResource1"
        XType="TextField" XTypeNameSpace="form" />   
   </MT:MTPanel> 

   <MT:MTPanel ID="StartOfRecurrencePanel" runat="server" meta:resourcekey="StartOfRecurrencePanelResource1" Text="Start of recurrence" Width="600">
     <MT:MTDatePicker ID="tbStartDate" runat="server" AllowBlank="False" Label="Start Date"
        TabIndex="220" ControlWidth="100" ControlHeight="18" HideLabel="False" LabelSeparator=":"
        LabelWidth="140" Listeners="{}" meta:resourcekey="tbStartDateResource1" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;altFormats:DATE_TIME_FORMAT"
        ReadOnly="False" XType="DateField" XTypeNameSpace="form" />     
  </MT:MTPanel> 
  <br />


  <!-- BUTTONS -->
  <div  class="x-panel-btns-ct">
    <div style="width:600px" class="x-panel-btns x-panel-btns-center"> 
    <center>  
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnSave" runat="server" Text="<%$ Resources:Resource,TEXT_SAVE %>" OnClick="btnSave_Click" OnClientClick="return ValidateForm();" TabIndex="230" />      
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" OnClientClick="goBack();" CausesValidation="False" TabIndex="240"/>
          </td>
        </tr>
      </table> 
      </center>    
    </div>
  </div>
  <br />
 
</asp:Content>

