
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Global Javascript - Metanga Web Application
    Javascript that initializes included plugins and generally runs things.

Author: Above The Fold, LLC - http://www.abovethefolddesign.com

Table of Contents
    Note: Equals signs (=) are search flags
-----------------------------------------------------------
	=Functions
	=Document-Ready
	=Sidebars
	=Buttons
	=Container Behaviors
	=DataTables
	=Enablement
	=Validation
	=Rich Text Editor
	=Widgets
	=Placeholder
	=Help
	=Text Resize
	=Tooltips
	=Window Resize
	=Menus
	----Section-specific behaviors----
	=Modal Dialogs
	=Cleanup
	=End
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Functions
    Defining UI functions that need to be used throughout.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Equalize content & sidebar height, using EqualHeightColumns plugin
// This function should be called after any other function that shows or hides page content.
var equalize_cols = function(){
	var cols = $(".has-sidebar #content, .has-sidebar .sidebar-left");
	$(cols).css("height","auto").equalHeightColumns().addClass("equalized");
};

// Equalize item heights via CSS class - default class is .eq-height
var equalize_heights = function(el){
	if (!el) var el = $(".eq-height");
	el.css("height","auto").equalHeightColumns().addClass("equalized");
	// Equalize cols again
	equalize_cols();
};

// Initialize jQuery UI Buttons
var buttons_init = function(){
	// Basic Buttons
	$("button, input:submit, a.btn").button();
	
	// Icon Buttons
	$(".btn.icon.newwin").button({ icons: {primary: "ui-icon-newwin"}});
	$(".btn.icon.save").button({ icons: {primary: "ui-icon-disk"}});
	$(".btn.icon.clear").button({	icons: {primary: "ui-icon-closethick"}});
	$(".btn.icon.edit").button({	icons: {primary: "ui-icon-pencil"}});
	$(".btn.icon.add").button({	icons: {primary: "ui-icon-plusthick"}});
	$(".btn.icon.goback, .DTTT_button_print").button({		icons: {primary: "ui-icon-arrowreturnthick-1-w"}, text: false});
	$(".btn.icon.print, .DTTT_button_print").button({		icons: {primary: "ui-icon-print"}, text: false});
	$(".btn.icon.export, .DTTT_button_csv, .DTTT_button_xls, .DTTT_button_pdf").button({
		icons: {primary: "ui-icon-arrowthick-1-e"}
	});
	$(".btn.icon.schedule").button({	icons: {primary: "ui-icon-clock"}});
	$(".btn.icon.copy, .DTTT_button_copy").button({	icons: {primary: "ui-icon-copy"}, text: false});
	
	$(".btn.icon.collapse-up").button({ icons: {primary: "ui-icon-triangle-1-n"}, text: false
	});
	$(".btn.icon.expand-down").button({ icons: {primary: "ui-icon-triangle-1-s"}, text: false });
  $(".btn.icon.settings").button({ icons: {primary:'ui-icon-gear',secondary:'ui-icon-triangle-1-s'}, text: false  });
	$(".btn.icon.drop-down").button({ icons: {primary: "ui-icon-triangle-1-s"} });
	$(".btn.icon.collapse-up2").button({ icons: {primary: "ui-icon-circle-triangle-n"} });
	$(".btn.icon.expand-down2").button({ icons: {primary: "ui-icon-circle-triangle-s"} });
	$(".icon.doc").button({ icons: {primary: "ui-icon-document"} });
	$(".btn.tiny.icon.add").button({
		icons: {primary: "ui-icon-plusthick"},
		text: false
	});
	$(".btn.tiny.icon.view").button({
		icons: {primary: "ui-icon-search"},
		text: false
	});
	$(".btn.icon.view").button({
		icons: {primary: "ui-icon-search"},
		text: false
	});
	$(".btn.icon.view-text").button({
		icons: {primary: "ui-icon-search"}
	});
	$(".btn.tiny.icon.edit").button({
		icons: {primary: "ui-icon-pencil"},
		text: false
	});
	$(".btn.tiny.icon.delete").button({
		icons: {primary: "ui-icon-closethick"},
		text: false
	});
	$(".btn.tiny.icon.user").button({
		icons: {primary: "ui-icon-person"},
		text: false
	});
	$(".btn.tiny.icon.doc").button({
		icons: {primary: "ui-icon-document"},
		text: false
	});
	$(".btn.tiny.icon.down").button({
		icons: {primary: "ui-icon-arrowthick-1-s"},
		text: false
	});
	$(".btn.tiny.icon.up").button({
		icons: {primary: "ui-icon-arrowthick-1-n"},
		text: false
	});
	$(".btn.tiny.icon.jump").button({
		icons: {primary: "ui-icon-arrowreturnthick-1-n"},
		text: false
	});
	$(".btn.icon.suitcase").button({
		icons: {primary: "ui-icon-suitcase"}
	});
	$(".btn.icon.link").button({
		icons: {primary: "ui-icon-link"},
		text: false
	});
	$(".btn.icon.replace").button({
		icons: {primary: "ui-icon-pencil"},
		text: false
	});
	$(".btn.icon.download").button({
		icons: {primary: "ui-icon-disk"},
		text: false
	});
	$(".btn.icon.delete-notxt").button({
		icons: {primary: "ui-icon-closethick"},
		text: false
	});
	$(".btn.icon.rss").button({
		icons: {primary: "ui-icon-signal-diag"}
	});
	$(".btn.icon.mail-closed").button({
		icons: {primary: "ui-icon-mail-closed"}
	});
	$(".btn.icon.hold-invoice").button({
		icons: {primary: "ui-icon-locked"}
	});
	$(".btn.icon.remove-hold-invoice").button({
		icons: {primary: "ui-icon-unlocked"}
	});
};

// Multiselect control
var multiselect_init = function(){
	//$(".multiselect").multiselect("destroy");
	$(".multiselect").multiselect({
		sortable: false
	});
	//$(".multiselect-products, .multiselect-sortable").multiselect("destroy");
	$(".multiselect-products, .multiselect-sortable").multiselect({
		sortable: true,
		dividerLocation: 0.5
	});
};

// Adjust Layout: Setting dimensions based on the viewport size.
// Needs to be called on initial page load and on window.resize.
var adjust_layout = function(){
	equalize_cols();
	equalize_heights();
	multiselect_init();
};

// Initialize all informational popups and their icons
var init_info_popup = function(){
	$(document).find('.popup_account_info').prepend('<span class="show-tooltip-html-sticky" href="#info_popup"></span>');
};
init_info_popup();

/* Metanga Page Processing Indication */

/* Main Function */

  var metangaProcessing = function(){

     if ($('div.reveal-modal-processing-bg').length){               //is processing there?
        $("div.reveal-modal-processing-bg").fadeOut(200);           //hide
        setTimeout(function() {                                     //remove with delay to allow for hide
          $('div.reveal-modal-processing-bg').remove();
        }, 300);
     } else {                                                       //add then show
        $('div#main').prepend('<div class="reveal-modal-processing-bg"><div class="ui-corner-bottom reveal-modal-processing-msg-bg">Processing</div></div>');
        $("div.reveal-modal-processing-bg").css("position", "absolute").fadeIn(200);
     }
  };

