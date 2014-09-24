<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="PriceListsList.aspx.cs" Inherits="PriceListsList" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" ExtensionName="Core" 
    TemplateFileName="PriceListsList" ButtonAlignment="Center" 
    Buttons="None" DefaultSortDirection="Ascending" DisplayCount="True" 
    EnableColumnConfig="True" EnableFilterConfig="True" EnableLoadSearch="False" 
    EnableSaveSearch="False" Expandable="False" ExpansionCssClass="" 
    Exportable="False" FilterColumnWidth="350" FilterInputWidth="220" 
    FilterLabelWidth="75" FilterPanelCollapsed="False" 
    FilterPanelLayout="MultiColumn" meta:resourcekey="MTFilterGrid1Resource1" 
    MultiSelect="False" PageSize="10" 
    Resizable="True" RootElement="Items" SearchOnLoad="True" 
    SelectionModel="Standard" ShowBottomBar="True" ShowColumnHeaders="True" 
    ShowFilterPanel="True" ShowGridFrame="True" ShowGridHeader="True" 
    ShowTopBar="True" TotalProperty="TotalRows" NoRecordsText="No records found" />

    <script type="text/javascript" language="javascript" src="/mcm/default/lib/browsercheck.js"></script>
    <script type="text/javascript" language="javascript" src="/mcm/default/lib/PopupEdit.js"></script>

    <script language="javascript" type="text/javascript">
      function CreatePriceList_<%=MTFilterGrid1.ClientID%> () {
        //var targetURL= "/MetraNet/TicketToMCM.aspx?Redirect=True&Title=Create New Price List&URL=/mcm/default/dialog/wizard/CreatePriceList/wizardstart.asp|Path=/mcm/default/dialog/wizard/CreatePriceList**PageID=start**NextPage=DISPLAY_NEW_ITEM";
        //OpenModalWindow(targetURL);
        location.href = '/MetraNet/MetraOffer/PriceLists/CreateSharedPriceList.aspx';
      }

      OverrideRenderer_<%=MTFilterGrid1.ClientID%> = function(cm) {
        cm.setRenderer(cm.getIndexById('Name'), NameColRenderer);
        cm.setRenderer(cm.getIndexById('ID'), actionsColRenderer);
      }
    
    function NameColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
        var str = String.format("<span title='Name_{0}'><a style='cursor:hand;' id='viewName_{0}' title='{1}' href='JavaScript:ViewPriceList({0});'>{2}</a></span>", 
                                record.data.ID,
                                "View Price List",
                                record.data.Name);

        return str;
    }

    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
        var str = "";
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='view_{0}'   title='{1}' href='JavaScript:ViewPriceList({0});'>  <img src='/Res/Images/icons/package_go.png'   alt='{1}' /></a>", record.data.ID, "View Price List");
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='edit_{0}'   title='{1}' href='JavaScript:EditPriceList({0});'>  <img src='/Res/Images/icons/pencil.png'       alt='{1}' /></a>", record.data.ID, "Edit Price List");
        str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='copy_{0}'   title='{1}' href='JavaScript:CopyPriceList({0},\"{2}\");'>  <img src='/Res/Images/icons/copy.png'         alt='{1}' /></a>", record.data.ID, "Copy Price List", store.sm.grid.id);
        
        if (<%=UI.CoarseCheckCapability("Delete Rates").ToString().ToLower()%>)
        {
            str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='delete_{0}' title='{1}' href='JavaScript:DeletePriceList({0},\"{2}\");'><img src='/Res/Images/icons/delete.png'       alt='{1}' /></a>", record.data.ID, "Delete Price List", store.sm.grid.id);
        }
        return str;
    }
  
    function ViewPriceList(ID) {
      var targetURL = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/Pricelist.ViewEdit.Frame.asp|ID=" + ID + "**LinkColumnMode=TRUE**Rates=TRUE**POBased=FALSE**Title=TEXT_RATES_ALLPRICELISTS_CHOOSE_PRICEABLE_ITEM**kind=10";
        location.href = targetURL;
    }  

    function EditPriceList(ID)
    {
       location.href = '/MetraNet/MetraOffer/PriceLists/UpdateSharedPriceList.aspx?ID=' + ID;
    }  

    function CopyPriceList(ID, gridId)
    {
        var targetURL="/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/PriceList.Copy.asp|ID=" + ID;
        OpenModalWindow(targetURL);
        GridRefresh(gridId);
    }  

    function DeletePriceList(ID, gridId)
    {
        var targetURL="/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/PriceListDelete.asp|ID=" + ID;
        OpenModalWindow(targetURL);
        GridRefresh(gridId);
    }

    function OpenModalWindow(url)
    {
        window.OpenDialogWindow(url, "height=400,width=600,resizable=yes,scrollbars=yes");
    }
    
    function GridRefresh(gridId) {
      var grid = window.Ext.getCmp(gridId);
      setTimeout(
        function() {
          if (window.winDialog.closed) {
            grid.getSelectionModel().deselectAll(true);
            grid.store.reload();
          }
          else
            setTimeout(arguments.callee, 10);
        }, 
        10);
    }

    </script>

    <div id="results-win" class="x-hidden"> 
      <div class="x-window-header"></div> 
    <div id="result-content"></div> 
  </div> 
</asp:Content>