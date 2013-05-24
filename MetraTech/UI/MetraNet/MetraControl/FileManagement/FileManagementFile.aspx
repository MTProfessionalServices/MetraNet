<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="MetraControl_FileManagement_File" CodeFile="FileManagementFile.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
    <MT:MTTitle ID="MTTitle1" Text="<%$Resources:FileManagementResources,FILE_REJECTED_TITLE %>" runat="server" />   
    <MT:MTFilterGrid ID="MTFilterGrid1" 
                     ExtensionName="Core" 
                     TemplateFileName="Core.FileLandingService.FileBE"
                     runat="server">
    </MT:MTFilterGrid>
    
    <script type="text/javascript">
   
   // Load the state filter set by Page Load
   defaultOption_ctl00_ContentPlaceHolder1_MTFilterGrid1['_State'] = "<%=stateFilter%>";
    
    // Event handlers

    function onNew_ctl00_ContentPlaceHolder1_MTFilterGrid1()
    {
    }

    function onOK_ctl00_ContentPlaceHolder1_MTFilterGrid1()
    {
    }

    function onCancel_ctl00_ContentPlaceHolder1_MTFilterGrid1()
    {
      document.location.href = "<%=cancelUrl%>";
    }

    // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {  
          // Retry is currently disabled.
          // cm.setRenderer(cm.getIndexById('Retry'), optionsColRenderer);  
    }; 
    
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      var internalId = record.data.internalId;
      var id = record.data[record.fields.items[1].mapping] + "";  // this is the primary key... it has to go first in the grid?  how else do I know?
     
      // The retry feature is currently disabled.
      // We may want to enable this feature in the future.
      if (false)
      { 
        // View only
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onRetry('{0}','{1}')\"><img src=\"/Res/Images/icons/application_view_detail.png\" title=\"{2}\" alt=\"{2}\"/></a>", 
                             internalId, 
                             String.escape(id).replace(/"/g,""), 
                             String.escape("<%=retryHint%>"));
      }
     
      return str;
    };    
    
    function onRetry(internalId, id)
    {
      top.Ext.MessageBox.show({
               title: "<%=retryTitle%>",
               msg: String.format("<%=retryMessage%>", id),
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
                  window.location = String.format("/MetraNet/MetraControl/FileManagement/FileManagementFile.aspx?name={0}",
                                                  id);
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
    }
 
  </script>
</asp:Content>