//Multiple open accordion
/*$.fn.togglepanels = function(){
  return this.each(function(){
    $(this).addClass("ui-accordion ui-accordion-icons ui-widget ui-helper-reset")
  .find("h3")
    .addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-top ui-corner-bottom")
    .hover(function() { $(this).toggleClass("ui-state-hover"); })
    .prepend('<span class="ui-icon ui-icon-triangle-1-e"></span>')
    .click(function() {
      $(this)
        .toggleClass("ui-accordion-header-active ui-state-active ui-state-default ui-corner-bottom")
        .find("> .ui-icon").toggleClass("ui-icon-triangle-1-e ui-icon-triangle-1-s").end()
        .next().slideToggle();
      return false;
    })
    .next()
      .addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom")
      .hide();
  });
};*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Document-Ready
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
$(function(){ // Document ready function, for jQuery


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Sidebars
    Check for sidebar, add classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    var sidebar_init = function(){
        var sbar = $('.sidebar-left');
        if (sbar.length === 0) {
            $('html').addClass('no-sidebar');
		} else {
            $('html').addClass('has-sidebar');
            if (sbar.hasClass('wide')){
                $('html').addClass('has-wide-sidebar');
            }
            if (sbar.hasClass('collapsed')){
                $('html').addClass('sidebar-off');
            } else {
                $('html').addClass('sidebar-on');
            }
            // Initialize collapsible sidebar behavior
            sbar.not('.static').append('<span class="clickable toggle toggle-sidebar" href="">Toggle</span>').parents('html').addClass('collapsible-sidebar');
		}
	};
	sidebar_init();
	

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Buttons
    Buttons must be initialized before container & table styles,
	so that element widths are interpreted correctly by dataTables.
	The buttons function is called again after other functions which
	dynamically produce or change button markup.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	buttons_init();

	
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Container Behaviors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	// Put UI controls in the header
	$(".container > header").append('<div class="ui-controls"></div>');
	
	// Check for the presence of filters, initialize toggle
	var filters_init = function(){
		var el = $(".container .filters");
		var parent = $(el).parents(".container");
		
		parent.children("header").find(".ui-controls").append('<a class="action toggle-filters" href="#">Show Filters</a>');
	};

filters_init();
	
	// Filters: Toggle behavior
	var toggle_filters = function(){
		var indx = 0;
		var el = $(".toggle-filters");
		
		el.each(function(i){
			var target = $(this).parents(".container").find(".filters");
		
			$(this).showhide({
				target_obj: target,
				default_open: true,
				plus_text: 'Show Filters',
				minus_text: 'Hide Filters',
				use_cookie: true,
				cookie_expires: 2,
				cookie_name: 'show_filters_' + indx,
				callback_show: function(){
					equalize_cols();
				},
				callback_hide: function(){
					equalize_cols();
				}
			});
			indx++;
		});
	};

	toggle_filters();
	
	// Filters: Adding/removing filters
	var idx = 0;
	var adjust_remove_links = function() {
		$('.filters').each(function(i, el) {
			if ($(el).find('.cloneable').length > 1) {
				$(el).find('.remove').show();
			} else {
				$(el).find('.remove').hide();
			}
		});
	};
	$('.action-clone').bind('click', function(e) {
		e.preventDefault();
		var parent_el = $(this).parents('.filters');
		var parent_id = $(parent_el).prop('id');
		var el = $(parent_el).find('.cloneable:first').clone();
		idx++;
		el.find('.column').attr('name', parent_id + '_column_' + idx).attr('id', parent_id + '_column_' + idx);
		el.find('.operator').attr('name', parent_id + '_operator_' + idx).attr('id', parent_id + '_operator_' + idx);
		el.find('.value').attr('name', parent_id + '_value_' + idx).attr('id', parent_id + '_value_' + idx);
		$(parent_el).find('.filter-set').append(el);
		adjust_remove_links();
	});
	$('.remove').bind('click', function(e) {
		e.preventDefault();
		$(this).parents('li').remove();
		adjust_remove_links();
	});
	adjust_remove_links();
	
	
	// Containers: Initialize collapsible behavior
	var collapsible_init = function(){
		var el = $(".container.collapsible");
        el.children("header").find(".ui-controls").append('<a href="#" class="btn icon tiny collapse-expand">Collapse</a>');
        el.each(function(){
            var cebtn = $(this).find(".collapse-expand");
			if ($(this).hasClass("collapsed")){
				$(cebtn).addClass("expand-down");
			} else {
				$(cebtn).addClass("collapse-up");
			}
		});
	};
	collapsible_init();
	
	// Containers: collapsible: button behavior
	$('.container.collapsible > header .collapse-expand').click(function(e){
		e.preventDefault();
		var parent = $(this).parents(".container");
		if ($(parent).hasClass("collapsed")){
			$(parent).removeClass("collapsed");
			$(this).removeClass("expand-down").addClass("collapse-up");
		} else {
			$(parent).addClass("collapsed");
			$(this).removeClass("collapse-up").addClass("expand-down");
		}
		equalize_cols();
		buttons_init();
	});
	// Also allow expanding when clicking a collapsed header title
	$('.container > header h2').click(function(e){
		e.preventDefault();
		var parent = $(this).parents('.container');
		if ($(parent).hasClass('collapsed')){
			parent.removeClass('collapsed');
            parent.find('.collapse-expand').removeClass('expand-down').addClass('collapse-up');
			equalize_cols();
			buttons_init();
		}
	});

	// Reveal modals: add close button to the header
	$(".reveal-modal").not(".no-close").append('<a class="close close-reveal-modal">Close</a>');
	

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=DataTables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	// Data Tables - Basic
	var ui_table_basic = function(){
		var tbl = $(".ui-table-basic");
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sDom": '<"H"<"toolbar">lfr>t<"F"ip<',
			"sPaginationType": "full_numbers",
			"fnDrawCallback": function() {
                if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
                        $('.dataTables_paginate').css("display", "block");
                } else {
                        $('.dataTables_paginate').css("display", "none");
                }
            }
		});
	};
	ui_table_basic();
		
	// Data Tables - Full
	var ui_table_full = function(){
		var tbl = $(".ui-table-full");
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sPaginationType": "full_numbers",
			"sDom": 'R<"H"<"toolbar">lTfr>t<"F"ip<',
			"oTableTools": {
				"sSwfPath": "../swf/copy_cvs_xls_pdf.swf"
			},
			"fnDrawCallback": function() {
                if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
                        $('.dataTables_paginate').css("display", "block");
                } else {
                        $('.dataTables_paginate').css("display", "none");
                }
            }
		});
		var tbl_parent = $(tbl).parents(".dataTables_wrapper");
	};
	ui_table_full();
	
	// Data Table - Custom Filter & ColViz Column Hiding capability
	var ui_table_customfilter = function(){
		var tbl = $('.ui-table-customfilter');
    //get last col ID to pass to oColVis
    var lastCol =  $('table.ui-table-customfilter tr:first-child td').length-1;
    
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sDom": '<"H"<"toolbar float lspace rspace">rC>t<"F"lip<',
			"sPaginationType": "full_numbers",
			"oColVis": {
            "buttonText": "Column Display",
            "aiExclude": [ 0, lastCol ] //Exclude 'Name' and 'Action' (first/last) cols
        },
      "fnDrawCallback": function() {
                if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
                        $('.dataTables_paginate').css("display", "block");
                } else {
                        $('.dataTables_paginate').css("display", "none");
                }
            }
		});
	};
  
	ui_table_customfilter();
	
	// Data Table - Jobs (special sorting)
	var ui_table_jobs = function(){
		var tbl = $(".ui-table-jobs");
		$(tbl).dataTable({
			"aaSorting": [[ 2, "desc" ]],
			"bJQueryUI": true,
			"sDom": '<"H"<"toolbar align-alt float">lr>t<"F"ip<',
			"sPaginationType": "full_numbers",
			"fnDrawCallback": function() {
                if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
                        $('.dataTables_paginate').css("display", "block");
                } else {
                        $('.dataTables_paginate').css("display", "none");
                }
            }
		});
	};
	ui_table_jobs();
	
	// Data Tables - Invoice Details Page (based on Full Table)
	var ui_table_full_invoice = function(){
		var tbl = $(".ui-table-full-invoice");
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sPaginationType": "full_numbers",
			"sDom": 'R<"H"<"toolbar">lTfr>t<"F"ip<',
			"bAutoWidth": false,
			"oTableTools": {
				"sSwfPath": "../common/swf/copy_cvs_xls_pdf.swf"
			},
			"fnDrawCallback": function() {
                if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
                        $('.dataTables_paginate').css("display", "block");
                } else {
                        $('.dataTables_paginate').css("display", "none");
                }
            },
			"aoColumnDefs": [
				{ "sWidth": "2.5%", "bSortable":false, "sClass":"select-row", "aTargets": [ 0 ] },
				{ "sWidth": "10%", "aTargets": [ 1 ] },
				{ "sWidth": "25%", "aTargets": [ 2 ] },
				{ "sWidth": "7.5%", "aTargets": [ 3 ] },
				{ "sWidth": "15%", "sClass":"text-right", "aTargets": [ 4 ] },
				{ "sWidth": "12.5%", "sClass":"text-right", "aTargets": [ 5 ] },
				{ "sWidth": "15%", "sClass":"text-right", "aTargets": [ 6 ] },
				{ "sWidth": "7.5%","bSortable":false, "sClass":"text-center", "aTargets": [ 7 ] },
				{ "sWidth": "5%","bSortable":false, "sClass":"text-center", "aTargets": [ 8 ] }
			],
			"aaSorting":[[1,'asc']]
		});
		var tbl_parent = $(tbl).parents(".dataTables_wrapper");
	};
	ui_table_full_invoice();
	
	// Data Tables - Payment Providers (based on Full Table)
	var ui_table_payment_providers = function(){
		var tbl = $(".ui-table-payment-providers");
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sPaginationType": "full_numbers",
			"sDom": 'R<"H"<"toolbar">lTfr>t<"F"ip<',
			"bAutoWidth": false,
			"oTableTools": {
				"sSwfPath": "../common/swf/copy_cvs_xls_pdf.swf"
			},
			"fnDrawCallback": function() {
                if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
                        $('.dataTables_paginate').css("display", "block");
                } else {
                        $('.dataTables_paginate').css("display", "none");
                }
            },
			"aoColumnDefs": [
				{ "sWidth": "5%", "aTargets": [ 0 ] },
				{ "sWidth": "25%", "aTargets": [ 1 ] },
				{ "sWidth": "25%", "aTargets": [ 2 ] },
				{ "sWidth": "25%", "sClass":"", "aTargets": [ 3 ] },
				{ "sWidth": "20%","bSortable":false, "aTargets": [ 4 ] }
			],
			"aaSorting":[[0,'asc']]
		});
		var tbl_parent = $(tbl).parents(".dataTables_wrapper");
	};
	ui_table_payment_providers();
	
	// Data Tables - Payment Gateway Routing
	var ui_table_routing = function(){
		var tbl = $(".ui-table-routing");
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sDom": '<t>',
			"bAutoWidth": false,
			"bPaginate": false,
			"bFilter": false,
			"bInfo": false,
			"bLengthChange": false,
			"bSort": false,
			"aoColumnDefs": [
				{ "sWidth": "5%", "sClass":"text-right", "aTargets": [ 0 ] },
				{ "sWidth": "20%", "aTargets": [ 1 ] },
				{ "sWidth": "20%", "aTargets": [ 2 ] },
				{ "sWidth": "60%", "aTargets": [ 3 ] },
				{ "sWidth": "5%","sClass":"text-left",  "aTargets": [ 4 ] }
			]
		});
		//tbl.find('.amount-range').hide();
	};
	ui_table_routing();

	// Data Tables - Manage Agreement Templates
	var ui_table_agreement_templates = function(){
		var tbl = $(".ui-table-manage-agreement-templates");
		$(tbl).dataTable({
			"bJQueryUI": true,
			"sPaginationType": "full_numbers",
			"sDom": 'R<"H"<"toolbar">lTfr>t<"F"ip<',
//			"oTableTools": {
//				"sSwfPath": "../common/swf/copy_cvs_xls_pdf.swf"
//			},
			"fnDrawCallback": function() {
				if (Math.ceil((this.fnSettings().fnRecordsDisplay()) / this.fnSettings()._iDisplayLength) > 1)  {
					$('.dataTables_paginate').css("display", "block");
				} else {
					$('.dataTables_paginate').css("display", "none");
				}
				var tableCurrentProductSplit = function () {
					$( ".table-current-product-split" )
					.button({icons:{ primary: "ui-icon-pencil"} })
					.next()
					.button({
						text: false,
						icons: {
							primary: "ui-icon-triangle-1-s"
						}
					})
					.click(function() {
						var menu = $( this ).parent().next().show().position({
							my: "right top",
							at: "right bottom",
							of: this
						});
						$( document ).one( "click", function() {
							menu.hide();
						}).one( "resize", function() {
							menu.hide();
						});
						return false;
					})
					.parent()
					.buttonset()
					.next()
					.hide()
					.menu();

				};
				tableCurrentProductSplit();
			}
		});
	var tbl_parent = $(tbl).parents(".dataTables_wrapper");
	};
	//ui_table_agreement_templates();
	
	/* Customized toolbar markup for various types of tables goes here. */
	
	// Data Tables - Template List - toolbar
	// $('.ui-table-template-list').parents(".dataTables_wrapper").find(".toolbar").html('<button class="btn icon add">Add a New Template</button>');
	
	// Data Tables - Subscription List - toolbar
	$('.ui-table-subscription-list').parents(".dataTables_wrapper").find(".toolbar").html('<span>Promotion code:</span> <select><option>Any</option><option>PROMO1</option><option>PROMO2</option><option>PROMO3</option></select>');

	// Data Tables - Subscription Entity Type Filter - toolbar
	$('.ui-table-subscriptionEntity-filter').parents(".dataTables_wrapper").find(".toolbar").html('<span>Extended property filter:</span> <select name="subscriptionEntTypeName"><option value="SubBaseEntityType">Subscription Base Properties</option><option value="%SubExtEntTypeName1%">My Extended Subscription Set1</option><option value="%SubscriptionEntTypeName2%">My Extended Subscription Set2</option></select>');
	
	// Data Tables - Report Data - toolbar
	$('.ui-table-report-data').parents(".dataTables_wrapper").find(".toolbar").html('<a class="btn" href="edit_columns.html">Edit Columns...</a>');
	
	// Data Tables - Report Map - toolbar
	$('.ui-table-map-data').parents(".dataTables_wrapper").find(".toolbar").html('<a class="btn" href="edit_column_map.html">Edit Columns...</a>');

    // Data Tables - Brand Assets - toolbar
	$('.ui-table-brand-assets').parents(".dataTables_wrapper").find(".toolbar").html('<span>File type:</span> <select><option>All Files</option><option>JPG</option><option>PNG</option><option>GIF</option><option>CSS</option></select>');
	
	// Data Tables - Units - toolbar
	$('.ui-table-units').parents(".dataTables_wrapper").find(".toolbar").html('<span>Unit category:</span> <select><option>All Categories</option><option>Digital Information</option><option>Fluid Volume</option><option>Time/Day</option><option>Weight</option></select>');
	
	// Data Tables - Jobs - toolbar
	$('.ui-table-jobs').parents(".dataTables_wrapper").find(".toolbar").html('<span>Job Status:</span> <select><option>All Jobs</option><option>Completed Jobs</option><option>In-Progress Jobs</option><option>Failed Jobs</option></select>');
	
	// Data Tables - Jobs > Tasks - toolbar
	$('.job-status-completed .ui-table-tasks').parents(".dataTables_wrapper").find(".toolbar").html('<span class="button-height">Task Status: <select><option>All Tasks</option><option selected="selected">Completed Tasks</option><option>In-Progress Tasks</option><option>Failed Tasks</option></select></span>');
	
	$('.job-status-failed .ui-table-tasks, .job-status-inprogress .ui-table-tasks').parents(".dataTables_wrapper").find(".toolbar").html('<span class="button-height inset">Task Status: <select><option>All Tasks</option><option>Completed Tasks</option><option>In-Progress Tasks</option><option selected="selected">Failed Tasks</option></select></span> <button class="btn sm">Retry All</button>');
	
	//Data Tables - Invoice Group Details
	$('.ui-table-full-invoice tr th.select-row input[type="checkbox"]').click(function(){
		var el = $('.ui-table-full-invoice tbody td.select-row input[type="checkbox"]');
		if(!($(this).is(':checked'))){
			el.filter(':checked').removeAttr("checked");
		}else{
			el.attr("checked", "checked");
		}
	});
	
	// Data Tables - Payment Providers
	$('.ui-table-payment-providers').parents(".dataTables_wrapper").find(".toolbar").html('<button class="btn icon add">Add A New Payment Provider</button>');

	

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Enablement
    Allows enabling/disabling of certain form controls based on
	toggling the value of a given form control.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// First, disable form controls inside .ui-state-disabled containers
