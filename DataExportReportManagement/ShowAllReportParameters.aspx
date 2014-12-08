<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="DataExportReportManagement_ShowAllReportParameters"
  Title="Select Report Parameters" Culture="auto" UICulture="auto" CodeFile="ShowAllReportParameters.aspx.cs" meta:resourcekey="PageResource1" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblShowAllReportParametersTitle" runat="server" Text="Select Report Parameters"
      meta:resourcekey="lblShowAllReportParametersTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="MTFilterGrid1" ExtensionName="DataExport" 
    TemplateFileName="DataExportFramework.ReportParameters.xml" 
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

    function onOK_<%=MTFilterGrid1.ClientID %>()
    {
      var parameterids = GetParameterIDs();
      if (parameterids.length == 0)
        {
          Ext.UI.SystemError('<%=GetGlobalResourceObject("JSConsts", "TEXT_No_parameter_was_selected_MESSAGE")%>'); 
          var dlg = top.Ext.MessageBox.getDialog();
	        var buttons = dlg.buttons;
          for (i = 0; i < buttons.length; i++) {
            buttons[i].addClass('custom-class');
          }
        return;
        }      
        
        // do ajax request
        Ext.Ajax.request({
        params: {ids: parameterids},
        url: 'AjaxServices/AssignReportParameters.aspx',
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
        var responseJSON = Ext.decode(response.responseText);
        }
      }
      );
      var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
      location.href = '/MetraNet/DataExportReportManagement/ShowAssignedReportParameters.aspx?reportid='+strincomingReportId;
      
    }

   function GetParameterIDs()
    {
      var nsRecords = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
      var parameterids = "";
      for(var i=0; i < nsRecords.length; i++)
      {
        if(i > 0)
        {
          parameterids += ",";
        }
        parameterids += nsRecords[i].data.IDParameter;
      }
      return parameterids;
    }

   function onCancel_<%=MTFilterGrid1.ClientID %>()
   {
      var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
      //location.href = '/MetraNet/DataExportReportManagement/ShowAllReportDefinitions.aspx';
      location.href = '/MetraNet/DataExportReportManagement/ShowAssignedReportParameters.aspx?reportid='+strincomingReportId;
   }
   
   function createnewparameter_<%=MTFilterGrid1.ClientID %>()
   {
     var strincomingReportId = escape('<%= Utils.EncodeForHtml(strincomingReportId) %>');
     location.href = '/MetraNet/DataExportReportManagement/AddNewReportParameters.aspx?reportid='+strincomingReportId;
   }  

  </script>
</asp:Content>