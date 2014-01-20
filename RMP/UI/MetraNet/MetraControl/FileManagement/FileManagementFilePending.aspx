<%@ Page Title="<%$Resources:Resource,TEXT_TITLE_METRACONTROL%>" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="MetraControl_FileManagement_File_Pending" CodeFile="FileManagementFilePending.aspx.cs" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    
    <MT:MTTitle ID="MTTitle1" Text="<%$Resources:FileManagementResources,FILE_PENDING_TITLE %>" runat="server" />   
    <MT:MTFilterGrid ID="MTFilterGrid1" 
                     ExtensionName="Core" 
                     TemplateFileName="Core.FileLandingService.FileBEPending"
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

    // Custom Renderers
    OverrideRenderer_<%= MTFilterGrid1.ClientID %> = function(cm)
    {   
    }; 

  </script>
</asp:Content>