$('.ui-state-disabled').find('input, select, textarea').attr('disabled', 'disabled');

$('.toggle-state-enablement').change(function(){
	// Get the target element(s)
	if ($(this).attr('data-target-class')) {
		var targetEl = $(this).attr('data-target-class');
		var selector = '.';
	} else if ($(this).attr('data-target-id')) {
		var targetEl = $(this).attr('data-target-id');
		var selector = '#';
	}
	// Toggle enablement
	if ($(this).is(':checked')) {
		$(this).parents('.container').find(selector + targetEl).removeClass('ui-state-disabled').find('input, select, textarea').attr('disabled', '');
	} else {
		$(this).parents('.container').find(selector + targetEl).addClass('ui-state-disabled').find('input, select, textarea').attr('disabled', 'disabled');
	}
});


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Validation
    This is just a beginning sample of what can be done with jQuery Validate.
	It appears on the Business Profile page.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	var validator = $("#validate").validate({
		rules: {
			company_identifier: "required"
		},
		messages: {
			company_identifier: "Please enter your company name."
		},
		invalidHandler: function(){
			$(".notifications").append('<div class="ui-alert ui-state-error ui-corner-all bspace"><div class="inner"><span class="ui-alert-icon ui-icon ui-icon-alert"></span><p>' + validator.numberOfInvalids() + ' field(s) are invalid.</p></div></div>');
			equalize_cols();
		}
	});


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Rich Text Editor
    Uses CKEditor, documented at http://docs.cksource.com/CKEditor_3.x/Developers_Guide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    // First, test to see if CKEditor library is included
	if (window.CKEDITOR) {
		$('.rich-text-area').ckeditor(function(){
			adjust_layout();
		});
	}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Widgets
    More jQuery UI controls & widgets.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	
	// Accordion
	//$(".accordion").accordion({ header: "h3" });
	


	var accordionHeight;
	var latestAccordionHeight;

	$(".sidebar div.accordion").accordion({
		autoHeight: false,
		collapsible: true,
		active: 2,
		icons: { "header": "ui-icon-circle-plus", "headerSelected": "ui-icon-circle-minus" },
		//header: "h3"
		activate: function( event, ui ) {
			//console.log("clicked");
			adjust_layout();
			
		},
		create: function( event, ui ) {
			adjust_layout();
		}
	});

	$(".sidebar div.togglepanel").multiOpenAccordion({
                active: 'all',
                init: function(event, ui) {
                        
                        adjust_layout();
                },
                tabShown: function(event, ui) {
                        //console.log("Parent Container: " + outerAcc.parentsUntil('aside.sidebar').height());
                        //console.log(outerAcc.parents('aside.sidebar'));
                        adjust_layout();
                },
                click: function(event, ui) {
                        //$(".sidebar div.accordion").accordion( "refresh" );
                        
                        adjust_layout();
                }
        });
	var outerAcc = $(".sidebar div.accordion").accordion( "widget" );
	var innerAcc = $(".sidebar div.accordion div.togglepanel");
	//console.log(outerAcc);
	//console.log(innerAcc);

	var checkheight = function(){
		if(accordionHeight === undefined && latestAccordionHeight === undefined){
			accordionHeight = outerAcc.height();
			latestAccordionHeight = accordionHeight;
			//console.log(accordionHeight + " "+ latestAccordionHeight);
		}else if (accordionHeight <= outerAcc.height()){

		}
	};
	/*$(".sidebar div.togglepanel").multiOpenAccordion('click', function(){
                alert('also clicked');
        });*/
	//console.log($(".sidebar div.accordion"));
	//console.log.apply(console, $(".sidebar div.accordion"));
	$(".sidebar div.togglepanel").multiOpenAccordion('option', 'active', 'all');
	//$(".sidebar div.accordion").accordion( "refresh" );
	//console.log($(".sidebar div.accordion").height());
	adjust_layout();
	//console.log($(".sidebar div.accordion").height());
	// Initialize Tabs
	$(".tabs-container").tabs();

	// Datepicker
	$('.datepicker').datepicker({
		inline: true
	});
	
	// Buttonset
	$('.buttonset').buttonset();
	
	// Slider
	$('.slider').slider({
		range: true,
		values: [17, 67]
	});
	
	// Progressbar
	$('.progress-bar').not('.preparing').progressbar({
		value: 20
	});
	
	// Dialog
	$('#dialog').dialog({
		autoOpen: false,
		width: 600,
		buttons: {
			"Ok": function() {
				$(this).dialog("close");
			},
			"Cancel": function() {
				$(this).dialog("close");
			}
		}
	});


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Placeholder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	// Placeholder text for inputs -- NOT CURRENTLY WORKING
	// $("input[placeholder]").placeholder().addClass("placeholder");
	
	// Zebra lists
	$(".zebra > li:odd").addClass("alt");
	$(".zebra.sortable").sortable({
		axis: 'y',
		distance: '5',
		update: function(){
			$(this).find("li").removeClass("alt");
			$(this).find("li:odd").addClass("alt");
		}
	});


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Help
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	// Contextual Help - toggle "Page Tips"
	$(".page-actions .help").toggle(function(e){
		$(this).addClass("active");
		$(".page-help").slideDown("fast");
		e.preventDefault();
		equalize_cols();
	}, function(e){
		$(this).removeClass("active");
		$(".page-help").slideUp("fast");
		e.preventDefault();
		equalize_cols();
	});
	$(".alert .close-alert").click(function(e){
		$(this).parents(".alert").slideUp("fast");
		$("header .help").removeClass("active");
		e.preventDefault();
		equalize_cols();
	});
	
	$('.link-alert').css('display','none');
	$('a.btn.link').click(function(){
		$('.link-alert').removeClass("hidden");
		$('.link-alert').slideDown("fast");
	});


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Tooltips
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	$(".show-tooltip").tooltip({
		showURL: false,
		extraClass: "ui-corner-all"
	});
	
	$(".show-tooltip-html").tooltip({
		showURL: false,
		bodyHandler: function(){
			return $($(this).attr("href")).html();
		},
		extraClass: "ui-corner-all html"
	});
	
	$(".show-tooltip-img").tooltip({
		showURL: false,
		bodyHandler: function(){
            var imgpath = '../common/img/inline/';
			var imgsrc = $(this).attr('href');
			var imgtitle = this.tooltipText;
			var imgEl = '<img class="preview" src="' + imgpath + imgsrc + '" alt="' + imgtitle + '" />';
			var dimensions = '999 x 999 pixels';
			return '<h4>' + imgtitle + '</h4> <p class="small">' + dimensions + '</p>' + imgEl;
		},
		extraClass: "ui-corner-all img"
	}).click(function(e){
		e.preventDefault();
	});
	
	$(".show-tooltip-html-sticky").nex_tooltip({
		showURL: false,
		bodyHandler: function(){
			return $($(this).attr("href")).html();
		},
		extraClass: "ui-corner-all html sticky"
	});


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Menus
    Pop-up menus
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	// Pop-up Menus
	$(".menu-link, .menu").hover(function(e){
		$(this).parents(".menu-container").find(".menu").addClass("shown");
		e.preventDefault();
	}, function(e) {
		$(this).parents(".menu-container").find(".menu").removeClass("shown");
		e.preventDefault();
	});
	$(".menu, .timeframe-name").hover(function(e){
		$(this).parents(".menu-container").find(".menu-link").addClass("over");
	}, function(e) {
		$(this).parents(".menu-container").find(".menu-link").removeClass("over");
	});
	
	$('.overlay-menu').click(function(){
		$('.receive-overlay-menu').block({
			
			message: '<div class="overlay-menu variables">Test <a href="#">Test</a></div>',
			css: { border: '1px solid #181818' }
		});
		return false;
	});
	
	
