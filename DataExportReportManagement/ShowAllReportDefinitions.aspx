<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_ShowAllReportDefinitions"
  Title="Show All Report Definitions" Culture="auto" UICulture="auto" CodeFile="ShowAllReportDefinitions.aspx.cs" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblShowAllReportDefinitionsTitle" runat="server" Text="Show All Report Definitions"
      meta:resourcekey="lblShowAllReportDefinitionsTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="DataExport" 
    TemplateFileName="ShowAllReportDefinitions.xml" ButtonAlignment="Center" 
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

    OverrideRenderer_<%=MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('ReportID'), reportidColRenderer); 
  }
  
  function reportidColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:managereportdefinition(\"{0}\");'><img src='/Res/Images/icons/database_edit.png' alt='{1}' /></a>", record.data.ReportID, "Edit Report Definition");
  
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:managereportinstances(\"{0}\");'><img src='/Res/Images/icons/application_view_list.png' alt='{1}' /></a>", record.data.ReportID, "Manage Report Instances"); 

  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:managereportparameters(\"{0}\");'><img src='/Res/Images/icons/application_form_edit.png' alt='{1}' /></a>", record.data.ReportID, "Manage Report Parameters"); 

  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{3}' href='JavaScript:deletereport(\"{0}\", \"{1}\", \"{2}\");'><img src='/Res/Images/icons/database_delete.png' alt='{3}' /></a>", record.data.ReportID, escape(record.data.ReportTitle), escape(record.data.ReportDescription), "Delete Report"); 

  return str;
  }
  
    
  function managereportdefinition(ReportID)
  {
     location.href = '/MetraNet/DataExportReportManagement/UpdateExistingReportDefinition.aspx?reportid=' + ReportID + '&action=Update';
  }  
  
  function managereportinstances(ReportID)
  {
     location.href = '/MetraNet/DataExportReportManagement/ManageReportInstances.aspx?reportid=' + ReportID;
  }

  //function addnewreportinstance(ReportID)
  //{
  //   location.href = '/MetraNet/DataExportReportManagement/AddNewReportInstance.aspx?reportid=' + ReportID;
  //}

  function managereportparameters(ReportID)
  {
     location.href = '/MetraNet/DataExportReportManagement/ShowAssignedReportParameters.aspx?reportid=' + ReportID;
  }

  //function showassignedreportparameters(ReportID)
  //{
  //   location.href = '/MetraNet/DataExportReportManagement/ShowAssignedReportParameters.aspx?reportid=' + ReportID;
  //}

  function deletereport(ReportID, ReportTitle, ReportDescription)
  {
  var retVal = confirm("Do you want to continue ?");

   if( retVal == true ){
	  //location.href = '/MetraNet/DataExportReportManagement/UpdateExistingReportDefinition.aspx?reportid=' + ReportID + '&action=Delete';
    location.href = '/MetraNet/DataExportReportManagement/DeleteExistingReportDefinition.aspx?reportid=' + ReportID + '&action=Delete';
   }
   else
   {
      location.href = '/MetraNet/DataExportReportManagement/ShowAllReportDefinitions.aspx'
   }

  }  


  function addnewreportdefinition_<%=MyGrid1.ClientID %>()
  {
     location.href = '/MetraNet/DataExportReportManagement/CreateNewReportDefinition.aspx';
  }
  
    </script>
</asp:Content>