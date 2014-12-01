<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_ManageReportInstances"
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
    var textEdit_Report_Definition = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Edit_Report_Instance")%>';
    var textManage_Report_Instances = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Manage_Report_Instance_Schedule")%>';
    var textManage_Report_Parameters = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Manage_Report__InstanceParameters")%>';
    var textDelete_Report = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Delete_Report_Instance")%>';
    var textDelete = '<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE")%>';
    
    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
    {
      cm.setRenderer(cm.getIndexById('IDReportInstance'), idreportinstanceColRenderer); 

    }
  
  function idreportinstanceColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
    
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstance(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_edit.png' alt='{2}' /></a>", record.data.IDReportInstance,strincomingReportId, textEdit_Report_Definition);

    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstanceschedule(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/application_view_list.png' alt='{2}' /></a>", record.data.IDReportInstance, strincomingReportId, textManage_Report_Instances); 
  
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:editreportinstanceparametervalues(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/application_form_edit.png' alt='{2}' /></a>", record.data.IDReportInstance,strincomingReportId, textManage_Report_Parameters);
  
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{2}' href='JavaScript:deletereportinstance(\"{0}\", \"{1}\");'><img src='/Res/Images/icons/database_delete.png' alt='{2}' /></a>", record.data.IDReportInstance,strincomingReportId, textDelete_Report);
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
    top.Ext.MessageBox.show({
        title: textDelete,
        msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE_MESSAGE")%>'),
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            location.href = '/MetraNet/DataExportReportManagement/DeleteExistingReportInstance.aspx?idreportinstance='+ IDReportInstance + '&idreport=' +strincomingReportId + '&action=Delete';
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