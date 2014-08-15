<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="RecurrencePattern.aspx.cs" Inherits="RecurrencePattern" Title="MetraNet" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script type="text/javascript">
    Ext.onReady(function () {
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        var el = document.getElementById("ctl00_PanelActiveAccount");
        if(el!=null)
               el.style.display = 'none';
    });


    function onCheck() {
        if (Ext.get("<%=radMinutely.ClientID%>").dom.checked) {
            Ext.get("ctl00_ContentPlaceHolder1_schedulePatternPage").dom.src = "<%=strMinutelyURL%>";
        }
        else if (Ext.get("<%=radDaily.ClientID%>").dom.checked) {
            Ext.get("ctl00_ContentPlaceHolder1_schedulePatternPage").dom.src = "<%=strDailyURL%>";
        }
        else if (Ext.get("<%=radWeekly.ClientID%>").dom.checked) {
            Ext.get("ctl00_ContentPlaceHolder1_schedulePatternPage").dom.src = "<%=strWeeklyURL%>";
        }
        else if (Ext.get("<%=radMonthly.ClientID%>").dom.checked) {
            Ext.get("ctl00_ContentPlaceHolder1_schedulePatternPage").dom.src = "<%=strMonthlyURL%>";
        }
        else if (Ext.get("<%=radManual.ClientID%>").dom.checked) {
            Ext.get("ctl00_ContentPlaceHolder1_schedulePatternPage").dom.src = "<%=strManualURL%>";
        }    
    }
</script>
 <br />
<div class="Left" >    
 
  <MT:MTPanel ID="RecurrencePatternPanel" runat="server" Collapsible="False" Width="150">
  <br /><br />
  <MT:MTRadioControl ID="radMinutely" meta:resourcekey="MinutelyBoxLabelResource1"
        Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }" runat="server"
        BoxLabel="Minutely" Name="r1" Text="Minutely" Value="MinutelyResource1" Checked="true" ControlWidth="150"  LabelWidth="10" />
        <MT:MTRadioControl ID="radDaily" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
        runat="server" BoxLabel="Daily" meta:resourcekey="DailyBoxLabelResource1"
        Name="r1" Text="Daily" Value="Daily" ControlWidth="150"  LabelWidth="10" />
    <MT:MTRadioControl ID="radWeekly" meta:resourcekey="WeeklyBoxLabelResource1"
        Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }" runat="server"
        BoxLabel="Weekly" Name="r1" Text="Weekly" Value="Weekly" ControlWidth="150"  LabelWidth="10" />
    <MT:MTRadioControl ID="radMonthly" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
        runat="server" BoxLabel="Monthly" meta:resourcekey="MonthlyBoxLabelResource1"
        Name="r1" Text="Monthly" Value="Monthly" ControlWidth="150"  LabelWidth="10" />
   <MT:MTRadioControl ID="radManual" Listeners="{ 'check' : { fn: this.onCheck, scope: this, delay: 100 } }"
        runat="server" BoxLabel="Manual" meta:resourcekey="ManualBoxLabelResource1"
        Name="r1" Text="Manual" Value="Manual" ControlWidth="150"  LabelWidth="10" />
          <br /> <br /> <br /> <br />
  </MT:MTPanel> 

  <input type="hidden" runat="server" id="selectedPattern" />
    
  </div>
  <div class="Left" style="width:650px">
    <iframe frameborder="0" id="schedulePatternPage" name="schedulePatternPage" style="width:100%" width="100%" height="560px" runat="server"></iframe>
  </div>
   
</asp:Content>

