<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_ManageReportInstances"
  Title="Manage Report Instances" Culture="auto" UICulture="auto" CodeFile="ManageReportInstances.aspx.cs" meta:resourcekey="PageResource1" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblManageReportInstancesTitle" runat="server" Text="Manage Report Instances"
      meta:resourcekey="lblManageReportInstancesTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="DataExport" 
    TemplateFileName="ManageReportInstances.xml" ButtonAlignment="Center" 
    Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True" 
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" 
    EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" 
    Exportable="False" FilterColumnWidth="350" FilterInputWidth="220" 
    FilterLabelWidth="75" FilterPanelCollapsed="False" 
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
    cm.setRenderer(cm.getIndexById('IDReportInstance'), idreportinstanceColRenderer); 

  }
  
  function idreportinstanceColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
    
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstance(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.IDReportInstance,strincomingReportId, "Edit Report Instance");

  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstanceschedule(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/application_view_list.png' alt='{2}' /></a>", record.data.IDReportInstance, strincomingReportId, "Manage Report Instance Schedule"); 
  
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstanceparametervalues(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/application_form_edit.png' alt='{2}' /></a>", record.data.IDReportInstance,strincomingReportId, "Edit Instance Parameter Values");
  
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:deletereportinstance(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_delete.png' alt='{2}' /></a>", record.data.IDReportInstance,strincomingReportId, "Delete Report Instance");
  return str;
  }
  
  
  function editreportinstance(IDReportInstance, strincomingReportId)
  {
     location.href = '/MetraNet/DataExportReportManagement/ShowReportInstanceDetails.aspx?idreportinstance='+ IDReportInstance + '&idreport=' +strincomingReportId + '&action=Update';

  }  
  
  function editreportinstanceschedule(IDReportInstance,strincomingReportId)
  {
     location.href = '/MetraNet/DataExportReportManagement/ManageReportInstanceSchedules.aspx?idreportinstance='+ IDReportInstance + '&idreport=' +strincomingReportId;
  }

  function editreportinstanceparametervalues(IDReportInstance, strincomingReportId)
  {
       location.href = '/MetraNet/DataExportReportManagement/ManageReportInstanceParameterValues.aspx?reportinstanceid='+ IDReportInstance + '&idreport=' +strincomingReportId;
  }
  
  function deletereportinstance(IDReportInstance, strincomingReportId)
  {
       var retVal = confirm("Do you want to continue ?");

   if( retVal == true ){
      
      //location.href = '/MetraNet/DataExportReportManagement/ShowReportInstanceDetails.aspx?idreportinstance='+ IDReportInstance + '&idreport=' +strincomingReportId + '&action=Delete';
        location.href = '/MetraNet/DataExportReportManagement/DeleteExistingReportInstance.aspx?idreportinstance='+ IDReportInstance + '&idreport=' +strincomingReportId + '&action=Delete';
   }
   else
   {
      //location.href = '/MetraNet/DataExportReportManagement/ManageReportInstances.aspx?reportid=' + strincomingReportId;
   }
  }  
  

 function addreportinstance_<%= MyGrid1.ClientID %>()
   {
     var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
     location.href = '/MetraNet/DataExportReportManagement/AddNewReportInstance.aspx?reportid=' + strincomingReportId;
     
  }  
  
 function back()
   {

     location.href = '/MetraNet/DataExportReportManagement/ShowAllReportDefinitions.aspx';
     
  }  
    
  </script>
</asp:Content>