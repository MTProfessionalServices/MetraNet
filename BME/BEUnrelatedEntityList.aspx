<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="BEUnrelatedEntityList" CodeFile="BEUnrelatedEntityList.aspx.cs"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<div style="padding:10px">
    <MT:MTLabel ID="LblcurrentEntityName" runat="server" Font-Bold="true" Font-Size="Medium"/>
  </div>
  <div style="width:810px">
    <MT:MTFilterGrid ID="BMEGrid" runat="Server"></MT:MTFilterGrid>
  </div>
  
<div id="relship_grid" style="padding:10px"></div> 

 <script type="text/javascript">
    var referer ='<%=RefererUrl%>';
    var entityName = '<%=BEName%>';
    var associationValue = '<%=AssociationValue%>';
    var parentId = '<%=ParentId%>';
    var parentName = '<%=ParentName%>';
          
    // Custom Renderers
    OverrideRenderer_<%= BMEGrid.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };
    
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
      document.location.href = String.format("BEEdit.aspx?name={0}&id={1}&url={2}", entityName, internalId, referer);
    }
 
    function onDelete(internalId, id)
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
                        url: '/MetraNet/AjaxServices/BEDeleteSvc.aspx?UnRelated=true',
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
   
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      var internalId = record.data.internalId;
      var id = record.data[record.fields.items[1].mapping] + "";  // this is the primary key... it has to go first in the grid?  how else do I know?
   
      if(<%=ReadOnly%>)
      { 
        // View only
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEdit('{0}','{1}')\"><img src=\"/Res/Images/icons/application_view_detail.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_VIEW));
      }     
      else
      {
        // Edit Template
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEdit('{0}','{1}')\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_EDIT));

        // Delete button     
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onDelete('{0}','{1}')\"><img src=\"/Res/Images/icons/cross.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_DELETE));
      }
    
      return str;
    };    

    function onNew_<%=BMEGrid.ClientID %>()
    {      
      document.location.href = String.format("BEEdit.aspx?name={0}&Association={1}&ParentId={2}&ParentName={3}&url={4}&NewOneToMany=true&Unrelated=true", entityName, associationValue, parentId, parentName, referer);
    }
     
    function onCancel_<%= BMEGrid.ClientID %>()
    {
      window.close();
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

     if(ids == "")
     {
         top.Ext.Msg.show({
                         title: TEXT_ERROR_MSG,
                         msg: TEXT_ERROR_SELECT,
                         buttons: Ext.Msg.OK,               
                         icon: Ext.MessageBox.ERROR
                     });
                     return false;
     }

    var parameters = {name: entityName, id: ids}; 
              // make the call back to the server
              Ext.Ajax.request({
                  url: '/MetraNet/AjaxServices/BEListSvc.aspx?CreateRelationship=true&TargetEntityIds=' + ids + "&parentId=" + parentId + "&parentName=" + parentName +"&Name=" + entityName,
                  params: parameters,
                  scope: this,
                  disableCaching: true,
                  callback: function(options, success, response) {
                    if (success) {
                        window.opener.dataStore_ctl00_ContentPlaceHolder1_BMEGrid.reload();                            
                        window.close();
                    }
                    else
                    {
                      Ext.UI.SystemError(TEXT_ERROR_CREATE_RELSHIP + " " + id);
                    }
                  }
                });      
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
                              Ext.get('relship_grid').innerHTML = "";
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
        
       grid_<%= BMEGrid.ClientID %>.getSelectionModel().clearSelections();
     }

  
  </script>  
</asp:Content>

