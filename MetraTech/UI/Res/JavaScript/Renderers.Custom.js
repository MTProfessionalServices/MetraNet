// Custom Renderers

CheckOrCreditCardNumberRenderer = function(value, meta, record, rowIndex, colIndex, store) {
  meta.attr = "align='right'";
  return "<span class='amount'>*******-" + value + "</span>";
}

CreditCardOrACHRenderer = function(value, meta, record, rowIndex, colIndex, store) {
   return record.data.PaymentMethod;
}