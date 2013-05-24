/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Non-Production Javascript for Demo Site - Metanga Web Application
    Javascript not intended for final production, which 
    controls presentation-related behavior on the Metanga demo site.

Author: Above The Fold, LLC - http://www.abovethefolddesign.com

Table of Contents
    Note: Equals signs (=) are search flags
-----------------------------------------------------------
	=Tooltips
	=Submit
	=Reports
	=Accounts
	=Products
	=Self Care
	=Configuration
	=Jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

$(function () { // Document ready function, for jQuery


  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Tooltips
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  $(document).find('#tooltip-sticky').prepend('<a class="close-alert" href="#">Close</a>');
  $('#tooltip-sticky .close-alert').click(function () {
    //$.tooltip.close;
    $('#tooltip-sticky').css('display', 'none');
    return false;
  });



  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Submit button mgmt -- This is for prototype only. NOT PRODUCTION CODE
  Disables the 'submit' buttons until 'Agree' checkbox is checked
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  // Finds and disables all buttons/links with class of 'btn-submit'
  $('.btn-submit').attr('disabled', 'disabled').attr('aria-disabled', 'true');

  // When #terms_agree is checked, if checked, enable '.btn-submit'
  $('#terms_agree').click(function () {
    if ($(this).is(':checked')) {
      $('.btn-submit').removeAttr('disabled').attr('aria-disabled', 'false').removeClass('ui-state-disabled');
    }
    else {
      $('.btn-submit').attr('disabled', 'disabled').attr('aria-disabled', 'true').addClass('ui-state-disabled');
    }
  });



  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Reports
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  // Adds "disabled" to the "next" control by default in the active timeframe -- NOT FOR PRODUCTION
  $(".timeframe-control li.active .timeframe-pager.next").addClass("disabled");

  // Fake-Clone list items from source list to destination -- NOT FOR PRODUCTION
  $(".add-list.source li").not("disabled").click(function () {
    var el = $(this);
    $(el).clone().prependTo(".add-list.destination");
    $(el).addClass("disabled");
  });

  // Schedule Reports - Add contacts -- NOT FOR PRODUCTION
  $(".add-list.select li").toggle(function (e) {
    $(this).addClass("selected");
  }, function () {
    $(this).removeClass("selected");
  });

  // Add Reports - Setting "disabled" state -- NOT FOR PRODUCTION
  $(".widget .status").click(function (e) {
    e.preventDefault();
    $(this).parents(".widget").addClass("disabled");
  });


  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Accounts
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  // Disable column in Subscription comparison, based on billing cycle -- NOT FOR PRODUCTION
  $("#billing_cycle_year").click(function (e) {
    $(".table-comparison th:last-child span").addClass("ui-state-disabled");
    $(".table-comparison td:last-child .btn").addClass("ui-state-disabled");
    $(".table-comparison .feature td:last-child").wrapInner('<span class="ui-state-disabled"></span>');
    $(".table-comparison .feature td:last-child .ui-icon").addClass("ui-state-disabled");
  });
  $("#billing_cycle_month").click(function (e) {
    $(".table-comparison *").removeClass("ui-state-disabled");
  });

  // Add "changed" class to configurable pricing tablerow -- NOT FOR PRODUCTION
  $(".table-product-pricing .save-configuration").click(function (e) {
    if (!$(this).hasClass("save-reset")) {
      var this_row = $(this).parents("tr");
      var parent_row = this_row.prev("tr");
      parent_row.addClass("changed");
      if (!parent_row.find(".product-name span").hasClass("chng")) {
        parent_row.find(".product-name").append('<span class="chng">*</span');
      }
      $(".message-changed").removeClass("hidden");
      this_row.find(".reset-configuration").removeClass("hidden");
    } else {
      $(this).removeClass("save-reset");
    }
  });
  // Reset pricing
  $(".table-product-pricing .reset-configuration").click(function (e) {
    e.preventDefault();
    var this_row = $(this).parents("tr");
    var parent_row = this_row.prev("tr");
    parent_row.removeClass("changed").find(".chng").remove();
    this_row.find(".reset-configuration").addClass("hidden");
    this_row.find(".save-configuration").addClass("save-reset");
  });


  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Products
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  // Clone a table row in Smart Products -- NOT FOR PRODUCTION
  $(".table-product-model-options").delegate(".add-row", "click", function (e) {
    e.preventDefault();
    
    var parent_row = $(this).parents("tr");
    if ($(this).hasClass("add-above")) {
      parent_row.clone().insertBefore(parent_row).addClass("highlight").removeClass("price-present");
    } 
    else {
      parent_row.clone().insertAfter(parent_row).addClass("highlight").removeClass("price-present");
    }
    adjust_layout();
    $('.datepicker').removeClass('hasDatepicker').attr("id", "").datepicker();
  });
  $(".table-product-model-options").delegate("input", "focus", function (e) {
    $(this).parents("tr").removeClass("highlight");
  });


  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Self Care/Upgrade-Downgrade
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  // Route the user to a success page when upgrading
  $('#upgrade-submit').click(function () {
    var checkedItem = $(this).parents('.reveal-modal').find('input[name="effective_date"]:checked');
    var checkedIndex = checkedItem.parent('li').index();
    if (checkedIndex == 0) {
      window.location.href = 'my-subscription-success-now.html';
    } else {
      window.location.href = 'my-subscription-success-later.html';
    }
  });

  // CSR version of the above
  $('#upgrade-submit-csr').click(function () {
    window.location.href = 'edit-subscription-settings-upgrade-success.html';
  });


  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Configuration
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */

  /* Notifications */

  // Show/hide a set of form fields depending on a checked radio button
  var notificationTypeToggle = function () {
    var el = $('[name="notification_type"]');

    var parent = $(el).closest('.container');
    var optid = $(el).filter(':checked').attr('id');

    if (optid) {
      // Get the string from the ID attribute
      var u = optid.lastIndexOf("_");
      var optval = optid.substring(u + 1);
    }

    parent.find('[id^="notification_options_"]').addClass('hidden');
    parent.find('#notification_options_' + optval).removeClass('hidden');

    adjust_layout();
  }
  notificationTypeToggle();
  $('[name="notification_type"]').change(function (e) {
    notificationTypeToggle();
  });

  // Remove disabled state from submit button when Notification Type is selected
  if ($('input[name="notification_type"]:checked').length) {
    $('button').removeAttr('disabled').button('option', 'disabled', false);
  }
  $('input[name="notification_type"]').click(function () {
    $('button').removeAttr('disabled').button('option', 'disabled', false);
  });

  // Cloning a set of criteria
  $('.action-clone a').click(function (e) {
    e.preventDefault();

    // Set parent <ul>
    var parent = $(this).closest('ul');

    // Get current count of cloneable <li> elements
    var qty = $(parent).find('li.cloneable').length;

    // Define the element to clone, and its <select> value
    var el = parent.find('li.cloneable:last');
    var optval = el.find('select').attr('value');

    // Clone it
    var clone = el.clone();

    // Get the current ID number
    var idx = qty + 1;

    // Increment the clone's ID
    clone[0].setAttribute('id', 'criteria_' + idx);

    // Clear the contents of the clone's <input>
    clone.find('input').each(function () {
      this.value = '';
    });

    // Put the clone where it goes
    clone.insertBefore('.action-clone').find('.remove').removeClass('hidden');
  });

  // "Remove" link behavior
  $('.remove').live('click', function (e) {
    e.preventDefault();
    $(this).closest('li').remove();
  });

  // Showing more options on selection
  var selectUnHide = function (el) {

    var optval = $(el).find('option:selected').attr('value');
    var targetObj = $(el).closest('li').find('.other-options');

    if (optval == 'email_destination_other' || optval == 'email_from_other') {
      targetObj.removeClass('hidden');
      adjust_layout();
    } else {
      targetObj.addClass('hidden');
      adjust_layout();
    }
  }
  selectUnHide('#email_destination');
  $('#email_destination').change(function () {
    selectUnHide(this);
  });
  selectUnHide('#email_from');
  $('#email_from').change(function () {
    selectUnHide(this);
  });

  // Inserting template variables
  $('.variable').click(function () {
    // If editor does not have focus, give it focus - Not working for initial load
    // var editor = $('.rich-text-area').ckeditorGet();
    // editor.focus();

    var vartext = $(this).text();
    CKEDITOR.instances.emailbody.insertText(vartext);
  });

  // AJAX loading of Email Preview
  $("#show-preview").click(function () {
    var load_url = "../invoices/email_template.html";

    $("#modal-preview-email").find(".content .inner").load(load_url, function () {
      buttons_init();
      adjust_layout();
    });
  });

  /* Units */
  // Replace "new unit" with new unit name
  $('#unit_name').change(function () {
    var nameValue = $(this).attr('value');
    if (nameValue.length) {
      $('#new-unit-name').text(nameValue.toLowerCase());
    } else {
      $('#new-unit-name').text('new unit');
    }
  });
  // Replace "base unit" with base unit name, enable conversion factor
  $('#base_unit').change(function () {
    var nameValue = $(this).attr('value');
    if (nameValue !== 'None') {
      $('#conversion-factor-fieldset').removeClass('ui-state-disabled').find('select, input').removeAttr('disabled');
      $('#conversion-preview').removeClass('hidden');
      $('#base-unit').text(nameValue + 's');
      adjust_layout();
    } else {
      $('#conversion-factor-fieldset').addClass('ui-state-disabled');
      $('#conversion-preview').addClass('hidden');
      $('#base-unit').text('base units');
      adjust_layout();
    }
  });
  // Handle multiply/divide
  $('#conversion_operator').change(function () {
    var opValue = $(this).attr('value');
    if (opValue == 'divide') {
      $('#conversion-factor').prepend('1/');
    } else {
      if ($('#conversion_factor').attr('value').length) {
        var cfValue = $('#conversion_factor').attr('value');
        $('#conversion-factor').text(cfValue);
      }
    }
  });
  // Replace example conversion factor with real conversion factor
  $('#conversion_factor').change(function () {
    var cfValue = $(this).attr('value');
    if ($('#conversion_operator').attr('value') == 'divide') {
      if (cfValue.length) {
        $('#conversion-factor').text('1/' + cfValue);
      } else {
        $('#conversion-factor').text('1/10');
      }
    } else {
      if (cfValue.length) {
        $('#conversion-factor').text(cfValue);
      } else {
        $('#conversion-factor').text('10');
      }
    }

  });
  /* Payment Gateway Routing */
  //$('.ui-table-routing .amount-dropdown').change(function(){
  var toggleRange = function () {
    var selection = $(this).val();
    if (selection == 'Range') {
      $(this).siblings().filter('.amount-range').children('input').removeAttr("disabled").val('');
      console.log($(this).siblings().filter('.amount-range').children('input'));
    } else if (selection == 'Any') {
      $(this).siblings().filter('.amount-range').children('input').attr('disabled', 'disabled').val("Any Amount");
    }
  };
  $('.ui-table-routing .amount-dropdown').on("change", toggleRange);

  var addRangeToAmtDropdown = function () {
    var lower = $(this).siblings().filter('.lower-amount').val();
    var upper = $(this).val();
    //var amtControl = $(this).parent().siblings('.amount-dropdown');
    var amtControl = $(this).parents('tbody').find('.amount-dropdown');
    console.log(amtControl);
    amtControl.append('<option>' + lower + ' - ' + upper + '</option>');

  };
  $('.ui-table-routing .upper-amount').on("blur", addRangeToAmtDropdown);

  $('#modal-routing-rule .add-routing-rule').click(function () {
    var oTable = $('.ui-table-routing').dataTable();
    var defaultRouting = oTable.fnGetData(0);
    defaultRouting[0] = "or:";
    oTable.fnAddData(defaultRouting);
    $('.ui-table-routing .amount-dropdown').on("change", toggleRange);
    $('.ui-table-routing .upper-amount').on("blur", addRangeToAmtDropdown);
    oTable.$('tr:last').find('a.btn.delete').removeClass('hidden').on("click", function () {
      var row = oTable.fnGetPosition($(this).parentsUntil('tbody', 'tr').get(0));
      oTable.fnDeleteRow(row);
    });
    oTable.fnDraw();
    oTable.$('tr:last').addClass('highlight-green').delay(2000).removeClass('highlight-green', 2000);
  });

  /*$('.ui-table-routing a.btn.delete').click(function(){
  var oTable = $('.ui-table-routing').dataTable();
  row = oTable.fnGetPosition($('a.btn.delete').parent().get(0));
  console.log(row);
  }); */
 
 /* Braintree - Payment Gateway Routing */	
	$('a.braintree-signup').click(function(){
		//url = "https://apply.braintreegateway.com/automated/application/business/edit";
		url = "braintree/edit.html"
		btiframe = '<div class="tspace lspace"><iframe id="btiframe" width="100%" height="100%" frameborder="0" seamless="seamless" scrolling="no" src="'+url+'"></iframe></div>';
		//btiframe = $('#btiframe');
		$('div.braintree-demo').css("height","auto");
		
		$('div.braintree-demo').flip({
			direction: 'tb',
			color: 'white',
			speed: 250,
			content: btiframe, //$('#btiframe'), 
			onBefore: function(){
				//$('.btiframe').removeClass("hidden");
			},
			onEnd: function(){
				//window.resize();
				//equalize_cols();
				//equalize_heights();
				$('div.braintree-demo').css("height","2000");
				//$('.btiframe').removeClass("hidden");
				$('iframe#btiframe').load(function(){
						$(this).contents().find('input[name="commit"]').click(function(e){
							e.preventDefault();
							$('body,html').animate({
								scrollTop: 0
							}, 0);
							metangaProcessing();
							setTimeout(function(){
								metangaProcessing();
								$('iframe#btiframe').remove();
								$('div.braintree-demo').append()
							},5000);
						});
				});
			}
		});
		
	});
	

  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Jobs
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */

  /* Show/hide job details */
  $('.toggle-job-details').supertoggle({
    togglerOnText: 'Hide details',
    togglerOffText: 'Show details',
    scopeParent: 'li',
    callbackShow: function () {
      adjust_layout();
    },
    callbackHide: function () {
      adjust_layout();
    }
  });

  /* Progress from stage1 to stage2 */
  $('.start-job').click(function (e) {
    e.preventDefault();
    $('.job').removeClass('hidden');
    window.setTimeout(function () {
      $('.job').find('#job-stage1').addClass('hidden').siblings('#job-stage2').removeClass('hidden');
      $('#nav-main li:contains("Jobs")').append('<span class="callout-count">1</span>');
    }, 3000);
  });


  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Enrollment Workflow - This is for prototype only, not production
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  // Change billing cycle text and price in the packages on enrollment page
  var origCost = [];
  $("div.offering span[totalprice]").each(function (index) {
    origCost[index] = parseFloat($(this).text().substring(1, $(this).text().length));
  });

  $("#enroll_billing_cycle_yearly").click(function (e) {
    $("div.offering span[totalprice]").each(function (index) {
      var moCost = origCost[index];
      moCost *= 12.00;
      $(this).html('$' + moCost.toFixed(2).toString());
    });

    $("div.offering span:contains('Month')").html('&nbsp;/ Year');
    //$(".quant-table").find("td:contains('month')").text('Year');
    //console.log(test);
  });

  $("#enroll_billing_cycle_monthly").click(function (e) {
    $("div.offering span[totalprice]").each(function (index) {
      var yrCost = origCost[index];
      $(this).html('$' + yrCost.toFixed(2).toString());
    });

    $("div.offering span:contains('Year')").html('&nbsp;/ Month');
  });

  $("#billing_same").change(function (e) {
    console.log($(this).attr("checked"));
    if ($(this).attr("checked") == false) {
      $(".billing-address-container").removeClass("hidden");
      //$("#mailing-ordinal").html('4');
    } else {
      $(".billing-address-container").addClass("hidden");
      //$("#mailing-ordinal").html('3');
    }
  });

  function setReservationVals() {
    //var reservation = $('#unit_select');
    //var timeunits = [];
    $('#unit_select').each(function (index) {
      var timeunit = $(this).find(':selected').val().substring(0, $(this).val().length - 3);
      $(this).parentsUntil('tbody', 'tr').find('div.unit-val').append(' / ' + timeunit);
      //$(this).filter('td div.unit-val').html();
      //console.log(timeunit);
    });
    //$('#unit_select option:selected').val().substring(0, $(this).val().length-3);
    //console.log(timeunits);
  }
  //setReservationVals();

  var dayCost = 30.00; //$('#unit_select').parentsUntil('tbody','tr').find('div.unit-val').text().substring();
  $('#unit_select').change(function (e) {
    var timeunit = $(this).find(':selected').val().substring(0, $(this).val().length - 3);
    switch (timeunit) {
      case 'day':
        $(this).parentsUntil('tbody', 'tr').find('div.unit-val').html('$' + dayCost.toFixed(2) + ' / ' + timeunit);
        break;
      case 'month':
        $(this).parentsUntil('tbody', 'tr').find('div.unit-val').html('$' + (dayCost * 25).toFixed(2) + ' / ' + timeunit);
        break;
      case 'week':
        $(this).parentsUntil('tbody', 'tr').find('div.unit-val').html('$' + (dayCost * 6).toFixed(2) + ' / ' + timeunit);
        break;
    }

  });

  function setPageButtonName() {
    var changeName = $.cookie('fromConfirm');
    //console.log(changeName);
    if (changeName == null) {
      //console.log('In null IF statement');
      $.cookie('fromConfirm', 'nochange');
    }
    else if (changeName == 'change') {
      $('a.continue').addClass("btn large bold").attr('href', 'confirm_purchase.html').html('<span class="ui-button-text">Go Back To Confirmation</span>');
      $('.enrollment-progress li').filter(':not(".active")').addClass("been-to");
      $.cookie('fromConfirm', 'nochange');
      //console.log(changeName);
    }

  }
  setPageButtonName();

  //var fromConfirm;
  $('.update.icon.btn').click(function (e) {
    //fromConfirm = true;
    //console.log(fromConfirm);
    $.cookie('fromConfirm', 'change');
    //console.log($.cookie(fromConfirm));
    //alert("here");
  });

  $('a.continue').click(function (e) {
    var changeName = $.cookie('fromConfirm');
    if (changeName == 'change') {
      $.cookie('fromConfirm', 'nochange');
      //console.log(changeName);
    }
  });

  $("#agree_tc").change(function (e) {
    //alert("here");
    if ($(this).attr("checked") == true) {

    }
  });
  //$('a.btn[disabled="true"]').



  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Show/Hide, New Bank Account, New Credit Card
  Shows additional options when selecting 'Add Bank Account' 
  or 'New Credit Card' from select drop-down boxes
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */

  var payment_type_init = function () {
    $('#payment_type').change(function () {
      $('.new-credit-card').addClass('hilite');
      $('.new-bank-account').addClass('hilite');
      $('.external-credit-card').addClass('hilite');
      $('.external-bank-account').addClass('hilite');
      var payment_type_selected = $('#payment_type option:selected').text();
      if (payment_type_selected == "New Bank Account...") {
        $('.visa-0123').addClass('hidden');
        $('.mastercard-9876').addClass('hidden');
        $('.new-credit-card').addClass('hidden');
        $('.external-credit-card').addClass('hidden');
        $('.external-bank-account').addClass('hidden');
        $('.new-bank-account').removeClass('hidden').delay(250).removeClass('hilite', 750);
      }
      else if (payment_type_selected == "New Credit Card...") {
        $('.visa-0123').addClass('hidden');
        $('.mastercard-9876').addClass('hidden');
        $('.new-bank-account').addClass('hidden');
        $('.external-credit-card').addClass('hidden');
        $('.external-bank-account').addClass('hidden');
        $('.new-credit-card').removeClass('hidden').delay(250).removeClass('hilite', 750);
      }
      else if (payment_type_selected == "Visa ending in 0123") {
        $('.new-credit-card').addClass('hidden');
        $('.mastercard-9876').addClass('hidden');
        $('.new-bank-account').addClass('hidden');
        $('.external-credit-card').addClass('hidden');
        $('.external-bank-account').addClass('hidden');
        $('.visa-0123').removeClass('hidden').delay(250).removeClass('hilite', 750);
      }
      else if (payment_type_selected == "MasterCard ending in 9876") {
        $('.new-credit-card').addClass('hidden');
        $('.visa-0123').addClass('hidden');
        $('.new-bank-account').addClass('hidden');
        $('.external-credit-card').addClass('hidden');
        $('.external-bank-account').addClass('hidden');
        $('.mastercard-9876').removeClass('hidden').delay(250).removeClass('hilite', 750);
      }
      else if (payment_type_selected == "External Credit Card Payment") {
        $('.visa-0123').addClass('hidden');
        $('.mastercard-9876').addClass('hidden');
        $('.new-bank-account').addClass('hidden');
        $('.new-credit-card').addClass('hidden');
        $('.external-bank-account').addClass('hidden');
        $('.external-credit-card').removeClass('hidden').delay(250).removeClass('hilite', 750);
      }
      else if (payment_type_selected == "External Bank Account Payment") {
        $('.visa-0123').addClass('hidden');
        $('.mastercard-9876').addClass('hidden');
        $('.new-bank-account').addClass('hidden');
        $('.new-credit-card').addClass('hidden');
        $('.external-credit-card').addClass('hidden');
        $('.external-bank-account').removeClass('hidden').delay(250).removeClass('hilite', 750);
      }
      else {
        $('.visa-0123').addClass('hidden');
        $('.mastercard-9876').addClass('hidden');
        $('.new-credit-card').addClass('hidden');
        $('.new-bank-account').addClass('hidden');
        $('.external-credit-card').addClass('hidden');
        $('.external-bank-account').addClass('hidden');
      }
      adjust_layout(); // Redraws the sidebar to match the new page height -JimATF
    });
  }
  payment_type_init();

  var terms_init = function () {
    $('.showhide').click(function () {
      $('.terms-container').toggle();
    })
  }
  terms_init();


  var toggle_use_billing_init = function () {
    $('#use-account-address').click(function () {
      if ($(this).is(':checked')) {
        $('.field').toggleClass('invisible').toggleClass('visible');
      }
      else {
        $('.field').toggleClass('visible').toggleClass('invisible');
      }
    });
  }
  toggle_use_billing_init();



  /*
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Autopay, Show's alert message once user checks the box
  If Payment Method changes once box is checked, another alert 
  is presented confirming the change.
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */

  var auto_pay_off_init = function () {
    $('.auto_pay_off').click(function () {
      $('#payment_auto_pay').removeAttr('checked');
      $('#payment_make_primary').removeAttr('checked');
      $('#payment_make_primary').removeAttr('disabled');
      $(this).parent().parent().parent().hide();
    });
  }
  auto_pay_off_init();

  var is_checked_autopay_init = function () {
    $('#payment_auto_pay').click(function () {
      if ($(this).is(':checked')) {
        //$('.auto-pay-set').show();
        $('#payment_make_primary').attr('checked', 'true');
        $('#payment_make_primary').attr('disabled', 'true');
      }
      else {
        //$('.auto-pay-set').hide();
        //$('.auto-pay-change').hide();
        $('#payment_make_primary').attr('checked', '');
        $('#payment_make_primary').attr('disabled', '');
      }
    });
  }

  var is_checked_autopay_change_init = function () {
    $('#payment_type').change(function () {
      //$('.auto-pay-set').hide();
      $('#payment_auto_pay').attr('checked', '');
      $('#payment_make_primary').attr('checked', '');
      $('#payment_make_primary').attr('disabled', '');
    });
  }

  is_checked_autopay_init();
  //is_checked_autopay_change_init();

  /*var use_auto_pay_init = function(){
  $('#use_auto_pay').click(function(){
  if($(this).is(':checked'))
  {
  $('.autopay').addClass('alert').addClass('success');
  }
  else
  {
  $('.autopay').removeClass('alert').removeClass('success');
  }
  });
  }
  use_auto_pay_init();*/




  /* 
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  =Payments For Accounts -- This is for prototype only. NOT PRODUCTION CODE
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
  /*function setPaymentPageFields(selected_option){
  var paytype = selected_option.find(':selected').val();
  var el = selected_option.parentsUntil('ul').siblings();
  switch(paytype){
  case 'Check':
  resetPaymentFields(el);
  el.find('label[for="payment_ref"]').html('Check Number:<span class="req">*</span>');
  break;
				
  case 'New Credit Card':
  resetPaymentFields(el);
  el.find('#use-account-address').attr("checked", "checked").change();
  el.filter('li.cc').removeClass("hidden");
  el.filter('div').find('li.cc').removeClass("hidden");
  el.filter('div').find('div.cc-billing-address').removeClass("hidden");
  el.filter('div').find('div.cc-billing-address > li:lt(2)').addClass("hidden");
  el.filter('div').find('div.cc-billing-address > li:nth-child(3) label').html("Name: ");
  el.filter('li.cc-note').removeClass("hidden");
  el.find('#cc-note').html("Note: This payment type will result in the customer's credit card being charged immediately.  The new credit card will also be stored in their account.");
  el.find('#payment_ref').parent().addClass("hidden");
  break;
				
  case 'Credit Card On File':
  resetPaymentFields(el);
  el.filter('li.cc-stored').removeClass("hidden");
  el.filter('li.cc-note').removeClass("hidden");
  el.find('#cc-note').html("Note: This payment type will result in the customer's credit card being charged immediately.");
  el.find('#payment_ref').parent().addClass("hidden");
  break;
				
  case 'External Credit Card Payment':
  resetPaymentFields(el);
  el.filter('li.cc-ext').removeClass("hidden");
  break;
				
  default:
  resetPaymentFields(el);
  break;
  }
  }
  setPaymentPageFields($('#payment_type'));*/

  function resetPaymentFields(element) {
    var el = element;
    el.find('label[for="payment_ref"]').html('Reference Number:');
    el.find('#payment_ref').parent().removeClass("hidden");
    el.filter('li.cc').addClass("hidden");
    el.filter('div').find('li.cc').addClass("hidden");
    el.filter('li.cc-stored').addClass("hidden");
    el.filter('li.cc-ext').addClass("hidden");
    el.filter('li.cc-note').addClass("hidden");
    el.filter('div').find('div.cc-billing-address').addClass("hidden");
    el.filter('div').find('div.cc-billing-address > li:lt(2)').removeClass("hidden");

  }

  $('#payment_date').datepicker('setDate', new Date());

  /*$("#payment_type").change(function(e){
  setPaymentPageFields($(this));
  });*/

  /*$('#use-account-address').change(function(){
  if($(this).is(':checked') == false){
  //$('.cc-billing-address').removeClass("hidden");
  $('.cc-billing-container').addClass("highlight");
  $('#cc-billing-label').addClass("bold");
  //$('.cc-billing-address').convertAdressToLabels();
  $('.cc-billing-address li input, .cc-billing-address li select').removeClass("hidden");
  $('.cc-billing-address li div').addClass("hidden");
  $('.cc-billing-address li label span.req').removeClass("hidden");
  $('div.cc-billing-address > li:lt(2)').removeClass("hidden");
  $('div.cc-billing-address > li:nth-child(3) label').html("Last Name:<span class=\"req\">*</span>");
  }
  else{
  //$('.cc-billing-address').addClass("hidden"); 
  $('.cc-billing-container').removeClass("highlight");
  $('#cc-billing-label').removeClass("bold");
  $('.cc-billing-address li input, .cc-billing-address li select').addClass("hidden");
  $('.cc-billing-address li div').removeClass("hidden");
  $('.cc-billing-address li label span.req').addClass("hidden");
  $('div.cc-billing-address > li:lt(2)').addClass("hidden");
  $('div.cc-billing-address > li:nth-child(3) label').html("Name:");
  }
  });*/

  var addressForm;
  $.fn.convertAdressToLabels = function () {
    var el = $(this);
    console.log(el);
    el.find('li input[type="text"]').each(function (i) {

      $(this).replaceWith('<div>This is a test.</div>');
    });

  }

  $('#cc_stored').change(function () {
    switch ($(this).val()) {
      case 'Visa ending in 1234':
        $('#cc_stored_last4').removeClass("small em").html("**** **** **** 1234");
        $('#cc_stored_exp').removeClass("small em").html("12 / 2011");
        break;
      case 'Mastercard ending in 5678':
        $('#cc_stored_last4').removeClass("small em").html("**** **** **** 5678");
        $('#cc_stored_exp').removeClass("small em").html("01 / 2012");
        break;
      default:
        $('#cc_stored_last4').addClass("small em").html("Select a credit card above by using the dropdown.");
        $('#cc_stored_exp').addClass("small em").html("Select a credit card above by using the dropdown.");
    }
  });

  var currencyType;
  $.fn.getCurrency = function () {
    /*currencyType = $(this).val().substring($(this).val().indexOf("(")+1, $(this).val().indexOf(")"));*/
    switch (currencyType) {
      case 'USD':
        currencyType = '$';
        break;
      case 'EUR':
        currencyType = '�';
        break;
      case 'GBP':
        currencyType = '�';
        break;
      default:
        currencyType = '$';
        break;
    }
    return currencyType;
  }
  $('select#payment_currency').getCurrency();


  $('select#payment_currency').change(function () {
    var cur = $(this).getCurrency();
    $('input#payment_amount').val(function (i, val) {
      return $(this).val().toString().replace(/[$ۣ]/i, cur);
    });
  });

  $('input#payment_amount').keyup(function () {

    $(this).val(function (i, v) {
      return currencyType + v.replace(currencyType, '');
    });
  });


});  // =End