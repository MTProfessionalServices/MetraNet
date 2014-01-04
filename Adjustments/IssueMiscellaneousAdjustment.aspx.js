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
		totalSum = totalSum + "0";
	  }
		
      $("input[id$='adjAmountFldTaxToatl']").css("color", "#000");      
	  $("input[id$='adjAmountFldTaxToatl']").val(totalSum.toString().match(/^\d+\.\d{2}/));
      });
    });
})(jQuery);
 