/*--------------------------------------
	Dashboard
----------------------------------------*/
	
	// Dashboard widget heights - using EqualHeightColumns plugin
	//$(".page-dashboard .widget, .page-dashboard .widget > div,.page-dashboard .first-time, .page-dashboard .first-time > div").equalHeightColumns();
	$(".page-dashboard .widget, .page-dashboard .widget > div").equalHeightColumns(); //removed first-time in equalheight plugin -- [Kenton]
	
	// Dashboard widgets - Sortable & draggable
	$( ".page-dashboard .widgets" ).sortable({
		item: 'widget',
		handle: 'header',
		opacity: '0.75',
		tolerance: 'pointer',
		placeholder: 'sort-placeholder widget grid_4',
		forcePlaceholderSize: true,
		start: function(){
			$(".widget").find(".close").removeClass("shown");
		}
	});
  //drag stop event
	$( ".page-dashboard .widgets" ).sortable({
   stop: function() {
     alert('Hey there widget shuffler!');
   }
  });
	
	// Dashboard widgets - "Flip" to edit
	$(".widget .edit").hide().css("left", 0);
	$(".widget .front .flip").click(function(e){
		$(this).parents('.widget').find('.front').fadeOut();
		$(this).parents('.widget').find('.edit').removeClass("success").fadeIn();
		e.preventDefault();
	});
	$(".widget .edit .flip.action-cancel").click(function(e){
		$(this).parents('.widget').find('.edit').fadeOut();
		$(this).parents('.widget').find('.front').fadeIn();
		e.preventDefault();
	});
	$(".widget .edit input.flip").click(function(e){
		$(this).parents('.widget').find('.edit').addClass("success").delay(500).fadeOut("fast");
		$(this).parents('.widget').find('.front').delay(600).fadeIn("slow");
		e.preventDefault();
	});
	
	// Dashboard widgets - Close
	$(".widget .close").click(function(e){
		$(this).parents(".widget").fadeOut("fast"); // Temporary substitute for actually removing the widget
		e.preventDefault();
	});
	
	// Add widget title attribute
	$(".widget header").attr({
		title: 'Drag and drop to rearrange widgets'
	});
	
	//RSS on Dashboard - [Kenton]
	var dashsize = $('.widgets').height();
	/* $('.page-dashboard .first-time, .page-dashboard .first-time > div').height(dashsize); */
	$(".page-dashboard .close, .page-dashboard .close-text, #launchModalrss").click(function(e){
		$(this).parents(".page-rss, .return-to-page").slideUp(200);
		e.preventDefault();
	});
	/*$('#metanga-new-features').gFeed({
		max: 1,
		url: 'http://metanga.squarespace.com/release-announcements_en-us/rss.xml',
		title: 'Test Title'
	});*/
	var stripStylingFromRSS = function(){
		$('.ItemContent span').removeAttr('style');
	};
	$('#metanga-new-features').FeedEk({
		FeedUrl : 'http://metanga.squarespace.com/release-announcements_en-us/rss.xml',
		MaxCount : 1,
		ShowDesc : true,
		ShowPubDate: false
	}, stripStylingFromRSS);
	
	
	

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Text Resize
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
   /* var text_callback = function(){
		console.log("text changed!");
	}
	
	var text_autosize = function(){
		$('.text-autosize-main').textfill({
			maxFontPixels: 20,
			minFontPixels: 75,
			callback: text_callback
		});
		$('.text-autosize-secondary').textfill({
			maxFontPixels: 20,
			minFontPixels: 40
		});
		$('.text-autosize-title').textfill({
			maxFontPixels: 8,
			minFontPixels: 14
		});
	}
	text_autosize();*/
	
	
var autosize = function(){
		$('.text-autosize-main').expandText({
			min: 20,
			max: 75
		});
		$('.text-autosize-secondary').expandText({
			min: 20,
			max: 40
		});
		/*
$('.text-autosize-main-big').expandText({
			min: 20,
			max: 30
		});
*/
		$('.text-autosize-title').expandText({
			min: 8,
			max: 14
		});
	};

	$(window).load(function(){
		autosize();
		//text_autosize();
		
	});
	//adjust_layout();
	$(window).resize(function(){
		//autosize();
		//text_autosize();
	}).trigger('resize');
	$('.widget-main, .widget-secondary, .widget-main-big').resize(function(){
		autosize();
	});

