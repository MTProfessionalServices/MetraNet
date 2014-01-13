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
 