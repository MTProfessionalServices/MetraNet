<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="BillSoftOverrides.aspx.cs" Inherits="Tax_BillSoftOverrides" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" ExtensionName="BillSoft" 
    TemplateFileName="BillSoftOverrides.xml" ButtonAlignment="Center" 
    Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True" 
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" 
    EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" 
    Exportable="False" FilterColumnWidth="350" FilterInputWidth="220" 
    FilterLabelWidth="75" FilterPanelCollapsed="False" 
    FilterPanelLayout="MultiColumn" meta:resourcekey="MTFilterGrid1Resource1" 
    MultiSelect="False" NoRecordsText="No records found" PageSize="10" 
    Resizable="True" RootElement="Items" SearchOnLoad="True" 
    SelectionModel="Standard" ShowBottomBar="True" ShowColumnHeaders="True" 
    ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" 
    ShowTopBar="True" TotalProperty="TotalRows">
  </MT:MTFilterGrid>

  <script type="text/javascript">

    function onAdd_<%=MTFilterGrid1.ClientID %>()
    {
      location.href = "SaveBillSoftOverride.aspx";
    }

    OverrideRenderer_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function(cm) 
    {
      //cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer); 
    };

    
    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";    
   
      // View
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='Delete' title='{1}' href='JavaScript:onDeleteOverride(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>", record.data.UniqueId, TEXT_DELETE);
   
      //Edit
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='Edit' title='{1}' href='JavaScript:onEditOverride(\"{0}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",  record.data.UniqueId, TEXT_EDIT);
     
      return str;
    }
    function onDeleteOverride(UniqueId)
    {
            top.Ext.MessageBox.show({
            title: TEXT_CONFIRM_CONTINUE,
            msg: TEXT_DELETE_BS_OVERRIDE,
            buttons: Ext.MessageBox.OKCANCEL,
            fn: function(btn){
              if (btn == 'ok')
              {   
                location.href= "BillSoftOverrides.aspx?Action=Delete&OverrideId=" + UniqueId;
              }
            }
          });    
    }
  
    function onEditOverride(UniqueId)
    {
      location.href= "EditBillSoftOverrides.aspx?Action=Edit&OverrideId=" + UniqueId;
    }

    </script>
    <div id="results-win" class="x-hidden"> 
      <div class="x-window-header"></div> 
    <div id="result-content"></div> 
  </div> 
</asp:Content>

