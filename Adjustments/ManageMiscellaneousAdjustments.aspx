<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ManageMiscellaneousAdjustments.aspx.cs" Inherits="Adjustments_ManageMiscellaneousAdjustments" meta:resourcekey="PageResource1" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTFilterGrid runat="Server" ID="MTFilterGrid1" ExtensionName="Core" 
    TemplateFileName="MiscAdjustment.xml" ButtonAlignment="Center" Buttons="None" 
    DefaultSortDirection="Ascending" DisplayCount="True" EnableColumnConfig="True" 
    EnableFilterConfig="True" EnableLoadSearch="False" EnableSaveSearch="False" 
    Expandable="False" ExpansionCssClass="" Exportable="False" 
    FilterColumnWidth="350" FilterInputWidth="220" FilterLabelWidth="75" 
    FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn" 
    meta:resourcekey="MTFilterGrid1Resource1" MultiSelect="False" 
    NoRecordsText="No records found" PageSize="10" Resizable="True" 
    RootElement="Items" SearchOnLoad="True" SelectionModel="Standard" 
    ShowBottomBar="True" ShowColumnHeaders="True" ShowFilterPanel="True" 
    ShowGridFrame="True" ShowGridHeader="True" ShowTopBar="True" 
    TotalProperty="TotalRows" ></MT:MTFilterGrid> 
    
    <script language="javascript" type="text/javascript">
      var win;
      function onApprove_<%=MTFilterGrid1.ClientID %>()
      {        
       var sessionIds = GetSessionIds();            
        // TODO: Localize
        if (sessionIds.length == 0)
        {
          Ext.UI.SystemError(TEXT_SELECT_ADJ_ERROR);
          return;
        }      
        
        // do ajax request
        Ext.Ajax.request({
        params: {ids: sessionIds},
        url: 'AjaxServices/ApproveMiscellaneousAdjustment.aspx',
        scope: this,
        disableCaching: true,
        timeout: 90000,
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
                          ReloadGrid();
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

      function onApproveAll_<%=MTFilterGrid1.ClientID %>()
      {        
            top.Ext.MessageBox.show({
            title: TEXT_CONFIRM_CONTINUE,
            msg: TEXT_ADJ_APPROVE,
            buttons: Ext.MessageBox.OKCANCEL,
            fn: function(btn){
            if (btn == 'ok')
            {        
              // Go get ALL the ids and put them in Session["SelectedIDs"] via ajax call
              // then go to the status page via popup
              var params = new Object(); 

              var totalRecords = dataStore_<%= MTFilterGrid1.ClientID %>.reader.jsonData.TotalRows;

              // copy base parameters
              for(var prop in dataStore_<%= MTFilterGrid1.ClientID %>.baseParams)
              {
                params[prop] = dataStore_<%= MTFilterGrid1.ClientID %>.baseParams[prop];
              }  

              // copy standard params, overwrite if necessary
              for(var prop in dataStore_<%= MTFilterGrid1.ClientID %>.lastOptions.params)
              {
                params[prop] = dataStore_<%= MTFilterGrid1.ClientID %>.lastOptions.params[prop];
              }

              // apply filters
              Ext.apply(params, grid_<%= MTFilterGrid1.ClientID %>.filters.buildQuery(grid_<%= MTFilterGrid1.ClientID %>.filters.getFilterData()));

              //configure data source URL
              var dataSourceURL = 'AjaxServices/ApproveAllMiscellaneousAdjustments.aspx';

              if(dataSourceURL.indexOf('?') < 0)
              {
                dataSourceURL += '?';
              }
              else{ dataSourceURL += '&'};
              dataSourceURL += 'mode=SelectAll&idNode=sessionid';

                Ext.Ajax.request({
                  url: dataSourceURL,
                  params: params,
                  scope: this,
                  disableCaching: true,
                  timeout: 90000,
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
                            ReloadGrid();
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
               },
               animEl: 'elId',
               icon: Ext.MessageBox.WARNING
            });

      }

      function onDenyAll_<%=MTFilterGrid1.ClientID %>()
      {
            top.Ext.MessageBox.show({
               title: TEXT_CONFIRM_CONTINUE,
               msg: TEXT_ADJ_DENIED,               
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
             // Go get ALL the ids and put them in Session["SelectedIDs"] via ajax call
            // then go to the status page via popup
            var params = new Object(); 
    
            var totalRecords = dataStore_<%= MTFilterGrid1.ClientID %>.reader.jsonData.TotalRows;

            // copy base parameters
            for(var prop in dataStore_<%= MTFilterGrid1.ClientID %>.baseParams)
            {
              params[prop] = dataStore_<%= MTFilterGrid1.ClientID %>.baseParams[prop];
            }  

            // copy standard params, overwrite if necessary
            for(var prop in dataStore_<%= MTFilterGrid1.ClientID %>.lastOptions.params)
            {
              params[prop] = dataStore_<%= MTFilterGrid1.ClientID %>.lastOptions.params[prop];
            }
   
            // apply filters
            Ext.apply(params, grid_<%= MTFilterGrid1.ClientID %>.filters.buildQuery(grid_<%= MTFilterGrid1.ClientID %>.filters.getFilterData()));

            //configure data source URL
            var dataSourceURL = 'AjaxServices/DenyAllMiscellaneousAdjustments.aspx';

            if(dataSourceURL.indexOf('?') < 0)
            {
              dataSourceURL += '?';
            }
            else{ dataSourceURL += '&'};
            dataSourceURL += 'mode=SelectAll&idNode=sessionid';
    
              Ext.Ajax.request({
                url: dataSourceURL,
                params: params,
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
                          ReloadGrid();
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
               },
               animEl: 'elId',
               icon: Ext.MessageBox.WARNING
            });


      }

      function onDeny_<%=MTFilterGrid1.ClientID %>() 
      { 
        var sessionIds = GetSessionIds();            
        // TODO: Localize
        if (sessionIds.length == 0)
        {
          Ext.UI.SystemError(TEXT_SELECT_ADJ_ERROR);
          return;
        }      
        
        // do ajax request
        Ext.Ajax.request({
        params: {ids: sessionIds},
        url: 'AjaxServices/DenyMiscellaneousAdjustment.aspx',
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
                          ReloadGrid();
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

      function GetSessionIds()
      {
        var adjRecords = grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().getSelections();
        var sessionIds = "";
        for(var i=0; i < adjRecords.length; i++)
        {
          if(i > 0)
          {
            sessionIds += ",";
          }
          sessionIds += adjRecords[i].data.SessionID;
        }
        return sessionIds;
      }

      function ReloadGrid()
      {
        grid_<%=MTFilterGrid1.ClientID %>.store.reload();
        grid_<%= MTFilterGrid1.ClientID %>.getSelectionModel().clearSelections();
      }
    </script>

      <div id="results-win" class="x-hidden"> 
    <div class="x-window-header">
    </div> 
    <div id="result-content"> 
    </div> 
  </div> 
</asp:Content>

