<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_ManageReportInstanceParameterValues"
  Title="Manage Report Instance Parameter Values" Culture="auto" UICulture="auto" CodeFile="ManageReportInstanceParameterValues.aspx.cs" meta:resourcekey="PageResource1" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblManageReportInstanceParameterValuesTitle" runat="server" Text="Report Instance Parameter Values"
      meta:resourcekey="lblManageReportInstanceParameterValuesTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="MTFilterGrid1" ExtensionName="DataExport" 
    TemplateFileName="DataExportFramework.ManageReportInstanceParameterValues.xml" 
    ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" 
    DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" 
    EnableLoadSearch="False" EnableSaveSearch="False" Expandable="False" 
    ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" 
    FilterInputWidth="220" FilterLabelWidth="75" FilterPanelCollapsed="False" 
    FilterPanelLayout="MultiColumn" meta:resourcekey="MTFilterGrid1Resource1" 
    MultiSelect="False" NoRecordsText="No records found" PageSize="10" 
    Resizable="True" RootElement="Items" SearchOnLoad="True" 
    SelectionModel="Standard" ShowBottomBar="True" ShowColumnHeaders="True" 
    ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" 
    ShowTopBar="True" 
    TotalProperty="TotalRows"></MT:MTFilterGrid>
     
  <script language="javascript" type="text/javascript">

  OverrideRenderer_<%=MTFilterGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('IDParameterValueInstance'), idparametervalueinstanceColRenderer); 
  }
  
  function idparametervalueinstanceColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editinstanceparametervalues(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.IDParameterValueInstance, record.data.ParameterValueInstance, "Edit Instance Parameter Value");
  
  return str;
  }
  
  function editinstanceparametervalues(IDParameterValueInstance, ParameterValueInstance)
    {
       var strinstanceid = escape('<%= Utils.EncodeForHtml(strincomingReportInstanceId) %>');
       var strreportid = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
       location.href = '/MetraNet/DataExportReportManagement/EditInstanceParameterValue.aspx?idparametervalueinstance=' + IDParameterValueInstance + '&parametervalueinstance=' + ParameterValueInstance + '&reportinstanceid=' + strinstanceid + '&idreport=' + strreportid;
  }  
  
  function goback()
    {
       var strreportid = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
       location.href = '/MetraNet/DataExportReportManagement/ManageReportInstances.aspx?reportid=' + strreportid;
  }  

  </script>
</asp:Content>