using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.UI.Tools;
using MetraTech.DomainModel.Common;
using System.Collections;
using RCD = MetraTech.Interop.RCD;
using System.Xml.Serialization;
using MetraTech.UI.Controls.MTLayout;
using System.Linq;
using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
    public enum MTAlignmentType
    {
        Left = 0,
        Center = 1,
        Right = 2
    }

    public enum MTButtonType
    {
        None = 0,
        OK = 1,
        Cancel = 2,
        OKCancel = 3,
        Custom = 4,
        Back = 5
    }

    public enum MTDataType
    {
        Numeric = 0,
        String = 1,
        Date = 2,
        List = 3,
        Boolean = 4,
        Account = 5
    }
    public enum MTGridSortDirection
    {
        Ascending = 0,
        Descending = 1
    }

    public enum MTGridSelectionModel
    {
        Standard = 0,
        Checkbox = 1
    }

    public enum MTFilterPanelLayout
    {
        SingleColumn = 1,
        MultiColumn = 2
    }

    public class GridElementSorter : IComparer<MTGridDataElement>
    {

        #region IComparer<MTGridDataElement> Members

        int IComparer<MTGridDataElement>.Compare(MTGridDataElement x, MTGridDataElement y)
        {
            return ((MTGridDataElement)x).Position.CompareTo(((MTGridDataElement)y).Position);
        }

        #endregion
    }

    public class URLParamList : Dictionary<string, object>
    {
        public new void Add(string key, object value)
        {
            base.Add("urlparam_" + key, value);
        }
    }

    [DefaultProperty("Text")]
    [ToolboxData("<{0}:MTFilterGrid runat=server></{0}:MTFilterGrid>")]
    public class MTFilterGrid : WebControl
    {
        private const string SCRIPT_INCLUDE_KEY = "script_includes";
        
        #region JavaScript

        protected string SCRIPT_EXPORT_BUTTON = @"
        ,items:[
          '-', {
          text: TEXT_EXPORT,
          tooltip: TEXT_EXPORT,
          icon:'/Res/Images/Icons/page_go.png',
          cls: 'x-btn-text-icon details',
          handler: onExportFromGrid_{control_id}
        }]
      ";

        protected string SCRIPT_EXPORT = @"

var formConfirmExport_{control_id};
var windowConfirmExport_{control_id};
function onExportFromGrid_{control_id}(btn, pressed)
{
  //open up a window
  if (!windowConfirmExport_{control_id})
  {
  
	   formConfirmExport_{control_id} = new Ext.form.FormPanel({
	      standardSubmit:true,
        baseCls: 'x-plain',
        defaultType: 'hidden',
        style:'padding:10px',
        items:[
          { 
            hideLabel:true,
            labelSeparator:'',	          
            xtype:'radio',
            name: 'CurPageOrAll',
            value: 'CurPage',
            inputValue: 'CurPage',
            boxLabel: TEXT_EXPORT_CURRENT_PAGE_ONLY
          },
          {
            checked:true,
            hideLabel:true,
            labelSeparator:'',
            xtype:'radio',
            name:'CurPageOrAll',
            value:'All',
            inputValue:'All',
            boxLabel: TEXT_EXPORT_ALL_RECORDS
          },
          {            
            hideLabel:true,
            labelSeparator:'',
            xtype:'radio',
            name:'CurPageOrAll',
            value:'Selected',
            inputValue:'Selected',
            boxLabel: TEXT_EXPORT_SELECTED_RECORDS
          },
          {            
            xtype:'hidden',
			id:'SelectedIds',
            name:'SelectedIds',
            value:''
          }
        ]
	    });
  
    if(grid_{control_id}.getSelectionModel().singleSelect ||
        !grid_{control_id}.supportExportSelected)
      formConfirmExport_{control_id}.items.items.splice(2);

    windowConfirmExport_{control_id} = new Ext.Window({
      el:'confirmExportWindow_{control_id}',
      cls:'x-hidden',
      layout:'fit',
      width:500,
      height:300,
      modal:true,
      title: TEXT_EXPORT_SEARCH_RESULTS,
      closeAction:'hide',
      plain: true,   
      items: [formConfirmExport_{control_id}]
      ,
      buttons:[{
        text:TEXT_EXPORT,
        handler:function(obj){
          onExport_{control_id}();
          windowConfirmExport_{control_id}.hide();
        }
      }
      ,
      {
        text:TEXT_CANCEL,
        handler:function(obj){
          windowConfirmExport_{control_id}.hide();
        }
      }]
    });
  
	}
	windowConfirmExport_{control_id}.show();
}

//ESR-4557 MetraControl Batch Management Export Errors
function GetFiltersToParamList_{control_id}()
{
  var i = 0;
  var j = 0;
  var maxFilterCount = filters_{control_id}.filters.keys.length;
  var params = {};
  
  while (i < maxFilterCount)
  {
    var filterName = filters_{control_id}.filters.keys[i];
    if ((Ext.get('filter_' + filterName + '_{control_id}')) /* || bInitialLoad*/)
    {
      var filter = filters_{control_id}.filters.items[i];
      
      var op = 'eq';
      if(filter.type == 'string')
      {
        op = 'lk';
      }
      
      //read the operation if it exists
      if(Ext.get('combo_filter_' + filterName + '_{control_id}-opValue'))
      {
        op = Ext.get('combo_filter_' + filterName + '_{control_id}-opValue').getValue();
      }
      
      var value1 = '';
      var value2 = '';
      
      // all except for Date read directly from the field
      if(filter.type != 'date')
      {
        if(filter.type == 'numeric')
        {
           //ranged numeric
          if(filter.rangeFilter)
          {
            value1 = Ext.get('filter_' + filterName + '_{control_id}-start-value').getValue();
            value2 = Ext.get('filter_' + filterName + '_{control_id}-end-value').getValue();
          }
          //regular numeric
          else{
            value1 = Ext.get('filter_' + filterName + '_{control_id}-value').getValue();
            op = Ext.get('filter_' + filterName + '_{control_id}-opValue').getValue();
          }
        }
        else
        {
          //ranged string
          if(filter.type == 'string' && filter.rangeFilter)
          {
            value1 = Ext.get('filter_' + filterName + '_{control_id}-start-value').getValue();
            value2 = Ext.get('filter_' + filterName + '_{control_id}-end-value').getValue();
          }
          //all other types, except for numeric and date
          else
          {
            value1 = Ext.get('filter_' + filterName + '_{control_id}').getValue();
            
            // additionally for combos and account types, read the display values into value2
            if((filter.type == 'combo') || (filter.type == 'account'))
            {
              value2 = Ext.get('combo_filter_' + filterName + '_{control_id}').getValue();
            }
          }    
        }  
      }
      // dates are read from start and end date fields
      // ESR-5546 Telus: Unable to export Audit Log 
      else
      {
        // If Text property is not set or empty for the date picker control, don't filter on the default selected Value in the date picker. 
        value1 = filter.dates.after.menu.picker.Text;
        value2 = filter.dates.before.menu.picker.Text;

        if (value1 != undefined && value1 != '')
        {
			value1 = filter.dates.after.menu.picker.value.format(DATE_FORMAT);
        }
        else
        {
			value1 = '';
        }
        if (value2 !=  undefined && value2 != '')
        {
			value2 = filter.dates.before.menu.picker.value.format(DATE_FORMAT);
        }
        else
        {
			value2 = '';
        }
      }

       // for use only existing values
      if(value1 != '')   
      {
        if(value2 != '')
        {
          params['filter[' + j + '][field]'] = filter.dataIndex;
          params['filter[' + j + '][visible]'] = filter.showFilter;
          params['filter[' + j + '][data][comparison]'] = 'gte';
          params['filter[' + j + '][data][type]'] = filter.type;
          params['filter[' + j + '][data][value]'] = value1;
          j++;
          params['filter[' + j + '][field]'] = filter.dataIndex;
          params['filter[' + j + '][visible]'] = filter.showFilter;
          params['filter[' + j + '][data][comparison]'] = 'lt';
          params['filter[' + j + '][data][type]'] = filter.type;
          params['filter[' + j + '][data][value]'] = value2;
        }
        else
        {
          params['filter[' + j + '][field]'] = filter.dataIndex;
           params['filter[' + j + '][data][comparison]'] = op;
          params['filter[' + j + '][visible]'] = filter.showFilter;
          params['filter[' + j + '][data][type]'] = filter.type;
          params['filter[' + j + '][data][value]'] = value1;
        }
      j++;
      }
    }
    
    i++;
  }

  return params;
}

function onExport_{control_id}(btn, pressed)
{
    //ESR-4557 MetraControl Batch Management Export Errors
  var params = GetFiltersToParamList_{control_id}(); 
  var totalRecords = dataStore_{control_id}.reader.jsonData.TotalRows;
  
  //copy base parameters
  for(var prop in dataStore_{control_id}.baseParams)
  {
    params[prop] = dataStore_{control_id}.baseParams[prop];
  }  

  //copy sortInfo
  for(var prop in dataStore_{control_id}.sortInfo)
  {
    if(prop == ""field"")
      params[""sort""] = dataStore_{control_id}.sortInfo[prop];

    if(prop == ""direction"")
      params[""dir""] = dataStore_{control_id}.sortInfo[prop];
  }  
  
  //copy standard params, overwrite if necessary
  for(var prop in dataStore_{control_id}.lastOptions.params)
  {
    params[prop] = dataStore_{control_id}.lastOptions.params[prop];
  }
  
  //add column params
  var cols = GetColumnInfo_{control_id}();
  Ext.apply(params, cols);
  
    //configure data source URL
  var dataSourceURL = '{data_source_url}';
  if(dataSourceURL.indexOf('?') < 0)
  {
    dataSourceURL += '?';
  }
  else{ dataSourceURL += '&'};
  dataSourceURL += 'mode=csv';
  
//prepare the dom
  domForm = formConfirmExport_{control_id}.getForm();
  var dom = formConfirmExport_{control_id}.getForm().getEl().dom;

  dom.action = dataSourceURL;
  dom.method = 'POST';
 
var formRes = formConfirmExport_{control_id}.getForm().getValues();
  if (formRes != null)
  {

    if (formRes.CurPageOrAll == 'CurPage')
    {
      dataSourceURL += '&export=curpage';    
    }

    if (formRes.CurPageOrAll == 'All')
    {
      if (params != null)
      {
        params.start = 0;
        params.limit = parseInt(totalRecords, 10);

        dataSourceURL += '&export=all';
      }    
    }

    if(document.getElementById('SelectedIds') != null)
    {
      if(dom.SelectedIds.value != null)
        dom.SelectedIds.value = '';

      if (formRes.CurPageOrAll == 'Selected')
      {
        var selectedIds = grid_{control_id}.getSelectionModel().getSelections();      
        for (var i = 0; i<selectedIds.length; i++)
          selectedIds[i] = selectedIds[i].id;
		
        dom.SelectedIds.value = selectedIds;   
      }
    }
  }


  dom.action = dataSourceURL;
  dom.method = 'POST';

  //clean up form
  for(var i = formConfirmExport_{control_id}.items.length - 1; i >= 0; i--) 
  {
    var curItem = formConfirmExport_{control_id}.items.items[i];
    if (curItem != null) 
    {
      var curName = curItem.name;
    
      if ( (curName == 'sort') || (curName == 'dir') || (curName == 'start') || (curName == 'limit') || (curName.substr(0,9) == 'urlparam_')
          || (curName.search(/column/i) == 0) || (curName.search(/filter/i) == 0))
      {
        formConfirmExport_{control_id}.remove(curName);   
      }
    }
  }
    
  //recreate the parameters
  for(var prop in params)
  {
    var value = params[prop];
    
    var curCmp = Ext.getCmp(prop);
    if(curCmp == null)
    {
      formConfirmExport_{control_id}.add({
	    id:prop,
        name:prop,
        value:value
      });
    }
    //update the value
    else
    {
      curCmp.setValue(value);
    }
  }
  
  formConfirmExport_{control_id}.doLayout();
  
  //submit the form
  domForm.getEl().dom.submit();
    
}


function GetColumnInfo_{control_id}()
{ 
  var columnParams = {};
  
  //iterate through columns
  var realIndex = 0;
  var columnCount = columnModel_{control_id}.getColumnCount();
  for (var i = 0; i < columnCount; i++)
  {
    //returns a column id at a given sequential position
    var columnID = columnModel_{control_id}.getColumnId(i);
   
    var curColumn = columnModel_{control_id}.getColumnById(columnID);
    
    if(curColumn.exportable)
    {
      if((curColumn.dataIndex != null) && (curColumn.dataIndex != ''))
      {
        var root = ['column', '[', realIndex, ']'].join('');
        
        columnParams[root + '[columnID]'] = curColumn.id;
        columnParams[root + '[mapping]'] = curColumn.mapping;//use mapping as it has the real path
        columnParams[root + '[headerText]'] = curColumn.header;
        
        realIndex++;
      }
    }
  }
  
  return columnParams;
}

";

        protected string SCRIPT_INCLUDES = @"
  <link rel=""stylesheet"" type=""text/css"" href=""{root_path}Styles/grid.css?v=6.5"" />
  <link href=""/Res/Styles/SuperBoxSelect.css"" media=""screen"" rel=""Stylesheet"" type=""text/css"" /> 

	<script type=""text/javascript"" src=""{root_path}ux/jpath/jpath.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/menu/EditableItem.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/menu/RangeMenu.js?v=6.5""></script>
	
	<script type=""text/javascript"" src=""{root_path}ux/grid/GridFilters.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/grid/filter/Filter.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/grid/filter/StringFilter.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/grid/filter/DateFilter.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/grid/filter/ListFilter.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/grid/filter/NumericFilter.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/grid/filter/BooleanFilter.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/form/DateRangeField.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/form/NumericRange.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}ux/form/StringRange.js?v=6.5""></script>
	<script type=""text/javascript"" src=""{root_path}JavaScript/common.js?v=6.5""></script>
  <script src=""{root_path}ux/renderer/ComboRenderer.js?v=6.5"" type=""text/javascript""></script>
	<script src=""{root_path}ux/form/ComboOperationField.js?v=6.5"" type=""text/javascript""></script>
  <script src=""{root_path}ux/grid/RowExpander.js?v=6.5"" type=""text/javascript""></script>  
	<script type=""text/javascript"" src=""{root_path}ux/form/NumericOperationField.js?v=6.5""></script>
  <script type=""text/javascript"" src=""{root_path}JavaScript/Renderers.js?v=6.5""></script>
  <script type=""text/javascript"" src=""{root_path}JavaScript/Renderers.Custom.js?v=6.5""></script>
  <script type=""text/javascript"" src=""{root_path}ux/grid/RowSelectionPaging.js?v=6.5""></script>
  <script type=""text/javascript"" src=""{root_path}JavaScript/RowSelectionModelOverride.js?v=6.5""></script>
  <script type=""text/javascript"" src=""/Res/ux/form/SuperBoxSelect.js?v=6.5""></script>

      ";

        protected string SCRIPT_FILTER_ENUM = @"
        Ext.Ajax.request({
            url: '{filter_enum_path}',
            scope: this,
            disableCaching: true,
            method: 'GET',
            success: function(response, options) {
              arrAsyncCalls_{control_id}[{filter_enum_id}] = response.responseText;
              asyncCallsCompleted_{control_id}++; 
              LoadGrid_{control_id}();
            }
         });
      "
;

        protected string SCRIPT_SAVED_SEARCH = @"

var listSavedSearchesWindow_{control_id};
var gridSavedSearch_{control_id};
var searchNameField_{control_id};
var searchDescriptionField_{control_id};
var windowSaveSearch_{control_id};
var xmlPath_{control_id} = '{template_xml}';

function onOpenSavedSearch_{control_id}(ev,tool,panel)
{
  var params = {'pageURL':'{page_url}', 'GridID':'{grid_id}', 'SearchLayout':xmlPath_{control_id}};
  if(!listSavedSearchesWindow_{control_id})
  {
    var record = Ext.data.Record.create([
      {name:'Name', mapping:'Name'},
      {name:'CreatedBy',mapping:'CreatedBy'},
      {name:'CreatedDate',mapping:'CreatedDate'},
      {name:'Description'},
      {name:'Id'}
    ]);
       
    var reader = new Ext.data.JsonReader({
      id:'Id',
		  totalProperty: 'TotalRows',
		  root: 'Items'
	  },
      record	    
    );
       
    var ds = new Ext.data.Store({
      proxy:new Ext.data.HttpProxy({
			  url:'{virtual_folder}/AjaxServices/GetSavedSearchList.aspx',
        method:'POST'
      }),
      reader:reader,
      remoteSort:false
    });
    
    var expander = new Ext.grid.RowExpander({
        tpl : new Ext.XTemplate(
            '<p><b>'+TEXT_DESCRIPTION + ':</b> {Description}<br>'
        )
    });
    
    var cm = new Ext.grid.ColumnModel([
      expander,
      {id:'SearchName',header: TEXT_NAME, width: 110, sortable: true, dataIndex: 'Name',
        renderer:function(value, md, record) {
          return '<a href=""javascript:void(0);"" class=""my-anchor"">'+value+'</a>';
        }
      },
      {header: TEXT_CREATED_ON, width: 150, sortable: true, renderer: Ext.util.Format.dateRenderer(TEXT_LONG_DATE_FORMAT), dataIndex: 'CreatedDate'}
      ,
      {header:'', width:30, renderer:savedSearchActionsRenderer}
    
    ]);
        
    gridSavedSearch_{control_id} = new Ext.grid.GridPanel({
      ds: ds,
      cm:cm,
      width: 250,
      height: 200,
      collapsible: false,
      border:false,
      columnLines:true,
      animCollapse: false,
      loadMask:true,
      iconCls: 'icon-grid',
      enableColumnHide:false,
      shadowOffset:12,
      enableHdMenu:false,
      plugins:expander
    });

    gridSavedSearch_{control_id}.getStore().load({params:params});
    
    listSavedSearchesWindow_{control_id} = new Ext.Window({
      el:'div-saved-search-list_{control_id}',
      layout:'fit',
      width:370,
      height:260,
      modal:true,
      title: TEXT_LOAD_SAVED_SEARCH,
      closeAction:'hide',
      plain: true,
      items: [gridSavedSearch_{control_id}],
      buttons: [{
        text: TEXT_OK,
        handler:function()
        {
          listSavedSearchesWindow_{control_id}.hide();
        }
      }]
    });

    gridSavedSearch_{control_id}.on('render', function(c){
      c.getEl().on('click', function(e, t){
        var row = gridSavedSearch_{control_id}.getView().findRowIndex(t);
        if(row !== false){
          var record = gridSavedSearch_{control_id}.getStore().getAt(row);
          // do something with record
          
          var myMask = new Ext.LoadMask(listSavedSearchesWindow_{control_id}.getEl());
          myMask.show();
          
          Ext.Ajax.request({
            url:'{virtual_folder}/AjaxServices/LoadSavedSearch.aspx',
            params:{SavedSearchID:record.get('Id')},
            failure:function(result, request){
              myMask.hide();
              Ext.MessageBox.show({
                      title:TEXT_ERROR,
                      msg:TEXT_ERROR_LOADING_SEARCH,
                      buttons:Ext.MessageBox.OK,
                      icon:Ext.MessageBox.ERROR
                    }); 
            },
            
            success:function(result,request)
            {
              //do something
              var searchFilters = Ext.util.JSON.decode(result.responseText);
              
              LoadFiltersFromSearch_{control_id}(searchFilters);
              
              myMask.hide();
              listSavedSearchesWindow_{control_id}.hide();
            }
          });
        }
      }, c, {delegate: 'a.my-anchor', stopEvent: true});
    });


  } //end if
  else{
    gridSavedSearch_{control_id}.getStore().load({params:params});
  }
  listSavedSearchesWindow_{control_id}.show(); 
  //configGridPanel_{control_id}.render();
}

function savedSearchActionsRenderer(value, metaData, record, rowIndex, colIndex, store)
{
  var str = String.format(""<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:deleteSavedSearch(\""{0}\"");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>"", record.data.Id, TEXT_DELETE);
  return str;
}

function deleteSavedSearch(id)
{
  Ext.Msg.show({
     title:TEXT_SAVE_SEARCH,
     msg: TEXT_DELETE_SEARCH_CONFIRM,
     buttons: Ext.Msg.YESNO,
     fn: function(btn, txt){
      if (btn == 'yes')
      {
          var params = {};
          params['delete'] = id;
          
          var myMask = new Ext.LoadMask(listSavedSearchesWindow_{control_id}.getEl());
          myMask.show();
          
          Ext.Ajax.request({
            url:'{virtual_folder}/AjaxServices/DeleteSavedSearch.aspx',
            params: params,
            failure:function(result,request){
              myMask.hide();
              Ext.MessageBox.show({
                      title:TEXT_ERROR,
                      msg:TEXT_ERROR_DELETING_SEARCH,
                      buttons:Ext.MessageBox.OK,
                      icon:Ext.MessageBox.ERROR
                    });  
            },
            success:function(result, request)
            {
              myMask.hide();
              
              if(result.responseText != 'OK')
              {
                Ext.MessageBox.show({
                      title:TEXT_ERROR,
                      msg:TEXT_ERROR_DELETING_SEARCH,
                      buttons:Ext.MessageBox.OK,
                      icon:Ext.MessageBox.ERROR
                    });  
              }
              else{
                gridSavedSearch_{control_id}.getStore().reload();
              }
            }
            
          });
      }
     },
     animEl: 'elId',
     icon: Ext.MessageBox.QUESTION
  });
}

function onSaveSearch_{control_id}(ev, toolEl, panel)
{  
  if(!windowSaveSearch_{control_id})
  {
      searchNameField_{control_id} = new Ext.form.TextField({
      fieldLabel: TEXT_SEARCH_NAME,
      width:200,
      allowBlank:false
    });
    
    searchDescriptionField_{control_id} = new Ext.form.TextArea({
      fieldLabel: TEXT_DESCRIPTION,
      width: 200,
      height: 100
    });
  
    windowSaveSearch_{control_id} = new Ext.Window({
    el:'div-save-search_{control_id}',
    layout:'form',
    width:330,
    height:210,
    modal:true,
    title: TEXT_SAVE_SEARCH,
    closeAction:'hide',
    plain: true,
    padding: 3,
    items: [searchNameField_{control_id}, searchDescriptionField_{control_id}],

    buttons: [{
        text: TEXT_OK,
        handler: function()
          {
            onOKSaveSearchClick_{control_id}(windowSaveSearch_{control_id}.items.items[0],windowSaveSearch_{control_id}.items.items[1]);
          },
        
        id: 'btnOK_SaveSearch_{control_id}'
      },
      {
        text: TEXT_CANCEL,
        id:'btnCancel_SaveSearch_{control_id}',
        handler:function()
        {
          windowSaveSearch_{control_id}.hide();
        }
      }]
  });
  }//end if
  else{
      for(i = 0, len = windowSaveSearch_{control_id}.items.length; i < len; i++){
	      windowSaveSearch_{control_id}.items.items[i].setValue('');
	      windowSaveSearch_{control_id}.items.items[i].clearInvalid();
  } 
  } 
  windowSaveSearch_{control_id}.show();
 
}
function onOKSaveSearchClick_{control_id}(searchField,descriptionField)
{
  if(!searchField.validate())
  {
    return;
  }
  SaveSearchResults_{control_id}(searchField,descriptionField)
}

function GetFiltersAsParamList_{control_id}(searchField,descriptionField)
{
  var i = 0;
  var maxFilterCount = filters_{control_id}.filters.keys.length;
  var params = {};
  
  while (i < maxFilterCount)
  {
    var filterName = filters_{control_id}.filters.keys[i];
    if ((Ext.get('filter_' + filterName + '_{control_id}')) /* || bInitialLoad*/)
    {
      var filter = filters_{control_id}.filters.items[i];
      
      var op = 'eq';
      if(filter.type == 'string')
      {
        op = 'lk';
      }
      
      //read the operation if it exists
      if(Ext.get('combo_filter_' + filterName + '_{control_id}-opValue'))
      {
        op = Ext.get('combo_filter_' + filterName + '_{control_id}-opValue').getValue();
      }
      
      var value1 = '';
      var value2 = '';
      
      // all except for Date read directly from the field
      if(filter.type != 'date')
      {
        if(filter.type == 'numeric')
        {
           //ranged numeric
          if(filter.rangeFilter)
          {
            value1 = Ext.get('filter_' + filterName + '_{control_id}-start-value').getValue();
            value2 = Ext.get('filter_' + filterName + '_{control_id}-end-value').getValue();
          }
          //regular numeric
          else{
            value1 = Ext.get('filter_' + filterName + '_{control_id}-value').getValue();
            op = Ext.get('filter_' + filterName + '_{control_id}-opValue').getValue();
          }
        }
        else
        {
          //ranged string
          if(filter.type == 'string' && filter.rangeFilter)
          {
            value1 = Ext.get('filter_' + filterName + '_{control_id}-start-value').getValue();
            value2 = Ext.get('filter_' + filterName + '_{control_id}-end-value').getValue();
          }
          //all other types, except for numeric and date
          else
          {
            value1 = Ext.get('filter_' + filterName + '_{control_id}').getValue();
            
            // additionally for combos and account types, read the display values into value2
            if((filter.type == 'combo') || (filter.type == 'account'))
            {
              value2 = Ext.get('combo_filter_' + filterName + '_{control_id}').getValue();
            }
          }    
        }  
      }
      // dates are read from start and end date fields
      else
      {
        value1 = Ext.get('filter_' + filterName + '_{control_id}-start-date').getValue();
        value2 = Ext.get('filter_' + filterName + '_{control_id}-end-date').getValue();
      }
         
      params['filter[' + i + '][field]'] = filter.dataIndex;
      params['filter[' + i + '][operation]'] = op;
      params['filter[' + i + '][visible]'] = filter.showFilter;
      params['filter[' + i + '][data][type]'] = filter.type;
      params['filter[' + i + '][data][value]'] = value1;
      params['filter[' + i + '][data][value2]'] = value2;
    }
    
    i++;
  }
 
  params['page_url'] = '{page_url}';
  params['search_name'] = searchField.getValue();
  params['description'] = descriptionField.getValue();
  params['grid_id'] = '{grid_id}';
  params['search_layout'] = '{template_xml}';
  return params;
}

function SaveSearchResults_{control_id}(searchField,descriptionField)
{
  var params = GetFiltersAsParamList_{control_id}(searchField,descriptionField);
  var myMask = new Ext.LoadMask(windowSaveSearch_{control_id}.getEl());
  myMask.show();
  
  Ext.Ajax.request({
    url:'{virtual_folder}/AjaxServices/SaveSearchParameters.aspx',
    params: params,
    failure:function(result,request){
      myMask.hide();
      Ext.MessageBox.show({
              title:TEXT_ERROR,
              msg:TEXT_ERROR_SAVING_SEARCH,
              buttons:Ext.MessageBox.OK,
              icon:Ext.MessageBox.ERROR
            });  
            
    },
    success:function(result, request)
    {
      myMask.hide();
      if(result.responseText != 'OK')
      {
        Ext.MessageBox.show({
              title:TEXT_ERROR,
              msg:TEXT_ERROR_SAVING_SEARCH,
              buttons:Ext.MessageBox.OK,
              icon:Ext.MessageBox.ERROR
            });      
      }
      else{
        windowSaveSearch_{control_id}.hide();
        return;
      }
    } //end success
    
  }); //end ajax request
}

