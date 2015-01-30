// Custom Renderers

CheckOrCreditCardNumberRenderer = function(value, meta, record, rowIndex, colIndex, store) {
  meta.attr = "align='right'";
  return "<span class='amount'>*******-" + value + "</span>";
};

CreditCardOrACHRenderer = function(value, meta, record, rowIndex, colIndex, store) {
  return record.data.PaymentMethod;
};

CustomReportNameColumnRenderer = function (value, meta, record, rowIndex, colIndex, store) {
  // getCustomReportUrl method is implemented to /MetraNet/Reporting/js/Reports.js
  var url = window.getCustomReportUrl(value, meta, record, rowIndex, colIndex, store, "", "");

  var str = String.format("<span><a style='cursor:hand;' id='viewReport_{0}' title='{1}' href='{2};'>{1}</a></span>",
    record.data.internalId,
    record.data.Name,
    url);

  return str;
};