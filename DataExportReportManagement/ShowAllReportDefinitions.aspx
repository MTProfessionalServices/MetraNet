<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  Inherits="DataExportReportManagement_ShowAllReportDefinitions" Title="Show All Report Definitions"
  Culture="auto" UICulture="auto" CodeFile="ShowAllReportDefinitions.aspx.cs" meta:resourcekey="PageResource1" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblShowAllReportDefinitionsTitle" runat="server" Text="Show All Report Definitions"
      meta:resourcekey="lblShowAllReportDefinitionsTitleResource1"></asp:Label>
  </div>
  <br />
  <MT:MTFilterGrid runat="Server" ID="MyGrid1" ExtensionName="DataExport" TemplateFileName="ShowAllReportDefinitions.xml"
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
    var textEdit_Report_Definition = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Edit_Report_Definition")%>';
    var textManage_Report_Instances = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Manage_Report_Instances")%>';
    var textManage_Report_Parameters = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Manage_Report_Parameters")%>';
    var textDelete_Report = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Delete_Report")%>';
    var textDelete = '<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE")%>';
    
  OverrideRenderer_<%=MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('ReportID'), reportidColRenderer); 
  };

  function reportidColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:managereportdefinition(\"{0}\");'><img src='/Res/Images/icons/database_edit.png' alt='{1}' /></a>", record.data.ReportID, textEdit_Report_Definition);
  
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:managereportinstances(\"{0}\");'><img src='/Res/Images/icons/application_view_list.png' alt='{1}' /></a>", record.data.ReportID, textManage_Report_Instances); 

  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:managereportparameters(\"{0}\");'><img src='/Res/Images/icons/application_form_edit.png' alt='{1}' /></a>", record.data.ReportID, textManage_Report_Parameters); 

  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{3}' href='JavaScript:deletereport(\"{0}\", \"{1}\", \"{2}\");'><img src='/Res/Images/icons/database_delete.png' alt='{3}' /></a>", record.data.ReportID, escape(record.data.ReportTitle), escape(record.data.ReportDescription), textDelete_Report); 

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
    top.Ext.MessageBox.show({
        title: textDelete,
        msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE_MESSAGE")%>'),
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            location.href = '/MetraNet/DataExportReportManagement/DeleteExistingReportDefinition.aspx?reportid=' + ReportID + '&action=Delete';
          }
        },
        animEl: 'elId',
        icon: window.Ext.MessageBox.QUESTION
      });
      
      var dlg = top.Ext.MessageBox.getDialog();
	    var buttons = dlg.buttons;
	    for (i = 0; i < buttons.length; i++) {
      buttons[i].addClass('custom-class');
     }

  }  

  function addnewreportdefinition_<%=MyGrid1.ClientID %>()
  {
     location.href = '/MetraNet/DataExportReportManagement/CreateNewReportDefinition.aspx';
  }
  
  </script>
</asp:Content>