";

        protected string SCRIPT_QUICK_EDIT = @"
        var editRecordWindow_{control_id};
    function editItem_{control_id}(accID) {
      var record = dataStore_{control_id}.getById(accID);

      if (!editRecordWindow_{control_id}) 
      {
        editRecordWindow_{control_id} = new Ext.Window({
          el: 'div-editRecordWindow_{control_id}',
          cls: 'x-small-editor',
          layout: 'form',
          floating: true,
          width: 450,
          height: 300,
          modal: true,
          title: TEXT_EDIT_RECORD,
          closeAction: 'hide',
          plain: true,
          resizable:false,
          items: [{
          xtype: 'form',
            labelWidth:140,
            autoScroll  : true,
            id: 'formpanel',
            height: 240,
            frame:true,
            border:false
          }],
          buttons: [{
            text: TEXT_UPDATE,
            handler: function(obj) {
              editRecord_onUpdate_{control_id}(record);
            }
          }
          ,
          {
            text: TEXT_CANCEL,
            handler: function(obj) {
              editRecord_onCancel_{control_id}();
            }
          }]//end buttons
        });   //end window
      }

      editRecordWindow_{control_id}.render(document.body);

      //clear the form
      var myForm = editRecordWindow_{control_id}.items.get('formpanel');
      if(myForm.items.getCount() != 0){ 
        while (myForm.items.getCount() > 0) {
          myForm.remove(myForm.items.items[0]);
        }
      }

      addItemsToEdit_{control_id}(record);

      editRecordWindow_{control_id}.doLayout();

      editRecordWindow_{control_id}.show(true);
    }
    function editRecord_onCancel_{control_id}()
    {
      editRecordWindow_{control_id}.hide();
    }

    function editRecord_onUpdate_{control_id}(record)
    {
      var params = prepareEditParams_{control_id}(record);
      addCustomEditParams_{control_id}(record,params);
      
      Ext.Ajax.request({
        method:'POST',
        url: '{update_url}',
        params: params,
        failure: onEditRecordUpdateFailure_{control_id},
        success: onEditRecordUpdateSuccess_{control_id}
      });
    }

    function onEditRecordUpdateFailure_{control_id}(result, request) {
      Ext.MessageBox.show({
                  title: TEXT_ERROR,
                  msg: TEXT_ERROR_RECEIVING_DATA,
                  buttons: Ext.MessageBox.OK,
                  icon: Ext.MessageBox.ERROR
                });
    } 
    
    function onEditRecordUpdateSuccess_{control_id}(result, request) {
      editRecordWindow_{control_id}.hide();
    }
    
    function prepareEditParams_{control_id}(record)
    {
      var params = {};
      params['_id'] = record.id;
      var myForm = editRecordWindow_{control_id}.items.get('formpanel');

      for (var i = 0; i < myForm.items.getCount(); i++) 
      {
        var ctrl = myForm.items.get(i);
        var key = ctrl.id.replace('editor_', '');

        if (ctrl.controlType == 'account') 
        {
          key = ctrl.hiddenId.replace('editor_', '');
          var hiddenCtrl = Ext.get(ctrl.hiddenId);
          if (hiddenCtrl != null) {
            params[key] = hiddenCtrl.getValue();
          }
        }
        else 
        {
          params[key] = ctrl.getValue();
        }
      }

      return params;
    }
    
    //override this function to add more properties for quick edit form submission
    function addCustomEditParams_{control_id}(record, params)
    {}

    function addItemsToEdit_{control_id}(record) {

      var myForm = editRecordWindow_{control_id}.items.get('formpanel');

      for (var i = 0; i < columnArr_{control_id}.length; i++) {
        var el = columnArr_{control_id}[i];
        if (el.editor) {
          if (el.dataIndex) {
            var curFilter = GetFilterByName_{control_id}(el.dataIndex.replace('ValueDisplayName', ''));

            //if(curFilter.type != 'boolean')
            switch (curFilter.type) {
              case 'numeric':
              case 'date':
              case 'string':
              case 'list':
                var fieldValue = record.get(el.dataIndex);
                var tb = el.editor.field.cloneConfig();
                tb.setWidth(200);
                tb.setValue(fieldValue);

                //if date picker
                if (curFilter.type == 'date') {
                  tb.setValue(new Date(fieldValue));
                }
                if (curFilter.type == 'list') {
                  var options = curFilter.options;
                  for (var j = 0; j < options.length; j++) {
                    if (options[j][1] == fieldValue) {
                      tb.setValue(options[j][0]);
                      //break;
                    }
                  }
                }

                tb.fieldLabel = el.header;
                tb.id = 'editor_' + el.dataIndex;

                myForm.add(tb);
                break;

              case 'boolean':
                var tb = new Ext.form.Checkbox({
                  id: 'editor_' + el.dataIndex,
                  boxLabel: el.header,
                  checked: record.get(el.dataIndex)
                });
                myForm.add(tb);
                break;

              case 'account':
                var fieldValue = record.get(el.dataIndex);

                var tb = GetAccountPicker_{control_id}(el.dataIndex, curFilter.filterLabel);
                tb.setWidth(200);
                tb.id = 'editorcombo_' + el.dataIndex;
                tb.name = tb.id;
                tb.hiddenId = 'editor_' + el.dataIndex;
                tb.hiddenName = tb.hiddenId;
                tb.fieldLabel = curFilter.filterLabel;
                tb.controlType = 'account';
                tb.setValue(fieldValue);
                tb.on('render', function(combo) {
                  combo.el.dom.value = '';
                  var fv = combo.getValue();
                  if (fv != null) {
                    if (!isNaN(fieldValue)) {
                      combo.hiddenField.value = fieldValue;
                    }
                  }

                  if (fv != null) {
                    var myMask = new Ext.LoadMask(editRecordWindow_{control_id}.getEl());
                    myMask.show();

                    Ext.Ajax.request({
                      url: '/MetraNet/AjaxServices/GetAccountStringById.aspx',
                      params: { AccountID: fv },
                      success: function(result, request) {
                        combo.el.dom.value = result.responseText;
                        myMask.hide();
                      },
                      failure: function(result, request) {
                        myMask.hide();
                      }
                    });
                  }
                }, this);

                myForm.add(tb);
                break;
            } //end switch

          } //if (el.dataIndex) {
        } //if (el.editor) {
      } //for 
      addCustomQuickEditItems_{control_id}(myForm);
    }
    
    //override this function to add more items to quick edit form
    function addCustomQuickEditItems_{control_id}(form) {
      
    }

    Ext.onReady(function() {
      grid_{control_id}.on('cellcontextmenu', function(grid, rowIndex, cellIndex, e) {
        var record = grid.getStore().getAt(rowIndex);

        var menu = new Ext.menu.Menu({
          itemId: 'editMenu',
          items: [{
            iconCls: 'edit',
            text: TEXT_EDIT_RECORD,
            handler: function() {
              editItem_{control_id}(record.id);
            }
          }]
        });

        addExtraQuickEditMenuItems_{control_id}(menu);
        e.stopEvent();
        menu.showAt(e.getXY());

      }, this);
      
      //override to add more items to the quick edit popup menu
      function addExtraQuickEditMenuItems_{control_id}(menu) {}
    });
";

        protected string SCRIPT_MAIN = @"
	<script type=""text/javascript"">
var arrAsyncCalls_{control_id} = new Array({num_list_elements});
var asyncCallsCompleted_{control_id} = 0;
var expander_{control_id};
var filters_{control_id};
var columnModel_{control_id};
var dataStore_{control_id};
var grid_{control_id};
var nested_grid_{control_id};
var tbar_{control_id};
var bbar_{control_id};
var filterPanel_{control_id};
var useFilters_{control_id} = {use_filters};
var filterPanelColumnLayout_{control_id} = '{filter_panel_layout}';
var windowConfigFilters_{control_id};
var windowConfigColumns_{control_id};
var configGridPanel_{control_id};
var configColumnsGridPanel_{control_id};
var cookiePrefix_{control_id};
var filterArr_{control_id};
var columnArr_{control_id};
var search_on_load_{control_id} = {search_on_load};
var enumOptions_{control_id} = new Array();
var defaultOption_{control_id} = new Array();
var supportQuickEdit_{control_id} = {support_quick_edit};
var gridView_{control_id};

{saved_search_code}

function LoadFiltersFromSearch_{control_id}(searchFilters)
{
  onClear_{control_id}();
  for(var i = 0 ; i < searchFilters.Items.length; i++)
  {
    var savedFilter =  searchFilters.Items[i];
    var curFilter = GetFilterByName_{control_id}(savedFilter.Name);
    if(curFilter != null)
    {
      curFilter.position = i;
      
    
      if(curFilter.type!= 'account' && curFilter.type != 'list' && curFilter.type != 'boolean')
      {
        if(curFilter.type == 'date'){
          Ext.getCmp('filter_' + savedFilter.Name + '_{control_id}').setStartDate(savedFilter.Value);
          Ext.getCmp('filter_' + savedFilter.Name + '_{control_id}').setEndDate(savedFilter.Value2);
        }
        else{
          Ext.getCmp('filter_' + savedFilter.Name + '_{control_id}').setValue(savedFilter.Value);
        }     
      }
      
      else{
        if(curFilter.type == 'list' || curFilter.type == 'boolean')
        {
          Ext.getCmp('combo_filter_' + savedFilter.Name + '_{control_id}').setValue(savedFilter.Value);
        }
        else{
                //Core-5844 Fix for Oracle
              if (savedFilter.Value == null)
              {
                  Ext.get('filter_' + savedFilter.Name + '_{control_id}').dom.value = '';
                  Ext.get('combo_filter_' + savedFilter.Name + '_{control_id}').dom.value = ''; 
              }
              else
              {
                  Ext.get('filter_' + savedFilter.Name + '_{control_id}').dom.value = savedFilter.Value;
                  Ext.get('combo_filter_' + savedFilter.Name + '_{control_id}').dom.value = savedFilter.Value2;  
              }      
        }
      }
    
      //set operation for numerics and lists
      if(curFilter.type == 'numeric' || curFilter.type == 'list')
      {
        if(curFilter.type == 'list')
        {
          if(Ext.getCmp('combo_filter_' + savedFilter.Name + '_{control_id}-opText'))
          {
            Ext.getCmp('combo_filter_' + savedFilter.Name + '_{control_id}-opText').setValue(savedFilter.Operation);
          }
        }
        //type = numeric
        else
        {
          Ext.getCmp('filter_' + savedFilter.Name + '_{control_id}-opText').setValue(savedFilter.Operation);
        }
      }
    
      showHideFilter_{control_id}(savedFilter.Name, savedFilter.IsVisible);
    }
  }
  
    //save filter position
  SavePositionToCookie_{control_id}();

  //redraw filters   
  ResetFilters_{control_id}();
  
  PerformSearch_{control_id}(false);  
}

function GetColumnByID_{control_id}(dataIndex)
{
  if(columnModel_{control_id} == null)
  {
    return null;
  }
  
  var columnCount = columnModel_{control_id}.getColumnCount();
  
  for(var i = 0; i < columnCount; i++)
  {
    var columnID = columnModel_{control_id}.getColumnId(i);
    var column = columnModel_{control_id}.getColumnById(columnID);
    if(column.id == dataIndex)
    {
      return column;
    }
  }
  return null;
}

function InitColumnPosition_{control_id}()
{
  var columnCount = columnModel_{control_id}.getColumnCount();

  for(var i = 0; i < columnCount; i++)
  {
    var column = columnModel_{control_id}.config[i];
    column.position = i;
  }
}

function GetColumnByPosition_{control_id}(posIndex)
{
  if(posIndex < 0)
  {
    return null;
  }
  var columnCount = columnModel_{control_id}.getColumnCount();
  if(posIndex > columnCount)
  {
    return null;
  }
  for(var i = 0; i < columnCount; i++)
  {
    var column = columnModel_{control_id}.config[i];
    if(column.position == posIndex)
    {
      return column;
    }
  }
  return null;
  
}

function GetFilterByPosition_{control_id}(posIndex)
{
  if((posIndex < 0) || (posIndex >= filterArr_{control_id}.length))
  {
    return null;
  }
  
  for (var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    if(filters_{control_id}.filters.items[i].position == posIndex)
    {
      return filters_{control_id}.filters.items[i];
    }
  }
  
  return null;
}

function GetFilterByName_{control_id}(name)
{
  if(name == '')
  {
    return null;
  }
  
  for (var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    if(filters_{control_id}.filters.items[i].dataIndex == name)
    {
      return filters_{control_id}.filters.items[i];
    }
  }
  
  return null;
}

function GetFilterArrElementByName_{control_id}(name)
{
  if(name == '')
  {
    return null;
  }
  
  for (var i = 0; i < filterArr_{control_id}.length; i++)
  {
    if(filterArr_{control_id}[i].dataIndex == name)
    {
      return filterArr_{control_id}[i];
    }
  }
  
  return null;
}

function ValidateFilters_{control_id}()
{
  var bValid = true;
  
  for(var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    var curFilter = filters_{control_id}.filters.items[i];
    
    if(curFilter != null)
    {
      if (curFilter.showFilter)
      {
        var filterCmp;
        
        //assume same processing for now
        switch(curFilter.type)
        {
          case 'string':
          case 'numeric':
          case 'date':
            filterCmp = Ext.getCmp('filter_' + curFilter.dataIndex + '_{control_id}');
            
            if(filterCmp != null)
            {
              filterCmp.clearInvalid();
              
              if (!filterCmp.validate())
              {
                bValid = false;
              }        
            }            
            
            break;
            
          case 'list':
          case 'boolean':
            filterCmp = Ext.getCmp('combo_filter_' + curFilter.dataIndex + '_{control_id}');
            if(filterCmp != null)
            {
              filterCmp.clearInvalid();
              if( !filterCmp.allowBlank && (filterCmp.getValue() == ''))
              {
                filterCmp.markInvalid(filterCmp.blankText);
                bValid = false;                
              }
            }
            
            break;
        
          case 'account':
            filterCmp = Ext.getCmp('combo_filter_' + curFilter.dataIndex + '_{control_id}');
            if(filterCmp != null)
            {
              filterCmp.clearInvalid();
              
              if (!filterCmp.validate())
              {
                bValid = false;
              }        
            }            
            
            break;  

        }
      }
    }
  }
  
  return bValid;
}


//position cookie is a comma separated list of data indices
//validation will first check if the number of items in the cookie equals to the length of the filter array
//and then for each item in  the cookie, attempt to find a corresponding existing filter. 
//Validation is necessary in cases where ASPX file contains a different set of filters.
function ValidatePositionCookie_{control_id}()
{
  var positionCookieVal = Cookies.get(cookiePrefix_{control_id} + 'filters');
  if((positionCookieVal == null) || (positionCookieVal == ''))
  {
    return false;
  }
  
  var arrPosCookies = positionCookieVal.split(',');
  if(arrPosCookies.length <= 0)
  {
    return false;
  }
  
  if (arrPosCookies.length != filterArr_{control_id}.length)
  {
    return false;
  }
  
  for (var i = 0; i < arrPosCookies.length; i++)
  {
  
    //split up name from showFilter flag
    var arrCurElement = arrPosCookies[i].split(':');
      
    if(arrCurElement.length != 2)
    {
      return false;
    }
    
    var curName = arrCurElement[0];
    var curShowFilter = arrCurElement[1];
    
    if((curShowFilter != '0') && (curShowFilter != '1'))
    {
      return false;
    }
  
    if (GetFilterArrElementByName_{control_id}(curName) == null)
    {
      return false;
    }
  }
  
  return true;
}


/*
Read cookie value, and iterate through elements.
For each one, find the filter and set position to current index of the cookie item.
*/
function LoadPositionFromCookie_{control_id}()
{
  var cookieData = Cookies.get(cookiePrefix_{control_id} + 'filters');
  if ((cookieData == null) || (cookieData == ''))
  {
    return;
  }
  
  var arrPosCookies = cookieData.split(',');  
  var realIndex = 0;
  
  for (var i = 0; i < arrPosCookies.length; i++)
  {
    //split up name from showFilter flag
    var arrCurElement = arrPosCookies[i].split(':');
    
    if(arrCurElement.length != 2)
    {
      continue;
    }
    
    var curName = arrCurElement[0];
    var curShowFilter = (arrCurElement[1] == '1') ? true : false;
  
    var curFilter = GetFilterArrElementByName_{control_id}(curName);
    if (curFilter == null)
    {
      continue;
    }
    
    curFilter.position = realIndex;
    curFilter.showFilter = curShowFilter;
    
    realIndex++;
  }
}

/*
Cookie will contain the comma-separated string of data indices followed by showFilter flag, represented by 0 or 1.
Iterate through available positions and find the filter at that position
*/
function SavePositionToCookie_{control_id}()
{
  var cookieData = '';
  
  for(var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    var curFilter = GetFilterByPosition_{control_id}(i);
    
    if(curFilter != null)
    {
      if(i > 0)
      {
        cookieData += ',';
      }
      var showFilter = (curFilter.showFilter) ? 1 : 0;
      
      cookieData += curFilter.dataIndex + ':' + showFilter; 
    }  
  }
  
  Cookies.set(cookiePrefix_{control_id} + 'filters', cookieData);
}


function Initialize_{control_id}()
{
  filterArr_{control_id} =[
    {grid_filters}
  ];

  if(!ValidatePositionCookie_{control_id}()){
    Cookies.clear();
  }else{
    LoadPositionFromCookie_{control_id}();
  }  
  
  filters_{control_id} = new Ext.ux.grid.GridFilters({filters:filterArr_{control_id}}); 

  
  var searchButton = new Ext.Button({
    text:TEXT_SEARCH,
    xtype:'button',
    handler:onSearch_{control_id}
   });

  var clearButton = new Ext.Button({
    id:'clear_button',
    text:TEXT_CLEAR,
    xtype:'button',
    handler:onClear_{control_id}
   }); 
   
  filterPanel_{control_id} = new Ext.Panel({
    labelWidth:75,
    iconCls:'icon-magnifier',
    id:'filterPanel1_div_{control_id}',
    collapsible:true,
    collapsed:false,
    frame:true,
    {grid_width}
    title:TEXT_SEARCH_FILTERS,
    buttonAlign:'center',
    buttons: [searchButton, clearButton],
    tools:[{filter_config_tool}]
  });  
}

function onClear_{control_id}()
{
  var maxFilterCount = filters_{control_id}.filters.keys.length;
  var i = 0;
  var filterName;
  
  while (i < maxFilterCount)
  {
    var filter = filters_{control_id}.filters.items[i];

    if(!filter.readonly)
    {
      ClearFilter_{control_id}(filter);
    }
    i++;
  }
}

function resetControl_{control_id}(ctrlName)
{
  var ctrl = Ext.getCmp(ctrlName);
  if (ctrl != null)
  {
    //reset field
    ctrl.setValue('');

    //reset operation
    if(ctrl.opField != null)
    {
      ctrl.opField.setValue('eq');
    }
  }
}

//Trigger reload/requery of the grid
function Reload_{control_id}()
{ 
  //make results pane visible, it could be hidden if not searching on load
  if (!grid_{control_id}.isVisible())
  {
    grid_{control_id}.setVisible(true);
  }

  BeforeSearch_{control_id}();

  var bInitialLoad = false;
  PerformSearch_{control_id}(bInitialLoad);

  AfterSearch_{control_id}();
}

//handler for the search button
function onSearch_{control_id}()
{
  Reload_{control_id}();
}

function BeforeSearch_{control_id}()
{
}

function AfterSearch_{control_id}()
{
}


var loadStoreTimer = null;

function LoadStoreWhenReady_{control_id}() {
    var paramsDataSource = getDataSourceUrlParams_{control_id}({{data_source_url_params}start: 0, limit: {page_size}});
     
    if(flagOkLoadStore == 'undefined')
    {
      dataStore_{control_id}.load({params: paramsDataSource});   
      return;
    }

    if(flagOkLoadStore == 'true')
    {
      dataStore_{control_id}.load({params: paramsDataSource});       
    }
    else
    {
      loadStoreTimer = setTimeout('LoadStoreWhenReady_{control_id}();', 100);
    }   
  
};
/*
  Read out filter values and use them
  to perform the search
*/
function PerformSearch_{control_id}(bInitialLoad){
  
  //validate filters, and exit if failed validation.  
  if(!bInitialLoad)
  {
    if(!ValidateFilters_{control_id}())
    {
      return false;
    }
  }

  var bFiltersSelected = false;
  var maxFilterCount = filters_{control_id}.filters.keys.length;
  var i = 0;

  while (i < maxFilterCount)
  {
    var filterName = filters_{control_id}.filters.keys[i];
    if ((Ext.get('filter_' + filterName + '_{control_id}')) || bInitialLoad)
    {
      var filter = filters_{control_id}.filters.items[i];
      
      if (filter.type == 'date')
      {
        //process start date
        var bUseDateFilter = processDateFilter_{control_id}(filter, filterName, 'after', bInitialLoad);
        bFiltersSelected = bFiltersSelected || bUseDateFilter;
        
        //process end date
        bUseDateFilter = processDateFilter_{control_id}(filter, filterName, 'before', bInitialLoad); 
        bFiltersSelected = bFiltersSelected || bUseDateFilter;     
      }
      
      if(filter.type == 'boolean')
      {
        var filterValue;
        
        if(bInitialLoad){
          filterValue = filter.value;
        }else{
          filterValue = Ext.get('filter_' + filterName + '_{control_id}').getValue();
        }
        
        if ((filterValue != null) && (filterValue != ''))
        {
          if (filterValue == '0')
            filter.setValue(0);
          else
            filter.setValue(1);

          //activate filter ONLY if filter is visible
          filter.setActive(filter.showFilter);
          bFiltersSelected = bFiltersSelected || filter.showFilter;
        }
        else
        {
          filter.setActive(false);
        }
      }   

      if(filter.type == 'string')
      {
        if(!filter.rangeFilter)
        {
          var filterValue;

          if (bInitialLoad) {
            filterValue = filter.filterValue;
          } else {
            filterValue = Ext.getCmp('filter_' + filterName + '_{control_id}').getValue();
          }

          if ((filterValue != null) && (filterValue != ''))
          {
            var objData = new Object();
            objData.lk = filterValue;
            filter.setValue(objData);

            //activate filter ONLY if filter is visible
            filter.setActive(filter.showFilter);
            bFiltersSelected = bFiltersSelected || filter.showFilter;
          }
          else
          {
            filter.setActive(false);
          }
        }
        else{
          processRangeFilter_{control_id}(filter, filterName, 'gte', bInitialLoad);
          processRangeFilter_{control_id}(filter, filterName, 'lte', bInitialLoad);
          bFiltersSelected = true;
        }
      }
      if (filter.type == 'list') 
      {
        var filterValue;
        
        if(bInitialLoad){
          filterValue = filterArr_{control_id}[i].filterValue;
        }
        else
        {
          if(filter.multiValue)
          {
            //read from multi-value dropdown
            filterValue = Ext.getCmp('filter_' + filterName + '_{control_id}').getValue();
          }
          else
          {
            //read from regular dropdown
            filterValue = Ext.get('filter_' + filterName + '_{control_id}').getValue();
          }
        }
        
        if ((filterValue != null) && (filterValue != ''))
        {
          var objData = new Object();

          if(filter.multiValue)
          {
            objData.eq = filterValue;
          }
          else{
            if(Ext.getCmp('combo_filter_' + filterName + '_{control_id}') != null)
            {
              var filterOp = Ext.getCmp('combo_filter_' + filterName + '_{control_id}').getOperation();
              eval('objData.' + filterOp + '= filterValue;');
            }
          }
          filter.setValue(objData);

          //activate filter ONLY if filter is visible
          filter.setActive(filter.showFilter);
          bFiltersSelected = bFiltersSelected || filter.showFilter;
        }
        else
        {
          filter.setActive(false);
        }
      }

      if (filter.type == 'account')
      {
        var filterValue;
        
        if(bInitialLoad){
          filterValue = filterArr_{control_id}[i].filterValue;
        }else{
          var comboBox = Ext.getCmp('combo_filter_' + filter.dataIndex + '_{control_id}');
          filterValue = comboBox.value;

          if((filterValue === undefined) || (filterValue == ''))
          {
            filterValue = Ext.get('combo_filter_' + filter.dataIndex + '_{control_id}').dom.value;
          }

          if((filterValue !== undefined) && (filterValue != ''))
          {
            //check if value contains parenthesis, e.g. it's in format UserName(accID)..If so, extract AccID
            var accIDregex = new RegExp('.*\\((\\d+)\\)');
            var fv = filterValue + '';
            var matches = fv.match(accIDregex);
            if (matches != null)
            {
              if (matches.length > 1)
              {
                //set filter value to the last match, there should be two if there is a match.
                filterValue = matches[matches.length - 1];
              }
            }
          }
          
          if((filterValue === undefined) || (filterValue == ''))
          {
            filterValue = Ext.get('filter_' + filterName + '_{control_id}').getValue();
          }

        }
        
        if ((filterValue != null) && (filterValue != ''))
        {
          var objData = new Object();
          objData.eq = filterValue;
          filter.setValue(objData);

          //activate filter ONLY if filter is visible
          filter.setActive(filter.showFilter);
          bFiltersSelected = bFiltersSelected || filter.showFilter;
        }
        else
        {
          filter.setActive(false);
        }
      }

      if (filter.type == 'numeric')
      {
        if (!filter.rangeFilter) {
          var filterValue;

          if (bInitialLoad) {
            filterValue = filter.filterValue;
          } else {
            filterValue = Ext.getCmp('filter_' + filterName + '_{control_id}').getValue();
          }

          if ((filterValue != null) && (filterValue !== '')) {
            var objData = new Object();
            var filterOp = Ext.getCmp('filter_' + filterName + '_{control_id}').getOperation();
            eval('objData.' + filterOp + '= filterValue;');
            filter.setValue(objData);

            //activate filter ONLY if filter is visible
            filter.setActive(filter.showFilter);
            bFiltersSelected = bFiltersSelected || filter.showFilter;
          }
          else {
            filter.setActive(false);
          }
        } // end rangeFilter
        else {
          processRangeFilter_{control_id}(filter, filterName, 'gte', bInitialLoad);
          processRangeFilter_{control_id}(filter, filterName, 'lte', bInitialLoad);
          bFiltersSelected = true;
      
        }
      }//end filtertype ==  numeric
    }  // ext.get(filterName)
    
    i++;
  }//end while

  //reload the search
 // var paramsDataSource = getDataSourceUrlParams_{control_id}({{data_source_url_params}start: 0, limit: {page_size}});
  //dataStore_{control_id}.load({params:{{data_source_url_params}start: 0, limit: {page_size}}});
  

//dataStore_{control_id}.load({params: paramsDataSource});
if(bInitialLoad && (flagOkLoadStore == 'true'))
{
  setTimeout(function() { dataStore_{control_id}.load({params:{{data_source_url_params}start: 0, limit: {page_size}}});  } , 1000);
}
else
{
LoadStoreWhenReady_{control_id}();
}
}//end on search

