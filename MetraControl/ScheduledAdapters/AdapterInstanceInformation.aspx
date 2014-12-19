<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true"
  CodeFile="AdapterInstanceInformation.aspx.cs" Inherits="AdapterInstanceInformation" %>

<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" meta:resourcekey="PageResource1"></asp:Label>
  </div>
  <table style="border-spacing: 10px;">
    <tr>
      <td>
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
          <br/>
          <div>
            <MT:MTButton ID="btnHistory" ClientIDMode="Static" meta:resourcekey="btnHistory"
              OnClientClick="ShowAuditHistory();return false;" runat="server" />
          </div>
        </MT:MTPanel>
      </td>
    </tr>
    <tr>
      <td>
        <div align="center" style="display: block">
          <table style="border-spacing: 10px;">
            <tr>
              <td>
                <MT:MTButton ID="btnRunAdapters" meta:resourcekey="btnRunAdapters" ClientIDMode="Static"
                  runat="server" OnClick="btnRunAdapters_Click" />
              </td>
              <td>
                <MT:MTButton ID="btnRunAdaptersLater" meta:resourcekey="btnRunAdaptersLater" ClientIDMode="Static"
                  runat="server" OnClientClick="btnRunRevertAdaptersLater_ClientClick('btnRunAdaptersLater'); return false;" />
              </td>
              <td>
                <MT:MTButton ID="btnRevertAdapters" meta:resourcekey="btnRevertAdapters" ClientIDMode="Static"
                  runat="server" OnClick="btnRevertAdapters_Click" />
              </td>
              <td>
                <MT:MTButton ID="btnRevertAdaptersLater" meta:resourcekey="btnRevertAdaptersLater"
                  ClientIDMode="Static" runat="server" OnClientClick="btnRunRevertAdaptersLater_ClientClick('btnRevertAdaptersLater'); return false;" />
              </td>
              <td>
                <MT:MTButton ID="btnCancelSubmittedAction" meta:resourcekey="btnCancelSubmittedAction"
                  ClientIDMode="Static" runat="server" OnClick="btnCancelSubmittedAction_Click" />
              </td>
            </tr>
          </table>
        </div>
      </td>
    </tr>
  </table>
  <table>
    <tr>
      <td>
        <MT:MTFilterGrid ID="AdapterInstanceRunHistoryGrid" runat="server" TemplateFileName="AdapterInstanceRunHistoryGrid"
          ExtensionName="Core" />
      </td>
    </tr>
    <tr>
      <td style="horiz-align: center;">
        <div align="center" style="display: block">
          <table style="border-spacing: 10px;">
            <tr>
              <td>
                <MT:MTButton ID="btnRefresh" ClientIDMode="Static" runat="server" OnClick="btnRefresh_Click" />
              </td>
              <td>
                <MT:MTButton ID="btnCancel" ClientIDMode="Static" runat="server" OnClick="btnCancel_Click" />
              </td>
            </tr>
          </table>
        </div>
      </td>
    </tr>
  </table>
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
      <div id="butchCountMessage" clientidmode="Static">
      </div>
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
    var locolizedStatuses = Ext.util.JSON.decode('<%=JsonLocalizedStatuses%>');
    var locolizedActions = Ext.util.JSON.decode('<%=JsonLocalizedActions%>');

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
      return String.format("<a href='#' style='cursor:pointer' onclick='ShowRunDetails({0}, \"{1}\");return false;'>{2}</a>", record.data.id_run, record.data.tx_status, value);
    }
      
    function DateStartColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      return value + GetDurationMessage(value, record.data.dt_end);
    }
    
    OverrideRenderer_<%=AuditHistoryGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('tx_action'), ActionColRenderer);
    }
        
    function ActionColRenderer(value, meta, record) {
      return getLocolizedAction(value);
    }

    function ShowAuditHistory() {
      var windowHeight = grid_AuditHistoryGrid.height + 70;
      if(!auditHistoryWin) {
        auditHistoryWin = new Ext.Window({
            title: '<%=DisplayName %>'+'&nbsp;&mdash;&nbsp;<%=GetLocalResourceObject("AdapterInstanceAuditHistoryGrid.Title").ToString() %>',
            modal: 'true',
            applyTo:'auditHistory-win',
            layout:'fit',
            height:windowHeight,
            closeAction:'hide',
            anchor:'100%',
            plain: true,
            buttonAlign: 'center',
            items: [{
                applyTo:'auditHistory-win-body',
                border: false,
                layout:'fit',
                bodyPadding: 0,
                anchor:'100%'
              }
            ],
            buttons: [{
              text: TEXT_CLOSE,
              handler: function() {
                auditHistoryWin.hide();
              }
            }]
        });
      }
      auditHistoryWin.show(this);  
    }
    
    function ShowRunDetails(runId, runStatus) {
      var runDetails = GetInstanceRunDetails(runId);
      var windowHeight = grid_RunDetailsGrid.height + 70;
      var batchMessage = "";
      if (runDetails.BatchCount > 0) {
        batchMessage = String.format("<a href='#' onclick=\"window.open('/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/BatchManagement.List.asp?Filter=AdapterRun&RerunId={0}','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')\">{1}</a>", runId, "<%=GetLocalResourceObject("BatchDetails").ToString() %>");
        windowHeight += 20;
      }
      if (runStatus == "Failed") {
        batchMessage += String.format("<br><a href='#' onclick=\"window.open('/MetraNet/TicketToMOM.aspx?URL=/MOM/default/dialog/AdapterManagement.RunDetails.FailedAccount.List.asp?BillingGroupID={0}&IntervalID={1}&PopulateFromAdapterRun={2}','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')\">{3}</a>", "<%=BillingGroupId %>", "<%=IntervalId %>", runId, "<%=GetLocalResourceObject("FailedAccounts").ToString() %>");
        windowHeight += 20;
      }
      if (batchMessage.length > 0) {
        Ext.fly("butchCountMessage").dom.innerHTML = batchMessage;
      }
      if(!runDetailsWin) {
        runDetailsWin = new Ext.Window({
            title: '<%=DisplayName %>'+'&nbsp;&mdash;&nbsp;<%=GetLocalResourceObject("AdapterInstanceRunDetailsGrid.Title").ToString() %>',
            modal: 'true',
            applyTo:'runDetails-win',
            layout:'fit',
            height:windowHeight,
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
                runDetailsWin.hide();
              }
            }]
        });
      }
      runDetailsWin.show(this);  
    }
    
    function GetInstanceRunDetails(runId) {
      var result = { Urlparam_q: "", BatchCount: 0 };
      Ext.Ajax.request({
        url: "/MetraNet/Adapter/GetRunDetails",
        params: "runId="+ runId,
        success: function(response) {
          result = Ext.util.JSON.decode(response.responseText);
          grid_RunDetailsGrid.store.baseParams.urlparam_q = result.Urlparam_q;
          grid_RunDetailsGrid.store.load();
        }
      });
      return result;
    }
    
    function GetDurationMessage(dateStart, dateEnd) {
      var diff =  Math.round((Date.parseDate(dateEnd, DATE_TIME_FORMAT_DEF, true) - Date.parseDate(dateStart, DATE_TIME_FORMAT_DEF, true)) / 1000);
      if (diff == 0 || diff > 1) {
        return String.format(" [{0} {1}]", diff, "<%=GetLocalResourceObject("SecondPlural").ToString() %>");
      }
      return String.format(" [{0} {1}]", diff, "<%=GetLocalResourceObject("SecondSingular").ToString() %>");
    };
    
    function btnRunRevertAdaptersLater_ClientClick(btnId) {
      var windowTitle = "<%=GetLocalResourceObject("btnRunAdaptersLater.Text").ToString() %>";
      var dtRunRevertOnLabel = "<%=GetLocalResourceObject("RunLaterOn.Text").ToString() %>";
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
                layout:'fit',
                anchor:'100%'
              }
            ],
            buttons: [{
              text: TEXT_OK,
              handler: function() {
                __doPostBack(btnId, '');
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
    
    function getLocolizedAction(action) {
      if (!locolizedActions[action]) {
        locolizedActions[action] = action;
      }
      return locolizedActions[action];
    }
  </script>
</asp:Content>
