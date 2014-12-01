<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  CodeFile="AdapterInstanceInformation.aspx.cs" Inherits="AdapterInstanceInformation" %>

<%@ Import Namespace="System.Threading" %>
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
        OnClientClick="ShowAuditHistory();return false;" runat="server" />
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
            runat="server" OnClick="btnRunAdaptersLater_Click" OnClientClick="btnRunRevertAdaptersLater_ClientClick('btnRunAdaptersLater'); return false;" />
        </td>
        <td>
          <MT:MTButton ID="btnRevertAdapters" meta:resourcekey="btnRevertAdapters" ClientIDMode="Static"
            runat="server" OnClick="btnRevertAdapters_Click" />
        </td>
        <td>
          <MT:MTButton ID="btnRevertAdaptersLater" meta:resourcekey="btnRevertAdaptersLater"
            ClientIDMode="Static" runat="server" OnClick="btnRevertAdaptersLater_Click" OnClientClick="btnRunRevertAdaptersLater_ClientClick('btnReverseAdaptersLater'); return false;" />
        </td>
        <td>
          <MT:MTButton ID="btnCancelSubmittedAction" meta:resourcekey="btnCancelSubmittedAction"
            ClientIDMode="Static" runat="server" OnClick="btnCancelSubmittedAction_Click" />
        </td>
      </tr>
    </table>
  </div>
  <MT:MTFilterGrid ID="AdapterInstanceRunHistoryGrid" runat="server" TemplateFileName="AdapterInstanceRunHistoryGrid"
    ExtensionName="Core" />
  <div id="later-win" class="x-hidden">
    <div id="later-win-body" class="x-panel">
      <MT:MTDatePicker runat="server" ID="dtRunRevertOn" ClientIDMode="Static" ViewStateMode="Disabled"
        EnableViewState="False" OptionalExtConfig="format:DATE_FORMAT,&#13;&#10;altFormats:DATE_TIME_FORMAT, minValue:new Date(),&#13;&#10;maxValue:null,&#13;&#10;minValue: new Date(),value: new Date(),anchor:'100%'"
        XType="datefield" ControlHeight="100" Height="100" />
    </div>
  </div>
  <div id="auditHistory-win" class="x-hidden">
    <div id="auditHistory-win-body" class="x-panel">
      <MT:MTFilterGrid ID="AuditHistoryGrid" runat="server" TemplateFileName="AdapterInstanceAuditHistoryGrid"
        ExtensionName="Core" ClientIDMode="Static" />
    </div>
  </div>
  <div id="runDetails-win" class="x-hidden">
    <div id="runDetails-win-body" class="x-panel">
      <div id="butchCountMessage" clientidmode="Static"></div>
      <MT:MTFilterGrid ID="RunDetailsGrid" runat="server" TemplateFileName="AdapterInstanceRunDetailsGrid"
        ExtensionName="Core" ClientIDMode="Static" />
    </div>
  </div>
  <script type="text/javascript">
    var instanceId = "<%=InstanceId %>";
    var adapterName = "<%=DisplayNameEncoded %>";
    var additionalParameters = "";
    var laterWin;
    var auditHistoryWin;
    var runDetailsWin;
    var dtRunRevertOnLabel = "<%=GetLocalResourceObject("RunLaterOn.Text").ToString() %>";

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
      return String.format("<a href='#' style='cursor:pointer' onclick='ShowRunDetails({0});return false;'>{1}</a>", record.data.id_run, value);
    }
      
    function DateStartColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      return value + GetDurationMessage(value, record.data.dt_end);
    }
    
    function ShowAuditHistory() {
      //window.open('/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/IntervalManagement.RunHistory.List.asp?InstanceId=<%=InstanceId %>&Title=<%=DisplayNameEncoded %>', '', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
      if(!auditHistoryWin) {
        auditHistoryWin = new Ext.Window({
            title: '<%=DisplayName %>'+'&nbsp;&mdash;&nbsp;<%=GetLocalResourceObject("AdapterInstanceAuditHistoryGrid.Title").ToString() %>',
            modal: 'true',
            applyTo:'history-win',
            layout:'fit',
            //width:650,
            height:420,
            closeAction:'hide',
            anchor:'100%',
            plain: true,
            buttonAlign: 'center',
            items: [{
                applyTo:'history-win-body',
                border: false,
                layout:'fit',
                bodyPadding: 0,
                anchor:'100%'
              }
            ],
            buttons: [{
              text: TEXT_CLOSE,
              handler: function() {
                laterWin.hide();
              }
            }]
        });
      }
      auditHistoryWin.show(this);  
    }
    
    function ShowRunDetails(runId) {
      //window.open('/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/AdapterManagement.RunDetails.List.asp?RunId='+runId+'&AdapterName='+adapterName+additionalParameters,'', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes');
      if(!runDetailsWin) {
        runDetailsWin = new Ext.Window({
            title: '<%=DisplayName %>'+'&nbsp;&mdash;&nbsp;<%=GetLocalResourceObject("AdapterInstanceRunDetailsGrid.Title").ToString() %>',
            modal: 'true',
            applyTo:'runDetails-win',
            layout:'fit',
            //width:650,
            height:420,
            closeAction:'hide',
            anchor:'100%',
            plain: true,
            buttonAlign: 'center',
            items: [{
                applyTo:'runDetails-win-body',
                border: false,
                layout:'fit',
                bodyPadding: 0,
                anchor:'100%'
              }
            ],
            buttons: [{
              text: TEXT_CLOSE,
              handler: function() {
                laterWin.hide();
              }
            }]
        });
      }
      runDetailsWin.show(this);  
    }
    
    function GetDurationMessage(dateStart, dateEnd) {
      var diff =  Math.round((new Date(dateEnd) - new Date(dateStart)) / 1000);
      if (diff == 0 || diff > 1) {
        return String.format(" [{0} {1}]", diff, "<%=GetLocalResourceObject("SecondPlural").ToString() %>");
      }
      return String.format(" [{0} {1}]", diff, "<%=GetLocalResourceObject("SecondSingular").ToString() %>");
    };
    
    function btnRunRevertAdaptersLater_ClientClick(btnId) {
      var windowTitle = "<%=GetLocalResourceObject("btnRunAdaptersLater.Text").ToString() %>";
      if (btnId == '<%=btnRevertAdaptersLater.ClientID %>') {
        windowTitle = "<%=GetLocalResourceObject("btnRevertAdaptersLater.Text").ToString() %>";
        dtRunRevertOnLabel = "<%=GetLocalResourceObject("RevertLaterOn.Text").ToString() %>";
      }
      Ext.fly('MTField_dtRunRevertOn').child('label').dom.innerText = dtRunRevertOnLabel+':';
      if(!laterWin) {
        laterWin = new Ext.Window({
            title: windowTitle,
            modal: 'true',
            applyTo:'later-win',
            layout:'fit',
            width:350,
            height:100,
            bodyPadding: 10,
            closeAction:'hide',
            plain: true,
            items: [{
                applyTo:'later-win-body',
                border: false,
                layout:'fit'
              }
            ],
            buttons: [{
              text: TEXT_OK,
              handler: function() {
                proceedAdapter(btnId);
                laterWin.hide();
              }
            },
            {
              text: TEXT_CANCEL,
              handler: function() {
                laterWin.hide();
              }
            }]
        });
      }
      laterWin.show(this);  
    }
    
    function proceedAdapter(btnId) {
      __doPostBack(btnId, '');
    }
  </script>
</asp:Content>
