<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  Inherits="DataExportReportManagement_ManageReportInstanceSchedules" Title="Manage Report Instance Schedule"
  Culture="auto" UICulture="auto" CodeFile="ManageReportInstanceSchedules.aspx.cs"
  meta:resourcekey="PageResource1" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblManageReportInstanceSchedulesTitle" runat="server" Text="Manage Report Instance Schedule"
      meta:resourcekey="lblManageReportInstanceSchedulesTitleResource1"></asp:Label>
  </div>
  <br />
  <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="DataExport" TemplateFileName="DataExportFramework.GetAllSchedulesOfAInstance.xml"
    ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True"
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" EnableSaveSearch="False"
    Expandable="False" ExpansionCssClass="" Exportable="False" FilterColumnWidth="350"
    FilterInputWidth="220" FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    meta:resourcekey="MyGrid1Resource1" MultiSelect="False" NoRecordsText="No records found"
    PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    ShowBottomBar="True" ShowColumnHeaders="True" ShowFilterPanel="True" ShowGridFrame="True"
    ShowGridHeader="True" ShowTopBar="True" TotalProperty="TotalRows">
  </MT:MTFilterGrid>
  <script language="javascript" type="text/javascript">
   var textUpdate = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Update_Report_Instance_Schedule")%>';//"Update Report Instance Schedule"
   var textDelete = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Delete_Report_Instance_Schedule")%>';
    
    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('IDSchedule'), idreportinstancescheduleColRenderer);
  }
  
  function idreportinstancescheduleColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    var ScheduleTypeTextEncoded = escape(record.data.ScheduleTypeText);
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstanceschedule(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.IDSchedule, ScheduleTypeTextEncoded, textUpdate);   
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:deletereportinstanceschedule(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_delete.png' alt='{2}' /></a>", record.data.IDSchedule, ScheduleTypeTextEncoded, textDelete);
    
  //str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{3}' href='JavaScript:deletereportinstanceschedule(\"{0}\");'><img src='/Res/Images/icons/database_delete.png' alt='{1}' /></a>", record.data.IDSchedule, "Delete Report Instance Schedule");

  return str;
  }
  
  function editreportinstanceschedule(IDSchedule, ScheduleTypeText)
  {
  var strincomingIDReportInstance = escape('<%= Utils.EncodeForHtml(strincomingIDReportInstance) %>');
  var incomingReportId = escape('<%= Utils.EncodeForHtml(strincomingIDReport) %>');

        if(ScheduleTypeText == 'Daily')
        {
        location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceDaily.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Update' + '&reportid=' + incomingReportId ;
        }
        else
          {
            if(ScheduleTypeText == 'Weekly')
              {
                location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceWeekly.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Update' + '&reportid=' + incomingReportId;
              }
            else 
              {
                if(ScheduleTypeText == 'Monthly')
                  {
                    location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceMonthly.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Update' + '&reportid=' + incomingReportId;
                  }
              }
          }  
  }

  function deletereportinstanceschedule(IDSchedule, ScheduleTypeText)
  {
  var strincomingIDReportInstance = escape('<%= Utils.EncodeForHtml(strincomingIDReportInstance) %>');
  var incomingReportId = escape('<%= Utils.EncodeForHtml(strincomingIDReport) %>');
  var retVal = confirm("Do you want to continue ?");
  if( retVal == true )
  {
  
        if(ScheduleTypeText == 'Daily')
        {
        //location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceDaily.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Delete' + '&reportid=' + incomingReportId;
        location.href = '/MetraNet/DataExportReportManagement/DeleteInstanceSchedule.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Delete' + '&reportid=' + incomingReportId;
        }
        else
          {
            if(ScheduleTypeText == 'Weekly')
              {
                //location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceWeekly.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Delete' + '&reportid=' + incomingReportId;
                location.href = '/MetraNet/DataExportReportManagement/DeleteInstanceSchedule.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Delete' + '&reportid=' + incomingReportId;
              }
            else 
              {
                if(ScheduleTypeText == 'Monthly')
                  {
                    //location.href = '/MetraNet/DataExportReportManagement/UpdateScheduleReportInstanceMonthly.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Delete' + '&reportid=' + incomingReportId;
                    location.href = '/MetraNet/DataExportReportManagement/DeleteInstanceSchedule.aspx?idreportinstanceschedule='+ IDSchedule + '&idreportinstance=' + strincomingIDReportInstance + '&action=Delete' + '&reportid=' + incomingReportId;
                  }
              }
          }  
  }

  else 
  {
  //location.href = '/MetraNet/DataExportReportManagement/ShowAllReportDefinitions.aspx'
  }
  }

  function adddailyschedule1_ctl00_ContentPlaceHolder1_MyGrid1()
  {
     var strincomingIDReportInstance = escape('<%= Utils.EncodeForHtml(strincomingIDReportInstance) %>');
     var incomingReportId = escape('<%= Utils.EncodeForHtml(strincomingIDReport) %>');
     location.href = '/MetraNet/DataExportReportManagement/CreateScheduleReportInstanceDaily.aspx?idreportinstance=' + strincomingIDReportInstance + '&reportid=' + incomingReportId;
       
  } 
  
  function addweeklyschedule1_ctl00_ContentPlaceHolder1_MyGrid1()
  {
     var strincomingIDReportInstance = escape('<%= Utils.EncodeForHtml(strincomingIDReportInstance) %>');
     var incomingReportId = escape('<%= Utils.EncodeForHtml(strincomingIDReport) %>');
     location.href = '/MetraNet/DataExportReportManagement/CreateScheduleReportInstanceWeekly.aspx?idreportinstance=' + strincomingIDReportInstance + '&reportid=' + incomingReportId ;
  } 

  
  function addmonthlyschedule1_ctl00_ContentPlaceHolder1_MyGrid1()
  {
     var strincomingIDReportInstance = escape('<%= Utils.EncodeForHtml(strincomingIDReportInstance) %>');
     var incomingReportId = escape('<%= Utils.EncodeForHtml(strincomingIDReport) %>');
     location.href = '/MetraNet/DataExportReportManagement/CreateScheduleReportInstanceMonthly.aspx?idreportinstance=' + strincomingIDReportInstance + '&reportid=' + incomingReportId;

  }

  function back()
  {
     var incomingReportId = escape('<%= Utils.EncodeForHtml(strincomingIDReport) %>');
     
     location.href = '/MetraNet/DataExportReportManagement/ManageReportInstances.aspx?reportid=' + incomingReportId;

  } 

  </script>
</asp:Content>
