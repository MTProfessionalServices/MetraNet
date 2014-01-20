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

    var handleAction = function(action){
        Ext.example.msg('<b>Action</b>', 'You clicked "'+action+'"');
    };
    
    var p = new Ext.Window({
        title: 'Standard',
        closable: false,
        height:250,
        width: 500,
        bodyStyle: 'padding:10px',
        contentEl: 'content',
        autoScroll: true,
        tbar: new Ext.Toolbar({
            enableOverflow: true,
            items: [{
                xtype:'splitbutton',
                text: 'Menu Button',
                iconCls: 'add16',
                handler: handleAction.createCallback('Menu Button'),
                menu: [{text: 'Menu Item 1', handler: handleAction.createCallback('Menu Item 1')}]
            },'-',{
                xtype:'splitbutton',
                text: 'Cut',
                iconCls: 'add16',
                handler: handleAction.createCallback('Cut'),
                menu: [{text: 'Cut menu', handler: handleAction.createCallback('Cut menu')}]
            },{
                text: 'Copy',
                iconCls: 'add16',
                handler: handleAction.createCallback('Copy')
            },{
                text: 'Paste',
                iconCls: 'add16',
                menu: [{text: 'Paste menu', handler: handleAction.createCallback('Paste menu')}]
            },'-',{
                text: 'Format',
                iconCls: 'add16',
                handler: handleAction.createCallback('Format')
            },'->',{
                text: 'Right',
                iconCls: 'add16',
                handler: handleAction.createCallback('Right')
            }]
        })
    });
    p.show();

});