<%@ Page Title="<%$Resources:Resource,TEXT_TITLE_METRACONTROL%>" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="FileManagementTargets" CodeFile="FileManagementTargets.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<%@ Register src="../../UserControls/BreadCrumb.ascx" tagname="BreadCrumb" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="<%$ Resources:FileManagementResources,TEXT_BE %>" runat="server" />
<uc1:BreadCrumb ID="BreadCrumb1" runat="server" />
<br /><br />

  <div style="width:810px">
    <MT:MTFilterGrid ID="MyGrid1" runat="Server"></MT:MTFilterGrid>
  </div>
  
  <script type="text/javascript">
    var referer ='<%=RefererUrl%>';
    var entityName = '<%=BEName%>';
    var associationValue = '<%=AssociationValue%>';
    var parentId = '<%=ParentId%>';
    var parentName = '<%=ParentName%>';
          
    // Custom Renderers
    OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
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
        dataStore_<%= MyGrid1.ClientID %>.reload();
      }
    }

    function onEdit(internalId, id)
    {
        document.location.href = String.format("/MetraNet/MetraControl/FileManagement/FileManagementTarget.aspx?name={0}&id={1}&url={2}", entityName, internalId, referer);
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
                        url: '/MetraNet/AjaxServices/BEDeleteSvc.aspx',
                        params: parameters,
                        scope: this,
                        disableCaching: true,
                        callback: function(options, success, response) {
                          if (success) {
                            if(response.responseText == "OK") {
                              // everything is good, refresh the grid
                              dataStore_<%= MyGrid1.ClientID %>.reload();
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

    function onNew_<%=MyGrid1.ClientID %>()
    {
       document.location.href = String.format("/MetraNet/MetraControl/FileManagement/FileManagementTarget.aspx?name={0}&Association={1}&ParentId={2}&ParentName={3}&url={4}&NewOneToMany=true", entityName, associationValue, parentId, parentName, referer);
    }
     
    function onCancel_<%= MyGrid1.ClientID %>()
    {
      document.location.href = '<%=ReturnUrl %>';
    }
  
    // Render related entities in details section 
    BeforeExpanderRender_<%= MyGrid1.ClientID %> = function(tplString)
    {
      var html = "<%=RelatedEntityLinksHtml%>";
      tplString = tplString + html;
      return tplString;
    };
  
  </script>  
</asp:Content>


