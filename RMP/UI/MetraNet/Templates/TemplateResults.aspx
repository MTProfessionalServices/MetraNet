<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_TemplateResults" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="TemplateResults.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Template History" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />
  
  <MT:MTFilterGrid ID="MTFilterGrid1" runat="server" 
    TemplateFileName="AccountTemplateSessionDetail" ExtensionName="Account"></MT:MTFilterGrid>

  <script type="text/javascript">

    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('ResultValueDisplayName'), resultRenderer); 
    };
    
    resultRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      
      switch(record.data.Result)
      {
        case 0: // Information
          str = "<img border='0' src='/Res/Images/Icons/information.png'>";
          break;
        
        case 1: // Success
          str = "<img border='0' src='/Res/Images/Icons/accept.png'>";
          break;
      
        case 2: // Failure
          str = "<img border='0' src='/Res/Images/Icons/exclamation.png'>";
          break;
        
        case 3: // FailureDetail 
          str = "<img border='0' src='/Res/Images/Icons/information_error.png'>";
          break;
                      
        default:
          str = "<img border='0' src='/Res/Images/Icons/flag_blue.png'>";
          break;
      }
      
      str += "&nbsp;" + value;  
    
      return str;
    };    

    BeforeExpanderRender_<%= MTFilterGrid1.ClientID %>  = function(tplString){
      
      tplString += "<div class='expanderSectionTitle'>" + TEXT_DETAIL_DESCRIPTION + "</div><div style='padding-left:20px;'>{Detail:formatLineBreaks}</div>"
      return tplString;
    };

    
    function onCancel_<%= MTFilterGrid1.ClientID %>() {
      if (checkButtonClickCount() == true) {
        pageNav.Execute("TemplateEvents_BackTemplateResults_Client", null, null);
      }
    }

    function onRefresh()
    {
      dataStore_<%= MTFilterGrid1.ClientID %>.reload();
    }
    
    GetTopBar_<%= MTFilterGrid1.ClientID %> = function()
    {
      var tbar = new Ext.Toolbar([{
                xtype: 'checkbox',
                boxLabel: TEXT_AUTO_REFRESH,
                id: 'cbRefresh',
                checked: false,
                name: 'cbRefresh'
            }]);
      return tbar;
    };

    function gridEvents() {
      this.refreshGrid = function() {
      if(Ext.get("cbRefresh").dom.checked)
      {
        onRefresh();
      }
      setTimeout("events.refreshGrid()", 25000); 
      }
    };

    // start event polling
    var events = new gridEvents();
    setTimeout("events.refreshGrid()", 25000);
    
  </script>
  
</asp:Content>
