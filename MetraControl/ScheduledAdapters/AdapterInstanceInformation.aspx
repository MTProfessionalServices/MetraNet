<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  CodeFile="AdapterInstanceInformation.aspx.cs" Inherits="AdapterInstanceInformation" %>

<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" meta:resourcekey="PageResource1"></asp:Label>
  </div>
  <MT:MTPanel runat="server" ClientIDMode="Static" ID="pnlInfo" meta:resourcekey="pnlInfo">
    <table>
      <tr>
        <td>
          <MT:MTLabel runat="server" ID="lblAdapter" ClientIDMode="Static" ViewStateMode="Disabled"
            meta:resourcekey="lblAdapter" />
        </td>
        <td>
          &nbsp;
        </td>
        <td>
          <MT:MTLabel runat="server" ID="lblAdapterValue" ClientIDMode="Static" ViewStateMode="Disabled" />
        </td>
      </tr>
      <tr>
        <td>
          <MT:MTLabel runat="server" ID="lblStatus" ClientIDMode="Static" ViewStateMode="Disabled"
            meta:resourcekey="lblStatus" />
        </td>
        <td>
          &nbsp;
        </td>
        <td>
          <MT:MTLabel runat="server" ID="lblStatusValue" ClientIDMode="Static" ViewStateMode="Disabled" />
        </td>
      </tr>
      <tr>
        <td>
          <MT:MTLabel runat="server" ID="lblInstanceId" ClientIDMode="Static" ViewStateMode="Disabled"
            meta:resourcekey="lblInstanceId" />
        </td>
        <td>
          &nbsp;
        </td>
        <td>
          <MT:MTLabel runat="server" ID="lblInstanceIdValue" ClientIDMode="Static" ViewStateMode="Disabled" />
        </td>
      </tr>
      <tr>
        <td>
          <MT:MTLabel runat="server" ID="lblArgStart" ClientIDMode="Static" ViewStateMode="Disabled"
            meta:resourcekey="lblArgStart" />
        </td>
        <td>
          &nbsp;
        </td>
        <td>
          <MT:MTLabel runat="server" ID="lblArgStartValue" ClientIDMode="Static" ViewStateMode="Disabled" />
        </td>
      </tr>
      <tr>
        <td>
          <MT:MTLabel runat="server" ID="lblArgEnd" ClientIDMode="Static" ViewStateMode="Disabled"
            meta:resourcekey="lblArgEnd" />
        </td>
        <td>
          &nbsp;
        </td>
        <td>
          <MT:MTLabel runat="server" ID="lblArgEndValue" ClientIDMode="Static" ViewStateMode="Disabled" />
        </td>
      </tr>
    </table>
    <div>
      <MT:MTButton ID="btnHistory" ClientIDMode="Static" meta:resourcekey="btnHistory"
        OnClientClick="ShowRunHistory();return false;" runat="server" />
    </div>
  </MT:MTPanel>
  <div>
    <table>
      <tr>
        <td>
          <MT:MTButton ID="btnRunAdapters" meta:resourcekey="btnRunAdapters" ClientIDMode="Static"
            runat="server" OnClick="btnRunAdapters_Click" />
        </td>
        <td>
          <MT:MTButton ID="btnRunAdaptersLater" meta:resourcekey="btnRunAdaptersLater" ClientIDMode="Static"
            runat="server" OnClick="btnRunAdaptersLater_Click" />
        </td>
        <td>
          <MT:MTButton ID="btnReverseAdapters" meta:resourcekey="btnReverseAdapters" ClientIDMode="Static"
            runat="server" OnClick="btnReverseAdapters_Click" />
        </td>
        <td>
          <MT:MTButton ID="btnReverseAdaptersLater" meta:resourcekey="btnReverseAdaptersLater"
            ClientIDMode="Static" runat="server" OnClick="btnReverseAdaptersLater_Click" />
        </td>
        <td>
          <MT:MTButton ID="btnCancelSubmittedAction" meta:resourcekey="btnCancelSubmittedAction"
            ClientIDMode="Static" runat="server" OnClick="btnCancelSubmittedAction_Click" />
        </td>
      </tr>
    </table>
  </div>
  <MT:MTFilterGrid ID="AdapterInstanceRunHistoryGrid" runat="server" TemplateFileName="AdapterInstanceRunHistoryGrid" ExtensionName="Core" />
  
  <script type="text/javascript">
    var instanceId = "<%=InstanceId %>";
    var adapterName = "<%=DisplayNameEncoded %>";
    var additionalParameters = "";
    if ("<%=IntervalId %>".len > 0) {
      additionalParameters = "&BillingGroupId=<%=BillingGroupId %>&IntervalId=<%=IntervalId %>";
    }
    OverrideRenderer_<%=AdapterInstanceRunHistoryGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('tx_detail'), DetailColRenderer);
      cm.setRenderer(cm.getIndexById('dt_start'), DateStartColRenderer);
    }

    function DetailColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      if (value.len == 0) {
        value = "<%=GetLocalResourceObject("ViewRunDetails").ToString() %>";
      }
      return String.format("<a href='#' style='cursor:pointer' onclick='getShowDetailsWindow({0});return false;'>{1}</a>", record.data.id_run, value);
    }
      
    function DateStartColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      return value + GetDurationMessage(value, record.data.dt_end);
    }
    
    function ShowRunHistory() {
      window.open('/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/IntervalManagement.RunHistory.List.asp?InstanceId=<%=InstanceId %>&Title=<%=DisplayNameEncoded %>', '', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
    }
    
    function getShowDetailsWindow(runId) {
      window.open('/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/AdapterManagement.RunDetails.List.asp?RunId='+runId+'&AdapterName='+adapterName+additionalParameters,'', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
    }
    
    function GetDurationMessage(dateStart, dateEnd) {
       var diff = new Date(dateStart) - new Date(dateEnd);
      return " [" + diff + "]";
    };
  </script>
</asp:Content>
