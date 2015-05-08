jQuery.noConflict();
(function ($) {
  $(function () {
    $("#adjustmentSummary input:not([id$='adjAmountFldTaxToatl'])").live("keyup", function () {
      var input = this.value;
      if (input != "-") {
        var totalSum = 0.00;

        $.each($("#adjustmentSummary input:not([id$='adjAmountFldTaxToatl'])"), function () {
          var currentValue = this.value;
          totalSum += Number(parseValue(currentValue));
        });

        var regDecimal = /\./;
        if (!regDecimal.test(totalSum)) {
          totalSum += '.00';
        } else {
          regDecimal = /\d+\.\d$/;
          if (regDecimal.test(totalSum))
            totalSum += '0';
        }

        $("input[id$='adjAmountFldTaxToatl']").css("color", "#000");

        if (isNaN(totalSum))
          $("input[id$='adjAmountFldTaxToatl']").val("");
        else if (totalSum.length >= 20)
          $("input[id$='adjAmountFldTaxToatl']").val(TEXT_ERROR_INVALID_VALUE);
        else
          $("input[id$='adjAmountFldTaxToatl']").val(parseFloat(totalSum).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: FRACTION_DIGITS, minimumFractionDigits: FRACTION_DIGITS }));
      }
    });
  });
})(jQuery);

var buttonClickCount;

Ext.onReady(function () {
  buttonClickCount = 0;
});

function incrementButtonClickCount() {
  buttonClickCount += 1;
}

function resetButtonClickCount() {
  buttonClickCount = 0;
}

// private
// Can't call parseFloat() because value might be too large.
// Instead, just replaces decimal separator with standard '.' and checks for NaN.
// Returns number or empty string.
function parseValue(value) {
  value = String(value).split(DECIMAL_SEPARATOR + DECIMAL_SEPARATOR).join("?");
  value = String(value).split(DECIMAL_SEPARATOR).join("_");
  if (DIGIT_SEPARATOR != " ")
    value = String(value).split(DIGIT_SEPARATOR).join("");
  else
    value = String(value).split(/\s+/).join("");
  value = String(value).split("_").join(".");
  value = Number(value);
  return isNaN(value) ? '' : value;
}

// Use this function to ensure that only one button click gets executed on the page
function checkButtonClickCount() {
  incrementButtonClickCount();
  if (buttonClickCount <= 1)
    return true;
  else
    return false;
};
