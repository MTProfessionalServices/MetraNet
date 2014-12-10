<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master"
  AutoEventWireup="true" Inherits="BEList" CodeFile="BEList.aspx.cs" %>

<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register Src="../UserControls/BreadCrumb.ascx" TagName="BreadCrumb" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="BE" runat="server"/>
  <uc1:BreadCrumb ID="BreadCrumb1" runat="server" />
  <div style="width: 810px">
    <MT:MTFilterGrid ID="BMEGrid" runat="Server">
    </MT:MTFilterGrid>
  </div>
  <div style="padding: 10px">
    <MT:MTLabel ID="LblcurrentEntityName" runat="server" Font-Bold="true" Font-Size="Medium" />
  </div>
  <div id="relship_grid" style="padding: 10px">
  </div>
  <input type="hidden" runat="server" id="targetRelationshipType" />
  <input type="hidden" runat="server" id="relatedEntityTypeName" />
  <input type="hidden" runat="server" id="relatedEntityTypeFullName" />
  <input type="hidden" runat="server" id="srcRelationshipType" />
  <input type="hidden" runat="server" id="currentSrcEntityName" />
  <script type="text/javascript">
    var referer ='<%=RefererUrl%>';
    var entityName = '<%=Utils.EncodeForJavaScript(BEName)%>';
    var associationValue = '<%=Utils.EncodeForJavaScript(AssociationValue)%>';
    var parentId = '<%=Utils.EncodeForJavaScript(ParentId)%>';
    var parentName = '<%=Utils.EncodeForJavaScript(ParentName)%>';
    var currentSourceEntityName = '<%=Utils.EncodeForJavaScript(CurrentSourceEntityName)%>'; 
    var subGrid = false;

    var currentEntityIsReadOnly = <%=ReadOnly%>;
    
    // Custom Renderers
    OverrideRenderer_<%= BMEGrid.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Actions'), defaultBMEActionsColumnRenderer); 
    };

 

  function onViewRelationships(rowIndex) {

      // this.grid_<%=BMEGrid.ClientID %>.on('cellclick', function(myGrid, rowIndex){      
       Ext.get('relship_grid').dom.innerHTML = "";
       var record = this.grid_<%=BMEGrid.ClientID %>.getStore().getAt(rowIndex);

       var totalRows =  this.grid_<%=BMEGrid.ClientID %>.store.data.length;
       var i;
      
       if(<%=ChildGrid %>)
       {         
            subGrid = true;
       }
       else
       {
         for(i = 0; i< totalRows; i ++)
         {
           grid_<%=BMEGrid.ClientID %>.getView().getRow(i).style.backgroundColor = 'white';
         }

         grid_<%=BMEGrid.ClientID %>.getView().getRow(rowIndex).style.backgroundColor = 'aqua';
         
       }       
     
       if(!subGrid)
       {

              var id = record.data.internalId;

              if(record.data.Name == undefined)
              {
                Ext.get("<%=currentSrcEntityName.ClientID %>").dom.value = record.data[record.fields.items[1].name];               
              }
              else
              {
                Ext.get("<%=currentSrcEntityName.ClientID %>").dom.value = record.data.Name;                    
              }   
                 
              Ext.get("<%=LblcurrentEntityName.ClientID %>").dom.innerHTML = TITLE_RELATIONSHIPS_FOR + " " + Ext.util.Format.htmlEncode(Ext.get("<%=currentSrcEntityName.ClientID %>").dom.value);               
       
              var tabs = new Ext.TabPanel({
                    renderTo: 'relship_grid',
                    activeTab : 0,
                    width:820,
                    height:450,
                    deferredRender: false,                      
                    autoTabs : true,                                                                                         
                    listeners: 
                    {
                      'tabchange': function(tp, p)
                      {
                      tp.doLayout();
                      }
                    }                                                    
              });                                    


              var i, urlString;                                        
              var fullnameArray = [];
              var relEntityFullName = Ext.get('<%=relatedEntityTypeFullName.ClientID%>').dom.value;
              var relEntityFullNameArr = new Array();                                        
              relEntityFullNameArr = relEntityFullName.split(',');
                                       
              for(i=1; i< relEntityFullNameArr.length; i++)
              {
                fullnameArray.push(relEntityFullNameArr[i]);
              }
              var numRelEntities = fullnameArray.length;


              var nameArray = [];
              var relEntityTypeName = Ext.get('<%=relatedEntityTypeName.ClientID%>').dom.value;
              var relEntityTypeNameArr = new Array();                                        
              relEntityTypeNameArr = relEntityTypeName.split(',');
                                       
              for(i=1; i< relEntityTypeNameArr.length; i++)
              {
                nameArray.push(relEntityTypeNameArr[i]);
              }


              var targetRelshipArray = [];
              var targetRelshipType = Ext.get('<%=targetRelationshipType.ClientID%>').dom.value;
              var targetRelshipTypeArr = new Array();                                        
              targetRelshipTypeArr = targetRelshipType.split(',');
                                       
              for(i=1; i< targetRelshipTypeArr.length; i++)
              {
                targetRelshipArray.push(targetRelshipTypeArr[i]);
              }

              var srcRelshipArray = [];
              var srcRelshipType = Ext.get('<%=srcRelationshipType.ClientID%>').dom.value;
              var srcRelshipTypeArr = new Array();                                        
              srcRelshipTypeArr = srcRelshipType.split(',');
                                       
              for(i=1; i< srcRelshipTypeArr.length; i++)
              {
                srcRelshipArray.push(srcRelshipTypeArr[i]);
              }
        
              for (i=0 ; i<numRelEntities; i++)
              {    
                urlString  =  fullnameArray[i]  + "&Extension=<%=BMEGrid.ExtensionName%>" + "&ParentId="+ id + "&ParentName=" + entityName + "&Association=" + associationValue + "&ChildGrid=true&IsRelationshipCase=true";                                                                           
                if(targetRelshipArray[i] == "Many")
                {
                  urlString = urlString + "&MultiSelect=true";
                }
                else
                {
                  urlString = urlString + "&MultiSelect=false";
                }

                var relshipTypeFullName = srcRelshipArray[i] + "--" + targetRelshipArray[i];
                urlString = urlString + "&RelshipType=" + escape(relshipTypeFullName);

                var currentSrcEntityName = Ext.get("<%=currentSrcEntityName.ClientID %>").dom.value;        
                urlString = urlString +  "&CurrentSrcEntityName=" + escape(currentSrcEntityName);
        
                tabs.add({                                               
                        title: nameArray[i],
                        id: "tab" + i,                                           
                        html: String.format("<iframe src='/MetraNet/BME/BEList.aspx?Name={0}' width='100%' height='100%' frameborder='0' scrolling='yes'/>", urlString),                                             
                        closable: false                                                                  
                    }).show();   
              } 

              if(numRelEntities == 0)
              {
                tabs.add({                                               
                        title: TITLE_RELATIONSHIPS,
                        id: "tab0",                                           
                        html: NO_RECORDS_FOUND,                                                                     
                        closable: false
                    }).show();   
              }
         
              tabs.setActiveTab(0);
              tabs.doLayout();  
        }

     // },this);       
        
      }
  //  });
    
    // Event handlers
    if (top.events) {
      top.events.on('INFO_MESSAGE', onBEUpdate, this);
    }
  
    function onBEUpdate(msg)
    {
      if(msg == entityName)
      {
        dataStore_<%= BMEGrid.ClientID %>.reload();
      }
    }
    
    function onEdit(internalId, id)
    {
      if(<%=ChildGrid %>)
      {
        document.location.href = String.format("BEEdit.aspx?EditChildRow=true&name={0}&id={1}&url={2}", entityName, internalId, referer);
      }
      else
      {
        document.location.href = String.format("BEEdit.aspx?name={0}&id={1}&url={2}", entityName, internalId, referer);
      }
    }
 
    function onDelete(internalId, id)
    {
    if(<%=ChildGrid %>)
    {
     
       top.Ext.MessageBox.show({
               title: TITLE_REMOVE_RELATIONSHIP,
               msg: TEXT_REMOVE_THIS_RELSHIP,
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
                    var parameters = {name: entityName, id: internalId, ParentId: parentId, ParentName: parentName}; 
                    // make the call back to the server
                    Ext.Ajax.request({
                        url: '/MetraNet/AjaxServices/BEDeleteSvc.aspx?ChildGrid=true',
                        params: parameters,
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                          if (success) {
                            if(response.responseText == "OK") {
                              // everything is good, refresh the grid
                              dataStore_<%= BMEGrid.ClientID %>.reload();
                              }    
                            else
                            {
                              Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                            }
                          }
                          else
                          {
                            Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                          }
                        }
                     }); 
      
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
    }
    else
    {
       top.Ext.MessageBox.show({
               title: TEXT_DELETE,
               msg: String.format(TEXT_DELETE_MESSAGE, id),
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {

                    var parameters = {name: entityName, id: internalId}; 
                    // make the call back to the server
                    Ext.Ajax.request({
                        url: '/MetraNet/AjaxServices/BEDeleteSvc.aspx',
                        params: parameters,
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                          if (success) {
                            if(response.responseText == "OK") {
                              // everything is good, refresh the grid
                              dataStore_<%= BMEGrid.ClientID %>.reload();
                              Ext.get('relship_grid').dom.innerHTML = "";                              
                            }    
                            else
                            {
                              Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                            }
                          }
                          else
                          {
                            Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                          }
                        }
                     }); 
      
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
        }
        grid_<%= BMEGrid.ClientID %>.getSelectionModel().clearSelections();
        Ext.get("<%=LblcurrentEntityName.ClientID %>").dom.innerHTML = "";
    }
   
    defaultBMEActionsColumnRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      var internalId = record.data.internalId;
      var id = record.data[record.fields.items[0].mapping] + "";  // this is the primary key... it has to go first in the grid?  how else do I know?
     
      if(<%=ReadOnly%>)
      { 
        // View only
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEdit('{0}','{1}')\"><img src=\"/Res/Images/icons/application_view_detail.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_VIEW));
      }
      else if(<%=ChildGrid%>)
      {       
         // Edit Template
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEdit('{0}','{1}')\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_EDIT));

       // Delete button     
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onDelete('{0}','{1}')\"><img src=\"/Res/Images/icons/cross.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_REMOVE));
      }
      else
      {
        // Edit Template
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEdit('{0}','{1}')\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_EDIT));

        // Delete button     
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onDelete('{0}','{1}')\"><img src=\"/Res/Images/icons/cross.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_DELETE));

        // View Relationships link
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onViewRelationships({3})\"><img src=\"/Res/Images/icons/table_relationship.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_VIEW_RELATIONSHIPS), rowIndex);

      }
    
      return str;
    };    

   function onCancelRelationship_<%= BMEGrid.ClientID %>() {
     parent.clearSubGrid();
   }

   function clearSubGrid() {
     Ext.get("relship_grid").dom.innerHTML = "";
     Ext.get("<%=LblcurrentEntityName.ClientID %>").dom.innerHTML = "";
     
     var totalRows =  grid_<%=BMEGrid.ClientID %>.store.data.length;
     for(i = 0; i< totalRows; i ++)
         {
           grid_<%=BMEGrid.ClientID %>.getView().getRow(i).style.backgroundColor = 'white';
         }
   }

   function onCancel_<%= BMEGrid.ClientID %>()
    {
       if(<%=ChildGrid%>)
       {
         document.location.href = '<%=ReturnUrl %>';         
       } 
       else
       {
        //This will break on MetraView
        document.location.href = "/MetraNet/BME/BE.aspx";
       }
    }

    function onDelete_<%= BMEGrid.ClientID %>()
    {
       var records = grid_<%= BMEGrid.ClientID %>.getSelectionModel().getSelections();    
      
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
       if(i > 0)
       {
         ids += ",";
       }
       ids += records[i].data.internalId;    
     }      

      if(ids == "")
     {
         top.Ext.Msg.show({
                         title:TEXT_ERROR_MSG,
                         msg: TEXT_ERROR_SELECT,
                         buttons: Ext.Msg.OK,               
                         icon: Ext.MessageBox.ERROR
                     });
                     return false;
     }

       if(<%=ChildGrid%>)
       { 
         top.Ext.MessageBox.show({
               title: TITLE_REMOVE_RELATIONSHIP,
               msg: TEXT_REMOVE_RELSHIP,
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {     
                    var parameters = {name: entityName, id: ids, ParentId: parentId, ParentName: parentName}; 
                    // make the call back to the server
                    Ext.Ajax.request({
                        url: '/MetraNet/AjaxServices/BEDeleteSvc.aspx?ChildGrid=true',
                        params: parameters,
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                          if (success) {         
                           if(response.responseText == "OK") {
                              // everything is good, refresh the grid
                              dataStore_<%= BMEGrid.ClientID %>.reload();
                              
                            }    
                            else
                            {
                              Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                            }
                          }
                          else
                          {
                            Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                          }
                        }
                     }); 
      
                 }
                 else if(btn == 'cancel')
                 {                   
                    dataStore_<%= BMEGrid.ClientID %>.reload();  
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
       }
       else
       {
           top.Ext.MessageBox.show({
               title: TEXT_DELETE,
               msg: TEXT_DELETE_SELECTED_ROWS,
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
                     var parameters = {name: entityName, id: ids};
                   
                    // make the call back to the server
                    Ext.Ajax.request({
                        url: '/MetraNet/AjaxServices/BEDeleteSvc.aspx',
                        params: parameters,
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                          if (success) {
                            if(response.responseText == "OK") {
                              // everything is good, refresh the grid
                              dataStore_<%= BMEGrid.ClientID %>.reload();                              
                              Ext.get('relship_grid').dom.innerHTML = "";
                            }    
                            else
                            {
                              Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                            }
                          }
                          else
                          {
                            Ext.UI.SystemError(TEXT_ERROR_DELETING + " " + id);
                          }
                        }
                     }); 
      
                 }
                 else if(btn == 'cancel')
                 {                   
                    dataStore_<%= BMEGrid.ClientID %>.reload();  
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
       }
       grid_<%= BMEGrid.ClientID %>.getSelectionModel().clearSelections();
       Ext.get("<%=LblcurrentEntityName.ClientID %>").dom.innerHTML  = "";
     }

    function onOK_<%= BMEGrid.ClientID %>()
    {

     var records = grid_<%= BMEGrid.ClientID %>.getSelectionModel().getSelections();    
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
       if(i > 0)
       {
         ids += ",";
       }
       ids += records[i].data.internalId;    
     } 

    }

    function onNew_<%=BMEGrid.ClientID %>()
    {          
            
        var relshipType = '<%= RelshipType %>';       
        var RelshipTypeArray = new Array();                                        
        RelshipTypeArray = relshipType.split('--');
        var targetRelshipType = RelshipTypeArray[1]; 
        var totalRows;                           
        
        if(<%=ChildGrid %>)
         { 
                   // make the call back to the server
                    Ext.Ajax.request({
                        url: '/MetraNet/AjaxServices/BEListSvc.aspx?parentId=' + parentId + "&parentName=" + parentName +"&Name=" + entityName,                       
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                         if (success) {
                             var jsonData = Ext.util.JSON.decode(response.responseText.trim());
                             totalRows = parseInt(jsonData.TotalRows);  
                                if(targetRelshipType == 'One')
                                {                                
                                      if(totalRows > 0)
                                      {                                       
                                        top.Ext.Msg.show({
                                                        title: TEXT_ERROR_MSG,
                                                        msg: TEXT_ERROR_ONE_ONE,
                                                        buttons: Ext.Msg.OK,               
                                                        icon: Ext.MessageBox.ERROR
                                                    });                                   
                                          return false;
                                      }
                                      else
                                      {
                                          var windowURL =  String.format("/MetraNet/BME/BEUnrelatedEntityList.aspx?Name={0}&Extension=<%=BMEGrid.ExtensionName%>&ParentId={1}&ParentName={2}&Association={3}&Unrelated=true&MultiSelect={4}&currentEntityName={5}",entityName, parentId, parentName, associationValue, targetRelshipType, currentSourceEntityName);
                                          window.open(windowURL,'popupwindow','height=600,width=800,scrollbars=1');
                                      }
                                  }
                                  else
                                  {                                        
                                        var windowURL =  String.format("/MetraNet/BME/BEUnrelatedEntityList.aspx?Name={0}&Extension=<%=BMEGrid.ExtensionName%>&ParentId={1}&ParentName={2}&Association={3}&Unrelated=true&MultiSelect={4}&currentEntityName={5}",entityName, parentId, parentName, associationValue, targetRelshipType, currentSourceEntityName);
                                        window.open(windowURL,'popupwindow','height=600,width=820,scrollbars=1');
                                  }                                        
                           }
                          else
                          {
                            Ext.UI.SystemError(TEXT_ERROR_ADDING + " " + id);
                          }
                        }
                      });     
          }
          else
          {        
             document.location.href = String.format("BEEdit.aspx?name={0}&Association={1}&ParentId={2}&ParentName={3}&url={4}&NewOneToMany=true", entityName, associationValue, parentId, parentName, referer);
          }
  }
  
    var formConfirmBulkUpdate_<%=BMEGrid.ClientID %>;
    var windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>;

    function onBulkUpdate_<%=BMEGrid.ClientID %>() {
    

      //open up a window
      if (!windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>) {

        formConfirmBulkUpdate_<%=BMEGrid.ClientID %> = new Ext.form.FormPanel({
          standardSubmit: true,
          baseCls: 'x-plain',
          defaultType: 'hidden',
          style: 'padding:10px',
          items: [
//            {
//              hideLabel: true,
//              labelSeparator: '',
//              xtype: 'radio',
//              name: 'BulkUpdateType',
//              value: 'CurPage',
//              inputValue: 'CurPage',
//              boxLabel: TEXT_BULKUPDATE_CURRENT_PAGE_ONLY
//            },
            {
              checked: true,
              hideLabel: true,
              labelSeparator: '',
              xtype: 'radio',
              name: 'BulkUpdateType',
              value: 'All',
              inputValue: 'All',
              boxLabel: TEXT_BULKUPDATE_ALL_RECORDS
            },
            {
              hideLabel: true,
              labelSeparator: '',
              xtype: 'radio',
              name: 'BulkUpdateType',
              value: 'Selected',
              inputValue: 'Selected',
              boxLabel: TEXT_BULKUPDATE_SELECTED_RECORDS
            },
            {
              xtype: 'hidden',
              name: 'SelectedIds',
              value: ''
            }
          ]
        });
        
        windowConfirmBulkUpdate_<%=BMEGrid.ClientID %> = new Ext.Window({
          el: 'confirmBulkUpdateWindow_<%=BMEGrid.ClientID %>',
          cls: 'x-hidden',
          layout: 'fit',
          width: 500,
          height: 300,
          modal: true,
          title: TEXT_BULKUPDATE_SEARCH_RESULTS,
          closeAction: 'hide',
          plain: true,
          items: [formConfirmBulkUpdate_<%=BMEGrid.ClientID %>],
          buttons: [{
            text: TEXT_BULKUPDATE,
            handler: function(obj) {
              onOkBulkUpdate_<%=BMEGrid.ClientID %>();
              windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>.hide();
            }
          },
            {
              text: TEXT_CANCEL,
              handler: function(obj) {
                windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>.hide();
              }
            }]
        });

      }
      windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>.show();

    }

    function onOkBulkUpdate_<%=BMEGrid.ClientID %>() {

      var params = { };

      var formRes = formConfirmBulkUpdate_<%=BMEGrid.ClientID %>.getForm().getValues();
      var limitForUpdate = 0;
      var selectedIds = grid_<%=BMEGrid.ClientID %>.getSelectionModel().getSelections();

      if (selectedIds.length > 0) {
        limitForUpdate = selectedIds.length;
        for (var i = 0; i < selectedIds.length; i++)
          selectedIds[i] = selectedIds[i].id;
      }

      if (formRes.BulkUpdateType == "Selected" && selectedIds.length == 0) {
        Ext.MessageBox.show({
          msg: TEXT_NO_SELECTED_BME_FOR_BULKUPDATE, //There are no selected BMEs for bulk update
          icon: Ext.MessageBox.WARNING,
          title: TEXT_ERROR_NOTHING_UPDATED_BULKUPDATE, //Nothing will be updated
          buttons: Ext.Msg.OK,
          listners: {
            click: {
              element: 'OK',
              fn: function(btn) {
                if (btn == 'OK') {
                  windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>.hide();
                }
              }
            }
          }
        });
        return;
      }

      //copy standard params, overwrite if necessary
      for (var prop in dataStore_<%=BMEGrid.ClientID %>.lastOptions.params) {
        params[prop] = dataStore_<%=BMEGrid.ClientID %>.lastOptions.params[prop];
      }

      if (formRes.BulkUpdateType == 'All') {
        var totalRecords = dataStore_<%=BMEGrid.ClientID %>.reader.jsonData.TotalRows;
        params.start = 0;
        limitForUpdate = params.limit = parseInt(totalRecords, 10);
      } else if (formRes.BulkUpdateType == 'CurPage') {
        limitForUpdate = params["QuantityPerPage"] = dataStore_<%=BMEGrid.ClientID %>.getCount();
      }

      if (limitForUpdate > <%=LIMIT_NUMBER %>) {
        Ext.MessageBox.show({
          msg: '<%=limitDownSearch %>'.replace('NUMBER_TO_UPDATE', limitForUpdate), //Limit down your search to N entries.
          icon: Ext.MessageBox.WARNING,
          title: TEXT_ERROR_TOO_MANY_RECORDS_BULKUPDATE, //Too many records to update
          buttons: Ext.Msg.OK,
          listners: {
            click: {
              element: 'OK',
              fn: function(btn) {
                if (btn == 'OK') {
                  windowConfirmBulkUpdate_<%=BMEGrid.ClientID %>.hide();
                }
              }
            }
          }
        });
        return;
      }

      params["SelectedIds"] = selectedIds;
      params["BulkUpdateType"] = formRes.BulkUpdateType;

      Ext.Ajax.request({
        url: '/MetraNet/AjaxServices/BEListSvc.aspx?IsBulkUpdate=true' + "&Name=" + entityName,
        params: params,
        async: false,
        success: function() {
          document.location.href = String.format('BEEdit.aspx?name={0}&Association={1}&ParentId={2}&ParentName={3}&url={4}&NewOneToMany=true&IsBulkUpdate={5}', entityName, associationValue, parentId, parentName, referer, true);
        }
      });
    }
  </script>
  <div id='confirmBulkUpdateWindow_<%=BMEGrid.ClientID %>'>
  </div>
</asp:Content>
