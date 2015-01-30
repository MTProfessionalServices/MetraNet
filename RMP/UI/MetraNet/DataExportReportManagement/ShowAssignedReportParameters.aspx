<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  Inherits="DataExportReportManagement_ShowAssignedReportParameters" Title="Assigned Report Parameters"
  Culture="auto" UICulture="auto" CodeFile="ShowAssignedReportParameters.aspx.cs"
  meta:resourcekey="PageResource1" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblShowAssignedReportParametersTitle" runat="server" Text="Assigned Report Parameters"
      meta:resourcekey="lblShowAssignedReportParametersTitleResource1"></asp:Label>
  </div>
  <br />
  <MT:MTFilterGrid runat="Server" ID="MTFilterGrid1" ExtensionName="DataExport" TemplateFileName="DataExportFramework.AssignedReportParameters.xml"
    ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True"
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" EnableSaveSearch="False"
    Expandable="False" ExpansionCssClass="" Exportable="False" FilterColumnWidth="350"
    FilterInputWidth="220" FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
    meta:resourcekey="MTFilterGrid1Resource1" MultiSelect="False" NoRecordsText="No records found"
    PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
    ShowBottomBar="True" ShowColumnHeaders="True" ShowFilterPanel="True" ShowGridFrame="True"
    ShowGridHeader="True" ShowTopBar="True" TotalProperty="TotalRows">
  </MT:MTFilterGrid>
  <script language="javascript" type="text/javascript">
  var textDelete = '<%=GetGlobalResourceObject("JSConsts", "TEXT_Delete_Report_Parameter")%>';//"Delete Report Parameter"
  OverrideRenderer_<%=MTFilterGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('IDParameter'), idparameterColRenderer);     
  }
  
  function idparameterColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
  str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:deletereportparameter(\"{0}\");'><img src='/Res/Images/icons/database_delete.png' alt='{1}' /></a>", record.data.IDParameter, textDelete);
  
  return str;
  }
  
    
  function deletereportparameter(IDParameter)
  {
    top.Ext.MessageBox.show({
        title: textDelete,
        msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_DELETE_MESSAGE")%>'),
        buttons: window.Ext.MessageBox.OKCANCEL,
        fn: function(btn) {
          if (btn == 'ok') {
            var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
            location.href = '/MetraNet/DataExportReportManagement/DeleteAssignedReportParameter.aspx?reportid=' + strincomingReportId + '&idparameter=' + IDParameter;
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

  function assignnewparameter_<%=MTFilterGrid1.ClientID %>() 
    {
      var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
      location.href = '/MetraNet/DataExportReportManagement/ShowAllReportParameters.aspx?reportid=' + strincomingReportId;
    }

    function back()
    {
      var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
      location.href = '/MetraNet/DataExportReportManagement/ShowAllReportDefinitions.aspx';
    }  

  </script>
</asp:Content>
