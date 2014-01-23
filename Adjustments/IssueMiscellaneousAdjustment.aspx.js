jQuery.noConflict();
(function ($) {
    $(function () {
      $("#adjustmentSummary input:not([id$='adjAmountFldTaxToatl'])").live("keyup", function () {
        var totalSum = 0.00;
         $.each($("#adjustmentSummary input:not([id$='adjAmountFldTaxToatl'])"),function() {
            totalSum += Number($(this).val());
         });

      var regDecimal = /\./;
      if (!regDecimal.test(totalSum))
        totalSum += '.00';
	  else {
		regDecimal = /\d+\.\d$/;
		if (regDecimal.test(totalSum))
		totalSum += '0';
	  }
		
      $("input[id$='adjAmountFldTaxToatl']").css("color", "#000");
	  
	  var regOnlyDec = /\d+\.\d+$/;
	  if (regOnlyDec.test(totalSum))
          $("input[id$='adjAmountFldTaxToatl']").val(parseFloat(totalSum).toFixed(2));
	  else
		  $("input[id$='adjAmountFldTaxToatl']").val("");
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

// Use this function to ensure that only one button click gets executed on the page
function checkButtonClickCount() {
  incrementButtonClickCount();
  if (buttonClickCount <= 1)
    return true;
  else
    return false;
};
