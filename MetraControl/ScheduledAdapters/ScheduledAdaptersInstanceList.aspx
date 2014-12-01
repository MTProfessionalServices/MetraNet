<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="ScheduledAdaptersInstanceList.aspx.cs" Inherits="MetraControl_ScheduledAdapters_ScheduledAdaptersInstanceList" %>
<%@ Import Namespace="agsXMPP.protocol.x.data" %>
<%@ Import Namespace="MetraTech.DomainModel.Enums" %>
<%@ Import Namespace="MetraTech.DomainModel.Enums.Core.Metratech_com_Events" %>
<%@ Import Namespace="QuickGraph.Serialization" %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 
 <div class="CaptionBar">
    <asp:Label ID="lblTitle" Text="Scheduled Adapter Instance List For" runat="server"></asp:Label>
 </div>

 <div style="padding-left:5px;">
   <MT:MTFilterGrid ID="ScheduledAdaptertGrid" runat="server" TemplateFileName="ScheduledAdaptersInstanceList" ExtensionName="Core">
   </MT:MTFilterGrid>
</div>

<script type="text/javascript">
  OverrideRenderer_<%= ScheduledAdaptertGrid.ClientID %> = function(cm) {
    cm.setRenderer(cm.getIndexById('instanceid'), iDColRenderer);
  };

  function iDColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
   return String.format("<a style='cursor:pointer;' id='View'  href='/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/AdapterManagement.Instance.ViewEdit.asp?ID={0}&ReturnUrl={1}'>{0}</a>"
              , value, encodeURIComponent("/MetraNet/MetraControl/ScheduledAdaptersInstanceList.aspx?AdapterName=<%=AdapterNameBase64%>&ID=<%=IdAdapter%>")); 
  }

  </script>
  
  

</asp:Content>
