<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_AdHocReportManagement"
  Title="Adhoc Reports" Culture="auto" UICulture="auto" CodeFile="AdHocReportManagement.aspx.cs" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblShowAdhocReportDefinitionsTitle" runat="server" Text="Adhoc Reports"
      meta:resourcekey="lblShowAdhocReportDefinitionsTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="DataExport" 
    TemplateFileName="DataExportFramework.AdhocReportManagement.xml" 
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
    var textDelete_Report = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Delete_Queue_AdHoc_Reports")%>';

    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
    {
      cm.setRenderer(cm.getIndexById('ReportID'), reportidColRenderer); 
    }
  
    function reportidColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}'   href='JavaScript:queueadhocreports(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.ReportID, escape(record.data.ReportTitle),textDelete_Report);

      return str;
    }
  
    
    function queueadhocreports(ReportID, ReportTitle)
    {
      location.href = '/MetraNet/DataExportReportManagement/QueueAdhocReports.aspx?reportid=' + ReportID + '&reporttitle=' + ReportTitle;
    }

  </script>
</asp:Content>