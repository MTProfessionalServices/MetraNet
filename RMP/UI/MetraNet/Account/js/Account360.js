// Account 360 Properties Template - TODO: Move to Account360Templates.js once closer to done
var baseAccount360Tpl = new Ext.XTemplate(
      '<div>',
      '<tpl if="this.hasLDAP([values])">',

      '<tpl for="LDAP">',
      '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == false)">',
      '<span class="AccountName">{FirstName:htmlEncode} {LastName:htmlEncode}</span><br/>',
      '</tpl>',
//      '<tpl if="this.isNull(Company) == false">',
//        '<span class="{[false == true  ? "AccountName" : "AccountCompanyName"]}">{Company:htmlEncode}</span><br/>',
//      '</tpl>',
      '<tpl if="this.isNull(Company) == false">',
      '<tpl if="(this.isNull(LastName) == false)">',
      '<span>{Company:htmlEncode}</span><br/>',
      '</tpl>',
      '<tpl if="(this.isNull(LastName) == true)">', //ELSE
      '<span class="AccountName">{Company:htmlEncode}</span><br/>',
      '</tpl>',
      '</tpl>',
      '<tpl if="(this.isNull(FirstName) == true) && (this.isNull(LastName) == false)">',
      '<span class="AccountName">{LastName:htmlEncode}</span><br/>',
      '</tpl>',
      '<tpl if="(this.isNull(FirstName) == false) && (this.isNull(LastName) == true)">',
      '<span>{FirstName:htmlEncode}</span><br/>',
      '</tpl>',
      '</tpl>',
      '</tpl>',
      '<span class="AccountIdentifier">{UserName} ({_AccountID})</span><br/>',
      '<br />',
      '<tpl for="Internal">',
//'{UsageCycleTypeValueDisplayName} {Currency} {LanguageValueDisplayName}<br/>',
//'{UsageCycleTypeDisplayName}: {UsageCycleTypeValueDisplayName}<br/>', 
      '<span class="AccountInformationLarger">{UsageCycleTypeValueDisplayName}</span><br/>',
      '</tpl>',
      '<br><span>' + ACCOUNT_STATUS_LABEL_TEXT + ': {AccountStatusValueDisplayName} <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/AccountStateSetup.asp">' + ACCOUNT_EDIT_INFO_TEXT + '</a></span><br/>',
      '<tpl for="Internal">',
//'{UsageCycleTypeValueDisplayName} {Currency} {LanguageValueDisplayName}<br/>',
//'{UsageCycleTypeDisplayName}: {UsageCycleTypeValueDisplayName}<br/>',      
      '</tpl>',
//'{Internal.UsageCycleTypeDisplayName}: {Internal.UsageCycleTypeValueDisplayName}<br/>',      
//'{AccountStartDate}<br/>',
//'<span>Payer {_AccountID} {PayerID} {PayerAccount} </span><br/>',
      '<tpl if="(_AccountID == PayerID)">',
      '<span>' + ACCOUNT_PAYEE_SELF_TEXT + '</span> <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/PayerSetupHistory.asp">' + ACCOUNT_EDIT_INFO_TEXT + '</a></span><br/>',
      '</tpl>',
      '<tpl if="(_AccountID != PayerID)">',
//'<span>This account is paid for by <img alt="" src="/ImageHandler/images/Account/CorporateAccount/account.gif?Payees=0&amp;State=AC&amp;Folder=TRUE&amp;FolderOpen=FALSE" /><a href="/MetraNet/ManageAccount.aspx?id=946270527">{PayerAccount}</a></span> <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/PayerSetupHistory.asp">Change</a></span><br/>',
      '<span>' + ACCOUNT_PAYEE_TEXT + ' <a href="/MetraNet/ManageAccount.aspx?id={PayerID}">{PayerAccount} ({PayerID})</a></span> <a href="/MetraNet/TicketToMam.aspx?URL=/MAM/default/dialog/PayerSetupHistory.asp">' + ACCOUNT_EDIT_INFO_TEXT + '</a></span><br/>',
      '</tpl>',


      '</tpl>',

      '', {
        isNull: function (inputstring) {
          var res = false;
          if ((inputstring == null) || (inputstring == '') || (inputstring == 'null')) {
            res = true;
          }
          return res;
        }
        ,
        hasLDAP: function (accObj) {
          if (accObj == undefined) {
            return false;
          }
          if (accObj[0] == undefined) {
            return false;
          }

          if (accObj[0].LDAP == undefined) {
            return false;
          }

          return true;
        }
      }
    );

