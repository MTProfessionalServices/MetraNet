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
    new Ext.ToolTip({
        target: 'tip1',
        html: 'A very simple tooltip'
    });

    new Ext.ToolTip({
        target: 'ajax-tip',
        width: 200,
        autoLoad: {url: 'ajax-tip.html'},
        dismissDelay: 15000 // auto hide after 15 seconds
    });

    new Ext.ToolTip({
        target: 'tip2',
        html: 'Click the X to close me',
        title: 'My Tip Title',
        autoHide: false,
        closable: true,
        draggable:true
    });

    new Ext.ToolTip({
        target: 'track-tip',
        title: 'Mouse Track',
        width:200,
        html: 'This tip will follow the mouse while it is over the element',
        trackMouse:true
    });
    
    new Ext.ToolTip({        
        title: '<a href="#">Rich Content Tooltip</a>',
        id: 'content-anchor-tip',
        target: 'leftCallout',
        anchor: 'left',
        html: null,
        width: 415,
        autoHide: false,
        closable: true,
        contentEl: 'content-tip', // load content from the page
        listeners: {
            'render': function(){
                this.header.on('click', function(e){
                    e.stopEvent();
                    Ext.Msg.alert('Link', 'Link to something interesting.');
                    Ext.getCmp('content-anchor-tip').hide();
                }, this, {delegate:'a'});
            }
        }
    });
    
    new Ext.ToolTip({
        target: 'bottomCallout',
        anchor: 'top',
        anchorOffset: 85, // center the anchor on the tooltip
        html: 'This tip\'s anchor is centered'
    });
    
    new Ext.ToolTip({
        target: 'trackCallout',
        anchor: 'right',
        trackMouse: true,
        html: 'Tracking while you move the mouse'
    });


    Ext.QuickTips.init();

});