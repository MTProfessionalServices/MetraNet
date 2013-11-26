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
    Ext.Direct.addProvider(Ext.app.REMOTING_API);

    var tree = new Ext.tree.TreePanel({
        width: 400,
        height: 400,
        autoScroll: true,
        renderTo: document.body,
        root: {
            id: 'root',
            text: 'Root'
        },
        loader: new Ext.tree.TreeLoader({
            directFn: TestAction.getTree
        }),
        fbar: [{
            text: 'Reload root',
            handler: function(){
                tree.getRootNode().reload();
            }
        }]
    });
});