//Used to retrieve the url parameters for the ajax call
//Can be overwridden on the page to add additional, dynamic values
getDataSourceUrlParams_{control_id} = function(paramsBase) {
  
  var newParams = paramsBase;
  //newParams.RequestDate = 'Now';
  //newParames.MyAjaxParam = 'MyValue1';

  return newParams;
}

processRangeFilter_{control_id} = function(filterObj, filterName, key, bInitialLoad) {
  var prefix = (key == 'lte') ? '-end-value' : '-start-value';

  var filterValue;

  if (bInitialLoad) {
    filterValue = (key == 'gte') ? filterObj.filterValue : filterObj.filterValue2;
  } else {
    filterValue = Ext.get('filter_' + filterName + '_{control_id}' + prefix).getValue();
  }

  if ((filterValue != null) && (filterValue != '')) {

    filterObj.menu.fields[key].setValue(filterValue)

    filterObj.setActive(filterObj.showFilter);
    return filterObj.showFilter;
  }

  else {
    filterObj.menu.fields[key].setValue('')
  }

  return false;
}


//sets or resets the showFilter flag of a given filter
function showHideFilter_{control_id}(filterName, bShow)
{
  for (var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    var curFilter = filters_{control_id}.filters.items[i];
    if(curFilter.dataIndex.toLowerCase() == filterName.toLowerCase())
    {
      curFilter.showFilter = bShow;
    }
  }
}
 
//Direction:  0=up, 1=down
function onUpDownClick_{control_id}(direction, rowIndex)
{
  var store = configGridPanel_{control_id}.store;
  var data = store.data;
  var substRowIndex = (direction == 0) ? rowIndex -  1 : rowIndex + 1;
  
  var curRecord = data.get(rowIndex);
  var substRecord = data.get(substRowIndex);
  
  //swap positions  
  var curPos = curRecord.data.position;
  var substPos = substRecord.data.position;
  
  var tempPos = curPos;
  curRecord.data.position = substRecord.data.position;
  substRecord.data.position = tempPos;
  
  //update position in filters collection
  var curRowFilter = GetFilterByPosition_{control_id}(rowIndex);
  var substRowFilter = GetFilterByPosition_{control_id}(substRowIndex);
  curRowFilter.position = curRecord.data.position;
  substRowFilter.position = substRecord.data.position;  

  store.sort('position','ASC');
}

function downRenderer_{control_id}(value, meta, record, rowIndex, colIndex, store)
{
  //nothing for the last record
  if(rowIndex == store.data.length - 1)
  {
    return '';
  }
  
  var str = String.format(""<a href='javascript:onUpDownClick_{control_id}(1,{0});'>{1}</a>"", rowIndex, 'DOWN');

  return str;
}
function upRenderer_{control_id}(value, meta, record, rowIndex, colIndex, store)
{
  //nothing for the first record
  if(rowIndex == 0)
  {
    return '';
  }
  
  var str = String.format(""<a href='javascript:onUpDownClick_{control_id}(0,{0});'>{1}</a>"", rowIndex, 'UP');

  return str;  
}

function onColumnSetup_{control_id} (ev, toolEl, panel)
{
  if(!windowConfigColumns_{control_id}){
    configColumnsGridPanel_{control_id} = new Ext.tree.TreePanel({
      useArrows:true,
      autoScroll:true,
      animate:true,
      lines:false,
      enableDD:true,
      containerScroll: true, 
      loader: new Ext.tree.TreeLoader(),
      root:new Ext.tree.TreeNode({
        text: TEXT_COLUMN_CONFIG_PROMPT,
        draggable:false,
        expanded:true,
        leaf:false,
        loaded:true,
        iconCls:'x-hide-display',
        icon:'',
        cls:'x-tree-selected',
        isTarget:false,
        checked:false,
        id:'rootNode'
      })
    });

    configColumnsGridPanel_{control_id}.getRootNode().getUI().childIndent = '';

    //do not collapse the fake root node
    configColumnsGridPanel_{control_id}.on('beforecollapsenode', function(node, deep, anim){
      if(node == configColumnsGridPanel_{control_id}.getRootNode())
      {
        return false;
      }
    },this);

    var arrSortedColumns = [];
    var cookieName = cookiePrefix_{control_id} + 'columns';
    if (ValidateCookie_{control_id}(cookieName, columnArr_{control_id}, 'id'))
    {
      LoadColumnsFromCookie_{control_id}(cookieName, columnArr_{control_id}, arrSortedColumns);
    }
    else{
      arrSortedColumns = columnArr_{control_id};
    }  

    //select all/deselect all filters, skipping the ones that cannot be hidden
    configColumnsGridPanel_{control_id}.getRootNode().on('checkchange', function(node, bChecked){
      //iterate through all children and set their checked status to bChecked
      for (var i = 0; i < node.childNodes.length; i++)
      {
        var curColumn = arrSortedColumns[i];
        var isHideable = (curColumn.hideable === undefined) ? true : curColumn.hideable;
        
        //do not uncheck special columns
        if( ((curColumn.id == 'checker') || (curColumn.id == 'expander') || (curColumn.key == 'expander')) && (!bChecked))
        {
          continue;
        }

        //do not uncheck the non-hideable filters
        if(!isHideable && !bChecked)
        {
          continue;
        }

        node.childNodes[i].ui.toggleCheck(bChecked);
      }
    },this);

    //iterate through columns and add them to the tree
    for (var i = 0; i < arrSortedColumns.length; i++)
    {
      var curElement = arrSortedColumns[i];
      var headerText = ((curElement.id == 'checker') || (curElement.id == 'expander')|| (curElement.key == 'expander') || (curElement.header == '')) ? curElement.id : curElement.header;
      var nodeId = ((curElement.id == 'checker') || (curElement.key == 'expander')|| (curElement.id == 'expander')) ? curElement.id : curElement.id;

      //determine visible state
      var isVisible = (curElement.hidden === undefined) ? true : (!curElement.hidden);
      var isHideable = (curElement.hideable === undefined) ? true : curElement.hideable;     
      
      if((curElement.id == 'checker') || (curElement.key == 'expander')|| (curElement.id == 'expander'))
      {
        isHideable = false;
      }

      var treeNode = new Ext.tree.TreeNode({
        text : headerText,
        expandable:false,
        leaf:true,
        draggable:true,
        checked: (isHideable ? isVisible : undefined),
        iconCls:(isHideable ? 'x-hide-display': 'x-mt-checkbox-disabled'), 
        icon:'',
        allowDrag:true,
        id:nodeId
      });
      
      treeNode.position = i;
      
      //node double click should do the same as check change
      treeNode.on('dblclick', function(node, e){
        node.fireEvent('checkchange',node, node.getUI().isChecked());
      });

      //block unchecking the node that corresponds to un-hideable column
      treeNode.on('checkchange', function(node, bChecked){
        //cannot uncheck special columns
        if((node.id == 'checker')|| (node.key == 'expander') || (node.id == 'expander'))
        {
          if(!node.getUI().isChecked())
          {
            node.ui.toggleCheck(true);
          }
          return;
        }
        
        var curColumn = GetColumnByID_{control_id}(node.id);
        if (curColumn != null)
        {        
          var isHideable = (curColumn.hideable === undefined) ? true : curColumn.hideable;
          if (!isHideable && !bChecked)
          {
            if(!node.getUI().isChecked())
            {
              node.ui.toggleCheck(true);
            }
            return;
          }
        }
      });
      configColumnsGridPanel_{control_id}.getRootNode().appendChild(treeNode);
    }


    windowConfigColumns_{control_id} = new Ext.Window({
      el:'div-column-config_{control_id}',
      layout:'fit',
      width:330,
      height:300,
      modal:true,
      title: TEXT_CONFIGURE_COLUMNS,
      closeAction:'hide',
      plain: true,
      
      items: [configColumnsGridPanel_{control_id}],

      buttons: [{
        text: TEXT_OK,
        handler: onOKcolumnConfigClick_{control_id}
      }]
    });

  }
  //the window has already been created, we just need to refresh the grid inside to reflect
  //the correct order of the items.
  else
  {    
    for(var i = 0; i < configColumnsGridPanel_{control_id}.getRootNode().childNodes.length; i++)
    {
      var curNode = configColumnsGridPanel_{control_id}.getRootNode().childNodes[i];
      var curID = curNode.id;
      
      //find a column by node ID, and record the position, then set the position to the curNode
      var curColumn = columnModel_{control_id}.getColumnById(curID);
      
      //set node's position to the one of the column model's item
      curNode.position = curColumn.position;
      
      curNode.getUI().toggleCheck(!curColumn.hidden);
    }
    
    configColumnsGridPanel_{control_id}.getRootNode().sort(sortByPosition_{control_id});
  }

  windowConfigColumns_{control_id}.show();
  
  configColumnsGridPanel_{control_id}.render();
}

function sortByPosition_{control_id}(node1, node2)
{
  if((node1 == null) || (node2 == null))
    return 0;
    
  if((node1.position == null) || (node2.position == null))
    return 0;
    
  return node1.position - node2.position;
}

//processes tool button click, prepares and displays filter configuration window
function onFilterSetup_{control_id}(ev, toolEl, panel)
{
  var data = {TotalRows:'1',filters:filterArr_{control_id}};

  if(!windowConfigFilters_{control_id}){
  
  var record = Ext.data.Record.create([{name:'dataIndex'},{name:'filterLabel'},{name:'type'},{name:'position'}]);
  
  var reader = new Ext.data.JsonReader({
                  root: 'filters',
                  totalProperty: 'TotalRows',
                  id: 'dataIndex'
              }, record
  );
  
  var store = new Ext.data.Store({
    reader: reader,
    data: data 
  });

  store.sort('position', 'ASC');
        
  var sm = new Ext.grid.CheckboxSelectionModel({singleSelect:false});
  
  var cm =new Ext.grid.ColumnModel([
    sm,
    {id:'Column',header: TEXT_COLUMN,  dataIndex: 'filterLabel'} ,
    {id:'DataType',header: TEXT_DATA_TYPE, dataIndex: 'type'},
    {header:'',sortable:false,dataIndex:'',renderer:upRenderer_{control_id}},
    {header:'',sortable:false,dataIndex:'',renderer:downRenderer_{control_id}}  

  ]);

  configGridPanel_{control_id} = new Ext.tree.TreePanel({
    useArrows:true,
    autoScroll:true,
    animate:true,
    lines:false,
    enableDD:true,
    containerScroll: true, 
    loader: new Ext.tree.TreeLoader(),
    root:new Ext.tree.TreeNode({
      text: TEXT_FILTER_CONFIG_PROMPT,
      draggable:false,
      expanded:true,
      leaf:false,
      loaded:true,
      iconCls:'x-hide-display',
      icon:'',
      cls:'x-tree-selected',
      isTarget:false,
      checked:false,
      id:'rootNode'
    })
  });

  configGridPanel_{control_id}.getRootNode().getUI().childIndent = '';

  //do not collapse the fake root node
  configGridPanel_{control_id}.on('beforecollapsenode', function(node, deep, anim){
    if(node == configGridPanel_{control_id}.getRootNode())
    {
      return false;
    }
  },this);

  //select all/deselect all filters, skipping the ones that cannot be hidden
  configGridPanel_{control_id}.getRootNode().on('checkchange', function(node, bChecked){
    //iterate through all children and set their checked status to bChecked
    for (var i = 0; i < node.childNodes.length; i++)
    {
      curItem = node.childNodes[i];
      var curFilter = GetFilterByName_{control_id}(curItem.id);
      
      //do not uncheck the non-hideable filters
      if(!curFilter.filterHideable && !bChecked)
      {
        continue;
      }

      node.childNodes[i].ui.toggleCheck(bChecked);
    }
  },this);

  //configPanel.getRootNode().childNodes = filterArr_{control_id};
  for(var i = 0; i < filterArr_{control_id}.length; i++)
  {
    var curElement = GetFilterByPosition_{control_id}(i);
    var treeNode = new Ext.tree.TreeNode({
      text : curElement.filterLabel,
      expandable:false,
      leaf:true,
      draggable:true,
      checked: (curElement.filterHideable ? curElement.showFilter : undefined),
      iconCls:(curElement.filterHideable ? 'x-hide-display': 'x-mt-checkbox-disabled'),   
      icon:'',
      allowDrag:true,
      id:curElement.dataIndex
    });
    treeNode.position = curElement.position;

    //block unchecking the node that corresponds to un-hideable filter
    treeNode.on('checkchange', function(node, bChecked){
      var curFilter = GetFilterByName_{control_id}(node.id);
      if (!curFilter.filterHideable && !bChecked)
      {
        node.ui.toggleCheck(true);
      }
    });

    //node double click should do the same as check change
    treeNode.on('dblclick', function(node, e){
      node.fireEvent('checkchange',node, node.getUI().isChecked());
    });
    
    configGridPanel_{control_id}.getRootNode().appendChild(treeNode);
  } 

      
  windowConfigFilters_{control_id} = new Ext.Window({
    el:'div-filter-config_{control_id}',
    layout:'fit',
    width:330,
    height:300,
    modal:true,
    title: TEXT_CONFIGURE_FILTERS,
    closeAction:'hide',
    plain: true,
    
    items: [configGridPanel_{control_id}],

    buttons: [{
      text: TEXT_OK,
      handler: onOKfilterConfigClick_{control_id},
      id: 'btnOK_FilterConfig_{control_id}'
    }]
  });

  } //end if
  windowConfigFilters_{control_id}.show(); 
  configGridPanel_{control_id}.render();

 
}



function onOKcolumnConfigClick_{control_id}()
{
  var root = configColumnsGridPanel_{control_id}.getRootNode();
  for(var i = 0 ; i < root.childNodes.length; i++)
  {
    var curItem = root.childNodes[i]; 
    var curColumn = GetColumnByID_{control_id}(curItem.id);
    var isHidden = !curItem.ui.isChecked();

    if(curColumn != null)
    {         
      var isHideable = (curColumn.hideable === undefined) ? true : curColumn.hideable;     
      if((curColumn.id == 'checker') || (curColumn.key == 'expander')|| (curColumn.id == 'expander'))
      {
        isHideable = false;
      }

      if(!isHideable)
      {
        isHidden = false;
      }

      var columnIndex = columnModel_{control_id}.getIndexById(curItem.id);   

      //show/hide column
      if(curColumn.hidden != isHidden)
      {
        columnModel_{control_id}.setHidden(columnIndex, isHidden);
      }
      
      if(curColumn.position != i)
      {
        columnModel_{control_id}.moveColumn( columnIndex, i );
        curColumn.position = i;
      }
    }   
  }

  
  //save to cookie
  SaveColumnInfoCookie_{control_id}();

  //hide the window
  windowConfigColumns_{control_id}.hide();
}

//handles OK button click on filter configuration window
function onOKfilterConfigClick_{control_id}()
{
  for(var i = 0; i < configGridPanel_{control_id}.getRootNode().childNodes.length; i++)
  {
    var curItem = configGridPanel_{control_id}.getRootNode().childNodes[i];  
    var curFilter = GetFilterByName_{control_id}(curItem.id);
    var isChecked = curItem.ui.isChecked() || (!curFilter.filterHideable);   
    
    if(curFilter != null)
    {
      curFilter.position = i;
    }
      
    showHideFilter_{control_id}(curItem.id,isChecked);
  }

  //save filter position
  SavePositionToCookie_{control_id}();

  //redraw filters   
  ResetFilters_{control_id}();

  //redo search
  PerformSearch_{control_id}(false);  
        
  //hide the window
  windowConfigFilters_{control_id}.hide();
}

//initialize grid selection based on showFilter flag
function InitializeConfigFilters_{control_id}(configPanel)
{
  for (var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    var curFilter = filters_{control_id}.filters.items[i];
    var curPos = curFilter.position;
    var filterName = curFilter.dataIndex;
            
    if(curFilter.showFilter)
    {
      configPanel.getSelectionModel().selectRow(curPos,true);
    }
    else
    {
      configPanel.getSelectionModel().deselectRow(curPos);
    }
  }
}

/*
  prefix is either -start-date, -end-date
  key is one of the three values: before, after, on
*/
processDateFilter_{control_id} = function(filterObj,filterName, key, bInitialLoad)
{
  var prefix = (key == 'before')? '-end-date' : '-start-date';

  var filterValue;
  
  if (bInitialLoad){
    filterValue = (key == 'after') ? filterObj.filterValue : filterObj.filterValue2;
  }else{
    filterValue = Ext.get('filter_' + filterName + '_{control_id}' + prefix).getValue();
  }
  
  var objData = new Object();
  eval('objData.' + key + ' = 0;'); 

  objData[key] = filterValue;

  if ((filterValue != null) && (filterValue != ''))
  {
    var parsedDate = Date.parseDate(filterValue, DATE_FORMAT);

    //for the end date filter, add 1 day to fully include the date that was entered
    if(key == 'before')
    {
      parsedDate = parsedDate.add('d',1);
    }

    objData[key] = parsedDate;
  }

  if(objData[key])
  {
    filterObj.dates[key].menu.picker.setValue(objData[key]);
    filterObj.dates[key].setChecked(filterObj.showFilter);
    return filterObj.showFilter;
  } 
  else 
  {
    filterObj.dates[key].setChecked(false);
  }

  return false;
}


function InitEnumOptions()
{
  {init_enum_options}
}

Ext.onReady(function(){
	Ext.ux.menu.RangeMenu.prototype.icons = {
    gt: '/Res/Images/icons/greater_then.png', 
    lt: '/Res/Images/icons/less_then.png',
    eq: '/Res/Images/icons/equals.png'
	};
  Ext.QuickTips.init();

	Ext.ux.grid.filter.StringFilter.prototype.icon = '/Res/Images/icons/find.png';

	cookiePrefix_{control_id} = '{cookie_prefix}';
	InitEnumOptions();
	Initialize_{control_id}();	
	
  LoadFilters_{control_id}();
  LoadGrid_{control_id}();
  
  //run saved search
  if('{saved_search_id}'.length > 0)
  {
    LoadSavedSearch_{control_id}('{saved_search_id}');
  }
});
    
function LoadSavedSearch_{control_id}(searchID)
{
  var myMask = new Ext.LoadMask(grid_{control_id}.getEl());
  myMask.show();
  
  Ext.Ajax.request({
    url:'{virtual_folder}/AjaxServices/LoadSavedSearch.aspx',
    params:{SavedSearchID:searchID},    
    success:function(result,request)
    {
      var searchFilters = Ext.util.JSON.decode(result.responseText);              
      LoadFiltersFromSearch_{control_id}(searchFilters);              
      myMask.hide();      
    }
  });
}

function GetFilterPanelByFilterPosition_{control_id}(curPos, totalItems)
{
  if (filterPanelColumnLayout_{control_id} == 'singlecolumn')
  {
    return 1;
  }
  
  var half = Math.ceil(totalItems / 2);
  var nResult = 0;

  if (curPos < half)
  {
    nResult = 1;
  }
  else
  {
    nResult = 2;
  }

  return nResult;
}

function GetVisibleFilterCount_{control_id}()
{
  var nTotal = 0;
  
  for (var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    var curFilter = filters_{control_id}.filters.items[i];
    
    if(curFilter.showFilter)
    {
      nTotal++;
    }    
  }
  
  return nTotal;
}

function ResetFilters_{control_id}()
{
  //get the left and right filter panels
  var formPanel1 = Ext.getCmp('formPanel1');
  var formPanel2 = Ext.getCmp('formPanel2');

  //hidden panel
  var hiddenPanel = Ext.getCmp('hiddenPanel');

  var actualPosition = 0;
  
  for (var i = 0; i < filterArr_{control_id}.length; i++)
  {
    var totalFilters = GetVisibleFilterCount_{control_id}();

    var curFilter = GetFilterByPosition_{control_id}(i);
    if(curFilter != null)
    {
      var curItemWrapper = Ext.getCmp('wrapper_filter_' + curFilter.dataIndex + '_{control_id}');
      
      if(curFilter.showFilter)
      {
        //calculate where this filter will be shown       
        var formPanelId = GetFilterPanelByFilterPosition_{control_id}(actualPosition, totalFilters);  	  
        var curPanel = eval('formPanel' + formPanelId);
        
        MoveComponent_{control_id}(curItemWrapper,curItemWrapper.ownerCt, curPanel);
        actualPosition++;
      }
      else
      {
        MoveComponent_{control_id}(curItemWrapper,curItemWrapper.ownerCt, hiddenPanel);
      }
    }
	}
}

function ClearFilter_{control_id}(filter)
{
  var filterName = filter.dataIndex;
  var ctrlName;

  switch(filter.type)
  {
    case 'string':
    case 'numeric':
      if (filter.rangeFilter) {
        ctrlName = 'filter_' + filterName + '_{control_id}' + '-start-value';
        resetControl_{control_id}(ctrlName);

        ctrlName = 'filter_' + filterName + '_{control_id}' + '-end-value';
        resetControl_{control_id}(ctrlName);
      }
      else {
        ctrlName = 'filter_' + filterName + '_{control_id}';
        resetControl_{control_id}(ctrlName);
      }
      break;

    case 'boolean':
    case 'list':
    case 'account':
      ctrlName = 'filter_' + filterName + '_{control_id}';
      resetControl_{control_id}(ctrlName);

      ctrlName = 'combo_filter_' + filterName + '_{control_id}';
      resetControl_{control_id}(ctrlName);
      break;

    case 'date':
      ctrlName = 'filter_' + filterName + '_{control_id}' + '-start-date';
      resetControl_{control_id}(ctrlName);

      ctrlName = 'filter_' + filterName + '_{control_id}' + '-end-date';
      resetControl_{control_id}(ctrlName);
      
      break;     
  }
}

function MoveComponent_{control_id}(component, sourceContainer, destContainer)
{
  if(sourceContainer == destContainer)
  {
    return;
  }

  sourceContainer.remove(component,false);
  destContainer.body.appendChild(Ext.getDom(component.el));    
  destContainer.add(component);
}

//string filter
function LoadStringFilter_{control_id}(curFilter, fieldID, fieldLabel)
{
  var allowBlank = (curFilter.required == true) ? false : true;

  var curField = null;
  
  if(curFilter.rangeFilter)
  {
    curField = new Ext.ux.StringRangeField({ 
      id: fieldID, 
      name: fieldID,
      fieldLabel:fieldLabel, 
      width:{filter_input_width},
      startValue: curFilter.filterValue + '',
      endValue: curFilter.filterValue2 + '' 
    });
  }
  else{  
    curField = new Ext.form.TextField({
      fieldLabel: fieldLabel,
      name: fieldID,
      width: {filter_input_width},
      id: fieldID,
      allowBlank: allowBlank
    });

    //set the value if non-null
    if(curFilter.filterValue != null)
    {
      curField.setValue(Ext.util.Format.htmlDecode(curFilter.filterValue));
    }
  }
  if(curFilter.readonly)
  {
    curField.setDisabled(true);
  }
    
  //if enter key is clicked, fire the search
  curField.on('specialkey', function(f, e){
      if(e.getKey() == e.ENTER){
          this.onSearch_{control_id}();
      }
  },this);
  
  return curField;
}

//numeric filter
function LoadNumericFilter_{control_id}(curFilter, fieldID, fieldLabel)
{
  var allowBlank = (curFilter.required == true) ? false : true;

  var curField = null;

  if(curFilter.rangeFilter == true)
  {
    curField = new Ext.ux.NumericRangeField({ 
      id: fieldID, 
      name: fieldID,
      fieldLabel:fieldLabel, 
      width:{filter_input_width},
      startValue: curFilter.filterValue + '',
      endValue: curFilter.filterValue2 + '' 
    });
  }
  else{
    curField = new Ext.ux.form.NumericOperationField({
      fieldLabel: fieldLabel,
      name: fieldID,
      width:{filter_input_width},
      id: fieldID,
      allowBlank: allowBlank
    });
  }
  if (curFilter.rangeFilter != true) {

    if(curFilter.filterValue != null)
    {
      curField.setValue(curFilter.filterValue);
    }

    if(curFilter.filterOperation != null)
    {
      curField.setOperation(curFilter.filterOperation);
    }
  }
  if(curFilter.readonly)
  {
    curField.setDisabled(true);
  }
  
  curField.on('specialkey', function(f, e){
    if(e.getKey() == e.ENTER){
        this.onSearch_{control_id}();
    }
  },this);
  
  return curField;	
}

//date filter
function LoadDateFilter_{control_id}(curFilter, fieldID, fieldLabel)
{
  var allowBlank = (curFilter.required == true) ? false : true;
  var startDate = curFilter.filterValue + '';
  var endDate = curFilter.filterValue2 + '';
  

  var curField = new Ext.ux.DateRangeField({
    fieldLabel: fieldLabel,
    startDate: startDate,
    endDate: endDate,
    id:fieldID,
    name:fieldID,
    width:{filter_input_width},
    dateFormat:DATE_FORMAT,
    allowBlank:allowBlank
  });

  curField.on('specialkey', function(f, e){
      if(e.getKey() == e.ENTER){
          this.onSearch_{control_id}();
      }
  },this);
  
  return curField;
}

/*
  List Filter
*/
function LoadListFilter_{control_id}(curFilter, fieldID, fieldLabel)
{
  var allowBlank = (curFilter.required == true) ? false : true;
  var data = curFilter.options;
  
  var store=new Ext.data.SimpleStore({
    fields:['value','text'],
    data:data,
    autoLoad:true
  });

  var comboId = 'combo_' + fieldID;

  var listField;
  
  if(curFilter.multiValue){
    var listField = new Ext.ux.form.SuperBoxSelect({
      allowBlank:allowBlank,
      id:fieldID,
      xtype:'superboxselect',
      fieldLabel: fieldLabel,
      resizable: true,
      name: 'states',
      width: {filter_input_width},
      store: store,
      mode: 'local',
      displayField: 'text',
      displayFieldTpl: '{text}',
      valueField: 'value',
      forceSelection : true
    }); 
  }
  else{
    listField = new Ext.ux.form.ComboOperationField({
      store: store,
      id:comboId,
      width: {filter_input_width},
      hiddenId: fieldID,
      hiddenName:fieldID,
      fieldLabel:fieldLabel,
      displayField:'text',
      valueField:'value',
      typeAhead: true,
      mode: 'local',
      triggerAction: 'all',
      selectOnFocus:true,
      editable:true,
      forceSelection:true,
      //valueNotFoundText:TEXT_ERROR_INVALID_VALUE,
      allowBlank:allowBlank
    });
    
    if(curFilter.filterOperation != null)
    {
      listField.setOperation(curFilter.filterOperation);
    }

  }
  if(curFilter.filterValue != null)
  {
    listField.setValue(curFilter.filterValue);
  }

  if(curFilter.readonly)
  {
    listField.setDisabled(true);
  }

  listField.on('specialkey', function(f, e){
    if(e.getKey() == e.ENTER){
      this.onSearch_{control_id}();
    }
  },this);	
/*
  listField.on('change', function(){
    this.onSearch_{control_id}();
  },this);
*/
  return listField;
}