/*--------------------------------------
	Add Reports
----------------------------------------*/
	// Carousels, using jCarousel
	$("#content .add-widgets").jcarousel({
		itemFallbackDimension: '260'
	});


/*--------------------------------------
	Manage Reports
----------------------------------------*/
	
	// Manage Reports categories - Sortable & draggable
	$( ".categories .column").sortable({
		connectWith: '.column',
		handle: 'header',
		opacity: '0.75',
		tolerance: 'pointer',
		placeholder: 'sort-placeholder category container',
		forcePlaceholderSize: true
	});
	$(".category header").addClass("draggable");
	$( "#section-category-view .reports-list").sortable({
		connectWith: '.reports-list',
		distance: '5',
		opacity: '0.75',
		tolerance: 'pointer',
		update: function(){
			$(this).parents("#section-category-view").find(".zebra > li").removeClass("alt");
			$(this).parents("#section-category-view").find(".zebra > li:odd").addClass("alt");
		}
	});
	

/*--------------------------------------
	View Report
----------------------------------------*/

	// Set report content & sidebar to equal height - using EqualHeightColumns plugin
	// $(".collapsible-sidebar #content, .collapsible-sidebar .sidebar").equalHeightColumns();
	
	// Sidebar toggle
	$('.toggle-sidebar').toggle(function(e){
		$('html').removeClass('sidebar-on').addClass('sidebar-off');
		$('.sidebar-left').addClass('collapsed clickable');
		e.preventDefault();
		adjust_layout();
	}, function(e){
		$('html').removeClass('sidebar-off').addClass('sidebar-on');
		$('.sidebar-left').removeClass('collapsed clickable');
		e.preventDefault();
		adjust_layout();
	});
	
	// Timeframe Control
	// Adding class="active" and related behavior
	$(".timeframe-control > ul > li .timeframe-name, .timeframe-control .menu a")
	.not(".timeframe-custom a").click(function(e){
		$(".timeframe-control").find("li").removeClass("active");
		$(this).parents(".timeframe-control > ul > li").addClass("active").find(".menu-link").removeClass("shown");
		e.preventDefault();
	});
	// Custom timeframe activation
	$("#modal-custom-timeframe").click(function(){
		$(".timeframe-control").find("li").removeClass("active");
		$(".timeframe-control .timeframe-custom").addClass("active");
	});
	
	// Prevents the use of "disabled" links
	$(".disabled").click(function(e){
		e.preventDefault();
	});
	
	// Table Sorting
	$(".sort-table .y-axis").addClass("active-sort");
		$(".sort-table th a").live("click", function(e){
			e.preventDefault();
			var el = $(this).parents("th");
			$(el).siblings().removeClass("active-sort").removeClass("ascending");
			if ($(el).hasClass("active-sort")) {
				$(el).toggleClass("ascending");
			} else {
				$(el).addClass("active-sort");
			}
		});
		
	
/*--------------------------------------
	Edit Columns/Create New Report
----------------------------------------*/
	
	// Draggable "table cells"
	// Position axis columns
	$(".axis-drag-column").css("width", function(index, value) {
		var elpw = $(this).parent().width();
		var elpwm = elpw - 8;
		return elpwm + "px";
	});
	// Define sortables
	$( ".table-preview" ).sortable({
		items: '.drag-column',
		axis: 'x',
		cancel: '.axis-drag-column'
	});
	$( ".axis-handle" ).draggable({
		zIndex: 2700,
		snap: 'true',
		containment: '.table-preview .container'
	});
	$( ".drag-column" ).droppable({
		accept: '.axis-handle',
		drop: function(event, ui){
			var target = $(this);
			var eldr = ui.draggable;
			var elparent = eldr.parents(".drag-column");
			eldr.css({'top': '0', 'left': '0'});
			if (elparent.hasClass("x-axis")) {
				elparent.removeClass("x-axis");
				target.addClass("x-axis");
				if (target.hasClass("y-axis")){
					target.removeClass("y-axis");
					elparent.addClass("y-axis");
				}
			} else if (elparent.hasClass("y-axis")) {
				elparent.removeClass("y-axis");
				target.addClass("y-axis");
				if (target.hasClass("x-axis")){
					target.removeClass("x-axis");
					elparent.addClass("x-axis");
				}
			} else if (elparent.hasClass("map-axis")) {
				elparent.removeClass("map-axis");
				target.addClass("map-axis");
            } else {
			}
		}
	}).addClass("draggable");


/*--------------------------------------
	Bill Pilot
----------------------------------------*/

	// Equal Height Columns for Pilot Header
	$(".pilot-nav li a, .pilot-progress-lg li, .pilot-actions").equalHeightColumns();
	
	// Toggle expandable billing-items
	var toggle_billitem = function(){
		var indx = 0;
		var el = $(".billing-item.collapsible h3.toggle");
		
		$(el).wrapInner('<button class="btn bold fauxbtn icon expand-down2"></button>');
		buttons_init();
		
		el.each(function(i){
			var target = $(this).parents(".billing-item").find(".content");
			
			$(this).showhide({
				target_obj: target,
				default_open: false,
				use_cookie: true,
				cookie_expires: 2,
				cookie_name: 'show_billing_item_details_'+indx,
				callback_show: function(){
					$(this).find(".btn").removeClass("expand-down2").addClass("collapse-up2");
					buttons_init();
					equalize_cols();
				},
				callback_hide: function(){
					$(this).find(".btn").removeClass("collapse-up2").addClass("expand-down2");
					buttons_init();
					equalize_cols();
				}
			});
			indx++;
		});
	};
	toggle_billitem();
	
	// AJAX loading of View Bill data
	$(".view-invoice").click(function(){
		var load_url = "../invoices/invoice_simple.html";
		
		$("#modal-invoices").children("#invoices-creditcard").addClass("hidden");
		$("#modal-invoices").children("#view-invoice-details").removeClass("hidden").find(".content .inner").load(load_url, function(){
			buttons_init();
			adjust_layout();
		});
	});
	$(".invoice-back").click(function(){
		$("#modal-invoices").children("#view-invoice-details").addClass("hidden");
		$("#modal-invoices").children("#invoices-creditcard").removeClass("hidden");
	});
	

/*--------------------------------------
	Self Care Template Picker
----------------------------------------*/

	$("#selfcare-template-picker").jcarousel({
		itemFallbackDimension: '300'
	});
	// Switching the active class
	$(".carousel-content.picker li").each(function(){
		$(this).children().click(function(e){
			e.preventDefault();
			$(this).parent("li").siblings().removeClass("active");
			$(this).parent("li").addClass("active");
		});
	});


/*--------------------------------------
	Subscriptions
----------------------------------------*/
	
	// Configure Pricing - expandable table rows
	$(".table-product-pricing .configure-pricing").click(function(e){
		e.preventDefault();
		var parent_row = $(this).parents("tr");
		parent_row.addClass("expanded highlight");
		parent_row.next("tr").removeClass("hidden");
		adjust_layout();
	});
	$(".table-product-pricing .save-configuration, .table-product-pricing .cancel-configuration").click(function(e){
		e.preventDefault();
		var parent_row = $(this).parents("tr").prev("tr");
		parent_row.removeClass("expanded highlight");
		parent_row.next("tr").addClass("hidden");
		adjust_layout();
	});

