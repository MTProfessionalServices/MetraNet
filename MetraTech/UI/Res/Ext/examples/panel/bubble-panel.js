/*
This file is part of Ext JS 3.4

Copyright (c) 2011-2013 Sencha Inc

Contact:  http://www.sencha.com/contact

Commercial Usage
Licensees holding valid commercial licenses may use this file in accordance with the Commercial
Software License Agreement provided with the Software or, alternatively, in accordance with the
terms contained in a written agreement between you and Sencha.

If you are unsure which license is appropriate for your use, please contact the sales department
at http://www.sencha.com/contact.

Build date: 2013-04-03 15:07:25
*/
Ext.onReady(function(){   
    var title = new Ext.ux.BubblePanel({
	bodyStyle: 'padding-left: 8px;color: #0d2a59',
	renderTo: 'bubbleCt',
	html: '<h3>Ext.ux.BubblePanel</h3',
	width: 200,
	autoHeight: true
    });
    var cp = new Ext.ux.BubblePanel({
	renderTo: 'bubbleCt',
	padding: 5,
	width: 400,
	autoHeight: true,
	contentEl: 'bubble-markup'
    });

    var plainOldPanel = new Ext.Panel({
        renderTo: 'panelCt',
	padding: 5,
	frame: true,
	width: 400,
	autoHeight: true,
	title: 'Plain Old Panel',
	html: Ext.example.bogusMarkup
    });

});