var CoreSubscriberTpl = baseTpl;
var CorporateAccountTpl = baseTpl;
var SystemAccountTpl = baseTpl;
var IndependentAccountTpl = baseTpl;
var DepartmentAccountTpl = baseTpl;
var Tpl = baseTpl;

function displayAccountStatusInformation() {
  var jsonData = getFrameMetraNet().accountJSON;
  var templateData = baseAccount360Tpl; //getFrameMetraNet().accountTemplate;

  if (jsonData === undefined)
    return;

  //Refresh accountSummaryPanel
  var accSummaryDiv = document.getElementById('AccountSummaryInformation');
  if (accSummaryDiv != null) {
    if (jsonData != null || jsonData != "") {
      try {
        if (templateData && templateData != "") {
          templateData.overwrite(accSummaryDiv, jsonData);
        }
      }
      catch (e) {
        getFrameMetraNet().Ext.UI.msg("Error1", e.message);
      }
    }
  }
  var accountStatusTpl = new Ext.XTemplate('<span class="valueLabel">' + ACCOUNT_STATUS_TEXT + '</span><span class="valueHighlighted">{AccountStatusValueDisplayName} </span>');
  var wAccountStatus = Ext.get('AccountStatus');

  if (wAccountStatus != null && (jsonData !== undefined)) {
    accountStatusTpl.overwrite(wAccountStatus, jsonData);
    wAccountStatus.show();
  }
}
    
function displayBalanceInformation() {
  var balanceInfoTpl = new Ext.XTemplate('<span class="valueLabel">' + ACCOUNT_BALANCE_TEXT + '</span><span class="valueHighlighted">{current_balanceAsString} </span><span class="valueDetail footer">' + ACCOUNT_BALANCE_AS_OF_TEXT + ' {currentbalancedate:date("F j, Y")}</span>');
      
  var wBalanceInformation = Ext.get('BalanceInformation');
                
  if (wBalanceInformation !=null)
  {
    Ext.Ajax.request({
      url: '/MetraNet/AjaxServices/ManagedAccount.aspx?operation=balancesummary',
      timeout: 10000,
      params: {},
      success: function (response) {
        if (response.responseText == '[]' || Ext.decode(response.responseText).Items[0] == null) {
        }
        else {
          balanceInfoTpl.overwrite(wBalanceInformation, Ext.decode(response.responseText).Items[0]);
          wBalanceInformation.show();
        }
      },
      failure: function () {
      }
    });
  }   
}

function displayFailedTransactionCount(accountId) {
  //Update Failed Transaction Count
  var failedTransactionInfoTpl = new Ext.XTemplate('<span class="valueLabel">' + ACCOUNT_FAILED_TRANSACTIONS_TEXT + '</span><span class="valueHighlighted"><a href="/MetraNet/MetraControl/FailedTransactions/FailedTransactionsView.aspx?Filter_FailedTransactionList_PossiblePayer=' + accountId + '">{payercount}</a> </span><span class="valueDetail footer"></span>');
  var wFailedTransaction = Ext.get('FailedTransactionInformation');
  if (wFailedTransaction != null) {
    Ext.Ajax.request({
      url: '/MetraNet/AjaxServices/ManagedAccount.aspx?operation=failedtransactionsummary',
      timeout: 10000,
      params: {},
      success: function (response) {
        if (response.responseText == '[]' || Ext.decode(response.responseText).Items[0] == null) {
          //Nothing to show, hide the panel
          //pBalanceInformation.hide();
        }
        else {
          var failedTransactionsCount = Ext.decode(response.responseText).Items[0];
          if (failedTransactionsCount.payercount > 0) {
            failedTransactionInfoTpl.overwrite(wFailedTransaction, Ext.decode(response.responseText).Items[0]);
            wFailedTransaction.show();
          }
        }

      },
      failure: function () {
      }
    });
  }   
}