/*--------------------------------------
	Self Care - Upgrade/Downgrade
----------------------------------------*/
    
    // Toggle Visibility with SuperToggle plugin
    $('.toggle-subscriptions').supertoggle({
        callbackShow: function() {
            $('#toggle-subscriptions-teaser').addClass('hidden');
        },
        callbackHide: function() {
            $('#toggle-subscriptions-teaser').removeClass('hidden');
        }
    });
    
    /* Confirmation Modal scripts */
    
    // Equalize heights
    $('.eq-height2').equalHeightColumns();

    // Highlights and custom alert text when choosing an effective date
    var options_init = function(e) {
        var checkedItem = $('input[name="effective_date"]:checked');
        var parent = checkedItem.parent('li');
        var opt_id = parent.index();
        var alertText = checkedItem.parents('.reveal-modal').find('.alert > div');
        
        // Highlight the date
        parent.siblings().find('span').removeClass('hilite');
        parent.find('span').addClass('hilite');
        
        // Change the alert text
        alertText.addClass('hidden');
        alertText.eq(opt_id).removeClass('hidden');
    };
    options_init();

    // Equalize heights
    $('.eq-height0').equalHeightColumns();

    // Highlights and custom alert text when choosing an effective date
    var options_init = function(e) {
        var checkedItem = $('input[name="effective_date"]:checked');
        var parent = checkedItem.parent('li');
        var opt_id = parent.index();
        var alertText = checkedItem.parents('.reveal-modal').find('.alert > div');
        
        // Highlight the date
        parent.siblings().find('span').removeClass('hilite');
        parent.find('span').addClass('hilite');
        
        // Change the alert text
        alertText.addClass('hidden');
        alertText.eq(opt_id).removeClass('hidden');
    };
    options_init();
    
    $('input[name="effective_date"]').change(function(){
        
        if ($(this).is(':checked')) {
            options_init();
            // Color fade
            var parent = $(this).parent('li');
            var opt_id = parent.index();
            $(this).parents('.reveal-modal').find('.alert').removeClass('quiet').delay(750).addClass('quiet', 750);
            
            // Focus the datepicker
            var parent = $(this).parent('li');
            if (parent.find('.datepicker').length) {
                parent.find('.datepicker').focus();
            }
            
            
        }
    });

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Subscription Expiration Notification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	$('button#save-template-name').click(function(e){
		$('a#template-1').removeClass('hidden');
		$('em#no-name-template').addClass('hidden');
		return false;
	});
	
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Bill Pilot +
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	jQuery.fn.animateAuto = function(prop, speed, callback){
    var elem, height, width;
    return this.each(function(i, el){
        el = jQuery(el), elem = el.clone().css({"height":"auto","width":"auto"}).appendTo("body");
        height = elem.css("height"),
        width = elem.css("width"),
        elem.remove();

        if(prop === "height")
            el.animate({"height":height}, speed, callback);
        else if(prop === "width")
            el.animate({"width":width}, speed, callback);
        else if(prop === "both")
            el.animate({"width":width,"height":height}, speed, callback);
    });
};

	$('a#group-1-next').click(function(e){
		$('section#group-1').addClass("collapsed", 500, openInvoiceContainer);
		var duration = 1500;
		var easing = 'easeInOutQuad';
		var callback = function(){
			$('a#sendInvoices').removeClass('hidden');
			$('a#moveInvoices').removeClass('hidden');
		};
		//$("section#group-2").animateAuto("height", duration, callback);
		//$('section#group-2').animate({height:'auto'},duration, easing, callback);
			//"height": "100%",
			//},{ "duration": "1500", "linear", function(){
			//	$('a#sendInvoices').removeClass('hidden');
			//	}
		//});
		function openInvoiceContainer(){
			$('a#sendInvoices').removeClass('hidden');
			$('a#hold-invoices').removeClass('hidden');
			$('a#unhold-invoices').removeClass('hidden');
			$('a#moveInvoices').removeClass('hidden');
			$('a#group-2-back').removeClass('hidden');
			$('section#group-2').removeClass("collapsed", 800);
		}
	});
	
	$('a#group-2-back').click(function(e){
		$('section#group-2').addClass("collapsed", 800, openChartsContainer);
		
		function openChartsContainer(){
			$('a#sendInvoices').addClass('hidden');
			$('a#hold-invoices').addClass('hidden');
			$('a#unhold-invoices').addClass('hidden');
			$('a#moveInvoices').addClass('hidden');
			$('a#group-2-back').addClass('hidden');
			$('section#group-1').removeClass("collapsed", 500);
		}
		return false;
	});
	$('section#group-1 a[data-reveal-id="modal-chart"]').click(function(){
		var myChart = new FusionCharts( "../common/charts/swf/Column3D.swf",
		"myChartId", "100%", "100%", "0", "1" );
		myChart.setXMLUrl("../common/charts/data/revenue_by_product_column_full.xml");
		myChart.setTransparent(true);
		myChart.render("chart-container-2");
		
		$('div#chart-container-2').append(myChart);
	});
	$('form#modal-chart a.close-reveal-modal').click(function(){
		$('object.FusionCharts').remove();
		//console.log('clicked close');
	});

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Login
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	
	var loadRandomBackgroundImage = function(){
		var root = '../common/img/login/';
		var backgroundName;
		var randImageNum = Math.floor(Math.random()*5);
		switch(randImageNum){
			case 0: backgroundName = 'dome.jpg'; break;
			case 1: backgroundName = 'fiber-optics.jpg'; break;
			case 2: backgroundName = 'grass.jpg'; break;
			case 3: backgroundName = 'office-light.jpg'; break;
			case 4: backgroundName = 'paper-blue.jpg'; break;
		}
		$('div#login-page-background').css({
			'background': 'url('+ root + backgroundName + ')'
		});
	};
	loadRandomBackgroundImage();
	$('input').placeholder();
	$('button#login-btn').click(function(){
		var login = $('div#login-container input[title="username"]').val();
		if(login == 'badlogin'){
			$('div#login-container').delay(2000).effect("shake", { times:4 }, 40, popMessage);
		}
		$('.alert.ajax').slideDown("fast");
		
		
	});
	$('div#login-container input').keyup(function(){
		if(event.which ==13){
			$('button#login-btn').click();
		}
	});
	function popMessage(){
		$('.alert.ajax').hide();
		$(this).find('.alert').not('.ajax').slideDown("fast");
		$('div#login-container').find('input').val('');
	}
	
	var flagDist = 34;
	$('div#lang-picker img').click(function(){
		var currentLang = $('div#selected-lang').attr('data-langnum');
		var nextLang = $(this).attr('data-langnum');
		var langDiff = nextLang - currentLang;

		$('div#selected-lang').animate({
			left: '+='+(langDiff*flagDist)
			},{duration: 250, easing:'easeInOutCubic' });
		$('div#selected-lang').attr('data-langnum', nextLang);
	});

  $('#down-page .text div#lang-picker img').click(function(){
    var selectedlang = $('div#selected-lang').attr('data-langnum');
    selectedlang = parseInt(selectedlang);
    //console.log(selectedlang);
    var firstline;
    var secondline;
    switch(selectedlang){
			case 1: firstline = "Metanga is currently down for maintenance.";
              secondline = "We will be back online shortly."; break;
      case 2: firstline = "Metanga se encuentra actualmente en mantenimiento.";
              secondline = "Estaremos de vuelta en línea en breve."; break;
      case 3: firstline = "Metanga est actuellement fermé pour maintenance.";
              secondline = "Nous serons de retour en ligne sous peu."; break;
      case 4: firstline = "Metangaは、メンテナンスのため現在停止しています。";
              secondline = "我々はまもなく戻ってオンラインになります。"; break;
      case 5: firstline = "Metanga está atualmente em manutenção.";
              secondline = "Estaremos de volta online em breve."; break;
      case 6: firstline = "Metanga в настоящее время закрыт на техническое обслуживание.";
              secondline = "Мы вернемся сайте в ближайшее время."; break;
      default: firstline = "Metanga is currently down for maintenance.";
              secondline = "We will be back online shortly."; break;
		}
    $('#down-msg #line1').html(firstline);
    $('#down-msg #line2').html(secondline);
  });
	
	$('div#login-container a.forgot').click(function(){
		$('input[placeholder="username"], input[placeholder="password"]').parent().addClass('hidden');
		$(this).addClass('hidden');
		$('div#rss-container').addClass('hidden');
		$('button#login-btn').addClass('hidden');
		$('li#forgot-pwd').removeClass('hidden');
		$('button#pswd-btn').removeClass('hidden');
		
	});
	
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Modal Dialogs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
	$(".reveal-modal .datepicker").datepicker();
	$(".reveal-modal .show-second-datepicker").live("click", (function(e){
		$(this).parents(".reveal-modal").find(".second-datepicker").removeClass("hidden");
		e.preventDefault();
	}));
	$(".reveal-modal .close-datepicker").live("click", (function(e){
		$(this).parents(".reveal-modal").find(".second-datepicker").addClass("hidden");
		e.preventDefault();
	}));
	
	$(".reveal-modal footer button").live("click", (function(e){
		e.preventDefault();
		$(this).parents('.container').addClass("success");
	}));
	
	// Save Report fields
	$(".show-save-fields").click(function(e){
		e.preventDefault();
		$('.save-fields').removeClass("hidden");
	});

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Functions for packages chaining screens
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// show and hide payment sections based on user radio choice
 $('input[name="payment"]').change(function() {
   
    var radioID=$(this).attr('id');
       
  if (radioID == 'payment_eft') {
		$('div#credit-options').addClass('hidden');
       $('div#eft-options').fadeIn(1000).removeClass('hidden');
       }
  else {
		$('div#eft-options').addClass('hidden');
       $('div#credit-options').fadeIn(1000).removeClass('hidden');
       }
});

// Route the user to a success page when converting/renewing
    $('#convert-renew-submit').click(function(){
        var checkedItem = $(this).parents('.reveal-modal').find('input[name="effective_date"]:checked');
        var checkedIndex = checkedItem.parent('li').index();
        if (checkedIndex === 0) {
            window.location.href = 'my-subscription-chain-success-now.html';
        } else {
            window.location.href = 'my-subscription-chain-success-later.html';
        }
    });

// Back button for compare screen
	$('a#compare-back').click(function(e){
		window.location.href = 'my-subscription-chaining.html';
    });

// Expose sections in Package Edit Screen
 $('input[name="package-fixed-term"]').change(function(){
   if ($('input[name="package-fixed-term"]:checked').val() !== undefined) {
        $('div#package-fixed-term-options').delay(225).slideDown(300);
        }
   else {
        $('div#package-fixed-term-options').delay(225).slideUp(100);
        }
});

