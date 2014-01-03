jQuery.noConflict();
(function ($) {
    $(function () {
      $("#adjustmentSummary input:not([id$='adjAmountFldTaxToatl'])").live("keyup", function () {
        var totalSum = 0.00;
         $.each($("#adjustmentSummary input:not([id$='adjAmountFldTaxToatl'])"),function() {
            totalSum += Number($(this).val());
         });

      var reg = /\./;
      if (!reg.test(totalSum))
        totalSum += '.00';

      var regOnlyDec = /\d+\.\d\d+$/;
      if (!regOnlyDec.test(totalSum))
          totalSum = '';

      $("input[id$='adjAmountFldTaxToatl']").css("color", "#000");
      $("input[id$='adjAmountFldTaxToatl']").val(totalSum);
      });
    });
})(jQuery);
 