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
    // shorthand
    var Tree = Ext.tree;

    var tree = new Tree.TreePanel({
        useArrows: true,
        autoScroll: true,
        animate: true,
        enableDD: true,
        containerScroll: true,
        border: false,
        // auto create TreeLoader
        dataUrl: 'get-nodes.php',

        root: {
            nodeType: 'async',
            text: 'Ext JS',
            draggable: false,
            id: 'src'
        }
    });

    // render the tree
    tree.render('tree-div');
    tree.getRootNode().expand();
});