// Init searchable select box for chaining
  $("select#chainPackageSelect").sexyCombo({
			emptyText: "Choose a package...",
			autoFill: true,
			skin: "custom"
	});

/*highlight input fields - account info redesign*/
$("section#account-profile input, section#profile input").focus(function() {
		$(this).parent().addClass("curFocus");
	});
	$("input").blur(function() {
		$(this).parent().removeClass("curFocus");
	});


/*add or delete a table row-----------------------------------------*/

    $('.row-delete').live("click", function (){
      $(this).closest("tr").remove();
    });

    $('.delete-td').live("click", function (){
      $(this).parent("span").remove();
    });

    $('.row-add').live("click", function () {
      var price = $(this).closest("span.original").clone();
      
      if
      ($(this).closest("td").hasClass("noprice")){
      	$(this).closest("td").removeClass("noprice");
      	$(this).parent("span").remove();
      	$(this).closest("td").append(price);
      }
      else {
		$(this).closest("td").append(price);
      }
    });

    $('.row-clone').live("click", function () {

    });



/*switch product table-----------------------------------------*/
  $(function(){
    var $containers = $("div.product-table").hide();

    $('ul.product-list dt a').each(function(i,el){
      var idx = i;
      $(this).click(function(e){
       
       var $target = $containers.filter(':eq(' + idx + ')');
        // Fade out visible div
        if($containers.filter(':visible').not($target).length){
          $containers.filter(':visible').fadeOut(100, function(){
            $target.not(':visible').fadeIn(100);
          });
        } else {
          $target.not(':visible').fadeIn(100);
        }
        e.preventDefault();
      });
    });
  });

/*highlight selected product-----------------------------------------*/
  $("ul.product-list dt a.sm2_title").click(function () {
    $(".product-selected").removeClass("product-selected");
    $(this).addClass("product-selected");
  });


/* Prototype Call */
$("a#start-processing").click(function() {
	metangaProcessing(); //call main function
});

/*selfcare-udrc-upgrade-----------------------------------------*/

     $('a.upgrade-btn').click(function () {
       var totalWidth = $('div.selfcare-udrc').width();
       var bigDiv = Math.floor(totalWidth * 0.6);
       var smallDiv = Math.floor(totalWidth * 0.35);
       //console.log(totalWidth +", " + bigDiv +", " + smallDiv);
       $('div.current').addClass("darkClass").effect("size", { to: { width: smallDiv }, scale: content }, 250, function () {
       $('div.upgrade').css("height", "auto");
       $('a.cancel-upgrade').delay(350).fadeIn();
       }).css("height", "auto");
       
       $('div.upgrade').effect("size", { to: { width: bigDiv }, scale: content, origin: ['top', 'right'] }, 250, function () {
         $('.view-upgrade').hide();
         $('.upgrade-btn').css("display", "none");
         $('.continue').removeClass("hidden");
         $('.edit-upgrade').fadeIn();
       });
      });

     $('a.cancel-upgrade').click(function () {
       var totalWidth = $('div.selfcare-udrc').width();
       var bigDiv = Math.floor(totalWidth * 0.6);
       var smallDiv = Math.floor(totalWidth * 0.35);
       //console.log(totalWidth +", " + bigDiv +", " + smallDiv);
       $('div.upgrade').effect("size", { to: { width: smallDiv }, scale: content, origin: ['top', 'right'] }, 250);
       $('.edit-upgrade').hide();
       $('.view-upgrade').fadeIn();
       $('.upgrade-btn').css("display", "inline-block");
       $('.continue').addClass("hidden");
       $('div.current').removeClass("darkClass").effect("size", { to: { width: bigDiv }, scale: content }, 250).css("height", "auto");
       $('div.upgrade').css("height", "auto");
       $('a.cancel-upgrade').hide();
     });

/*Account Home Page Prototype */

//Initialize timeline
	$.timeliner();
    
// View/more or less on account details
	$('body.page-account-home a.view-more').click(function(e){
      //switch links and expose hidden fields
      $(this).delay(200).fadeOut(100); //hide view more link
      $('body.page-account-home a.view-less').delay(200).fadeIn(100); //show view less link
      $('body.page-account-home li.suppress').delay(200).slideDown(250); //show hidden links
      e.preventDefault(); //stop the page from scrolling
    });

	$('body.page-account-home a.view-less').click(function(e){
      //switch links and hide hidden fields
      $('body.page-account-home a.view-more').delay(200).fadeIn(100); //show view more link
      $('body.page-account-home a.view-less').delay(200).fadeOut(100); //hide view less link
      $('body.page-account-home li.suppress').delay(200).slideUp(200); //hide hidden links
      e.preventDefault(); //stop the page from scrolling
    });

/*edit Account Details Section*/
      $(".edit-one-button").click(function () {
      $(this).siblings('fieldset').toggle('normal');
      var divheight;
      if ($(this).hasClass('edit')) {
        $(this).closest('.account-widget').removeAttr('style');
      }
      else {
        divheight = $(this).parent().siblings('.account-widget').height();
        $(this).closest('.account-widget').css("min-height", divheight);
      }
    });
      
    $('.edit').click(function () {
    $('.edit-one-button.edit').addClass('hidden');
    $(".edit-one-button.save").show();
    $(".edit-one-button.cancel").show();
    });

    $('.cancel').click(function() {
    $('.edit-one-button.edit').removeClass('hidden');
    $('.edit-one-button.save').hide();
    $('.edit-one-button.cancel').hide();
    });

    $('.save').click(function() {
    $('.edit-one-button.edit').removeClass('hidden');
    $('.edit-one-button.cancel').hide();
    $('.edit-one-button.save').hide();
    });

    /*tooltip on account info page*/
    $('.masterTooltip').hover(function(){
                // Hover over code
                var title = $(this).attr('title');
                $(this).data('tipText', title).attr('title', '');
                $('<p class="tooltip"></p>')
                .text(title)
                .appendTo('body')
                .fadeIn('fast');
    }, function() {
                // Hover out code
                $(this).attr('title', $(this).data('tipText'));
                $('.tooltip').remove();
    }).mousemove(function(e) {
                var mousex = e.pageX + 20; //Get X coordinates
                var mousey = e.pageY + 10; //Get Y coordinates
                $('.tooltip')
                .css({ top: mousey, left: mousex });
    });


$("div.account-home-right").tabs("select", 0);  //set default tab on load (replace with stored user setting)

/*Toggle status functionality*/

      $("li.suspend-account").click(function () {
      if ($("span.account-home-profile_icon").hasClass('active')) {
          $("span.account-home-profile_icon").removeClass('active').addClass('suspended');
          $('#AccountStatusToolTip span.bold:contains("Active")').text('Suspended');
          $("div#account-actions li.suspend-account").hide();
      }
      else {
        $("span.account-home-profile_icon").removeClass('suspended').addClass('active');
        $('#AccountStatusToolTip span.bold:contains("Suspended")').text('Active');
      }
    });

// Init the tables

	var dtableDialogmenuSubscriptions = function(){
		var tbl = $("table.dtable-dialogmenu-subscriptions");
		$(tbl).dataTable({
        "aaSorting": [[0,'asc']],
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
		"aoColumnDefs": [
			{ "sWidth": "20%", "aTargets": [ 5 ] },
			{ "bSortable": false, "aTargets": [ 5 ] }
		]
		});
	};
	dtableDialogmenuSubscriptions();

	var dtableDialogmenuBills = $("table.dtable-dialogmenu-bills").dataTable({
        "aaSorting": [[0,'asc']],
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
		"aoColumnDefs": [
			{ "sWidth": "20%", "aTargets": [ 5 ] },
			{ "bSortable": false, "aTargets": [ 5 ] }
		]
		});

	var dtableDialogmenuOptionalProduct = $("table.table-optional-product").dataTable({
        "aaSorting": [[0,'asc']],
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
		"aoColumnDefs": [
			{ "sWidth": "25%", "aTargets": [ 0 ] },
			{ "sWidth": "33%", "aTargets": [ 1 ] },
			{ "sWidth": "150px", "aTargets": [ 3 ] },
			{ "bSortable": false, "aTargets": [ 3 ] }
		]
		});

	var dtableDialogmenuCurrentProduct = $("table.table-current-product").dataTable({
        "aaSorting": [[0,'asc'],[2,'desc']],
        "bJQueryUI": true,
        "sPaginationType": "full_numbers",
		"aoColumnDefs": [
			{ "sWidth": "25%", "aTargets": [ 0 ] },
			{ "sWidth": "15%", "aTargets": [ 6 ] },
			{ "bSortable": false, "aTargets": [ 5, 6 ] }
		]
		});

	// Data Tables - Show subscription history
	$('table.table-current-product').parents(".dataTables_wrapper").find(".fg-toolbar.ui-corner-tl").append('<div><input id="" type="checkbox" name="show-product-history" /><label for="showHistory" class="lspace">Show Ended Subscriptions</label></div>');

