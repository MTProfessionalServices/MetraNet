<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"  CodeFile="AccountBillManagees.aspx.cs" Inherits="Relationships_AccountBillManagees" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" ExtensionName="Core" 
    TemplateFileName="AccountBillManagees.xml" ButtonAlignment="Center" 
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

  <script language="javascript" type="text/javascript">  
  var win;
  function onRemove_<%=MTFilterGrid1.ClientID %>()
    {
      grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections()
      var manageeIds = GetManageeIds();        
        if (manageeIds.length == 0)
        {
           top.Ext.Msg.show({
                           title:TEXT_ERROR_MSG,
                           msg: TEXT_ERROR_SELECT,
                           buttons: Ext.Msg.OK,               
                           icon: Ext.MessageBox.ERROR
                       });   

          var dlg = top.Ext.MessageBox.getDialog();
	        var buttons = dlg.buttons;
	        for (i = 0; i < buttons.length; i++) {
          buttons[i].addClass('custom-class');
          }                
          return;
        }     
        
        // do ajax request
        Ext.Ajax.request({
        params: {ids: manageeIds},
        url: 'AjaxServices/RemoveAccountBillManagees.aspx',
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
        var responseJSON = Ext.decode(response.responseText);
        if(responseJSON)
        {
          var tpl = new Ext.XTemplate(
                  '<tpl for=".">',
                    '<tpl if="Success == false">',
                      '<img src="/Res/images/icons/error.png" />  ' + TEXT_ERROR,
                    '</tpl>',
                    '<tpl if="Success == true">',
                      '<img src="/Res/images/icons/accept.png" />  ' + TEXT_SUCCESS,
                    '</tpl>',
                    '<p>{Message}</p>',
                   '</tpl>'
              );

              if(!win) {
            win = new Ext.Window({
                  applyTo:'results-win',
                  layout:'fit',
                  width:500,
                  height:300,
                  closeAction:'hide',
                  plain: true,
                  buttons: [{
                      text: TEXT_CLOSE,
                      handler: function(){
                          grid_<%=MTFilterGrid1.ClientID %>.store.reload();
                          win.hide();
                      }
                  }]
             });
          }
          tpl.overwrite(win.body, responseJSON);
          win.show(this);
          }
          else
          {
            Ext.UI.msg(TEXT_ERROR, responseJSON.Message);
          }
        }
      });
    }
  
   function GetManageeIds()
    {
      var records = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
      var manageeIds = "";
      for(var i=0; i < records.length; i++)
      {
        if(i > 0)
        {
          manageeIds += ",";
        }
        manageeIds += records[i].data.AccountID;
      }
      return manageeIds;
    }
  function onAdd_<%=MTFilterGrid1.ClientID %>()
  {
    getFrameMetraNet().getMultiSelection('ProcessSelectedAccounts', 'DropGrid');
  }

  function ProcessSelectedAccounts(ids, records, target)
    {

      // do ajax request
        Ext.Ajax.request({
        params: {ids : ids},
        url: 'AjaxServices/AddAccountBillManagees.aspx',
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
        var responseJSON = Ext.decode(response.responseText);
        if(responseJSON)
        {
          var tpl = new Ext.XTemplate(
                  '<tpl for=".">',
                    '<tpl if="Success == false">',
                      '<img src="/Res/images/icons/error.png" />  ' + TEXT_ERROR,
                    '</tpl>',
                    '<tpl if="Success == true">',
                      '<img src="/Res/images/icons/accept.png" />  ' + TEXT_SUCCESS,
                    '</tpl>',
                    '<p>{Message}</p>',
                   '</tpl>'
              );

              if(!win) {
            win = new Ext.Window({
                  applyTo:'results-win',
                  layout:'fit',
                  width:500,
                  height:300,
                  closeAction:'hide',
                  plain: true,
                  buttons: [{
                      text: TEXT_CLOSE,
                      handler: function(){
                          grid_<%=MTFilterGrid1.ClientID %>.store.reload();
                          win.hide();
                      }
                  }]
             });
          }
          tpl.overwrite(win.body, responseJSON);
          win.show(this);
          }
          else
          {
            Ext.UI.msg(TEXT_ERROR, responseJSON.Message);
          }
        }
      });
    }
  </script>
  <div id="results-win" class="x-hidden"> 
    <div class="x-window-header">
    </div> 
    <div id="result-content"> 
    </div> 
  </div> 
  </asp:Content>

