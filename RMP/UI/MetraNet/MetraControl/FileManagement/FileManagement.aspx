<%@ Page Title="<%$Resources:Resource,TEXT_TITLE_METRACONTROL%>" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="MetraControl_FileManagement_FileManagement" Codefile="FileManagement.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
    <MT:MTTitle ID="MTTitle1" Text="<%$Resources:FileManagementResources,JOB_GRID_GENERAL_TITLE %>" runat="server" />   
    <MT:MTFilterGrid ID="MTFilterGrid1" 
                     ExtensionName="Core" 
                     TemplateFileName="Core.FileLandingService.InvocationRecordBE"
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
    }
    
    function defaultOnClear()
    {
      var maxFilterCount = filters_ctl00_ContentPlaceHolder1_MTFilterGrid1.filters.keys.length;
      var i = 0;
      var filterName;
  
      while (i < maxFilterCount)
      {
        var filter = filters_ctl00_ContentPlaceHolder1_MTFilterGrid1.filters.items[i];

        if(!filter.readonly)
        {
          ClearFilter_ctl00_ContentPlaceHolder1_MTFilterGrid1(filter);
        }
        i++;
      }
    }

    function onClear_ctl00_ContentPlaceHolder1_MTFilterGrid1()
    {
       defaultOnClear();
       Ext.getCmp('filter_' + '_ControlNumber' + '_ctl00_ContentPlaceHolder1_MTFilterGrid1').setValue('');
       Ext.getCmp('filter_' + '_BatchId' + '_ctl00_ContentPlaceHolder1_MTFilterGrid1').setValue('');
       Ext.getCmp('filter_' + '_TrackingId' + '_ctl00_ContentPlaceHolder1_MTFilterGrid1').setValue('');
    }

    // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
      cm.setRenderer(cm.getIndexById('_ControlNumber'), optionsColRenderer); 
    };
     
    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = ""

      // Control Number

      str += String.format("&nbsp;<a style='cursor:hand;' id='edit' href='/MetraNet/MetraControl/FileManagement/FileManagementDetailReport.aspx?controlNumber={0}&filter={1}'>{0}</a>", 
                            String.escape(record.data._ControlNumber),
                            "<%=TryParseWithDefault(rawFilter)%>");

      return str;
    };    

  </script>
</asp:Content>