// Edit table rows in-line
function editRow ( oTable, nRow ) {

    var aData = oTable.fnGetData(nRow);  //array of all the data in the row
    var jqTds = $('>td', nRow);  //array of all the tds in the row
    //set background style
    $(jqTds).css( 'background', '#fffada' );

    //parse quant
    var qData  = $(jqTds[3]).children(':first-child').text();
    var qLbl  = $(jqTds[3]).children(':last-child').text();
    //parse price
    var pData  = $(jqTds[4]).children(':first-child').text();
    var pLbl  = $(jqTds[4]).children(':last-child').text();
    var pLblshort = pLbl.substr(2,pLbl.length);  //remove slash from unit

    //create unit list variables for setting dropdown
    var selectSecond = '', selectMinute = '', selectHour = '', selectDay = '', selectBiweek = '', selectWeek = '', selectMonth = '', selectYear = '';

    if(pLblshort=='Second') {
		selectSecond = 'selected="selected"';
	}
    else if(pLblshort=='Minute') {
		selectMinute = 'selected="selected"';
	}
	else if(pLblshort=='Hour') {
		selectHour = 'selected="selected"';
	}
	else if(pLblshort=='Day') {
		selectDay = 'selected="selected"';
	}
	else if(pLblshort=='Biweek') {
		selectBiweek = 'selected="selected"';
	}
	else if(pLblshort=='Week') {
		selectWeek = 'selected="selected"';
	}
	else if(pLblshort=='Month') {
		selectMonth = 'selected="selected"';
	}
	else {
		selectYear = 'selected="selected"';
	}


	//push data into the row
    jqTds[1].innerHTML = '<input class="datepicker" type="text" name="" id="" value="'+aData[1]+'">';
    jqTds[2].innerHTML = '<input class="datepicker" type="text" name="" id="" value="'+aData[2]+'">';
	jqTds[3].innerHTML = qData;

    //console.log(pLbl);
    if (pLbl==='') {
		jqTds[4].innerHTML = '<input type="text" class="medium-large" name="" id="" value="'+pData+'">';
	} else {
		jqTds[4].innerHTML = '<input type="text" class="medium-large" name="" id="" value="'+pData+'"> / <select><option value=""'+selectSecond+'>Second</option><option value=""'+selectMinute+'>Minute</option><option value=""'+selectHour+'>Hour</option><option value=""'+selectDay+'>Day</option><option value=""'+selectBiweek+'>Bi-Week</option><option value=""'+selectWeek+'>Week</option><option value=""'+selectMonth+'>Month</option><option value=""'+selectYear+'>Year</option></select>';
      }

    initDatepicker(); //need to reinit the datepicker
}

// Init datepicker
function initDatepicker () {
	$("table.table-current-product tr td").find('input.datepicker').each(function() {
		if ($(this).hasClass('hasDatepicker')) {
			return false;
		}
		else {
			$(this).removeAttr('id').removeClass('hasDatepicker').datepicker();
		}
	});
}

// Save Row
function saveRow ( oTable, nRow ) {
    var jqTds = $('td', nRow);
    oTable.fnUpdate( jqTds[1].value, nRow, 0, false );
    oTable.fnUpdate( jqTds[1].value, nRow, 1, false );
    oTable.fnUpdate( jqTds[2].value, nRow, 2, false );
    oTable.fnUpdate( jqTds[3].value, nRow, 3, false );
    oTable.fnUpdate( jqTds[4].value, nRow, 4, false );
    oTable.fnDraw();
}
// Restore Row
function restoreRow ( oTable, nRow ) {
	var aData = oTable.fnGetData(nRow);
	var jqTds = $('>td', nRow);

    //remove background style
    $(jqTds).css( 'background', '' );
	
	for ( var i=0, iLen=jqTds.length-1 ; i<iLen ; i++ ) {
		oTable.fnUpdate( aData[i], nRow, i, false );
	}
	oTable.fnDraw();
}

// Delete Row
$('table.table-current-product a.remove').live('click', function (e) {
    e.preventDefault();
    var nRow = $(this).parents('tr')[0];
    dtableDialogmenuCurrentProduct.fnDeleteRow( nRow );
} );

// Edit Handler
$('table.table-current-product button.table-current-product-split, table.table-current-product a.amend').live('click', function (e) {
	e.preventDefault();
	/* Get the row as a parent of the link that was clicked on */
	var nRow = $(this).parents('tr')[0];
	editRow( dtableDialogmenuCurrentProduct, nRow );
	// Swap buttons
	
	//show Revert button
	$(this).parents('div.splitbutton').prev().removeClass('hidden');
	//hide splitbutton div
	$(this).parents('div.splitbutton').addClass('hidden');
} );

//Revert Handler
$('table.table-current-product a.revert').live('click', function (e) {
	e.preventDefault();
	var nRow = $(this).parents('tr')[0];
	restoreRow ( dtableDialogmenuCurrentProduct, nRow );

	//hide Revert button
	$(this).parent().addClass('hidden');
	//show splitbutton div
	$(this).parent().siblings('div.splitbutton').removeClass('hidden');
} );

//Copy over optional product - add
$('table.table-optional-product a.add').click( function (e) {
		e.preventDefault();

		//get description
		var cRow = $(this).parents('tr')[0]; //get current add row
		var cData = dtableDialogmenuOptionalProduct.fnGetData(cRow);

		//get date
		var d = new Date();
		var month = d.getMonth()+1;
		var day = d.getDate();
		var dateOutput =  ((''+month).length<2 ? '0' : '') + month + '/' + ((''+day).length<2 ? '0' : '') + day + '/' + d.getFullYear();


		
		var aiNew = dtableDialogmenuCurrentProduct.fnAddData( [
			cData[0],
			dateOutput,
			'',
			'<span class="data">1</span><span class="label"> Year</span> ',
			cData[2],
			'',
			'<a class="btn " href="">Save</a><a class="remove lspace" href="">Cancel</a>'
			] );
		var nRow = dtableDialogmenuCurrentProduct.fnGetNodes( aiNew[0] );
		buttons_init(); //initialize buttons
		editRow( dtableDialogmenuCurrentProduct, nRow );
	} );


/* Optional Product toggle*/
$( "#radio-product-type" ).buttonset();

/* Jquery split button */


var tableCurrentProductSplit = function () {
        $( ".table-current-product-split" )
            .button({icons:{ primary: "ui-icon-pencil"} })
            .next()
                .button({
                    text: false,
                    icons: {
                        primary: "ui-icon-triangle-1-s"
                    }
                })
                .click(function() {
                    var menu = $( this ).parent().next().show().position({
                        my: "right top",
                        at: "right bottom",
                        of: this
                    });
                    $( document ).one( "click", function() {
                        menu.hide();
                    }).one( "resize", function() {
                        menu.hide();
                    });
                    return false;
                })
                .parent()
                    .buttonset()
                    .next()
                        .hide()
                        .menu();

    };
tableCurrentProductSplit();

var dtableDialogmenuBillsSplit = function ($) {
        $( ".dtable-dialogmenu-bills-split" )
            .button({icons:{ primary: "ui-icon-search"} })
            .click(function() {
                 alert( "Acion!" );
            })
            .next()
                .button({
                    text: false,
                    icons: {
                        primary: "ui-icon-triangle-1-s"
                    }
                })
                .click(function() {
                    var menu = $( this ).parent().next().show().position({
                        my: "right top",
                        at: "right bottom",
                        of: this
                    });
                    $( document ).one( "click", function() {
                        menu.hide();
                    }).one( "resize", function() {
                        menu.hide();
                    });
                    return false;
                })
                .parent()
                    .buttonset()
                    .next()
                        .hide()
                        .menu();

    };

dtableDialogmenuBillsSplit(jQuery);

var dtableDialogmenuSubscriptionsSplit = function ($) {
        $( ".dtable-dialogmenu-subscriptions-split" )
            .button({icons:{ primary: "ui-icon-pencil"} })
            .click(function() {
                 window.location.href = 'prototype-edit-subscription-settings.html';
            })
            .next()
                .button({
                    text: false,
                    icons: {
                        primary: "ui-icon-triangle-1-s"
                    }
                })
                .click(function() {
                    var menu = $( this ).parent().next().show().position({
                        my: "right top",
                        at: "right bottom",
                        of: this
                    });
                    $( document ).one( "click", function() {
                        menu.hide();
                    }).one( "resize", function() {
                        menu.hide();
                    });
                    return false;
                })
                .parent()
                    .buttonset()
                    .next()
                        .hide()
                        .menu();

    };

dtableDialogmenuSubscriptionsSplit(jQuery);

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Cleanup
    Last things to do before loading is finished.  NOTE: Place all new jQuery before this block.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
    /* Adjust layout to viewport dimensions
        Equalized columns, height items, and multi-selects */
	adjust_layout();
	
    /* Window resize behaviors
        Includes a time-delay of the adjust_layout function, to prevent UI from slowing down */
	var resizeTimer;
	$(window).resize(function() {
		clearTimeout(resizeTimer);
		resizeTimer = setTimeout(adjust_layout, 100);

		//text_autosize();
		autosize();
	});
	
	/* Hide all 'show-hide' classes */
	$('.show-hide').hide();

}); // End Document-Ready

/* End Cleanup  NOTE: Do not place any new jQuery after this line and block */