/*
  Boolean filter
*/
function LoadBooleanFilter_{control_id}(curFilter, fieldID, fieldLabel)
{
  var allowBlank = (curFilter.required == true) ? false : true;

  var data=[['', '--'],['1', TEXT_YES],['0', TEXT_NO]];
  var store=new Ext.data.SimpleStore({
    fields:['value','text'],
    data:data,
    autoLoad:true
  });

  var comboId = 'combo_' + fieldID;

  var boolField = new Ext.form.ComboBox({
    store: store,
    id:comboId,
    hiddenId: fieldID,
    hiddenName:fieldID,
    fieldLabel:fieldLabel,
    displayField:'text',
    valueField:'value',
    typeAhead: true,
    mode: 'local',
    triggerAction: 'all',
    selectOnFocus:true,
    editable:true,
    forceSelection:true,
    allowBlank:allowBlank
  });

  //set the value if non-null
  if(curFilter.filterValue != null)
  {
    if ((curFilter.filterValue == '1') || (curFilter.filterValue.toLowerCase() == 'true') || 
        (curFilter.filterValue.toLowerCase() == 'y') || (curFilter.filterValue.toLowerCase() == 'yes'))
    {
      boolField.setValue('1');
    }
    if ((curFilter.filterValue == '0') || (curFilter.filterValue.toLowerCase() == 'false') || 
        (curFilter.filterValue.toLowerCase() == 'n') || (curFilter.filterValue.toLowerCase() == 'no'))
    {
      boolField.setValue('0');
    }
  }

  
  if(curFilter.readonly)
  {
    boolField.setDisabled(true);
  }

  boolField.on('specialkey', function(f, e){
    if(e.getKey() == e.ENTER){
        this.onSearch_{control_id}();
    }
  },this);	

  boolField.on('change', function(){
    this.onSearch_{control_id}();
  },this);
  
  return boolField;
}

/*
  Overridable format validator for username/acc_id display
*/
function AccountFilterValidator_{control_id}(value)
{
  if(value.length == 0)
  {
    return true;
  }

  var res = value.match(/(\d+)|.*\((\d+)\)$/);
  if (res == null)
  {
    return false;
  }

  var accID = ( (res[1] === undefined) || (res[1] == '')) ? res[2] : res[1];
  var ctrl = Ext.get(this.hiddenId);
  if(ctrl != null)
  {
    ctrl.dom.value = accID;
  }
  return true;
}

function LoadAccountFilter_{control_id}(curFilter, fieldID, fieldLabel)
{
  var allowBlank = (curFilter.required == true) ? false : true;

  var ds = new Ext.data.Store({
    proxy: new Ext.data.HttpProxy({
        url: '{virtual_folder}/AjaxServices/FindAccountSvc.aspx'
    }),
    reader: new Ext.ux.JPathJsonReader({
        root: 'Items',
        totalProperty: 'TotalRows',
        id: '_AccountID'
    }, 
    [
      {name: 'UserName', mapping: 'UserName'},
      {name: 'FirstName', mapping: 'LDAP[ContactType == 1]/FirstName',useJPath:true},
      {name: 'LastName', mapping: 'LDAP[ContactType == 1]/LastName',useJPath:true},
      {name: 'AccountType', mapping: 'AccountType'},
      {name: 'AccountStatus', mapping: 'AccountStatus'},
      {name: 'Folder', mapping: 'Internal.Folder'},
      {name: '_AccountID', mapping: '_AccountID'}
    ])
  });
  
  //exit if error occurred
  ds.on('loadexception',
   function(a,conn,resp) {         	    
	    if(resp.status == 200)
	    {
	      Ext.UI.SessionTimeout();
	    }
	    else if(resp.status == 500)
	    {
	      Ext.UI.SystemError();
	    }
  });

  var comboId = 'combo_' + fieldID;
  		  
  var accField   = new Ext.form.ComboBox({
    store: ds,
    displayField:'UserName',
    valueField:'_AccountID',
    cls:'inlineSearch', 
    id:comboId,
    name:comboId,
    hiddenId: fieldID,
    hiddenName: fieldID,  
    fieldLabel:fieldLabel,                                      
    typeAhead: false,
    width: {filter_input_width},
    pageSize:10,
    hideTrigger:true,
    minChars:1,
    allowBlank:allowBlank,
                
    tpl: new Ext.XTemplate(
      '<tpl for="".""><div class=""search-item"">',
          '<h3><img src=""/ImageHandler/images/Account/{AccountType}/account.gif?State={AccountStatus}&Folder={Folder}"">{UserName} ({_AccountID})</h3>',
                    
          '<tpl if=""this.isNull(FirstName)==false && this.isNull(LastName)==false"">',
            '{FirstName:htmlEncode} {LastName:htmlEncode}',
          '</tpl>',
          
          '<tpl if=""this.isNull(FirstName) || this.isNull(LastName)"">',
            '<tpl if=""this.isNull(FirstName)"">',
              '<tpl if=""this.isNull(LastName) == false"">',
                '{LastName:htmlEncode}',
              '</tpl>',
            '</tpl>', 
                     
            '<tpl if=""this.isNull(LastName)"">',
              '<tpl if=""this.isNull(FirstName)==false"">',
                '{FirstName:htmlEncode}',
              '</tpl>',
            '</tpl>',  
          '</tpl>',          
      '</div></tpl>',

      {
        isNull: function(inputString)
        {
          if((inputString == null) || (inputString == '') || (inputString == 'null'))
          {
            return true;
          }
          return false;
        }
      }
    ),
    itemSelector: 'div.search-item',
    validator:AccountFilterValidator_{control_id}
  });
   
  accField.on('render', function(combo){
    if(curFilter.filterValue != null)
    {
      if(!isNaN(curFilter.filterValue))
      {
        combo.hiddenField.value = curFilter.filterValue;
      }
    }

    if(curFilter.filterValue2 != null)
    {
      combo.el.dom.value = curFilter.filterValue2;
    }
  }, this);
                       
  accField.on('select', function(combo,record,index){
    var display = record.data.UserName + ' (' + record.data._AccountID + ')';
    combo.el.dom.value = display;
    var hid = Ext.get(combo.hiddenId);
    if(hid != null)
    {
      hid.dom.value = record.data._AccountID;
    }
    
    combo.collapse();
      
  },this);	
                  
  accField.on('specialkey', function(f, e){
      var key = e.getKey();
      
      if(key == e.ENTER){
      
        //clean up internal field
        if(f.el.dom.value == '')
        {
          var hid = Ext.get(f.hiddenId);
          if(hid != null)
          {
            hid.dom.value = '';
          }
        }
      
        this.onSearch_{control_id}();
      }
  },this);	
          
  accField.on('blur', function(f, e){
    //clean up internal value
    var hid = Ext.get(f.hiddenId);
    if (f.el.dom.value == '')
    {
      if (hid != null)
      {
        hid.dom.value = '';
      }
    }
  },this);
  
  return accField;
}

/*
  Iterate through the filters and display them
*/
function LoadFilters_{control_id}()
{
  var columnPanel = new Ext.Panel({
    layout:'column',
    id:'columnPanel'
  });
  
  var hiddenPanel = new Ext.Panel(
    {
        id:'hiddenPanel',
        pageX: -400, 
        pageY: -500,
        height:0
    }
  );

  var formPanel1 = new Ext.Panel({
    bodyStyle: 'padding:5px 5px 5px 5px',  
    layout:'form',
    width:'{filter_column_width}',
    id:'formPanel1'
  });
  
  var formPanel2 = new Ext.Panel({
    bodyStyle: 'padding:5px 5px 5px 5px',  
    layout:'form',
    width:'{filter_column_width}',
    id:'formPanel2'
  });

  filterPanel_{control_id}.add(columnPanel); 
  filterPanel_{control_id}.add(hiddenPanel); 
    
  columnPanel.add(formPanel1);
  columnPanel.add(formPanel2)

  var actualPosition = 0;
  for (var i = 0; i < filters_{control_id}.filters.items.length; i++)
  {
    var curFilter = GetFilterByPosition_{control_id}(i);
    
    var fieldLabel = (curFilter.filterLabel == undefined) ? curFilter.dataIndex : curFilter.filterLabel;
    var fieldID = 'filter_' + curFilter.dataIndex + '_{control_id}';

    var totalFilters = GetVisibleFilterCount_{control_id}();
    var formPanelId = GetFilterPanelByFilterPosition_{control_id}(actualPosition, totalFilters);
    
    //target panel will be either formPanel1, or formPanel2, or hiddenPanel
    var curPanel = (curFilter.showFilter) ? eval('formPanel' + formPanelId) : hiddenPanel;

    var wrapperPanel = new Ext.Panel({
      layout:'form',
      id:'wrapper_' + fieldID,
      bodyStyle: 'padding:5px 5px 0px 5x'
    });
        
    curPanel.add(wrapperPanel);
    var curField;
    
    switch (curFilter.type.toLowerCase())
    {
      case 'string':
        curField = LoadStringFilter_{control_id}(curFilter, fieldID, fieldLabel);
        break;
        
      case 'numeric':
        curField = LoadNumericFilter_{control_id}(curFilter, fieldID, fieldLabel);
        break;
        
      case 'date':
        curField = LoadDateFilter_{control_id}(curFilter, fieldID, fieldLabel);
        break;
        
      case 'boolean':
        curField = LoadBooleanFilter_{control_id}(curFilter, fieldID, fieldLabel);
        break;
        
      case 'list':
        curField = LoadListFilter_{control_id}(curFilter, fieldID, fieldLabel);
        break;
        
      case 'account':
        curField = LoadAccountFilter_{control_id}(curFilter, fieldID, fieldLabel);
        break;       
    }
    
    wrapperPanel.add(curField);
	    
    if(curFilter.showFilter)
    {
      actualPosition++;
    }
  } 
}

/*
This function takes the name of the cookie, and array containing raw objects.
It compares if the two entities have the same elements, referenced by the indexPropertyName parameter.
*/
function ValidateCookie_{control_id}(cookieName, arrRawData, indexPropertyName)
{
  //var cookieName = cookiePrefix_{control_id} + 'columns';
  
  var cookieVal = Cookies.get(cookieName);
  if((cookieVal == null) || (cookieVal == ''))
  {
    return false;
  }
  
  var arrCookies = cookieVal.split(',');
  if(arrCookies.length <= 0)
  {
    return false;
  }
  
  if (arrCookies.length != arrRawData.length)
  {
    return false;
  }
  
  for (var i = 0; i < arrCookies.length; i++)
  {
    //split up name from showFilter flag
    var arrCurElement = arrCookies[i].split(':');
      
    //each elt must contain 2 items  
    if(arrCurElement.length != 2)
    {
      return false;
    }
    
    var curName = arrCurElement[0];
    var curShowFlag = arrCurElement[1];
    
    if((curShowFlag != '0') && (curShowFlag != '1'))
    {
      return false;
    }
    
    //check if each item from cookie hasn't been removed from aspx
    if(GetArrayElementByPropertyValue_{control_id}(arrRawData, indexPropertyName, curName) == null)
    {
      return false;
    }
    
    return true;
  }
}

//checks if a given array contains an element with certain value in a property
function GetArrayElementByPropertyValue_{control_id}(arr, property, value)
{
  if(value == '')
  {
    return null;
  }
  
  for (var i = 0; i < arr.length; i++)
  {
    var elt = arr[i];
    var propValue = eval('elt.' + property);
    
    if(propValue == value)
    {
      return elt;
    }
  }
  
  return null;
}

function LoadColumnsFromCookie_{control_id}(cookieName,sourceArr, destArr)
{
  var cookieData = Cookies.get(cookieName);
  if ((cookieData == null) || (cookieData == ''))
  {
    return;
  }
  
  var arrCookies = cookieData.split(','); 
  
  for(var i = 0; i < arrCookies.length; i++)
  {
    var arrCurElement = arrCookies[i].split(':');
    
    if(arrCurElement.length != 2)
    {
      continue;
    }
    
    var curName = arrCurElement[0];
    var curShowFlag = (arrCurElement[1] == '1') ? true : false;
    
    //find column that has curName in the id field, and move it from sourceArr to destArr
    var curColumn = GetArrayElementByPropertyValue_{control_id}(sourceArr, 'id', curName);
    if(curColumn != null)
    {
      //set the show/hide flag
      curColumn.hidden = (!curShowFlag);
      
      destArr.push(curColumn);
    }
  }
}


//Text Editor
GetTextEditor_{control_id} = function(validatorObj)
{
  var editor = new Ext.Editor(
    new Ext.form.TextField({
      selectOnFocus:true,
      allowBlank: validatorObj.editorAllowBlank,
      minLength: validatorObj.editorMinLength,
      maxLength: ((validatorObj.editorMaxLength == -1) ? Number.MAX_VALUE : validatorObj.editorMaxLength),
      regex : ((validatorObj.editorRegex === undefined) ? null : validatorObj.editorRegex),
      validator : ((validatorObj.editorValidationFunction === undefined) ? null : validatorObj.editorValidationFunction),
      vtype:((validatorObj.editorVType === undefined) ? '' : validatorObj.editorVType )
    }), 
        {
          autoSize: 'width'
        }
      );
  return editor;
};

	        GetAccountPicker_{control_id} = function(fieldID, fieldLabel) {
	        
	          var comboId = 'combo_' + fieldID;
	          var ds = new Ext.data.Store({
	            proxy: new Ext.data.HttpProxy({
	              url: '/MetraNet/AjaxServices/FindAccountSvc.aspx'
	            }),
	            reader: new Ext.ux.JPathJsonReader({
	              root: 'Items',
	              totalProperty: 'TotalRows',
	              id: '_AccountID'
	            },
            [
              { name: 'UserName', mapping: 'UserName' },
              { name: 'FirstName', mapping: 'LDAP[ContactType == 1]/FirstName', useJPath: true },
              { name: 'LastName', mapping: 'LDAP[ContactType == 1]/LastName', useJPath: true },
              { name: 'AccountType', mapping: 'AccountType' },
              { name: 'AccountStatus', mapping: 'AccountStatus' },
              { name: 'Folder', mapping: 'Internal.Folder' },
              { name: '_AccountID', mapping: '_AccountID' }
            ])
	          });
	          //exit if error occurred
	          ds.on('loadexception',
             function(a, conn, resp) {
               if (resp.status == 200) {
                 Ext.UI.SessionTimeout();
               }
               else if (resp.status == 500) {
                 Ext.UI.SystemError();
               }
             });

	          var comboId = 'combo_' + fieldID;

	          var accField = new Ext.form.ComboBox({
	            store: ds,
	            displayField: 'UserName',
	            valueField: '_AccountID',
	            cls: 'inlineSearch',
	            id: comboId,
	            name: comboId,
	            hiddenId: fieldID,
	            hiddenName: fieldID,
	            fieldLabel: fieldLabel,
	            typeAhead: false,
	            width: 220,
	            pageSize: 10,
	            hideTrigger: true,
	            minChars: 1,
	            allowBlank: true,

	            tpl: new Ext.XTemplate(
                '<tpl for="".""><div class=""search-item"">',
                    '<h3><img src=""/ImageHandler/images/Account/{AccountType}/account.gif?State={AccountStatus}&Folder={Folder}"">{UserName} ({_AccountID})</h3>',

                    '<tpl if=""this.isNull(FirstName)==false && this.isNull(LastName)==false"">',
                      '{FirstName:htmlEncode} {LastName:htmlEncode}',
                    '</tpl>',

                    '<tpl if=""this.isNull(FirstName) || this.isNull(LastName)"">',
                      '<tpl if=""this.isNull(FirstName)"">',
                        '<tpl if=""this.isNull(LastName) == false"">',
                          '{LastName:htmlEncode}',
                        '</tpl>',
                      '</tpl>',

                      '<tpl if=""this.isNull(LastName)"">',
                        '<tpl if=""this.isNull(FirstName)==false"">',
                          '{FirstName:htmlEncode}',
                        '</tpl>',
                      '</tpl>',
                    '</tpl>',
                '</div></tpl>',

                {
                  isNull: function(inputString) {
                    if ((inputString == null) || (inputString == '') || (inputString == 'null')) {
                      return true;
                    }
                    return false;
                  }
                }
              ),
	            itemSelector: 'div.search-item',
	            validator: AccountFilterValidator_{control_id}
	          });
	          
	          accField.on('select', function(combo, record, index) {
	            var display = record.data.UserName + ' (' + record.data._AccountID + ')';
	            combo.el.dom.value = display;
	            var hid = Ext.get(combo.hiddenId);
	            if (hid != null) {
	              hid.dom.value = record.data._AccountID;
	            }

	            combo.collapse();

	          }, this);

	          accField.on('specialkey', function(f, e) {
	            var key = e.getKey();

	            if (key == e.ENTER) {

	              //clean up internal field
	              if (f.el.dom.value == '') {
	                var hid = Ext.get(f.hiddenId);
	                if (hid != null) {
	                  hid.dom.value = '';
	                }
	              }

	              this.onSearch_{control_id}();
	            }
	          }, this);

	          accField.on('blur', function(f, e) {
	            //clean up internal value
	            var hid = Ext.get(f.hiddenId);
	            if (f.el.dom.value == '') {
	              if (hid != null) {
	                hid.dom.value = '';
	              }
	            }
	          }, this);

	          return accField;	          
	        };

//Date Editor
GetDateEditor_{control_id} = function(validatorObj)
{
  var editor = new Ext.Editor(
    new Ext.form.DateField(
      {
        selectOnFocus:true,
        format : DATE_FORMAT,
        altFormat : ALT_FORMAT,
        allowBlank: validatorObj.editorAllowBlank,
        minLength: validatorObj.editorMinLength,
        maxLength: ((validatorObj.editorMaxLength == -1) ? Number.MAX_VALUE : validatorObj.editorMaxLength),
        minValue: ( (validatorObj.editorMinValue === undefined) ? null : validatorObj.editorMinValue ),
        maxValue: ( (validatorObj.editorMaxValue === undefined) ? null : validatorObj.editorMaxValue ),
        regex : ((validatorObj.editorRegex === undefined) ? null : validatorObj.editorRegex),
        validator : ((validatorObj.editorValidationFunction === undefined) ? null : validatorObj.editorValidationFunction)

      }),
      {
		    autoSize: 'width',
		    
		    startEdit:function(el,value)
        {
          if(this.editing){
              this.completeEdit();
          }
          this.boundEl = Ext.get(el);
          var v = value !== undefined ? value : this.boundEl.dom.innerHTML;
        
          if(!this.rendered){
            this.render(this.parentEl || document.body);
          }
        
          if(this.fireEvent('beforestartedit', this, this.boundEl, v) === false){
              return;
          }
                    
          this.startValue = v;
          
          if(v == null)
          {
            v = new Date();
          }

          this.field.setValue(new Date(v));
          this.doAutoSize();
          this.el.alignTo(this.boundEl, this.alignment);
          this.editing = true;
          this.show();
        },
		    
		    getValue : function(){
			    var dt = this.field.getValue();
			    if(dt == '')
			    {
			      return '';
			    }
          this.value = dt;			
					return this.value.dateFormat(DATE_FORMAT);
			  }
			});
			
	return editor;
};

//boolean editor
GetBooleanEditor_{control_id} = function(){
  var editor = new Ext.Editor(
        new Ext.form.ComboBox({
               width:'auto',
               selectOnFocus:true,
               store:new Ext.data.SimpleStore(
                {
                  fields:['value','text'],
                  data:[['','--'],['true',TEXT_YES],['false',TEXT_NO]]               
                }
               ),
               displayField:'text',
               valueField:'value',
               mode:'local',
               triggerAction:'all',
               typeAhead:true
      }),
      
      {
        autoSize: 'width',
        startEdit:function(el,value)
        {
          if(this.editing){
              this.completeEdit();
          }
          this.boundEl = Ext.get(el);
          var v = value !== undefined ? value : this.boundEl.dom.innerHTML;
        
          if(!this.rendered){
            this.render(this.parentEl || document.body);
          }
        
          if(this.fireEvent('beforestartedit', this, this.boundEl, v) === false){
              return;
          }

          this.startValue = v;
          this.field.setValue(v + '');
          this.doAutoSize();
          this.el.alignTo(this.boundEl, this.alignment);
          this.editing = true;
          this.show();
        }
      });
      
  return editor;
}

//Account editor TBD
GetAccountEditor_{control_id} = function(validatorObj){
  //return GetNumericEditor_{control_id}(validatorObj);
  return new Ext.Editor(new Ext.form.TextField());
};



//numeric editor
GetNumericEditor_{control_id} = function(validatorObj){
  var editor = new Ext.Editor(
    new Ext.ux.form.LargeNumberField({
      selectOnFocus:true,
      allowBlank: validatorObj.editorAllowBlank,
      minLength: validatorObj.editorMinLength,
      maxLength: ((validatorObj.editorMaxLength == -1) ? Number.MAX_VALUE : validatorObj.editorMaxLength),
      minValue: ( (validatorObj.editorMinValue === undefined) ? Number.NEGATIVE_INFINITY : validatorObj.editorMinValue ),
      maxValue: ( (validatorObj.editorMaxValue === undefined) ? Number.MAX_VALUE : validatorObj.editorMaxValue ),
      regex : ((validatorObj.editorRegex === undefined) ? null : validatorObj.editorRegex),
      validator : ((validatorObj.editorValidationFunction === undefined) ? null : validatorObj.editorValidationFunction)
    })
    ,
    {
      autoSize: 'width'
    });
  return editor;
};

GetComboEditor_{control_id} = function(options)
{
  var combo = new Ext.form.ComboBox({
               store:new Ext.data.SimpleStore(
                {
                  fields:['value','text'],
                  data:options           
                }
               ),
               selectOnFocus:true,
               displayField:'text',
               valueField:'value',
               mode:'local',
               triggerAction:'all',
               typeAhead:true
            });
            
  var editor = new Ext.Editor(combo,
    {
      autoSize: 'width',
      startEdit: function(el, value)
      {
        if(this.editing){
        this.completeEdit();
        }
        this.boundEl = Ext.get(el);
        var v = (value !== undefined) ? value : this.boundEl.dom.innerHTML;
      
        if(!this.rendered){
          this.render(this.parentEl || document.body);
        }
      
        if(this.fireEvent('beforestartedit', this, this.boundEl, v) === false){
            return;
        }
        var comboValue = '';
        
        for (var i = 0; i < options.length; i++)
        {
          if(options[i][1] == v)
          {
            comboValue = options[i][0];
          }
        }
        
        this.startValue = comboValue;
        this.field.setValue(comboValue);
        this.doAutoSize();
        this.el.alignTo(this.boundEl, this.alignment);
        this.editing = true;
        this.show();
        
      }
    });
  return editor;
};

GetColumnModel_{control_id} = function(selectionModel){
  columnArr_{control_id} = [
    {expander_in_column_model}{sel_model_in_column_model}{column_model}
  ];

  var arrSortedColumns = [];
  var cookieName = cookiePrefix_{control_id} + 'columns';
  if (ValidateCookie_{control_id}(cookieName, columnArr_{control_id}, 'id'))
  {
    LoadColumnsFromCookie_{control_id}(cookieName, columnArr_{control_id}, arrSortedColumns);
  }
  else{
    arrSortedColumns = columnArr_{control_id};
  }

  var cm = new Ext.grid.ColumnModel(arrSortedColumns);
  cm.defaultSortable = true;

  return cm;
};

GetRecord_{control_id} = function(){
  var myRecord = Ext.data.Record.create([{record_structure}]);
  return myRecord;
};

GetDataReader_{control_id} = function(){
  var recordStructure = GetRecord_{control_id}();

  var reader = new Ext.ux.JPathJsonReader({
				id:   {identity_field},
				totalProperty: '{total_property}',
				root: '{root_element}'
			}, 
      recordStructure
      );

  return reader;
};
    
OverrideRenderer_{control_id} = function() {};
GetExpanderTemplate_{control_id} = function()
{
  if(!{is_expandable})
  {
    return;
  }

  var strTemplate = BeforeExpanderRender_{control_id}('{generate_template}');
  var tpl = new Ext.XTemplate(strTemplate,
    {
      formatDate: function(value){
         return RenderDate(value, DATE_FORMAT);
      },
      formatBool: function(value)
      {
        return BooleanRenderer(value);
      }
    }
  );

  return tpl;
};

BeforeExpanderRender_{control_id} = function(tplString){
  return tplString;
};

//Function to allow page to modify toolbar programmatically
GetTopToolBar_{control_id} = function(toolbarFromConfiguration)
{
  return toolbarFromConfiguration;
};

GetTopBar_{control_id} = function()
{
  var tbar = {use_top_bar}new Ext.Toolbar([{generate_toolbar_buttons}]);
  return GetTopToolBar_{control_id}(tbar);
};

GetFilterBar_{control_id} = function()
{
  var tbar = new Ext.Panel();
  return tbar;
};

GetBottomBar_{control_id} = function()
{
  var config = {
    displayInfo:{display_info},
    store: dataStore_{control_id},
    plugins: filters_{control_id},
    pageSize: {page_size}
    {export_button}
  };

  var bbar ={use_bottom_bar} new Ext.PagingToolbar(config);

  return bbar;
};

{export_code}

GetBottomButtons_{control_id} = function()  
{
  var bottom_buttons = [{bottom_buttons}];
  return bottom_buttons;
};

function SaveColumnInfoCookie_{control_id}()
{
  var cookieData = '';
  var columnCount = columnModel_{control_id}.getColumnCount();
  for (var i = 0; i < columnCount; i++)
  {
    //returns a column id at a given sequential position
    //var columnID = columnModel_{control_id}.getColumnId(i);
    //var column = columnModel_{control_id}.getColumnById(columnID);
    
    var curColumn = GetColumnByPosition_{control_id}(i);
    if(curColumn != null)
    {
      columnID = curColumn.id;
      
      if(cookieData != '')
      {
        cookieData += ',';
      }
      
      var isVisible = (curColumn.hidden == true) ? 0 : 1
      
      cookieData += columnID + ':' + isVisible;
    }
  }
  
  Cookies.set(cookiePrefix_{control_id} + 'columns', cookieData);
}

function GetRowClassFunction_{control_id} (record, rowIndex, rowParam, dataStore)
{
  return '';
}

LoadGrid_{control_id} = function(){
  var selectionModel = {selection_model};
  var expanderTemplate_{control_id} = GetExpanderTemplate_{control_id}();
  expander_{control_id} = {generate_row_expander};
  expander_{control_id}.id = 'expander';

	dataStore_{control_id} = new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
      timeout:{ajax_timeout},
			url:'{data_source_url}',
      method:'POST'
		}),
		reader: GetDataReader_{control_id}()
		{sort_info}
    ,remoteSort: true
    ,sm:selectionModel
	}); 

  {setup_base_params}

  //exit if error occurred
  dataStore_{control_id}.on('loadexception',
   function(a,conn,resp) {         	    
	    if(resp.status == 200)
	    {
	      Ext.UI.SessionTimeout();
	    }
	    else if(resp.status == 500)
	    {
        var errMsg;
        try{
          var res = new Object();
          res = Ext.util.JSON.decode(resp.responseText);
          errMsg = res.message;
        }
        catch (err){ errMsg = 'Response: ' + resp.responseText;}
	      Ext.UI.SystemError(errMsg);
	    }
  });

  {generate_internal_grid}

  var gridHeight =  37 * filters_{control_id}.filters.items.length;

  columnModel_{control_id} = GetColumnModel_{control_id}(selectionModel);				
  InitColumnPosition_{control_id}();	
  OverrideRenderer_{control_id}(columnModel_{control_id});
