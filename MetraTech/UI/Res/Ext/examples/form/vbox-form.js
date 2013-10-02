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
Ext.onReady(function() {
    var form = new Ext.form.FormPanel({
        baseCls: 'x-plain',
        labelWidth: 55,
        url: 'save-form.php',
        layout: {
            type: 'vbox',
            align: 'stretch'  // Child items are stretched to full width
        },
        defaults: {
            xtype: 'textfield'
        },

        items: [{
            xtype: 'combo',
            store: ['test@example.com', 'someone-else@example.com' ],
            plugins: [ Ext.ux.FieldReplicator, Ext.ux.FieldLabeler ],
            fieldLabel: 'Send To',
            name: 'to'
        },{
            plugins: [ Ext.ux.FieldLabeler ],
            fieldLabel: 'Subject',
            name: 'subject'
        }, {
            xtype: 'textarea',
            fieldLabel: 'Message text',
            hideLabel: true,
            name: 'msg',
            flex: 1  // Take up all *remaining* vertical space
        }]
    });

    var w = new Ext.Window({
        title: 'Compose message',
        collapsible: true,
        maximizable: true,
        width: 750,
        height: 500,
        minWidth: 300,
        minHeight: 200,
        layout: 'fit',
        plain: true,
        bodyStyle: 'padding:5px;',
        buttonAlign: 'center',
        items: form,
        buttons: [{
            text: 'Send'
        },{
            text: 'Cancel'
        }]
    });
    w.show();
});