function displayBillingActivityAndMRR(displayMRRData) {
  var dateFormat = d3.time.format("%m/%d/%Y %I:%M:%S");
  //var dayFormat = d3.time.format("%B %e, %Y");
  d3.json("/MetraNet/AjaxServices/ManagedAccount.aspx?_=" + new Date().getTime() + "&operation=billingsummary", function (error, data) {
    if (error) {
      console.log("Error:" + error.valueOf());
    } else {
      var items = [];
      var rowCounter = 1;
      var latestMRR = '';
      data.Items.forEach(function (d) {
        //d.n_order = +d.n_order;
        d.n_invoice_amount = +d.n_invoice_amount;
        d.n_mrr_amount = +d.n_mrr_amount;
        //d.n_payment_amount = -d.n_payment_amount;
        //d.n_balance_amount = +d.n_balance_amount;
        //d.n_adj_amount = +d.n_adj_amount;
        d.dd = dateFormat.parse(d.dt_transactionGraph);
        d.dd = new Date(d.dd.getUTCFullYear(), d.dd.getUTCMonth(), d.dd.getUTCDate());
        if (d.nm_type == 'Invoice') {
          d.n_order = rowCounter++;
          items.push(d);
          if (displayMRRData)
            latestMRR = d.n_mrramountAsString.replace("&pound", "£");
        }
      });
      drawGraph(items, displayMRRData);
      if (displayMRRData)
        displayMRR(latestMRR);
    }
  });
}

function drawGraph(items, displayMRRData) {
  var ndx = crossfilter(items);
  var dateDimension = ndx.dimension(function(d) { return d.n_order; });
  var invoiceGroup = dateDimension.group().reduceSum(function(d) { return d.n_invoice_amount; });
  var mrrGroup = dateDimension.group().reduceSum(function(d) { return d.n_mrr_amount; });
  var composite = dc.compositeChart("#billsPaymentsChart");
  composite
    .margins({ top: 5, right: 5, bottom: 60, left: 5 })
    .height(289)
    .width(360)
    .x(d3.scale.linear().domain([0.5, 12]))
    .elasticY(true)
    .renderHorizontalGridLines(true)
    .transitionDuration(0)
    .legend(dc.legend().x(15).y(245).itemHeight(13).gap(5))
    .brushOn(false)
    .title("MRR", function(d) { return items[d.key - 1].dt_transactionGraphTooltip + " " + ACCOUNT_MRR_GRAPH_TEXT + ": " + items[d.key - 1].n_mrramountAsString.replace("&pound", "£"); });
  if (displayMRRData) {
     composite.compose([
          dc.barChart(composite)
            .dimension(dateDimension)
            .group(invoiceGroup, ACCOUNT_INVOICE_GRAPH_TEXT)
            .centerBar(true)
            .colors('#0070C0')
            .title(function (d) { return items[d.key - 1].dt_transactionGraphTooltip + " " + ACCOUNT_INVOICE_GRAPH_TEXT + ": " + items[d.key - 1].n_invoiceamountAsString.replace("&pound", "£"); }),
          dc.lineChart(composite)
            .dimension(dateDimension)
            .group(mrrGroup, ACCOUNT_MRR_GRAPH_TEXT)
            .colors('#00B0F0')
            .renderDataPoints({ radius: 4, fillOpacity: 0.5, strokeOpacity: 0.8 })
            .title(function (d) { return items[d.key - 1].dt_transactionGraphTooltip + " " + ACCOUNT_MRR_GRAPH_TEXT + ": " + items[d.key - 1].n_mrramountAsString.replace("&pound", "£"); })
        ]);
  } else {
     composite.compose([
          dc.barChart(composite)
            .dimension(dateDimension)
            .group(invoiceGroup, ACCOUNT_INVOICE_GRAPH_TEXT)
            .centerBar(true)
            .colors('#0070C0')
            .title(function (d) { return items[d.key - 1].dt_transactionGraphTooltip + " " + ACCOUNT_INVOICE_GRAPH_TEXT + ": " + items[d.key - 1].n_invoiceamountAsString.replace("&pound", "£"); })]);    
  }
 
  composite.xAxis().tickSize(0, 0).tickFormat("");
  composite.yAxis().tickSize(0, 0).tickFormat("");
  if (items.length == 0) {
    d3.select("#billsPaymentsChart").text(TEXT_NO_DATA_FOR_GRAPH).attr("x", "2").attr("y", "2").style("color", "gray");
    composite.height(275);
  }
  composite.render();
  composite.redraw();
  dc.renderAll();
}

function displayMRR(MRRValue) {
  var mrrInfoTpl = new Ext.XTemplate('<span class="valueLabel">' + ACCOUNT_MRR_TEXT + '</span><span class="valueHighlighted">{.} </span>');

  var wMRRInformation = Ext.get('MRRInformation');

  if (wMRRInformation != null) {
    mrrInfoTpl.overwrite(wMRRInformation, MRRValue);
    wMRRInformation.show();
  }
}