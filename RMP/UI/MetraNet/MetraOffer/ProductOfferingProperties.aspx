<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="ProductOfferingProperties.aspx.cs" Inherits="MetraOffer_ProductOfferingProperties" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  
  <MT:MTTitle ID="MTTitle1" Text="Properties" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" TemplateFileName="ProductOfferingProperties" ExtensionName="Account" ></MT:MTFilterGrid>
  
  <script type="text/javascript">

    // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('Actions'), optionsColRenderer); 
    };
    
    // Event handlers
    function onEdit(poId, specId)
    {
       location.href = '/MetraNet/MetraOffer/ProductOfferingPropertyEdit.aspx?poId=' + poId + '&specId=' + specId;
    }
        
    function onDelete(poId, specId)
    {
      top.Ext.MessageBox.show({
               title: TEXT_DELETE,
               msg: String.format(TEXT_DELETE_TEMPLATE_MESSAGE, String.escape(specId)),
               buttons: Ext.MessageBox.OKCANCEL,
               fn: function(btn){
                 if (btn == 'ok')
                 {
                   alert('delete ' + specId);
                 }
               },
               animEl: 'elId',
               icon: Ext.MessageBox.QUESTION
            });
    }
   
    function deleteResult(responseText)
    {
      //refresh grid
      dataStore_<%= MTFilterGrid1.ClientID %>.reload();
    }
   
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = ""

      // Edit Template
      str += String.format("&nbsp;<a style='cursor:hand;' id='edit' href='javascript:onEdit({0}, \"{1}\")'><img src='/Res/Images/icons/shape_square_edit.png' title='{2}' alt='{2}'/></a>", record.data.PoId, record.data.SpecId);
     
      // Delete button
      str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:onDelete({0}, \"{1}\")'><img src='/Res/Images/icons/cross.png' title='{2}' alt='{2}'/></a>", record.data.PoId, record.data.SpecId);
      return str;
    };    

    function onAddProperty_<%=MTFilterGrid1.ClientID %>()
    {
      location.href = '/MetraNet/MetraOffer/ProductOfferingPropertyEdit.aspx';  
    }
  

    // Remove Pager
    GetBottomBar_<%= MTFilterGrid1.ClientID %> = function()
    {
      var bbar = null;
      return bbar;
    };

  </script>
</asp:Content>

