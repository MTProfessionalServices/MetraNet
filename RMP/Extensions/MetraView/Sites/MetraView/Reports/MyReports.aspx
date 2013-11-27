<%@ Page Language="C#" MasterPageFile="~/MasterPages/ReportsPageExt.master" AutoEventWireup="true" Inherits="Reports_MyReports" CodeFile="MyReports.aspx.cs" Culture="auto" UICulture="auto" Title="<%$Resources:Resource,TEXT_TITLE%>" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<h1><%=Resources.Resource.TEXT_MY_REPORTS %></h1>
<MT:MTFilterGrid ID="MyGrid1" ExtensionName="MetraView" TemplateFileName="MyReportsLayoutTemplate.xml" runat="server"></MT:MTFilterGrid>


<script language="javascript" type="text/javascript">
  OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('Name'), nameRenderer); 
  }
  
  function nameRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var url = "";

    url = record.get('PageUrl');
    // no params
    if(url.indexOf('?') < 0)
    {
      url += '?';
    }  
    else{
      url+= '&';
    }
    url+= 'SavedSearchID=' + record.get('Id');
   
    var str = String.format("<a href='{0}'>{1}</a>", url, record.get('Name'));
    return str;
  }
</script>

</asp:Content>