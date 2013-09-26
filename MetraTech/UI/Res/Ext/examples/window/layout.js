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
    
    Ext.state.Manager.setProvider(
            new Ext.state.SessionProvider({state: Ext.appState}));

    var button = Ext.get('show-btn');

    button.on('click', function(){

        // tabs for the center
        var tabs = new Ext.TabPanel({
            region: 'center',
            margins:'3 3 3 0', 
            activeTab: 0,
            defaults:{autoScroll:true},

            items:[{
                title: 'Bogus Tab',
                html: Ext.example.bogusMarkup
            },{
                title: 'Another Tab',
                html: Ext.example.bogusMarkup
            },{
                title: 'Closable Tab',
                html: Ext.example.bogusMarkup,
                closable:true
            }]
        });

        // Panel for the west
        var nav = new Ext.Panel({
            title: 'Navigation',
            region: 'west',
            split: true,
            width: 200,
            collapsible: true,
            margins:'3 0 3 3',
            cmargins:'3 3 3 3'
        });

        var win = new Ext.Window({
            title: 'Layout Window',
            closable:true,
            width:600,
            height:350,
            //border:false,
            plain:true,
            layout: 'border',

            items: [nav, tabs]
        });

        win.show(this);
    });
});