/*
	//handler for column move
  columnModel_{control_id}.on('columnmoved', function(cm, oldIndex, newIndex){
      SaveColumnInfoCookie_{control_id}();
  },this);
  */
  //handler for column move
  columnModel_{control_id}.on('hiddenchange', function(cm, colIndex, bHidden){
      SaveColumnInfoCookie_{control_id}();
  },this);

  tbar_{control_id} = GetTopBar_{control_id}();
  bbar_{control_id} = GetBottomBar_{control_id}();
  fbar_{control_id} = GetFilterBar_{control_id}();

  var buttons_{control_id} = GetBottomButtons_{control_id}();        
  var pagingSelection_{control_id} = new Ext.ux.grid.RowSelectionPaging();

  gridView_{control_id} = new Ext.grid.GridView({
    emptyText: '{no_records_text}'
  });

	grid_{control_id} = new Ext.grid.GridPanel({
    id: 'extGrid_{control_id}',
    ds: dataStore_{control_id},
    cm: columnModel_{control_id},
		enableColLock: false,
		loadMask: true,
		view: gridView_{control_id},
		plugins: {grid_plugins},
    //height:{grid_height},
    //autoHeight: true,
    {grid_height_options}
    {grid_width}
		sm:selectionModel,
		el: 'grid-container_{control_id}',
    iconCls:'icon-grid',
		frame:{show_grid_frame},
    header:{show_grid_header},
    hideHeaders:{show_column_headers},
    collapsible:true,
    buttons:buttons_{control_id},
    buttonAlign:'{button_alignment}',
    title:'{grid_title}',
		bbar: bbar_{control_id},
    tbar: tbar_{control_id},
    supportExportSelected: {supportExportSelected},
    tools:[{column_config_tool}]
	});

	grid_{control_id}.on('afteredit', function(e){
      //send the data back
      var propPath = '';
      
      //remove dirty flag
      if(e.record.modified != null)
        e.record.modified[e.field] = undefined;
      
      //grab the property path (e.g. mapping)
      if(e.record.fields.keys.indexOf(e.field) >= 0)
      {
        var dataObj = e.record.fields.items[e.record.fields.keys.indexOf(e.field)];
        if((dataObj + '') != 'undefined')
        {
          propPath = dataObj.mapping;
        }
      }
      
      Ext.Ajax.request(
      {
        url:'{update_url}',
        params:{id:e.record.id,ppath:propPath,nv:e.value},
        failure:
          function(result, request)
          {
            Ext.MessageBox.show({
              title:TEXT_ERROR,
              msg:TEXT_ERROR_RECEIVING_DATA,
              buttons:Ext.MessageBox.OK,
              icon:Ext.MessageBox.ERROR
            });          
          },
        success: 
          function(result, request)
          {
            var res = new Object();
            res = Ext.util.JSON.decode(result.responseText);
            if(res.success == 'false')
            {
              Ext.MessageBox.show({
                title:TEXT_ERROR,
                msg:res.message,
                buttons:Ext.MessageBox.OK,
                icon:Ext.MessageBox.ERROR,
                fn:function(buttonId)
                {
                  if(buttonId == 'ok')
                  {
                    e.grid.getStore().reload();
                  }
                }
              });
            }
          }
      }
      
      );
      e.grid.getView().refreshRow(e.record);
  },this);

	grid_{control_id}.on('columnmove', function(oldIndex, newIndex){
      InitColumnPosition_{control_id}();
      SaveColumnInfoCookie_{control_id}();      
  },this);

  if({grid_resizable})
  {
    var resizer_{control_id} = new Ext.Resizable(grid_{control_id}.getEl(),
    {
        handles:'all',
        minHeight:150,
        minWidth:150
    });

    resizer_{control_id}.on('resize', function(){
            grid_{control_id}.syncSize();
            if (grid_{control_id}.layout) {
                grid_{control_id}.doLayout();
            }
    });
  }


  //if search on initial load, then perform search
  if(search_on_load_{control_id})
  {
    PerformSearch_{control_id}(true);  
	}
  else
  { 
    //otherwise hide results pane
    grid_{control_id}.setVisible(false);
  }

	grid_{control_id}.render();

  //hide filters if there should be none on the page
  if (useFilters_{control_id} == false)
  {
    filterPanel_{control_id}.setVisible(false);
    Ext.get('filterPanel_div_{control_id}').dom.style.display = 'none';
    return;
  }

  filterPanel_{control_id}.render(Ext.get('filterPanel_div_{control_id}'));

  //hide hidden panel after filters have been rendered
  Ext.getCmp('hiddenPanel').hide();
  
  if({filter_collapsed})
  {
    filterPanel_{control_id}.collapse(false);
  }
};
{default_button_handlers}
{setup_sub_grid}
{quick_edit}
	</script>


<div id='filterPanel_div_{control_id}' style='margin:10px;'></div>
<div id='grid-container_{control_id}' style='margin: 10px;'></div>

<div id='div-filter-config_{control_id}'>   
    <div id='grid-filter-config'></div>
</div>

<div id='div-column-config_{control_id}'> 
  <div id='grid-column-config'></div>
</div>

<div id='confirmExportWindow_{control_id}'></div>
  {custom_implementation_file_path}

<div id='div-save-search_{control_id}'></div>
<div id='div-saved-search-list_{control_id}'></div>
<div id='div-editRecordWindow_{control_id}'></div>
{override_include}
";


        #endregion

        private MTGridDataBinding dataBinder;

        /// <summary>
        /// Gets or sets the binder control for the grid
        /// </summary>
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public MTGridDataBinding DataBinder
        {
            get { return dataBinder; }
            set { dataBinder = value; }
        }


        private List<MTGridDataElement> elements;

        /// <summary>
        /// Returns the collection of elements that specify filters and/or columns in the grid
        /// </summary>
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public List<MTGridDataElement> Elements
        {
            get
            {
                if (elements == null)
                {
                    elements = new List<MTGridDataElement>();
                }
                return elements;
            }
        }

        private List<MetraTech.UI.Controls.MTGridExpanderSection> expanderTemplate;

        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public List<MetraTech.UI.Controls.MTGridExpanderSection> ExpanderTemplate
        {
            get
            {
                if (expanderTemplate == null)
                {
                    expanderTemplate = new List<MetraTech.UI.Controls.MTGridExpanderSection>();
                }

                return expanderTemplate;
            }
        }


        private List<MetraTech.UI.Controls.Field> defaultColumnOrder;

        /// <summary>
        /// Specifies the default order for the columns
        /// </summary>
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public List<MetraTech.UI.Controls.Field> DefaultColumnOrder
        {
            get
            {
                if (defaultColumnOrder == null)
                {
                    defaultColumnOrder = new List<MetraTech.UI.Controls.Field>();
                }
                return defaultColumnOrder;
            }
        }
        private List<MetraTech.UI.Controls.Field> defaultFilterOrder;

        /// <summary>
        /// Specifies the default order for the columns
        /// </summary>
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public List<MetraTech.UI.Controls.Field> DefaultFilterOrder
        {
            get
            {
                if (defaultFilterOrder == null)
                {
                    defaultFilterOrder = new List<MetraTech.UI.Controls.Field>();
                }
                return defaultFilterOrder;
            }
        }

        private List<MTGridButton> toolbarButtons;

        /// <summary>
        /// Returns the collection of buttons on the grid toolbar
        /// </summary>
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public List<MTGridButton> ToolbarButtons
        {
            get
            {
                if (toolbarButtons == null)
                {
                    toolbarButtons = new List<MTGridButton>();
                }
                return toolbarButtons;
            }
        }

        private List<MTGridButton> gridButtons;

        /// <summary>
        /// Collection of buttons that may appear at the bottom of the grid
        /// </summary>
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
        [PersistenceMode(PersistenceMode.InnerProperty)]
        [NotifyParentProperty(true)]
        public List<MTGridButton> GridButtons
        {
            get
            {
                if (gridButtons == null)
                {
                    gridButtons = new List<MTGridButton>();
                }
                return gridButtons;
            }
        }


        private string noRecordsText = "No records found";

        /// <summary>
        /// Sets or gets the text to display if no records are found
        /// </summary>
        [NotifyParentProperty(true)]
        public string NoRecordsText
        {
            get { return noRecordsText; }
            set { noRecordsText = value; }
        }

        private string totalProperty = "TotalRows";

        /// <summary>
        /// Specifies the name of JSon attribute containing the total rows count
        /// </summary>
        [NotifyParentProperty(true)]
        public string TotalProperty
        {
            get
            {
                if (String.IsNullOrEmpty(totalProperty))
                {
                    totalProperty = "TotalRows";
                }
                return totalProperty;
            }
            set { totalProperty = value; }
        }

        private string rootElement = "Items";

        /// <summary>
        /// Specifies the name of the root element in JSon returned by the data service. Default is Items
        /// </summary>
        [NotifyParentProperty(true)]
        public string RootElement
        {
            get
            {
                if (String.IsNullOrEmpty(rootElement))
                {
                    rootElement = "Items";
                }
                return rootElement;
            }
            set { rootElement = value; }
        }

        private MTFilterPanelLayout filterPanelLayout = MTFilterPanelLayout.MultiColumn;

        /// <summary>
        /// Specifies the layout for the filter pane. Options are SingleColumn or MultiColumn(default)
        /// </summary>
        [NotifyParentProperty(true)]
        public MTFilterPanelLayout FilterPanelLayout
        {
            get { return filterPanelLayout; }
            set { filterPanelLayout = value; }
        }

        private string customImplementationFilePath;

        [NotifyParentProperty(true)]
        public string CustomImplementationFilePath
        {
            get { return customImplementationFilePath; }
          set
          {
            customImplementationFilePath = value;
        }
        }

        /// <summary>
        /// Contains optional javascript includes for the grid that should included
        /// after the grid javascript so they may override existing methods
        /// Multiple includes should be separated with semi-colons (;)
        /// </summary>
        [NotifyParentProperty(true)]
        public List<string> CustomOverrideJavascriptIncludes { get; set; }

        private bool isFilterCollapsed = false;
        /// <summary>
        /// Indicates if the filter pane is shown collapsed or expanded on the initial load.   Default is expanded.
        /// </summary>
        [NotifyParentProperty(true)]
        public bool FilterPanelCollapsed
        {
            get { return isFilterCollapsed; }
            set { isFilterCollapsed = value; }
        }

        private bool enableColumnConfig = true;
        /// <summary>
        /// Sets or gets a value indicating whether or not column configuration should be enabled. Default is enabled.
        /// </summary>
        [NotifyParentProperty(true)]
        public bool EnableColumnConfig
        {
            get { return enableColumnConfig; }
            set { enableColumnConfig = value; }
        }

        private bool enableFilterConfig = true;

        /// <summary>
        /// Indicates if filter configuration (ordering and visibility) is available to the end user.
        /// </summary>
        [NotifyParentProperty(true)]
        public bool EnableFilterConfig
        {
            get { return enableFilterConfig; }
            set { enableFilterConfig = value; }
        }

        private bool enableSaveSearch;
        /// <summary>
        /// Indicates if the end user is allowed to save searches on this page
        /// </summary>
        [NotifyParentProperty(true)]
        public bool EnableSaveSearch
        {
            get { return enableSaveSearch; }
            set { enableSaveSearch = value; }
        }

        private bool enableLoadSearch;
        /// <summary>
        /// Indicates if the end user is allowed to load previously saved searches
        /// </summary>
        [NotifyParentProperty(true)]
        public bool EnableLoadSearch
        {
            get { return enableLoadSearch; }
            set { enableLoadSearch = value; }
        }

        private bool showTopBar = true;

        public bool ShowTopBar
        {
            get { return showTopBar; }
            set { showTopBar = value; }
        }


        private bool showBottomBar = true;

        public bool ShowBottomBar
        {
            get { return showBottomBar; }
            set { showBottomBar = value; }
        }

        private bool showGridFrame = true;

        public bool ShowGridFrame
        {
            get { return showGridFrame; }
            set { showGridFrame = value; }
        }

        private bool showGridHeader = true;

        public bool ShowGridHeader
        {
            get { return showGridHeader; }
            set { showGridHeader = value; }
        }

        private bool showColumnHeaders = true;

        public bool ShowColumnHeaders
        {
            get { return showColumnHeaders; }
            set { showColumnHeaders = value; }
        }

        private bool showFilterPanel = true;

        public bool ShowFilterPanel
        {
            get { return showFilterPanel; }
            set { showFilterPanel = value; }
        }

        private bool resizable = true;
        /// <summary>
        /// Indicates if the search results panel can be resized
        /// </summary>
        [NotifyParentProperty(true)]
        public bool Resizable
        {
            get { return resizable; }
            set { resizable = value; }
        }


        private bool exportable = false;

        /// <summary>
        /// Indicates if data in the grid can be exported to CSV. Default is False
        /// </summary>
        [NotifyParentProperty(true)]
        public bool Exportable
        {
            get { return exportable; }
            set { exportable = value; }
        }

        private bool expandable = false;
        /// <summary>
        /// Indicates whether each row in the grid has a turn-down option.  Grid Elements' ShowInExpander property
        /// defines whether or not that element is shown in the expander
        /// </summary>
        [NotifyParentProperty(true)]
        public bool Expandable
        {
            get { return expandable; }
            set { expandable = value; }
        }

        private string expanderGridLayoutTemplatePath;
        public string ExpanderGridLayoutTemplatePath
        {
            get { return expanderGridLayoutTemplatePath; }
            set { expanderGridLayoutTemplatePath = value; }
        }

        private string expansionCssClass = "";
        [NotifyParentProperty(true)]
        public string ExpansionCssClass
        {
            get { return expansionCssClass; }
            set { expansionCssClass = value; }
        }

        private bool multiSelect = false;

        /// <summary>
        /// Sets or gets the grid item multi-selection.  Default is false
        /// </summary>
        [NotifyParentProperty(true)]
        public bool MultiSelect
        {
            get { return multiSelect; }
            set { multiSelect = value; }
        }

        private MTGridSelectionModel selectionModel = MTGridSelectionModel.Standard;

        /// <summary>
        /// Sets or gets the default selection model for the grid. Options are Standard(default) or Checkbox
        /// </summary>
        [NotifyParentProperty(true)]
        public MTGridSelectionModel SelectionModel
        {
            get { return selectionModel; }
            set { selectionModel = value; }
        }

        private MTAlignmentType buttonAlignment = MTAlignmentType.Center;

        /// <summary>
        /// Sets or gets the alignment of buttons at the bottom of the grid. Default is center aligned
        /// </summary>
        [NotifyParentProperty(true)]
        public MTAlignmentType ButtonAlignment
        {
            get { return buttonAlignment; }
            set { buttonAlignment = value; }
        }

        private MTButtonType buttons;

        /// <summary>
        /// Sets or gets the buttons under the grid. The button handlers should be done externally in JS
        /// </summary>
        [NotifyParentProperty(true)]
        public MTButtonType Buttons
        {
            get { return buttons; }
            set { buttons = value; }
        }

        //sets up default group field
        private string defaultGroupField;

        [NotifyParentProperty(true)]
        public string DefaultGroupField
        {
            get { return defaultGroupField; }
            set { defaultGroupField = value; }
        }

        //sets up default sort field
        private string defaultSortField;

        /// <summary>
        /// Sets or gets the sort field for the initial load of the grid
        /// </summary>
        [NotifyParentProperty(true)]
        public string DefaultSortField
        {
            get { return defaultSortField; }
            set { defaultSortField = value; }
        }

        private MTGridSortDirection defaultSortDirection = MTGridSortDirection.Ascending;

        /// <summary>
        /// Gets or sets default sort direction (Ascending or Descending)
        /// </summary>
        [NotifyParentProperty(true)]
        public MTGridSortDirection DefaultSortDirection
        {
            get { return defaultSortDirection; }
            set { defaultSortDirection = value; }
        }

        private string title;

        /// <summary>
        /// Sets or gets the grid title
        /// </summary>
        [NotifyParentProperty(true)]
        public string Title
        {
            get { return title; }
            set { title = value; }
        }

        private bool displayCount = true;
        /// <summary>
        /// Indicates whether the count of records is displayed in the lower right corner of the grid
        /// </summary>
        [NotifyParentProperty(true)]
        public bool DisplayCount
        {
            get { return displayCount; }
            set { displayCount = value; }
        }

        private List<MTGridNestedParameter> nestedGridParams;
        [NotifyParentProperty(true)]
        public List<MTGridNestedParameter> NestedGridParams
        {
            get
            {
                if (nestedGridParams == null)
                {
                    nestedGridParams = new List<MTGridNestedParameter>();
                }
                return nestedGridParams;
            }
        }

        private ChildGridDefinition subGridDefinition;
        [NotifyParentProperty(true)]
        public ChildGridDefinition SubGridDefinition
        {
            get
            {
                if (subGridDefinition == null)
                {
                    subGridDefinition = new ChildGridDefinition();
                }
                return subGridDefinition;
            }
            set { subGridDefinition = value; }
        }

        private URLParamList dataSourceURLParams;
        [NotifyParentProperty(true)]
        public URLParamList DataSourceURLParams
        {
            get
            {
                if (dataSourceURLParams == null)
                {
                    dataSourceURLParams = new URLParamList();
                }
                return dataSourceURLParams;
            }
        }

        private string dataSourceURL;

        /// <summary>
        /// Path to a REST-ful service that returns data for the grid
        /// </summary>
        [NotifyParentProperty(true)]
        public string DataSourceURL
        {
            get { return dataSourceURL; }
            set { dataSourceURL = value; }
        }

        private string ajaxTimeout = null;

        /// <summary>
        /// Timout for ajax request
        /// </summary>
        [NotifyParentProperty(true)]
        public string AjaxTimeout
        {
            get { return ajaxTimeout; }
            set { ajaxTimeout = value; }
        }

        private string updateURL;

        /// <summary>
        /// Path to a REST-ful service that persists changes made in the editor
        /// </summary>
        [NotifyParentProperty(true)]
        public string UpdateURL
        {
            get { return updateURL; }
            set { updateURL = value; }
        }

        private string xmlPath;

        /// <summary>
        /// Path to XML file that determines the control structure, overriding the ASPX contents
        /// </summary>
        [NotifyParentProperty(true)]
        public string XMLPath
        {
            get { return xmlPath; }
            set { xmlPath = value; }
        }

        private string extensionName;

        [NotifyParentProperty(true)]
        public string ExtensionName
        {
            get { return extensionName; }
            set { extensionName = value; }
        }

        private string templateFileName;

        [NotifyParentProperty(true)]
        public string TemplateFileName
        {
            get { return templateFileName; }
            set { templateFileName = value; }
        }

        private string productViewObjectName;

        [NotifyParentProperty(true)]
        public string ProductViewObjectName
        {
            get { return productViewObjectName; }
            set { productViewObjectName = value; }
        }

        private string productViewAssemblyName;

        [NotifyParentProperty(true)]
        public string ProductViewAssemblyName
        {
            get { return productViewAssemblyName; }
            set { productViewAssemblyName = value; }
        }

        private int pageSize = 10;

        /// <summary>
        /// Sets or gets the number of records on each page. Default is 10
        /// </summary>
        [NotifyParentProperty(true)]
        public int PageSize
        {
            get { return pageSize; }
            set { pageSize = value; }
        }

        private int filterColumnWidth = 350;

        /// <summary>
        /// Width of each column in filter panel section
        /// </summary>
        [NotifyParentProperty(true)]
        public int FilterColumnWidth
        {
            get { return filterColumnWidth; }
            set { filterColumnWidth = value; }
        }

        private int filterLabelWidth = 75;
        [NotifyParentProperty(true)]
        public int FilterLabelWidth
        {
            get { return filterLabelWidth; }
            set { filterLabelWidth = value; }
        }

        private int filterInputWidth = 220;
        [NotifyParentProperty(true)]
        public int FilterInputWidth
        {
            get { return filterInputWidth; }
            set { filterInputWidth = value; }
        }

        private bool isRelationshipCase = false;
        [NotifyParentProperty(true)]
        public bool IsRelationshipCase
        {
          get { return isRelationshipCase; }
          set { isRelationshipCase = value; }
        }

        private bool searchOnLoad = true;
        public bool SearchOnLoad
        {
            get { return searchOnLoad; }
            set { searchOnLoad = value; }
        }

        private string quickEditCapability;
        /// <summary>
        /// gets or sets the capability required to show this feature
        /// </summary>
        public string QuickEditCapability
        {
            get { return quickEditCapability; }
            set { quickEditCapability = value; }
        }

      /// <summary>
      /// Indicates if the end user is allowed to load previously saved searches
      /// </summary>
      [NotifyParentProperty(true)]
      public bool SupportExportSelected { get; set; }


        protected override void Render(HtmlTextWriter writer)
        {
            RenderContents(writer);
        }

        //iterate through list elements end generate ajax requests
        //NOTE: this should be done before control_id replacement
        protected string GenerateFilterEnumRequests()
        {
            String scriptEnum = String.Empty;
            String scriptFull = String.Empty;
            int pos = 0;

            foreach (MTGridDataElement elt in elements)
            {
                if (elt.DataType == MTDataType.List)
                {
                    scriptEnum = SCRIPT_FILTER_ENUM;
                    scriptEnum = scriptEnum.Replace("{filter_enum_path}", "GenericService.aspx?Method=GetEnum&Enum=size"/*elt.FilterEnum.ServicePath*/);
                    scriptEnum = scriptEnum.Replace("{filter_enum_id}", pos.ToString());

                    scriptFull += scriptEnum;

                    pos++;
                }
            }

            return scriptFull;
        }

        /// <summary>
        /// Parses out the index and if it is not numeric, validate the enum and get the proper enum value
        /// </summary>
        /// <param name="dataIndex"></param>
        /// <returns></returns>
        private string FixDataIndexEnums(string dataIndex)
        {
            return dataIndex;
            /*
            int openBracketPos = dataIndex.IndexOf('[');
            if (openBracketPos < 0)
            {
                return dataIndex;
            }

            int closeBracketPos = dataIndex.IndexOf(']', openBracketPos);
            if (closeBracketPos < 0)
            {
                return dataIndex;
            }

            string indexer = dataIndex.Substring(openBracketPos + 1, closeBracketPos - openBracketPos - 1);
            int nIndexer = -1;

            //if a number inside brackets, return data index with that number
            if (Int32.TryParse(indexer, out nIndexer))
            {
                return dataIndex;
            }

            int indexOfLastDot = indexer.LastIndexOf('.');
            if (indexOfLastDot < 0)
            {
                return dataIndex;
            }

            //break the string into class and value
            string className = indexer.Substring(0, indexOfLastDot);
            string valueName = indexer.Substring(indexOfLastDot + 1, indexer.Length - indexOfLastDot - 1);

            //get the list of values in the enum
            Type enumType = EnumHelper.GetEnumTypeByTypeName(className);

            //second attempt, append the prefix
            if (enumType == null)
            {
                string prefix = "MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation";
                enumType = EnumHelper.GetEnumTypeByTypeName(prefix + "." + className);
            }

            if (enumType == null)
            {
                return dataIndex;
            }
            List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

            //match each enum value to the one in data index
            int matchedPosition = -1;
            for (int i = 0; i < enums.Count; i++)
            {
                MetraTech.DomainModel.BaseTypes.EnumData enumData = enums[i];
                if (enumData.EnumInstance.ToString() == valueName)
                {
                    matchedPosition = i;
                }
            }

            //enum not found
            if (matchedPosition < 0)
            {
                return dataIndex;
            }

            //replace the indexer with the enum position
            return dataIndex.Replace(indexer, matchedPosition.ToString());
            */
        }

        public string GenerateColumnModelElement(MTGridDataElement elt)
        {
            StringBuilder sb = new StringBuilder();

            if (elt.IsColumn)
            {
                //string dataIndex = FixDataIndexEnums(elt.DataIndex);

                sb.Append("{dataIndex:'");
                sb.Append(elt.ID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));
                sb.Append("',header:'");
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //sb.Append(elt.HeaderText.Replace("'", "\\'"));
                sb.Append(elt.HeaderText.EncodeForJavaScript());
                sb.Append("',mapping:'");
                sb.Append(elt.DataIndex.Replace("'", "\\'"));
                sb.Append("',id:'");
                sb.Append(elt.ID.Replace("'", "\\'").Replace(".", "#").Replace("/", "#"));
                sb.Append("'");

                if (elt.Width > 0)
                {
                    sb.Append(",width: " + elt.Width.ToString() + "");
                }

                sb.Append(",sortable: " + elt.Sortable.ToString().ToLower());

                sb.Append(",exportable:" + elt.Exportable.ToString().ToLower());

                if (!elt.Resizable)
                {
                    sb.Append(",resizable: " + elt.Resizable.ToString().ToLower());
                }

                if (!elt.ColumnHideable)
                {
                    sb.Append(",hideable:" + elt.ColumnHideable.ToString().ToLower());
                }

                if (elt.Editable)
                {
                    //only the types below can have editors
                    if ((elt.DataType == MTDataType.Boolean) || (elt.DataType == MTDataType.Date)
                        || (elt.DataType == MTDataType.Numeric) || (elt.DataType == MTDataType.String)
                        || (elt.DataType == MTDataType.Account) || (elt.DataType == MTDataType.List))
                    {
                        sb.Append(",editor:");
                        sb.Append(GetEditorForElement(elt));
                    }
                }

                //provide proper rendering for known data types, or use custom renderer if one is provided
                if (elt.DataType == MTDataType.Date)
                {
                    string renderer = (string.IsNullOrEmpty(elt.Formatter))
                                                            ? "DateRenderer" : elt.Formatter.Trim();
                    sb.Append(",renderer:");
                    sb.Append(renderer);
                }
                else if (elt.DataType == MTDataType.Boolean)
                {
                    string renderer = (string.IsNullOrEmpty(elt.Formatter))
                                                                ? "BooleanRenderer" : elt.Formatter.Trim();
                    sb.Append(",renderer:");
                    sb.Append(renderer);
                }

                else if (elt.DataType == MTDataType.String)
                {
                    if (elt.ID.EndsWith("ValueDisplayName"))
                    {
                        string realID = FixID(elt.ID).Replace("ValueDisplayName", "");
                        sb.Append(",renderer:Ext.ux.renderer.ComboEx(enumOptions_");
                        sb.Append(ClientID);
                        sb.Append("['");
                        sb.Append(realID);
                        sb.Append("'])");
                    }

                        //provide currency renderer if the property ends with 'DisplayAmountAsString'
                    else if (elt.ID.ToLower().EndsWith("asstring")
                                        && elt.ID.ToLower() != "asstring")
                    {
                        string renderer = (string.IsNullOrEmpty(elt.Formatter)) ? "CurrencyRenderer" : elt.Formatter.Trim();
                        sb.Append(",renderer:");
                        sb.Append(renderer);
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(elt.Formatter))
                        {
                            sb.Append(",renderer:");
                            sb.Append(elt.Formatter.Trim());
                        }
                    }
                }
                //all other data types
                else
                {
                    //use renderer if one is provided
                    if (!string.IsNullOrEmpty(elt.Formatter))
                    {
                        sb.Append(",renderer:");
                        sb.Append(elt.Formatter.Trim());
                    }
                }

                if (!elt.DefaultColumn)
                {
                    sb.Append(",hidden:" + ((System.Boolean)(!elt.DefaultColumn)).ToString().ToLower());
                }
                sb.Append("}");
            }
            return sb.ToString();
        }


        protected string GetEditorValidatorJSObject(MTGridDataElement elt)
        {
            StringBuilder sb = new StringBuilder();
            if (elt.Editable)
            {
                if (elt.EditorValidation != null)
                {
                    sb.Append("{");
                    sb.Append("editorAllowBlank:");
                    bool bReversedRequired = !elt.EditorValidation.Required;
                    sb.Append(bReversedRequired.ToString().ToLower());

                    sb.Append(",editorMinLength:");
                    sb.Append(elt.EditorValidation.MinLength.ToString());

                    sb.Append(",editorMaxLength:");
                    sb.Append(elt.EditorValidation.MaxLength.ToString());

                    if (!String.IsNullOrEmpty(elt.EditorValidation.MinValue))
                    {
                        sb.Append(",editorMinValue:");
                        if (!Utils.IsNumeric(elt.EditorValidation.MinValue))
                        {
                            sb.Append("'");
                        }
                        sb.Append(elt.EditorValidation.MinValue);
                        if (!Utils.IsNumeric(elt.EditorValidation.MinValue))
                        {
                            sb.Append("'");
                        }
                    }
                    if (!String.IsNullOrEmpty(elt.EditorValidation.MaxValue))
                    {
                        sb.Append(",editorMaxValue:");
                        if (!Utils.IsNumeric(elt.EditorValidation.MaxValue))
                        {
                            sb.Append("'");
                        }
                        sb.Append(elt.EditorValidation.MaxValue);
                        if (!Utils.IsNumeric(elt.EditorValidation.MaxValue))
                        {
                            sb.Append("'");
                        }
                    }

                    if (!String.IsNullOrEmpty(elt.EditorValidation.Regex))
                    {
                        sb.Append(",editorRegex:");
                        sb.Append(elt.EditorValidation.Regex);
                    }

                    if (!String.IsNullOrEmpty(elt.EditorValidation.ValidationFunction))
                    {
                        sb.Append(",editorValidationFunction:'");
                        sb.Append(elt.EditorValidation.ValidationFunction);
                        sb.Append("_");
                        sb.Append(ClientID);
                        sb.Append("'");
                    }

                    if (!String.IsNullOrEmpty(elt.EditorValidation.ValidationType))
                    {
                        sb.Append(",editorVType:'");
                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added JavaScript encoding
                        //sb.Append(elt.EditorValidation.ValidationType.Replace("'", "\\'"));
                        sb.Append(elt.EditorValidation.ValidationType.EncodeForJavaScript());
                        sb.Append("'");
                    }
                    sb.Append("}");

                }
            }
            return sb.ToString();
        }

        protected string GetEditorForElement(MTGridDataElement elt)
        {
            StringBuilder sb = new StringBuilder();

            switch (elt.DataType)
            {
                case MTDataType.Numeric:
                    sb.Append("GetNumericEditor_" + ClientID + "(");
                    sb.Append(GetEditorValidatorJSObject(elt));
                    sb.Append(")");
                    break;
                case MTDataType.String:
                    if (elt.ID.EndsWith("ValueDisplayName"))
                    {
                        string realID = FixID(elt.ID).Replace("ValueDisplayName", "");
                        sb.Append("GetComboEditor_" + ClientID + "(enumOptions_" + ClientID + "['" + realID + "'])");
                    }
                    else
                    {
                        sb.Append("GetTextEditor_" + ClientID + "(");
                        sb.Append(GetEditorValidatorJSObject(elt));
                        sb.Append(")");
                    }
                    break;
                case MTDataType.Date:
                    sb.Append("GetDateEditor_" + ClientID + "(");
                    sb.Append(GetEditorValidatorJSObject(elt));
                    sb.Append(")");
                    break;
                case MTDataType.List:
                    sb.Append("GetComboEditor_" + ClientID + "(enumOptions_" + ClientID + "['" + FixID(elt.ID) + "'])");
                    break;
                case MTDataType.Boolean:
                    sb.Append("GetBooleanEditor_" + ClientID + "()");
                    break;
                case MTDataType.Account:
                    sb.Append("GetAccountEditor_" + ClientID + "(");
                    sb.Append(GetEditorValidatorJSObject(elt));
                    sb.Append(")");
                    break;
                default:
                    break;
            }

            return sb.ToString();
        }

        /* NOT USED
         * cookie is in the following format:
         *  comma separated list of items.  Each items is dataIndex of the column and 0/1 (0=hidden, 1=visible), separated by semicolon
         * Items are ordered in the order selected by user.
         */
        protected void LoadColumnCookie()
        {
            HttpCookie columnCookie = null;
            if (!this.DesignMode)
            {
                columnCookie = Page.Request.Cookies.Get(GetCookiePrefix() + "columns");
            }

            if (columnCookie == null)
            {
                return;
            }

            string cookieData = columnCookie.Value;
            cookieData = HttpUtility.UrlDecode(cookieData);

            if (String.IsNullOrEmpty(cookieData))
            {
                return;
            }
            int actualPosition = 0;

            string[] cookieEltArr = cookieData.Split(',');
            for (int i = 0; i < cookieEltArr.Length; i++)
            {
                string curCookieElt = cookieEltArr[i];

                string[] colInfoArr = curCookieElt.Split(':');

                if (colInfoArr.Length >= 2)
                {
                    string dataIndex = colInfoArr[0];
                    string isVisible = colInfoArr[1];

                    //add position to element associated with dataIndex
                    MTGridDataElement curColumn = GetColumnByDataIndex(dataIndex);

                    //make sure column has not been removed
                    if (curColumn != null)
                    {
                        curColumn.Position = actualPosition;
                        curColumn.DefaultColumn = (isVisible == "1") ? true : false;

                        actualPosition++;
                    }
                }
            }

            this.Elements.Sort(new GridElementSorter());
        }

        public bool ElementsContainsID(string sItem)
        {
            foreach (MTGridDataElement elt in this.Elements)
            {
                if (elt.ID.ToLower() == sItem.ToLower())
                {
                    return true;
                }
            }

            return false;
        }

        protected MTGridDataElement GetColumnByDataIndex(string dataIndex)
        {
            foreach (MTGridDataElement elt in this.Elements)
            {
                if (elt.DataIndex.ToLower() == dataIndex.ToLower())
                {
                    return elt;
                }
            }

            return null;
        }

        public string GenerateColumnModel()
        {
            //LoadColumnCookie();

            StringBuilder sb = new StringBuilder();

            //use specified ordering
            if (this.DefaultColumnOrder.Count != 0)
            {
                foreach (Field field in DefaultColumnOrder)
                {
                    MTGridDataElement elt = FindElementByID(field.Name);

                    if ((elt != null) && (elt.IsColumn))
                    {
                        string elementConfig = GenerateColumnModelElement(elt);
                        if (elementConfig.Length > 0)
                        {
                            if (sb.Length > 0)
                            {
                                sb.Append(",");
                            }

                            sb.Append(elementConfig);
                        }
                    }
                }
            }
            else
            //ordering not specified, use default
            {
                for (int i = 0; i < elements.Count; i++)
                {
                    MTGridDataElement elt = (MTGridDataElement)elements[i];

                    string elementConfig = GenerateColumnModelElement(elt);
                    if (elementConfig.Length > 0)
                    {
                        if (sb.Length > 0)
                        {
                            sb.Append(",");
                        }

                        sb.Append(elementConfig);
                    }
                }
            }
            return sb.ToString();
        }

        protected string GenerateRecordStructure()
        {
            StringBuilder sb = new StringBuilder();
            foreach (MTGridDataElement elt in this.Elements)
            {
                if (!String.IsNullOrEmpty(elt.DataIndex))
                {
                    if (sb.Length > 0)
                    {
                        sb.Append(",");
                    }

                    if (elt.RecordElement)
                    {
                        //string dataIndex = FixDataIndexEnums(elt.DataIndex);

                        sb.Append("{name:'");
                        sb.Append(elt.ID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));
                        sb.Append("',mapping:'");
                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added JavaScript encoding
                        //sb.Append(elt.DataIndex.Replace("'", "\\'")); //this is the only place where data index is used!!
                        sb.Append(elt.DataIndex.EncodeForJavaScript()); //this is the only place where data index is used!!
                        sb.Append("'");
                        if (elt.DataIndex.Contains("/"))
                        {
                            sb.Append(",useJPath:true");
                        }
                        sb.Append("}");
                    }
                }
            }
            return sb.ToString();
        }

        protected string GenerateGroupInfo()
        {
            String s = String.Empty;

            if (!String.IsNullOrEmpty(this.defaultGroupField))
            {
                if (ElementsContainsID(defaultGroupField))
                {
                    s = ",groupField:'" + defaultGroupField + "'";
                }
            }

            return s;
        }


        protected string GenerateSubGrid()
        {
            //exit if subgrid not specified
            if (string.IsNullOrEmpty(SubGridDefinition.Id))
            {
                return "";
            }
            StringBuilder sb = new StringBuilder();

            if (SubGridDefinition.LoadSubGridAutomaticallyWhenParentRowSelected)
            {
                string sRowSelected =
                    @"//Hook up row selected to reload details grid
    Ext.onReady(function(){

          var grid = grid_{parent_control_id};
          grid.on('rowclick', function(grid, rowIndex, e) {
          grid.getSelectionModel().selectRow(rowIndex);
          var row = grid.store.getAt(rowIndex);

          onShowChildGridForParentGridRow_{parent_control_id}(row);
          });
  });";
                sb.Append(sRowSelected);
            }

            sb.Append(
                @"
  function onShowChildGridForParentGridRow_{parent_control_id}(row)
  {
    //Set filter based on current row
");

            //      string sFilter =
            //        @"    var elm = Ext.getCmp('filter_' + 'stagename' + '_{parent_control_id}');
            //    if (elm!=null)
            //      elm.setValue(row.data.stagename);
            //      ";
            string sFilter =
                @"    elm = Ext.getCmp('filter_{0}_{{child_control_id}}');
    if (elm!=null)
      elm.setValue({1});
      ";

            if (SubGridDefinition.ParentGridParameters.Count > 0)
                sb.Append(@"    var elm;" + System.Environment.NewLine);

            foreach (NestedGridParameterLayout nparam in SubGridDefinition.ParentGridParameters)
            {
                string paramValue = nparam.ParameterValue;
                if (!string.IsNullOrEmpty(paramValue))
                {
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //paramValue = "'" + paramValue + "'";
                    paramValue = "'" + (paramValue ?? string.Empty).EncodeForJavaScript() + "'";
                }
                else
                {
                    string parentRowName = nparam.ElementID;
                    if (string.IsNullOrEmpty(parentRowName))
                    {
                        parentRowName = nparam.ParameterName;
                    }
                    if (string.IsNullOrEmpty(parentRowName))
                        continue;

                    paramValue = "row.data." + parentRowName;
                }

                //Code assumes we are setting the filter so no need to check nparam
                string childParamName = nparam.ParameterName;
                sb.AppendFormat(sFilter, childParamName, paramValue);
            }

            sb.Append(
                @"
    //After setting the filter, ask the child grid to refresh
    Reload_{child_control_id}();
  }");

            sb = sb.Replace("{parent_control_id}", this.ClientID);
            sb = sb.Replace("{child_control_id}", "ctl00_ContentPlaceHolder1_SummaryDetailsGrid");

            return sb.ToString();
        }

        /*generate the string in the following format:
        * 
        * var expander_CONTROLID=new Ext.grid.RowExpander({tpl : GetExpanderTemplate_CONTROLID()});
        */
        protected string GenerateRowExpander()
        {
            //exit if non-expandable
            if (!expandable)
            {
                return "''";
            }
            StringBuilder sb = new StringBuilder();

            if (string.IsNullOrEmpty(ExpanderGridLayoutTemplatePath))
            {
                sb.Append("new Ext.grid.RowExpander({lazyRender:true,enableCaching:false,tpl : expanderTemplate_");
                sb.Append(this.ClientID);
                sb.Append("})");
            }
            else
            {
                string s = @" new Ext.ux.grid.RowExpander({
			    tpl              : '<div class=""ux-row-expander-box""></div>',
			    actAsTree        : true,
			    treeLeafProperty : 'is_leaf',
			    listeners        : {
				    expand : function( expander, record, body, rowIndex) {
					    getGrid_{control_id}({grid_width},record, rowIndex,  Ext.get( this.grid.getView().getRow( rowIndex)).child( '.ux-row-expander-box'));
				    }
			    }
		    }); //nested grid expander
        ";
                s = s.Replace("{control_id}", this.ClientID);
                s = s.Replace("{grid_width}", this.Width.Value.ToString());
                sb.Append(s);
            }
            return sb.ToString();
        }

        protected string GenerateInternalGrid()
        {
            if (string.IsNullOrEmpty(ExpanderGridLayoutTemplatePath))
            {
                return string.Empty;
            }

            MTGridSerializer ser = new MTGridSerializer();
            GridLayout gl = ser.Load(ExpanderGridLayoutTemplatePath);
            if (gl == null)
            {
                return string.Empty;
            }

            InsertEnumNodes(gl);

            string getGridJSFunction = @"
function getGrid_{control_id}(gridWidth, record, rowIndex, element)
{
  var selModel = new Ext.grid.RowSelectionModel({singleSelect:false});

  var myRecord = Ext.data.Record.create([
    {nested_grid_record}
    ]);

  var reader = new Ext.ux.JPathJsonReader({
				id:   {nested_grid_identity_field},
				totalProperty: '{nested_grid_total_property}',
				root: '{nested_grid_root}'
			}, 
      myRecord
      );
      
  var store = new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({
			url:'{nested_grid_data_source_url}',
      method:'POST'
		}),
		reader: reader,
    remoteSort: true,
    sm:selModel
  });
 
  var expander = new Ext.ux.grid.RowExpander({
			tpl              : '<div class=""ux-row-expander-box""></div>',
			actAsTree        : true,
			treeLeafProperty : 'is_leaf',
			listeners        : {
				expand : function( expander, record, body, rowIndex) {
					getGrid_{control_id}(gridWidth - 40, record, rowIndex, Ext.get( this.grid.getView().getRow( rowIndex)).child( '.ux-row-expander-box'));
				}
			}
		});

  var cm =new Ext.grid.ColumnModel([expander,
    {nested_grid_column_model}
  ]);
  var grid1 = new Ext.grid.EditorGridPanel({
    sm: selModel,
    id:'detailGrid' + rowIndex,
    cm:cm,
    plugins:expander,
    ds:store,
    height:{nested_grid_height},
    width:gridWidth - 40,
    collapsible:false,
    bbar:new Ext.PagingToolbar({
      displayInfo:true,
      store: store,
      pageSize: {nested_grid_page_size}        
    })
  });
  
  store.load({nested_url_params});
  element && grid1.render( element);

  nested_grid_{control_id} = grid1;
  return grid1;
}

