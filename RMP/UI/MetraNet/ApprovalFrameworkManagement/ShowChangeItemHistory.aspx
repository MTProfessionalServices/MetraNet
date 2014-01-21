<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="ApprovalFrameworkManagement_ShowChangeItemHistory"
  Title="Change Item History" Culture="auto" UICulture="auto" CodeFile="ShowChangeItemHistory.aspx.cs" meta:resourcekey="PageResource1" %>
  <%@ Import Namespace="MetraTech.UI.Tools"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblShowChangeItemHistoryTitle" runat="server" Text="Change Item History"
      meta:resourcekey="lblShowChangeItemHistoryTitleResource1"></asp:Label>
  </div>
  <br />

    <MT:MTFilterGrid runat="Server" ID="ChangeHistory" ExtensionName="Core" 
    TemplateFileName="Approvals.ChangeHistory.xml" 
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

      OverrideRenderer_<%=ChangeHistory.ClientID %> = function(cm)
      {
        cm.setRenderer(cm.getIndexById('Details'), customDetailsRenderer); 
      }

        function back() 
        {
        var iscs = escape('<%= Utils.EncodeForHtml(incomingshowchangestate) %>');
        location.href = '/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=' + iscs;
        }

        function customDetailsRenderer(value, metadata, record, rowIndex, colIndex, store) {
            metadata.attr = 'ext:qtip="' + value + '"';
            return value;
        }
      </script>


  </asp:Content>