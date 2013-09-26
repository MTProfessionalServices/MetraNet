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
    var tree = new Ext.tree.TreePanel({
        renderTo:'tree-div',
        title: 'My Task List',
        height: 300,
        width: 400,
        useArrows:true,
        autoScroll:true,
        animate:true,
        enableDD:true,
        containerScroll: true,
        rootVisible: false,
        frame: true,
        root: {
            nodeType: 'async'
        },
        
        // auto create TreeLoader
        dataUrl: 'check-nodes.json',
        
        listeners: {
            'checkchange': function(node, checked){
                if(checked){
                    node.getUI().addClass('complete');
                }else{
                    node.getUI().removeClass('complete');
                }
            }
        },
        
        buttons: [{
            text: 'Get Completed Tasks',
            handler: function(){
                var msg = '', selNodes = tree.getChecked();
                Ext.each(selNodes, function(node){
                    if(msg.length > 0){
                        msg += ', ';
                    }
                    msg += node.text;
                });
                Ext.Msg.show({
                    title: 'Completed Tasks', 
                    msg: msg.length > 0 ? msg : 'None',
                    icon: Ext.Msg.INFO,
                    minWidth: 200,
                    buttons: Ext.Msg.OK
                });
            }
        }]
    });

    tree.getRootNode().expand(true);
});