";
            string jsCode = getGridJSFunction.Replace("{nested_grid_identity_field}", GenerateIdentityField(gl));
            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added JavaScript encoding
            //jsCode = jsCode.Replace("{nested_grid_total_property}", gl.TotalProperty);
            //jsCode = jsCode.Replace("{nested_grid_root}", gl.RootElement);
            //jsCode = jsCode.Replace("{nested_grid_data_source_url}", gl.DataSourceURL);
            jsCode = jsCode.Replace("{nested_grid_total_property}", (gl.TotalProperty ?? string.Empty).EncodeForJavaScript());
            jsCode = jsCode.Replace("{nested_grid_root}", (gl.RootElement ?? string.Empty).EncodeForJavaScript());
            jsCode = jsCode.Replace("{nested_grid_data_source_url}", (gl.DataSourceURL ?? string.Empty).EncodeForJavaScript());
            jsCode = jsCode.Replace("{nested_grid_page_size}", gl.PageSize.ToString());
            jsCode = jsCode.Replace("{nested_grid_height}", ((gl.PageSize * 25) + 60).ToString());
            jsCode = jsCode.Replace("{nested_grid_width}", gl.Width);
            jsCode = jsCode.Replace("{nested_grid_record}", GenerateRecordStructure(gl));
            jsCode = jsCode.Replace("{nested_grid_column_model}", GenerateColumnModel(gl));
            jsCode = jsCode.Replace("{nested_url_params}", GenerateNestedURLParams());
            jsCode = jsCode.Replace("{control_id}", this.ClientID);

            return jsCode;
        }

        private string GenerateNestedURLParams()
        {
            if (NestedGridParams.Count == 0)
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder();

            sb.Append("{params:{");
            int i = 0;
            foreach (MTGridNestedParameter nparam in NestedGridParams)
            {
                if (!string.IsNullOrEmpty(nparam.ParamName))
                {
                    MTGridDataElement outerElement = null;

                    if (!string.IsNullOrEmpty(nparam.ElementID))
                    {
                        outerElement = FindElementByID(nparam.ElementID);
                    }

                    if (nparam.UseParamAsFilter)
                    {
                        if (string.IsNullOrEmpty(nparam.ElementID))
                        {
                            continue;
                        }

                        if (i > 0)
                        {
                            sb.Append(",");
                        }

                        sb.Append("'filter[" + i.ToString() + "][data][comparison]':'eq',");
                        sb.Append("'filter[" + i.ToString() + "][data][type]':'");
                        if (outerElement.DataType.ToString().ToLower() == "account")
                        {
                            sb.Append("numeric");
                        }
                        else
                        {
                            sb.Append(outerElement.DataType.ToString().ToLower());
                        }
                        sb.Append("',");
                        sb.Append("'filter[" + i.ToString() + "][data][value]':");

                        sb.Append("record.data[\"");
                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added JavaScript encoding
                        //sb.Append(nparam.ElementID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));
                        sb.Append(nparam.ElementID.EncodeForJavaScript().Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));
                        sb.Append("\"],");

                        //sb.Append("'filter[" + i.ToString() + "][field]':'" + nparam.ParamName + "'");
                        sb.Append("'filter[" + i.ToString() + "][field]':'" + (nparam.ParamName ?? string.Empty).EncodeForJavaScript() + "'");

                        i++;
                    }

                        //parameters are hard-coded
                    else
                    {
                        if (i > 0)
                        {
                            sb.Append(",");
                        }
                        sb.Append(nparam.ParamName);
                        sb.Append(":");


                        if (outerElement == null)
                        {
                            //if outer element is invalid, use Parameter Value
                            sb.Append("'");
                            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                            // Added JavaScript encoding
                            //sb.Append(nparam.ParamValue.Replace("'", "\\'"));
                            sb.Append(nparam.ParamValue.EncodeForJavaScript());
                            sb.Append("'");
                        }
                        else
                        {
                            if (!string.IsNullOrEmpty(nparam.ElementID))
                            {
                                continue;
                            }

                            sb.Append("record.data[\"");
                            sb.Append(nparam.ElementID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));
                            sb.Append("\"]");
                        }

                        i++;

                    } //paramAsFilter = false
                } //ParamName length check
            }

            sb.Append("} }");

            return sb.ToString();
        }

        /// <summary>
        /// Look for enum nodes and insert ValueDisplayName elements
        /// </summary>
        /// <param name="gl"></param>
        private void InsertEnumNodes(GridLayout gl)
        {
            MTGridSerializer ser = new MTGridSerializer();

            //foreach (ElementLayout elt in gl.Elements)
            for (int i = 0; i < gl.Elements.Count; i++)
            {
                ElementLayout elt = gl.Elements[i];

                bool bIsEnum = false;
                if (elt.DataType == "List")
                {
                    if (ser.IsEnumField(gl, elt, elt.ID))
                    {
                        bIsEnum = true;
                    }
                }

                //need to create a new element and insert it into collection
                if (bIsEnum)
                {
                    ElementLayout enumElement = new ElementLayout();

                    //copy properties into the new element
                    enumElement.ID = elt.ID + "ValueDisplayName";
                    enumElement.DataIndex = elt.DataIndex + "ValueDisplayName";
                    enumElement.AssemblyFilename = elt.AssemblyFilename;
                    enumElement.ColumnHideable = elt.ColumnHideable;
                    enumElement.DataType = "String";
                    enumElement.DefaultColumn = elt.DefaultColumn;
                    enumElement.DefaultFilter = elt.DefaultFilter;
                    enumElement.DropdownItems = elt.DropdownItems;
                    enumElement.EditorValidation = elt.EditorValidation;
                    enumElement.ElementValue = elt.ElementValue;
                    enumElement.ElementValue2 = elt.ElementValue2;
                    enumElement.Exportable = elt.Exportable;
                    enumElement.Filterable = false;
                    enumElement.FilterEnum = elt.FilterEnum;
                    enumElement.FilterHideable = elt.FilterHideable;
                    enumElement.FilterLabel = elt.FilterLabel;
                    enumElement.FilterOperation = elt.FilterOperation;
                    enumElement.FilterReadOnly = elt.FilterReadOnly;
                    enumElement.HeaderText = elt.HeaderText;
                    enumElement.IsColumn = elt.IsColumn;
                    enumElement.IsIdentity = false;
                    enumElement.LabelSource = elt.LabelSource;
                    enumElement.ObjectName = elt.ObjectName;
                    enumElement.ReadOnly = elt.ReadOnly;
                    enumElement.RecordElement = elt.RecordElement;
                    enumElement.RequiredFilter = elt.RequiredFilter;
                    enumElement.Resizable = elt.Resizable;
                    enumElement.ShowInExpander = elt.ShowInExpander;
                    enumElement.Sortable = elt.Sortable;
                    enumElement.Width = elt.Width;

                    int curIndex = gl.Elements.IndexOf(elt);
                    gl.Elements.Insert(curIndex, enumElement);

                    //override the original element if it is an enum
                    elt.IsColumn = false;

                    i = i + 1;

                }
            }
        }

        /// <summary>
        /// This overload is used solely for the nested grid
        /// </summary>
        /// <param name="gl"></param>
        /// <returns></returns>
        private string GenerateColumnModel(GridLayout gl)
        {
            StringBuilder sb = new StringBuilder();
            MTGridSerializer ser = new MTGridSerializer();

            for (int i = 0; i < gl.Elements.Count; i++)
            {
                ElementLayout elt = (ElementLayout)gl.Elements[i];

                //skip if not a column 
                if ((!elt.IsColumn) || (elt.ID.ToLower() == "navigate") || (elt.ID.ToLower() == "options"))
                {
                    continue;
                }

                string elementConfig = GenerateColumnModelElement(elt);
                if (elementConfig.Length > 0)
                {
                    if (sb.Length > 0)
                    {
                        sb.Append(",");
                    }
                }
                sb.Append(elementConfig);
            }
            return sb.ToString();
        }

        private string GenerateColumnModelElement(ElementLayout elt)
        {
            StringBuilder sb = new StringBuilder();
            MTGridSerializer ser = new MTGridSerializer();

            if (elt.IsColumn && elt.DefaultColumn)
            {
                //string dataIndex = FixDataIndexEnums(elt.DataIndex);

                sb.Append("{dataIndex:'");
                sb.Append(elt.ID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));

                if (!string.IsNullOrEmpty(elt.HeaderText) && !string.IsNullOrEmpty(elt.HeaderText.Value))
                {
                    sb.Append("',header:'");
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append(elt.HeaderText.Value.Replace("'", "\\'"));
                    sb.Append(elt.HeaderText.Value.EncodeForJavaScript());
                }
                else
                {
                    sb.Append("',header:'");
                    //sb.Append(ser.GetElementDisplayName(elt, null).Replace("'", "\\'"));
                    sb.Append(ser.GetElementDisplayName(elt, null).EncodeForJavaScript());
                }

                if (!string.IsNullOrEmpty(elt.DataIndex))
                {
                    sb.Append("',mapping:'");
                    //sb.Append(elt.DataIndex.Replace("'", "\\'"));
                    sb.Append(elt.DataIndex.EncodeForJavaScript());
                }

                sb.Append("',id:'");
                sb.Append(elt.ID.Replace("'", "\\'").Replace(".", "#").Replace("/", "#"));
                sb.Append("'");

                if (elt.Width > 0)
                {
                    sb.Append(",width: " + elt.Width.ToString() + "");
                }

                sb.Append(",sortable: " + elt.Sortable.ToString().ToLower());

                sb.Append(",exportable:" + elt.Exportable.ToString().ToLower());

                if (!elt.Resizable)
                {
                    sb.Append(",resizable: " + elt.Resizable.ToString().ToLower());
                }

                if (!elt.ColumnHideable)
                {
                    sb.Append(",hideable:" + elt.ColumnHideable.ToString().ToLower());
                }

                //provide default date rendering for Date data types
                if (elt.DataType == "Date")
                {
                    string renderer =
                        (string.IsNullOrEmpty(elt.Formatter)) ? "DateRenderer" : elt.Formatter.Trim();
                    sb.Append(",renderer:");
                    sb.Append(renderer);
                }
                else if (elt.DataType == "Boolean")
                {
                    string renderer =
                        (string.IsNullOrEmpty(elt.Formatter)) ? "BooleanRenderer" : elt.Formatter.Trim();
                    sb.Append(",renderer:");
                    sb.Append(renderer);
                }
                /*else if (elt.DataType == "String")
                {
                    if (elt.ID.EndsWith("ValueDisplayName"))
                    {
                        string realID = FixID(elt.ID).Replace("ValueDisplayName", "");
                        sb.Append(",renderer:Ext.ux.renderer.ComboEx(enumOptions_");
                        sb.Append(ClientID);
                        sb.Append("['");
                        sb.Append(realID);
                        sb.Append("'])");
                    }
          
                }*/
                else
                {
                    if (!string.IsNullOrEmpty(elt.Formatter))
                    {
                        sb.Append(",renderer:");
                        sb.Append(elt.Formatter.Trim());
                    }
                }


                if (!elt.DefaultColumn)
                {
                    sb.Append(",hidden:" + ((System.Boolean)(!elt.DefaultColumn)).ToString().ToLower());
                }
                sb.Append("}");
            }
            return sb.ToString();
        }

        private string GenerateRecordStructure(GridLayout gl)
        {
            StringBuilder sb = new StringBuilder();
            foreach (ElementLayout elt in gl.Elements)
            {
                if (sb.Length > 0)
                {
                    sb.Append(",");
                }

                string recordElement = GenerateRecordElement(elt);
                if (!string.IsNullOrEmpty(recordElement))
                {
                    sb.Append(recordElement);


                }
            }
            return sb.ToString();
        }

        private string GenerateRecordElement(ElementLayout elt)
        {
            StringBuilder sb = new StringBuilder();

            if (!String.IsNullOrEmpty(elt.DataIndex))
            {


                if (elt.RecordElement)
                {
                    sb.Append("{name:'");
                    sb.Append(elt.ID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));
                    sb.Append("',mapping:'");
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append(elt.DataIndex.Replace("'", "\\'")); //this is the only place where data index is used!!
                    sb.Append(elt.DataIndex.EncodeForJavaScript()); //this is the only place where data index is used!!
                    sb.Append("'");
                    if (elt.DataIndex.Contains("/"))
                    {
                        sb.Append(",useJPath:true");
                    }
                    sb.Append("}");
                }
            }

            return sb.ToString();
        }

        protected string GenerateIdentityField(GridLayout gl)
        {
            StringBuilder sb = new StringBuilder();
            foreach (ElementLayout elt in gl.Elements)
            {
                if (sb.Length > 0)
                {
                    sb.Append(",");
                }

                if (elt.IsIdentity)
                {
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append("'" + elt.DataIndex + "'");
                    sb.Append("'" + (elt.DataIndex ?? string.Empty).EncodeForJavaScript() + "'");
                    break;
                }
            }
            //CORE-5316 MTFilterGrid has render error in case no one column has IsIdentity is TRUE 
            return sb.ToString() == string.Empty ? "''" : sb.ToString();
        }

        protected string GenerateSortInfo()
        {
            StringBuilder sb = new StringBuilder();
            if ((!String.IsNullOrEmpty(this.defaultSortField)) && (ElementsContainsID(defaultSortField)))
            {
                //initialize to ascending
                MTGridSortDirection dir = this.defaultSortDirection;

                //generate string
                sb.Append(",sortInfo:{field:'");
                sb.Append(this.defaultSortField);
                sb.Append("',direction:'");
                String sDir = (dir == MTGridSortDirection.Ascending) ? "ASC" : "DESC";
                sb.Append(sDir);
                sb.Append("'}");
            }
            return sb.ToString();
        }

        protected string GenerateIdentityField()
        {
            StringBuilder sb = new StringBuilder();
            foreach (MTGridDataElement elt in this.Elements)
            {
                if (sb.Length > 0)
                {
                    sb.Append(",");
                }

                if (elt.IsIdentity)
                {
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append("'" + elt.DataIndex + "'");
                    sb.Append("'" + (elt.DataIndex ?? string.Empty).EncodeForJavaScript() + "'");
                    break;
                }
            }
            //CORE-5316 MTFilterGrid has render error in case no one column has IsIdentity is TRUE 
            return sb.ToString() == string.Empty ? "''" : sb.ToString();
        }

        //parse out filename from path
        protected string ParseFilename(string sPath)
        {
            String fileName = String.Empty;
            int startPos = 0;
            int endPos = 0;

            if (String.IsNullOrEmpty(sPath))
            {
                return fileName;
            }

            //advance to the next char after last slash, or 0'th char if no slashes
            startPos = sPath.LastIndexOf('/') + 1;

            //find the last dot to strip out extension
            endPos = sPath.LastIndexOf('.', startPos);

            //if no trailing dot, assume it's after the last char
            if (endPos < 0)
            {
                endPos = sPath.Length;
            }

            //parse out the filename
            fileName = sPath.Substring(startPos, endPos - startPos);

            //replace all remaining dots with underscores
            fileName = fileName.Replace('.', '_');

            return fileName;
        }

        /// <summary>
        /// Generates the options key value pairs that is used in dropdowns.  The format is
        /// options:[['0','CoreSubscriber'],['1','DeptAcct']]
        /// </summary>
        /// <param name="elt">Current element to process</param>
        /// <returns></returns>
        protected string GenerateOptionsValues(MTGridDataElement elt)
        {
            //only applies to lists
            if (elt.DataType != MTDataType.List)
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder();
            string defaultOption = String.Empty;

            sb.Append(",options:[");

            //determine the proper enum type
            Type enumType = null;
            if (!String.IsNullOrEmpty(elt.FilterEnum.EnumClassName))
            {
                enumType = EnumHelper.GetEnumTypeByTypeName(elt.FilterEnum.EnumClassName);
            }

            //if enum type could not be determined by class name use enumSpace/enumType combo
            if (enumType == null)
            {
                enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(elt.FilterEnum.EnumSpace, elt.FilterEnum.EnumType, Path.GetDirectoryName(new Uri(this.GetType().Assembly.CodeBase).AbsolutePath));
            }

            if (enumType != null)
            {
                List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

                int nCount = 0;
                foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
                {
                    //insert artificial clear entry
                    if (elt.MultiValue)
                    {
                        if (nCount > 0)
                        {
                            sb.Append(",");
                        }
                    }
                    else
                    {
                        if (nCount == 0)
                        {
                            sb.Append("['','--']");
                        }
                        if (enums.Count > 0)
                        {
                            sb.Append(",");
                        }
                    }

                    string optionValue = (elt.FilterEnum.UseEnumValue == true) ?
                            EnumHelper.GetValueByEnum(enumData.EnumInstance).ToString() :
                            EnumHelper.GetDbValueByEnum(enumData.EnumInstance).ToString();

                    sb.Append("['");
                    sb.Append(optionValue);
                    sb.Append("','");
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append(enumData.DisplayName.Replace("'", "\\'"));
                    sb.Append(enumData.DisplayName.EncodeForJavaScript());
                    sb.Append("']");

                    //check if current item is default, and if so, remember the value (not display name)
                    if (!String.IsNullOrEmpty(elt.FilterEnum.DefaultValue))
                    {
                        if (elt.FilterEnum.DefaultValue == enumData.DisplayName)
                        {
                            defaultOption = EnumHelper.GetValueByEnum(enumData.EnumInstance).ToString();
                        }
                    }

                    nCount++;
                }
            }
            //Dropdown list items are present
            else
            {
                if (elt.FilterDropdownItems.Count > 0)
                {
                    for (int i = 0; i < elt.FilterDropdownItems.Count; i++)
                    {
                        String key = elt.FilterDropdownItems[i].Key;
                        String value = elt.FilterDropdownItems[i].Value;

                        //insert artificial clear entry
                        if (!elt.MultiValue)
                        {
                            if (i == 0)
                            {
                                sb.Append("['','--']");
                                sb.Append(",");
                            }
                        }

                        if (i > 0)
                        {
                            sb.Append(",");
                        }

                        sb.Append("['");
                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added JavaScript encoding
                        //sb.Append(key.Replace("'", "\\'"));
                        sb.Append(key.EncodeForJavaScript());
                        sb.Append("','");
                        //sb.Append(value.Replace("'", "\\'"));
                        sb.Append(value.EncodeForJavaScript());
                        sb.Append("']");
                    }
                }
            }

            sb.Append("]");

            //set up value if available
            if (!String.IsNullOrEmpty(defaultOption))
            {
                //sb.Append(",filterValue:'" + defaultOption.Replace("'", "\\'") + "'");
                sb.Append(",filterValue:'" + defaultOption.EncodeForJavaScript() + "'");
            }

            return sb.ToString();
        }


        protected string GenerateSingleFilter(MTGridDataElement elt, int position)
        {
            StringBuilder sb = new StringBuilder();

            if (!elt.Filterable)
            {
                return string.Empty;
            }


            //generate output in format {type:'xxx',dataIndex:'yyy',filterLabel:'xx',showFilter:'xx',filterValue:'xx'}
            sb.Append("{type:'");
            sb.Append(elt.DataType.ToString().ToLower());

            sb.Append("',position:");
            sb.Append(position.ToString());

            sb.Append(",dataIndex:'");
            sb.Append(elt.ID.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#"));

            sb.Append("',filterLabel:'");
            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
            // Added JavaScript encoding
            //sb.Append(elt.FilterLabel.Replace("'", "\\'"));
            sb.Append(elt.FilterLabel.EncodeForJavaScript());

            sb.Append("',showFilter:");
            sb.Append(elt.DefaultFilter.ToString().ToLower());

            sb.Append(",required:");
            sb.Append(elt.RequiredFilter.ToString().ToLower());

            sb.Append(",filterHideable:");
            sb.Append(elt.FilterHideable.ToString().ToLower());

            sb.Append(",readonly:");
            sb.Append(elt.FilterReadOnly.ToString().ToLower());

            if ((elt.DataType == MTDataType.Numeric) || (elt.DataType == MTDataType.String))
            {
                sb.Append(",rangeFilter:");
                sb.Append(elt.RangeFilter.ToString().ToLower());
            }

            //set up the value attribute
            if (!String.IsNullOrEmpty(elt.ElementValue))
            {
                sb.Append(",filterValue:");

                //for Lists, it should come from defaultOption[elementID]
                if (elt.DataType == MTDataType.List)
                {
                    sb.Append("defaultOption_");
                    sb.Append(ClientID);
                    sb.Append("['");
                    sb.Append(FixID(elt.ID));
                    sb.Append("']");
                }

                    //for all other types it should be whatever was specified
                else
                {
                    sb.Append("'");
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append(Page.Server.HtmlEncode(elt.ElementValue).Replace("'", "\\'"));
                    sb.Append(Page.Server.HtmlEncode(elt.ElementValue).EncodeForHtml().EncodeForJavaScript());
                    sb.Append("'");
                }
            }

            if (!String.IsNullOrEmpty(elt.ElementValue2))
            {
                sb.Append(",filterValue2:'");
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //sb.Append(Page.Server.HtmlEncode(elt.ElementValue2).Replace("'", "\\'"));
                sb.Append(Page.Server.HtmlEncode(elt.ElementValue2).EncodeForJavaScript());
                sb.Append("'");
            }

            //set filter operation
            sb.Append(",filterOperation:'");
            sb.Append(GetFilterOperationString(elt.FilterOperation));
            sb.Append("'");


            //additional code for the lists
            if (elt.DataType == MTDataType.List)
            {
                sb.Append(",multiValue:");
                sb.Append(elt.MultiValue.ToString().ToLower());

                //sb.Append(GenerateOptionsValues(elt));
                sb.Append(",options:enumOptions_");
                sb.Append(this.ClientID);
                sb.Append("['");
                sb.Append(FixID(elt.ID));
                sb.Append("']");

            }//end list type

            sb.Append("}");
            return sb.ToString();
        }

        /// <summary>
        /// Generate javascript containing filter information
        /// </summary>
        /// <returns></returns>
        protected string GenerateGridFilters()
        {
            StringBuilder sb = new StringBuilder();
            int position = 0;

            if (this.Elements != null)
            {
                if (DefaultFilterOrder.Count != 0)
                {
                    foreach (Field field in DefaultFilterOrder)
                    {
                        MTGridDataElement elt = FindElementByID(field.Name);
                        if ((elt != null) && (elt.Filterable))
                        {
                            if (sb.Length > 0)
                            {
                                sb.Append(",");
                            }
                            sb.Append(GenerateSingleFilter(elt, position));

                            position++;
                        }
                    }
                }
                else
                {
                    foreach (MTGridDataElement elt in this.Elements)
                    {
                        if (elt.Filterable)
                        {
                            if (sb.Length > 0)
                            {
                                sb.Append(",");
                            }
                            sb.Append(GenerateSingleFilter(elt, position));

                            position++;
                        }
                    }
                }
            }
            return sb.ToString();
        }

        private string GetFilterOperationString(MTFilterOperation op)
        {
            string opString = "eq";

            switch (op)
            {
                case MTFilterOperation.Equal:
                    opString = "eq";
                    break;

                case MTFilterOperation.Greater:
                    opString = "gt";
                    break;

                case MTFilterOperation.GreaterOrEqual:
                    opString = "gte";
                    break;

                case MTFilterOperation.Less:
                    opString = "lt";
                    break;

                case MTFilterOperation.LessOrEqual:
                    opString = "lte";
                    break;

                case MTFilterOperation.Like:
                    opString = "lk";
                    break;

                case MTFilterOperation.NotEqual:
                    opString = "ne";
                    break;

                default:
                    opString = "eq";
                    break;
            }

            return opString;
        }

        protected int GetNumListElements()
        {
            int numCalls = 0;
            foreach (MTGridDataElement elt in elements)
            {
                if (elt.DataType == MTDataType.List)
                {
                    numCalls++;
                }
            }

            //always return zero
            return 0;
        }

        //generates sm: Ext.grid.<Row><Checkbox>SelectionModel({singleSelect:true})
        protected string GenerateSelectionModel()
        {
            StringBuilder sb = new StringBuilder();

            sb.Append("new Ext.grid.");
            switch (SelectionModel)
            {
                case MTGridSelectionModel.Standard:
                    sb.Append("RowSelectionModel");
                    break;

                case MTGridSelectionModel.Checkbox:
                    sb.Append("CheckboxSelectionModel");
                    break;
            }

            sb.Append("({singleSelect:");
            sb.Append((!multiSelect).ToString().ToLower());

            if (multiSelect && SelectionModel == MTGridSelectionModel.Checkbox)
            {
                sb.Append(",header:'<div class=\"x-grid3-hd-checker\">&#160;</div>'");
            }
            else
            {
                sb.Append(",header:''");
            }

            if (multiSelect)
            {
                sb.Append(",keepSelections:true");
            }
            sb.Append("})");


            return sb.ToString();
        }

        protected string GenerateCustomImplementation()
        {
            String sCustomScript = String.Empty;
            if (!String.IsNullOrEmpty(customImplementationFilePath))
            {
                sCustomScript = "<script type=\"text/javascript\" src=\"" + customImplementationFilePath + "\"></script>";

            }

            return sCustomScript;
        }

        protected string GenerateGridPlugins()
        {
            String sPlugins = "[filters_{control_id}";
            if (expandable)
            {
                sPlugins += ",expander_{control_id}";
            }

            if (this.SelectionModel == MTGridSelectionModel.Checkbox)
            {
                sPlugins += ",pagingSelection_{control_id}";
            }

            sPlugins += "]";
            return sPlugins;
        }

        protected string GenerateColumnConfig()
        {
            if (!EnableColumnConfig)
            {
                return string.Empty;
            }

            string columnConfigTool = @"
          {
            qtip:TEXT_CONFIGURE_COLUMNS,
            id:'gear', 
            handler:function(ev, tool, panel){
              onColumnSetup_{control_id}(ev, tool,panel);
            }
          }";
            return columnConfigTool;
        }

        protected string GenerateFilterConfig()
        {
            if (!EnableFilterConfig)
            {
                return String.Empty;
            }

            string filterConfigTool = @"
          {
            qtip:TEXT_CONFIGURE_FILTERS,
            id:'gear', 
            handler:function(ev, tool, panel){
              onFilterSetup_{control_id}(ev, tool,panel);
            }
          }";

            return filterConfigTool;
        }


        protected string GenerateTemplate()
        {
            if ((this.expanderTemplate == null) || (expanderTemplate.Count == 0))
            {
                return GenerateDefaultTemplate();
            }

            return GenerateExpanderTemplateFromLayout();
        }

        /// <summary>
        /// Generates a simple key-value template for the turn-down section
        /// </summary>
        /// <returns></returns>
        protected string GenerateDefaultTemplate()
        {
            StringBuilder sb = new StringBuilder();
            if (this.Elements.Count == 0)
            {
                sb.Append("---");
            }
            else
            {
                //append class information if available to outer div
                sb.Append("<div");
                if (!String.IsNullOrEmpty(expansionCssClass))
                {
                    sb.Append(" class='");
                    sb.Append(expansionCssClass);
                    sb.Append("'>");
                }
                else
                {
                    sb.Append(">");
                }

                sb.Append("<table>");
                foreach (MTGridDataElement elt in elements)
                {
                    if (elt.ShowInExpander)
                    {
                        string dataIndex = elt.ID;//FixDataIndexEnums(elt.DataIndex);
                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added JavaScript encoding
                        dataIndex = dataIndex.Replace("'", "\\'").Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#");
                        //dataIndex = dataIndex.EncodeForJavaScript().Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#");

                        //sb.Append("<tr><td>&nbsp;</td><td class=\"expanderFieldLabel\">" + elt.HeaderText.Replace("'", "\\'") + ":</td><td class=\"expanderFieldValue\">{" + dataIndex);
                        sb.Append("<tr><td>&nbsp;</td><td class=\"expanderFieldLabel\">" + elt.HeaderText.EncodeForJavaScript() + ":</td><td class=\"expanderFieldValue\">{" + dataIndex);
                        if (elt.DataType != MTDataType.Date)
                        {
                            sb.Append(":hideNull");
                        }
                        else
                        {
                            sb.Append(elt.Formatter == "DateTimeRenderer" ? ":formatDateTime" : ":formatDate");
                        }

                        sb.Append("}</td></tr>");
                    }
                }
                sb.Append("</table></div>");
            }
            return sb.ToString();
        }


        public MTGridDataElement FindElementByID(string ID)
        {
            if (string.IsNullOrEmpty(ID))
            {
                return null;
            }

            foreach (MTGridDataElement el in elements)
            {
                if (el.ID.ToLower() == ID.ToLower())
                {
                    return el;
                }
            }

            return null;
        }

        /// <summary>
        /// Returns a template that should be used for the turn-down section.
        /// This template is based on the ExpanderTemplate layout.  If no layout is present,
        /// default template should be used.
        /// </summary>
        /// <returns></returns>
        protected string GenerateExpanderTemplateFromLayout()
        {
            StringBuilder sb = new StringBuilder();
            //append class information if available to outer div
            sb.Append("<div");
            if (!String.IsNullOrEmpty(expansionCssClass))
            {
                sb.Append(" class='");
                sb.Append(expansionCssClass);
                sb.Append("'>");
            }
            else
            {
                sb.Append(">");
            }

            foreach (MTGridExpanderSection section in expanderTemplate)
            {
                if ((section.Columns != null) && (section.Columns.Count > 0))
                {
                    sb.Append("<table width=\"100%\" class=\"expanderSectionTable\">");
                    if (!String.IsNullOrEmpty(section.Title))
                    {
                        sb.Append("<tr><td class=\"expanderSectionTitle\" colspan=\"");
                        sb.Append(section.Columns.Count.ToString());
                        sb.Append("\">");
                        sb.Append(section.Title);
                        sb.Append("</td></tr>");
                    }

                    if (section.Columns.Count > 0)
                    {
                        sb.Append("<tr>");
                        int columnWidth = 100 / section.Columns.Count;

                        foreach (Column col in section.Columns)
                        {
                            sb.Append("<td width=\"");
                            sb.Append(columnWidth.ToString());
                            sb.Append("%\">");
                            sb.Append("<table width=\"100%\"  class=\"expanderColumnTable\">");

                            foreach (Field field in col.Fields)
                            {
                                MTGridDataElement el = FindElementByID(field.Name);
                                if ((el == null) || (!el.ShowInExpander))
                                {
                                    continue;
                                }

                                string dataIndex = el.ID;
                                dataIndex = dataIndex.Replace("[", "_").Replace("]", "_").Replace(".", "#").Replace("/", "#");

                                //since the dates returned in format new Date(xxxx), we need to run the eval on the content
                                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                                // Added JavaScript encoding
                                //sb.Append("<tr><td class=\"expanderFieldLabel\">" + el.HeaderText.Replace("'", "\\'") + ":</td><td class=\"expanderFieldValue\">{" + dataIndex);
                                sb.Append("<tr><td class=\"expanderFieldLabel\">" + el.HeaderText.EncodeForJavaScript() + ":</td><td class=\"expanderFieldValue\">{" + dataIndex);
                                if (el.DataType != MTDataType.Date)
                                {
                                    if (el.DataType == MTDataType.Boolean)
                                    {
                                        sb.Append(":formatBool");
                                    }
                                    else
                                    {
                                        sb.Append(":hideNull");
                                    }
                                }
                                else
                                {
                                    sb.Append(":formatDate");
                                }
                                sb.Append("}</td></tr>");

                            }

                            sb.Append("</table>");
                            sb.Append("</td>");
                        }
                        sb.Append("</tr>");
                    }
                    sb.Append("</table>");
                }
            }

            sb.Append("</div>");
            return sb.ToString();
        }


        protected string GetRootPath()
        {
            /* String rootPath = String.Empty;

            String pathInfo = null;

            if(!this.DesignMode)
            {
                pathInfo = Page.Request.ServerVariables["PATH_INFO"];
            }
      
            if (pathInfo.Length == 0)
            {
                return "";
            }
            int lastSlash = pathInfo.IndexOf("/", 2);
            if (lastSlash < 0)
            {
                return "";
            }

            rootPath = pathInfo.Substring(0, lastSlash + 1);

            return rootPath;
            */
            return "/Res/";
        }


        protected string GenerateUseFilters()
        {
            bool useFilters = false;

            if (!ShowFilterPanel)
            {
                return ShowFilterPanel.ToString().ToLower();
            }

            foreach (MTGridDataElement elt in this.Elements)
            {
                if (elt.Filterable)
                {
                    useFilters = true;
                    break;
                }
            }

            return useFilters.ToString().ToLower();
        }

        protected string GenerateToolbarButtons()
        {
            StringBuilder sb = new StringBuilder();

            foreach (MTGridButton button in ToolbarButtons)
            {
                if (!String.IsNullOrEmpty(button.Capability))
                {
                    if (Page is MTPage)
                    {
                        if (!((MTPage)Page).UI.CoarseCheckCapability(button.Capability))
                        {
                            continue;
                        }
                    }
                }

                if (sb.Length > 0)
                {
                    sb.Append(",");
                }

                // DGAZ: CORE-5168 MetraView BillSetting page is lacking Edit but permits adding more than one set of billing options to a single site
                // added an id to all ToolbarButtons so the buttons can be disabled/enabled later on in a page
                sb.Append("{id:'");
                sb.Append(button.ButtonID.EncodeForJavaScript());
                sb.Append("',text:'");
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //sb.Append(button.ButtonText.Replace("'", "\\'"));
                sb.Append(button.ButtonText.EncodeForJavaScript());
                sb.Append("',handler:");
                //sb.Append(button.JSHandlerFunction.Replace("'", "\\'") + "_" + ClientID);
                sb.Append(button.JSHandlerFunction.EncodeForJavaScript() + "_" + ClientID);

                if (!String.IsNullOrEmpty(button.ToolTip))
                {
                    sb.Append(",tooltip:'");
                    //sb.Append(button.ToolTip.Replace("'", "\\'"));
                    sb.Append(button.ToolTip.EncodeForJavaScript());
                    sb.Append("'");
                }

                if (!String.IsNullOrEmpty(button.IconClass))
                {
                    sb.Append(",iconCls:'");
                    //sb.Append(button.IconClass.Replace("'", "\\'"));
                    sb.Append(button.IconClass.EncodeForJavaScript());
                    sb.Append("'");
                }

                sb.Append("},'-'");
            }
            return sb.ToString();
        }

        protected string GenerateGridHeightOptions(Unit height)
        {
            //Determine if we should set the autoHeight settings on grid
            if ((height.Type == UnitType.Pixel && height == 0) || (height.Type == UnitType.Percentage && height == 100))
                return "autoHeight: true,";
            else
                return string.Format("height: {0},", height.Value.ToString());
        }

        /// <summary>
        /// Perform check on comma-separated capability list
        /// </summary>
        /// <param name="capList"></param>
        /// <returns></returns>
        protected bool PerformMultiCapabilityCheck(String capList)
        {
            //no capabilities, then success
            if (String.IsNullOrEmpty(capList))
            {
                return true;
            }

            //single capability
            if (capList.IndexOf(",") < 0)
            {
                return SingleCapabilityCheck(capList);
            }

            //if reached here, then there are multiple capabilities
            String[] arrCaps = capList.Split(new char[] { ',' });
            foreach (String cap in arrCaps)
            {
                if (!SingleCapabilityCheck(cap))
                {
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Abstract the call to check for a single capability
        /// </summary>
        /// <param name="capability"></param>
        /// <returns></returns>
        protected bool SingleCapabilityCheck(String capability)
        {
            if (Page is MTPage)
            {
                bool bChecked = false;

                try
                {
                    bChecked = ((MTPage)Page).UI.CoarseCheckCapability(capability);
                }
                catch
                {
                    return false;
                }

                return bChecked;
            }

            return false;
        }

        protected StringBuilder defaultHandlersForBottomButtons = new StringBuilder();
        protected string GenerateDefaultButtonHandler(string functionName) //MTGridButton button)
        {

            string result =
                @"function {function_name}_{client_id}()
{ return {function_name}(grid_{client_id},'{client_id}');}";

            result = result.Replace("{client_id}", ClientID);
            result = result.Replace("{function_name}", functionName);

            return result;
        }

        protected string GenerateBottomButtons()
        {
            string sResult = String.Empty;

            //exit if no buttons specified
            if (this.buttons == MTButtonType.None)
            {
                return sResult;
            }

            if (this.buttons == MTButtonType.Custom)
            {
                //iterate through custom grid buttons if any
                if (GridButtons.Count > 0)
                {
                    foreach (MTGridButton button in GridButtons)
                    {
                        //check capabilities, and skip if failed
                        if (!PerformMultiCapabilityCheck(button.Capability))
                        {
                            continue;
                        }

                        if (!String.IsNullOrEmpty(sResult))
                        {
                            sResult += ",";
                        }

                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added JavaScript encoding
                        //string functionName = button.JSHandlerFunction.Replace("'", "\\'");
                        string functionName = button.JSHandlerFunction.EncodeForJavaScript();
                        StringBuilder sb = new StringBuilder();
                        sb.Append("{text:'");
                        //sb.Append(button.ButtonText.Replace("'", "\\'"));
                        sb.Append(button.ButtonText.EncodeForJavaScript());
                        sb.Append("',handler:");
                        sb.Append(functionName + "_" + ClientID);

                        if (!String.IsNullOrEmpty(button.ToolTip))
                        {
                            sb.Append(",tooltip:'");
                            //sb.Append(button.ToolTip.Replace("'", "\\'"));
                            sb.Append(button.ToolTip.EncodeForJavaScript());
                            sb.Append("'");
                        }

                        if (!String.IsNullOrEmpty(button.IconClass))
                        {
                            sb.Append(",iconCls:'");
                            //sb.Append(button.IconClass.Replace("'", "\\'"));
                            sb.Append(button.IconClass.EncodeForJavaScript());
                            sb.Append("'");
                        }

                        sb.Append("}");


                        sResult += sb.ToString();

                        defaultHandlersForBottomButtons.Append(GenerateDefaultButtonHandler(functionName));
                    }
                }
            }

            if ((this.buttons == MTButtonType.OK) || (this.buttons == MTButtonType.OKCancel))
            {
                if (!String.IsNullOrEmpty(sResult))
                {
                    sResult += ",";
                }
                sResult += "{text:TEXT_OK,handler:onOK_" + this.ClientID + "}";

                defaultHandlersForBottomButtons.Append(GenerateDefaultButtonHandler("onOK"));
            }

          if ((this.buttons == MTButtonType.Cancel) || (this.buttons == MTButtonType.OKCancel))
          {
            if (!String.IsNullOrEmpty(sResult))
            {
              sResult += ",";
            }

            var cancelFunc = IsRelationshipCase ? "onCancelRelationship" : "onCancel";

            sResult += string.Format("{{text:TEXT_CANCEL, handler: {0}_{1}}}", cancelFunc, this.ClientID);
            defaultHandlersForBottomButtons.Append(GenerateDefaultButtonHandler(cancelFunc));

          }

          if (this.buttons == MTButtonType.Back)
            {
              if (!String.IsNullOrEmpty(sResult))
              {
                sResult += ",";
              }

              sResult += "{text:TEXT_BACK, handler: onBack_" + this.ClientID + "}";
              defaultHandlersForBottomButtons.Append(GenerateDefaultButtonHandler("onBack"));

            }

            return sResult;
        }

        protected int GetFilterCount()
        {
            int filterCount = 0;

            foreach (MTGridDataElement elt in this.Elements)
            {
                if (elt.Filterable)
                {
                    filterCount++;
                }
            }

            return filterCount;
        }

        protected string GenerateExportButton()
        {
            if (Exportable)
            {
                return SCRIPT_EXPORT_BUTTON;
            }

            return String.Empty;
        }

        protected string GenerateExportScript()
        {
            string str = String.Empty;

            if (Exportable)
            {
                str = SCRIPT_EXPORT;
            }

            return str;
        }

        protected string CustomizeMainScript()
        {
            if (this.DesignMode)
            {
                return string.Empty;
            }

            // Using a string builder as a memory efficient way of doing large string replace
            String tempScript = new string(SCRIPT_MAIN.ToCharArray());
            StringBuilder mainScript = new StringBuilder(tempScript);

            mainScript = mainScript.Replace("{export_code}", GenerateExportScript());
            mainScript = mainScript.Replace("{grid_filters}", GenerateGridFilters());
            mainScript = mainScript.Replace("{record_structure}", GenerateRecordStructure());
            mainScript = mainScript.Replace("{identity_field}", GenerateIdentityField());
            mainScript = mainScript.Replace("{page_size}", this.PageSize.ToString());
            mainScript = mainScript.Replace("{sort_info}", GenerateSortInfo());
            mainScript = mainScript.Replace("{group_info}", GenerateGroupInfo());
            mainScript = mainScript.Replace("{data_source_url}", this.dataSourceURL);
            mainScript = mainScript.Replace("{override_include}", GenerateAdditionalIncludesFromLayout());

            if (String.IsNullOrEmpty(this.ajaxTimeout))
            {
                mainScript = mainScript.Replace("{ajax_timeout}", "Ext.Ajax.timeout");
            }
            else
            {
                mainScript = mainScript.Replace("{ajax_timeout}", this.ajaxTimeout);
            }

            mainScript = mainScript.Replace("{data_source_url_params}", GetDataSourceURLParams());
            mainScript = mainScript.Replace("{update_url}", this.updateURL);
            mainScript = mainScript.Replace("{use_top_bar}", showTopBar ? "" : "null //");
            mainScript = mainScript.Replace("{use_bottom_bar}", showBottomBar ? "" : "null //");
            mainScript = mainScript.Replace("{num_list_elements}", GetNumListElements().ToString());
            mainScript = mainScript.Replace("{show_grid_frame}", ShowGridFrame.ToString().ToLower());
            mainScript = mainScript.Replace("{show_grid_header}", ShowGridHeader.ToString().ToLower());
            mainScript = mainScript.Replace("{show_column_headers}", (!ShowColumnHeaders).ToString().ToLower());

            //mainScript = mainScript.Replace("{filter_enum_requests}", GenerateFilterEnumRequests());
            mainScript = mainScript.Replace("{init_enum_options}", InitEnumOptions());
            mainScript = mainScript.Replace("{grid_height_options}", this.GenerateGridHeightOptions(this.Height));
            mainScript = mainScript.Replace("{grid_width}", (this.Width.Value > 0) ? "width:" + Width.Value.ToString() + "," : "");
            mainScript = mainScript.Replace("{selection_model}", GenerateSelectionModel());
            mainScript = mainScript.Replace("{sel_model_in_column_model}", (SelectionModel == MTGridSelectionModel.Checkbox) ? "selectionModel," : "");
            mainScript = mainScript.Replace("{expander_in_column_model}", (expandable) ? "expander_" + ClientID + "," : "");
            mainScript = mainScript.Replace("{grid_title}", title);
            mainScript = mainScript.Replace("{grid_resizable}", this.Resizable.ToString().ToLower());
            mainScript = mainScript.Replace("{generate_row_expander}", GenerateRowExpander());
            mainScript = mainScript.Replace("{grid_plugins}", GenerateGridPlugins());
            mainScript = mainScript.Replace("{generate_template}", GenerateTemplate());
            mainScript = mainScript.Replace("{custom_implementation_file_path}", GenerateCustomImplementation());
            mainScript = mainScript.Replace("{total_property}", this.TotalProperty);
            mainScript = mainScript.Replace("{root_element}", this.RootElement);
            mainScript = mainScript.Replace("{display_info}", this.DisplayCount.ToString().ToLower());
            mainScript = mainScript.Replace("{no_records_text}", this.noRecordsText);
            mainScript = mainScript.Replace("{bottom_buttons}", GenerateBottomButtons());
            mainScript = mainScript.Replace("{button_alignment}", this.buttonAlignment.ToString().ToLower());
            mainScript = mainScript.Replace("{use_filters}", GenerateUseFilters());
            mainScript = mainScript.Replace("{filter_collapsed}", FilterPanelCollapsed.ToString().ToLower());
            mainScript = mainScript.Replace("{filter_panel_layout}", FilterPanelLayout.ToString().ToLower());
            mainScript = mainScript.Replace("{fieldset_height}", String.Format("{0}", GetFilterCount() * 25 + 50));
            mainScript = mainScript.Replace("{filterpanel_height}", String.Format("{0}", GetFilterCount() * 25 + 135));
            mainScript = mainScript.Replace("{filter_label_width}", FilterLabelWidth.ToString());
            mainScript = mainScript.Replace("{filter_input_width}", FilterInputWidth.ToString());
            mainScript = mainScript.Replace("{filter_config_tool}", DrawFilterTools());
            mainScript = mainScript.Replace("{filter_column_width}", filterColumnWidth.ToString());
            mainScript = mainScript.Replace("{column_config_tool}", GenerateColumnConfig());
            mainScript = mainScript.Replace("{cookie_prefix}", GetCookiePrefix());
            mainScript = mainScript.Replace("{search_on_load}", this.SearchOnLoad.ToString().ToLower());
            mainScript = mainScript.Replace("{export_button}", GenerateExportButton());
            mainScript = mainScript.Replace("{setup_base_params}", SetupDataSourceBaseParams());
            mainScript = mainScript.Replace("{is_expandable}", this.Expandable.ToString().ToLower());
            mainScript = mainScript.Replace("{generate_toolbar_buttons}", GenerateToolbarButtons());
            mainScript = mainScript.Replace("{get_primary_view_name}", GetPrimaryViewName());
            mainScript = mainScript.Replace("{column_model}", GenerateColumnModel());
            mainScript = mainScript.Replace("{generate_internal_grid}", GenerateInternalGrid());
            mainScript = mainScript.Replace("{setup_sub_grid}", GenerateSubGrid());
            mainScript = mainScript.Replace("{saved_search_code}", ProcessSavedSearchCode());
            mainScript = mainScript.Replace("{saved_search_id}", GetSavedSearchID());
            mainScript = mainScript.Replace("{virtual_folder}", GetVirtualFolder());
            mainScript = mainScript.Replace("{support_quick_edit}", SupportQuickEdit().ToString().ToLower());
            mainScript = mainScript.Replace("{quick_edit}", GenerateQuickEditCode());
            mainScript = mainScript.Replace("{control_id}", this.ClientID);
            mainScript = mainScript.Replace("{default_button_handlers}", defaultHandlersForBottomButtons.ToString());

            mainScript = mainScript.Replace("{supportExportSelected}", SupportExportSelected.ToString().ToLower());

            return mainScript.ToString();
        }

        private string GenerateQuickEditCode()
        {
            if (!SupportQuickEdit())
            {
                return string.Empty;
            }

            string qeScript = SCRIPT_QUICK_EDIT.Replace("{control_id}", this.ClientID);
            qeScript = qeScript.Replace("{update_url}", UpdateURL);
            return qeScript;
        }

        //Check if quick edit mode is supported by checking the following:
        //1) capability check
        //2) UpdateURL field
        //3) at least one editable field
        private bool SupportQuickEdit()
        {
            if (!PerformMultiCapabilityCheck(QuickEditCapability))
            {
                return false;
            }

            if (string.IsNullOrEmpty(UpdateURL))
            {
                return false;
            }

            int count = Elements.Count(n => n.Editable == true);
            if (count <= 0)
            {
                return false;
            }
            return true;
        }

        private string GetSavedSearchID()
        {
            string savedSearchID = string.Empty;

            if (!Page.IsPostBack)
            {
                savedSearchID = Page.Request["SavedSearchID"];
                if (string.IsNullOrEmpty(savedSearchID))
                {
                    savedSearchID = string.Empty;
                }
                else
                {
                    try
                    {
                        Guid testGuid = new Guid(savedSearchID);
                    }
                    catch
                    {
                        savedSearchID = string.Empty;
                    }
                }
            }

      	    // SECENG: CORE-4794 CLONE - BSS 29002 Security - CAT .NET - Cross Site Scripting in MetraTech Binaries (SecEx)
            // Added Encoding
            return Utils.EncodeForJavaScript(savedSearchID);
        }

        protected string DrawFilterTools()
        {
            string tools = GenerateFilterConfig();
            if (tools.Length > 0)
            {
                tools += ",";
            }

            string savedSearchTool = DrawSaveSearchTool();
            tools += savedSearchTool;

            if (savedSearchTool.Length > 0)
            {
                tools += ",";
            }

            tools += DrawLoadSavedSearchTool();

            if (tools.EndsWith(","))
            {
                tools = tools.Substring(0, tools.Length - 1);
            }

            return tools;
        }

        protected string DrawLoadSavedSearchTool()
        {
            var toolString = string.Empty;
            if (EnableLoadSearch)
            {
                toolString = @"
          {
            id:'folder',
            qtip:TEXT_OPEN_SAVED_SEARCH ,
            handler:function(ev,tool,panel)
            {
              onOpenSavedSearch_{control_id}(ev, tool, panel);
            }
          }
        ";
                toolString = toolString.Replace("{control_id}", this.ClientID);
            }

            return toolString;
        }

        protected string DrawSaveSearchTool()
        {
            var toolString = string.Empty;
            if (EnableSaveSearch)
            {
                toolString = @"
          {
            qtip:TEXT_SAVE_SEARCH,
            id:'save',
            handler:function(ev,tool,panel){
              onSaveSearch_{control_id}(ev, tool, panel);
            }
          }
        ";
                toolString = toolString.Replace("{control_id}", this.ClientID);
            }

            return toolString;
        }

        /// <summary>
        /// Generates the javascript code required only for saving/loading searches
        /// </summary>
        /// <returns></returns>
        protected string ProcessSavedSearchCode()
        {
            string savedSearchJS = string.Empty;
            if (EnableSaveSearch || EnableLoadSearch)
            {
                savedSearchJS = SCRIPT_SAVED_SEARCH;
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added HTML encoding
                //savedSearchJS = savedSearchJS.Replace("{page_url}", HttpUtility.HtmlEncode(HttpUtility.UrlDecode(Page.Request.Url.PathAndQuery).
                //	Replace(";", string.Empty).Replace("'", string.Empty).Replace("\"", string.Empty).Replace("+", string.Empty)));
                savedSearchJS = savedSearchJS.Replace("{page_url}", HttpUtility.UrlDecode(Page.Request.Url.PathAndQuery).EncodeForHtml().Replace("&amp;", "&").
                    Replace(";", string.Empty).Replace("'", string.Empty).Replace("\"", string.Empty).Replace("+", string.Empty));
                savedSearchJS = savedSearchJS.Replace("{grid_id}", this.ID);

                //SECENG: Replace physical paths for appropriate aliases
                savedSearchJS = savedSearchJS.Replace("{template_xml}", !string.IsNullOrEmpty(XMLPath) ? SecurityKernel.ObjectReferenceMapper.Api.GetDefaultEngine(ObjectReferenceMapperEngineCategory.Str.ToString()).Execute(XMLPath) : null);
                savedSearchJS = savedSearchJS.Replace("{virtual_folder}", GetVirtualFolder());
                savedSearchJS = savedSearchJS.Replace("{control_id}", this.ClientID);
            }
            return savedSearchJS;
        }

        protected string FixID(string ID)
        {
            return ID.Replace("'", "\\'").Replace(".", "#").Replace("/", "#");
        }

        /// <summary>
        /// Checks if the enumInstance string present in the enum blacklist for this element
        /// </summary>
        /// <param name="enumInstance"></param>
        /// <param name="elt"></param>
        /// <returns></returns>
        protected bool IsEnumInBlackList(string enumInstance, MTGridDataElement elt)
        {
            if ((elt.FilterEnum == null) || (elt.FilterEnum.HideEnumValues == null))
            {
                return false;
            }

            if (String.IsNullOrEmpty(enumInstance))
            {
                return false;
            }

            foreach (string curString in elt.FilterEnum.HideEnumValues)
            {
                if (curString.ToLower() == enumInstance.ToLower())
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Creates a javascript array of option values for each item of List data type - either enum-based or free-form
        /// </summary>
        /// <returns></returns>
        protected string InitEnumOptions()
        {
            StringBuilder sb = new StringBuilder();

            foreach (MTGridDataElement elt in Elements)
            {
                //only applies to lists
                if (elt.DataType != MTDataType.List)
                {
                    continue;
                }

                string defaultOption = String.Empty;

                sb.Append("enumOptions_");
                sb.Append(this.ClientID);
                sb.Append("['" + FixID(elt.ID) + "'] = [");

                //determine the proper enum type
                Type enumType = null;
                if (!String.IsNullOrEmpty(elt.FilterEnum.EnumClassName))
                {
                    enumType = EnumHelper.GetEnumTypeByTypeName(elt.FilterEnum.EnumClassName);
                }

                //if enum type could not be determined by class name use enumSpace/enumType combo
                if (enumType == null)
                {
                    enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(elt.FilterEnum.EnumSpace, elt.FilterEnum.EnumType, Path.GetDirectoryName(new Uri(this.GetType().Assembly.CodeBase).AbsolutePath));
                }

                if (enumType != null)
                {
                    List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

                    if (!elt.MultiValue)
                    {
                        sb.Append("['','--']");
                    }

                    int nCount = 0;
                    foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
                    {
                        if (!IsEnumInBlackList(EnumHelper.GetEnumEntryName(enumData.EnumInstance), elt))
                        {
                            if (!elt.MultiValue || nCount != 0)
                            {
                                sb.Append(",");
                            }

                            string optionValue = (elt.FilterEnum.UseEnumValue == true) ?
                                    EnumHelper.GetValueByEnum(enumData.EnumInstance).ToString() :
                                    EnumHelper.GetDbValueByEnum(enumData.EnumInstance).ToString();

                            sb.Append("['");
                            sb.Append(optionValue);
                            sb.Append("','");
                            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                            // Added JavaScript encoding
                            //sb.Append(enumData.DisplayName.Replace("'", "\\'"));
                            sb.Append(enumData.DisplayName.EncodeForJavaScript());
                            sb.Append("']");

                            if (!String.IsNullOrEmpty(elt.ElementValue))
                            {
                                if (elt.ElementValue.ToLower() == enumData.EnumInstance.ToString().ToLower())
                                {
                                    defaultOption = EnumHelper.GetValueByEnum(enumData.EnumInstance).ToString();
                                }
                            }

                            nCount++;
                        }
                    }
                }
                //Dropdown list items are present
                else
                {
                    if (elt.FilterDropdownItems.Count > 0)
                    {
                        defaultOption = elt.ElementValue;

                        for (int i = 0; i < elt.FilterDropdownItems.Count; i++)
                        {
                            String key = elt.FilterDropdownItems[i].Key;
                            String value = elt.FilterDropdownItems[i].Value;

                            //insert artificial clear entry
                            if (!elt.MultiValue && (i == 0))
                            {
                                sb.Append("['','--']");
                                sb.Append(",");
                            }

                            if (i > 0)
                            {
                                sb.Append(",");
                            }

                            sb.Append("['");
                            // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                            // Added JavaScript encoding
                            //sb.Append(key.Replace("'", "\\'"));
                            sb.Append(key.EncodeForJavaScript());
                            sb.Append("','");
                            //sb.Append(value.Replace("'", "\\'"));
                            sb.Append(value.EncodeForJavaScript());
                            sb.Append("']");
                        }
                    }
                }

                sb.Append("];\n");

                //set default value for enums
                //if (enumType != null)
                {
                    if (!String.IsNullOrEmpty(elt.ElementValue) && !String.IsNullOrEmpty(defaultOption))
                    {
                        sb.Append("defaultOption_");
                        sb.Append(this.ClientID);
                        sb.Append("['");
                        sb.Append(FixID(elt.ID));
                        sb.Append("'] = '");
                        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                        // Added HTML encoding
                        //sb.Append(Page.Server.HtmlEncode(defaultOption));
                        sb.Append(defaultOption.EncodeForHtml());
                        sb.Append("';\n");

                    }
                }
            }

            return sb.ToString();
        }

        /// <summary>
        /// Sets up the baseParams attributes for the data store
        /// Currently based on Data Source URL Params only
        /// </summary>
        /// <returns></returns>
        protected string SetupDataSourceBaseParams()
        {
            if ((DataSourceURLParams == null) || (DataSourceURLParams.Count <= 0))
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder();
            string tpl = "dataStore_{0}.setBaseParam('{1}','{2}');";

            //iterate through the list
            foreach (KeyValuePair<string, object> param in DataSourceURLParams)
            {
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //string s = string.Format(tpl, this.ClientID, param.Key, param.Value.ToString().Replace("'", "\\'"));
                string s = string.Format(tpl, this.ClientID, param.Key, param.Value.ToString().EncodeForJavaScript());
                sb.Append(s);
            }

            return sb.ToString();
        }

        /// <summary>
        /// Sets up additional parameters that are submitted to DataSourceURL
        /// </summary>
        /// <returns></returns>
        protected string GetDataSourceURLParams()
        {
            if ((DataSourceURLParams == null) || (DataSourceURLParams.Count <= 0))
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder();

            //iterate through the list and construct the string in format param1:value1,param2:value2
            foreach (KeyValuePair<string, object> param in DataSourceURLParams)
            {
                sb.Append("'" + param.Key + "'");
                sb.Append(":");
                if (param.Value == null)
                {
                    sb.Append("''");
                }
                else
                {
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //sb.Append("'" + param.Value.ToString().Replace("'", "\\'") + "'");
                    sb.Append("'" + param.Value.ToString().EncodeForJavaScript() + "'");
                }
                sb.Append(",");
            }

            return sb.ToString();
        }

        protected string GetCookiePrefix()
        {
            int userID = 0;
            if (Page is MTPage)
            {
                userID = ((MTPage)Page).UI.SessionContext.SecurityContext.AccountID;
            }
            string strUserID = Utils.Encrypt(userID.ToString()).Replace("=", "");
            string scriptName = string.Empty;
            if (!this.DesignMode)
            {
                scriptName = Page.Request.ServerVariables["SCRIPT_NAME"];
            }

            return ParseFilename(scriptName) + "_" + this.ID + "_" + strUserID + "_";
        }

        /// <summary>
        /// NOTE: dead code
        /// Returns the string representation of the view that is used
        /// to extract the primary account info, e.g. Bill-To.  The string returned
        /// will be the name of the contact view, e.g. LDAP, followed by the enum index
        /// of Bill-To in that enum.
        /// </summary>
        /// <returns></returns>
        protected string GetPrimaryViewName()
        {
            String viewName = "LDAP";
            String primaryContactViewIndex = GetPrimaryContactViewIndex();
            return viewName + "[" + primaryContactViewIndex + "]";
        }

        //NOTE:Dead code
        protected string GetPrimaryContactViewIndex()
        {
            try
            {
                return (String)EnumHelper.GetValueByEnum(ContactType.Bill_To);
            }
            catch
            {
                return "0";
            }
        }

        /// <summary>
        /// If DataSourceURL was not provided, then attempt to create it using the DataBinder properties,
        /// e.g. GetData.aspx with parameters coming from ServicePath, Operation, OutPropertyName,etc
        /// </summary>
        protected void RectifyDataSourceURL()
        {
            //if data source URL is set up, use it
            if (String.IsNullOrEmpty(this.dataSourceURL))
            {


                //otherwise, check for data binder property
                if (dataBinder == null)
                {
                    throw new ApplicationException("DataBinder is not set up properly.");
                }

                StringBuilder sb = new StringBuilder();

                if (String.IsNullOrEmpty(dataBinder.ServicePath))
                {
                    dataBinder.ServicePath = "/MetraNet/AjaxServices/GetData.aspx";
                }
                sb.Append(this.dataBinder.ServicePath);
                sb.Append("?op=");
                sb.Append(dataBinder.Operation);
                sb.Append("&piid=");
                if (Page is MTPage)
                {
                    sb.Append(((MTPage)Page).PageNav.ProcessorId.ToString());
                }
                else
                {
                    sb.Append(this.dataBinder.ProcessorID);
                }

                sb.Append("&AccID=");
                if (Page is MTPage)
                {
                    sb.Append(((MTPage)Page).UI.User.AccountId.ToString());
                }
                else
                {
                    sb.Append(dataBinder.AccountID);
                }

                if (!String.IsNullOrEmpty(dataBinder.OutPropertyName))
                {
                    sb.Append("&OutPropertyName=");
                    sb.Append(HttpUtility.UrlEncode(dataBinder.OutPropertyName));
                }

                if (!String.IsNullOrEmpty(dataBinder.ServiceMethodName))
                {
                    sb.Append("&ServiceMethodName=");
                    sb.Append(HttpUtility.UrlEncode(DataBinder.ServiceMethodName));

                    //check if there are any parameters for the service
                    if (dataBinder.ServiceMethodParameters != null)
                    {
                        for (int i = 0; i < dataBinder.ServiceMethodParameters.Count; i++)
                        {
                            MTServiceParameter param = dataBinder.ServiceMethodParameters[i];
                            sb.Append("&SvcMethodParamName[" + i.ToString() + "]=" + HttpUtility.UrlEncode(param.ParamName));
                            sb.Append("&SvcMethodParamValue[" + i.ToString() + "]=" + HttpUtility.UrlEncode(param.ParamValue));
                            sb.Append("&SvcMethodParamType[" + i.ToString() + "]=" + HttpUtility.UrlEncode(param.DataType));
                        }
                    }
                }

                //iterate through arguments
                if (dataBinder.Arguments != null)
                {
                    sb.Append("&args=");

                    StringBuilder argList = new StringBuilder();

                    foreach (MTGridDataBindingArgument arg in dataBinder.Arguments)
                    {
                        //append arg list concatenation
                        if (argList.Length != 0)
                        {
                            argList.Append("**");
                        }

                        argList.Append(HttpUtility.UrlEncode(arg.Name));
                        argList.Append("=");
                        argList.Append(HttpUtility.UrlEncode(arg.Value));

                    }

                    //append arguments to the full list
                    sb.Append(argList.ToString());
                }

                dataSourceURL = sb.ToString();
            }

          //Adjust the absolute URL depending on base application directory
          dataSourceURL = AdjustAbsoluteURL(dataSourceURL);
          
        }
        
        /// <summary>
        /// Takes the specified URL and adjusts/modifies it for use in the specific page
        /// Currently only takes a URL that may start with a ~ where the ~ represents the Application specific URL (necessary for page reuse between MetraNet and MetraView)
        /// </summary>
        /// <param name="URL">URL to be adjusted/expanded</param>
        /// <returns>the fully application specific adjusted/expanded URL</returns>
        public string AdjustAbsoluteURL(string URL)
            {
          string result = URL;
          if (!string.IsNullOrEmpty(URL))
          {
                //Replace leading tilda with application directory
            if (URL.StartsWith("~") && Page is MTPage)
                {
                    string appURL = ((MTPage)Page).ApplicationURL;
              result = appURL + URL.Substring(1);
                }
            }
          return result;
        }

        protected override void OnPreRender(EventArgs e)
        {
            RectifyDataSourceURL();
            if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), SCRIPT_INCLUDE_KEY))
            {
                SCRIPT_INCLUDES = SCRIPT_INCLUDES.Replace("{root_path}", GetRootPath());
                Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), SCRIPT_INCLUDE_KEY, SCRIPT_INCLUDES);
            }
        }

        /// <summary>
        /// Generates the list of optional additional javascript includes that are included at the end
        /// of the control rendering so that they may override control generated javascript
        /// </summary>
        /// <returns></returns>
        protected string GenerateAdditionalIncludesFromLayout()
        {
          if (CustomOverrideJavascriptIncludes != null)
          {
            StringBuilder result = new StringBuilder();
            foreach (string includePath in CustomOverrideJavascriptIncludes)
            {
              result.AppendFormat(@"<script type=""text/javascript"" src=""{0}""></script>", includePath);
            }

            return result.ToString();
          }
          else
          {
            return ""; 
          }
        }

        

        protected override void OnLoad(EventArgs e)
        {
            //if XML path is not there, attempt to build it using extension and filename
            if (String.IsNullOrEmpty(XMLPath))
            {
                if (Page.Request.QueryString[this.ID + "_TemplateFileName"] != null)
                {
                    this.TemplateFileName = Page.Request.QueryString[this.ID + "_TemplateFileName"];
                }

                if (!String.IsNullOrEmpty(extensionName) && !String.IsNullOrEmpty(templateFileName))
                {
                    //SECENG: SECURITY-358 Cat.Net issues MetraNet 6.5
                    // Check for directory traversal.
                    SecurityKernel.Detector.Api.ExecuteDefaultByCategory(
                        DetectorEngineCategory.DirectoryTraversal.ToString(), new ApiInput(extensionName));
                    SecurityKernel.Detector.Api.ExecuteDefaultByCategory(
                        DetectorEngineCategory.DirectoryTraversal.ToString(), new ApiInput(templateFileName));

                    RCD.IMTRcd rcd = new RCD.MTRcd();
                  string path = Path.Combine(rcd.ExtensionDir,
                                             extensionName.Replace(
                                               string.Format("{0}.", MetraTech.BusinessEntity.Core.BMEConstants.BMERootNameSpace),
                                               string.Empty) + "\\Config\\GridLayouts");

                    xmlPath = path + "\\" + templateFileName;

                    if (!templateFileName.EndsWith(".xml", StringComparison.CurrentCultureIgnoreCase))
                    {
                        xmlPath += ".xml";
                    }
                }
                else
                {
                    //For the love of god, we should do something here like log friggin something!
                }
            }

            //if xmlPath is available use it to load all the properties
            if (!String.IsNullOrEmpty(XMLPath))
            {
                if (!File.Exists(XMLPath))
                {
                    throw new Exception(String.Format("Layout Template not found: {0}", XMLPath));
                }

                try
                {
                    MTGridSerializer ser = new MTGridSerializer();
                    ser.PopulateGridFromLayout(this, XMLPath, (MTPage)this.Page);

                    if (subGridDefinition != null && !String.IsNullOrEmpty(subGridDefinition.Id))
                    {
                        var subGrid = Parent.FindControl(subGridDefinition.Id) as MTFilterGrid;
                        if (subGrid != null)
                            subGrid.TemplateFileName = subGridDefinition.GridLayoutFile;
                    }
                }
                catch (Exception exp)
                {
                    throw new Exception(String.Format("Invalid Layout Template: {0}.  Details: {1}", XMLPath, exp));
                }
            }

            InitializeColumnOrder();
        }

        /// <summary>
        /// Initializes the column order to sequential position.
        /// </summary>
        protected void InitializeColumnOrder()
        {
            int i = 0;

            foreach (MTGridDataElement elt in elements)
            {
                if (elt.IsColumn)
                {
                    elt.Position = i;
                    i++;
                }
            }
        }

        protected override void RenderContents(HtmlTextWriter output)
        {
            String mainScript = CustomizeMainScript();
            output.Write(mainScript);

        }

        protected string GetVirtualFolder()
        {
            string path = AppDomain.CurrentDomain.FriendlyName;
            path = path.Substring(path.LastIndexOf("/"));
            path = path.Substring(0, path.IndexOf("-"));

            return path;
        }
    }
}
