<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_GetAllSchedulesOfAReportInstance"
  Title="Show All Report Definitions" Culture="auto" UICulture="auto" CodeFile="GetAllSchedulesOfAReportInstance.aspx.cs" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblGetAllSchedulesOfAReportInstanceTitle" runat="server" Text="All Schedules Of The Instance"
      meta:resourcekey="lblGetAllSchedulesOfAReportInstanceTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="DataExport" 
    TemplateFileName="DataExportFramework.GetAllSchedulesOfAInstance.xml" 
    ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" 
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" 
    EnableLoadSearch="False" EnableSaveSearch="False" Expandable="False" 
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" 
    FilterInputWidth="220" FilterLabelWidth="75" FilterPanelCollapsed="False" 
    FilterPanelLayout="MultiColumn" meta:resourcekey="MyGrid1Resource1" 
    MultiSelect="False" NoRecordsText="No records found" PageSize="10" 
    Resizable="True" RootElement="Items" SearchOnLoad="True" 
    SelectionModel="Standard" ShowBottomBar="True" ShowColumnHeaders="True" 
    ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" 
    ShowTopBar="True" 
    TotalProperty="TotalRows"></MT:MTFilterGrid>

  <script language="javascript" type="text/javascript">

    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('IDSchedule'), idscheduleColRenderer); 
    cm.setRenderer(cm.getIndexById('ScheduleType'), scheduletypeColRenderer); 
  }
  
  function idscheduleColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
  //str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editschedule(\"{0}\");'><img src='/Res/Images/icons/database_edit.png' alt='{1}' /></a>", record.data.IDSchedule, "Edit Schedule");
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editschedule(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.IDSchedule, record.data.ScheduleType, "Edit Schedule");

  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:deleteschedule(\"{0}\");'><img src='/Res/Images/icons/database_delete.png' alt='{1}' /></a>", record.data.IDSchedule, "Delete Schedule"); 

  return str;
  }
      
  function editschedule(IDSchedule,ScheduleType)
  {
     //depending on the schedule type, edirect to the respective accordingly
     if(ScheduleType == "Daily")
     {
         location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceDaily.aspx?scheduleid=' + IDSchedule;
     
     }
  
     if(ScheduleType == "Weekly")
     {
         location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceDaily.aspx?scheduleid=' + IDSchedule;
     
     }
  
     if(ScheduleType == "Monthly")
     {
         location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceDaily.aspx?scheduleid=' + IDSchedule;
     
     }
  
  }  
  
  function deleteschedule(IDSchedule)
  {
     location.href = '/MetraNet/DataExportReportManagement/ManageReportInstances.aspx?reportid=' + IDSchedule;

  }
  </script>
</asp:Content>