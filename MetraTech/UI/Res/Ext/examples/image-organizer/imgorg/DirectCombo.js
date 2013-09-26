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
Imgorg.DirectCombo = Ext.extend(Ext.form.ComboBox, {
    displayField: 'text',
    valueField: 'id',
    triggerAction: 'all',
    queryAction: 'name',
    forceSelection: true,
    mode: 'remote',
    
    initComponent: function() {
        this.store = new Ext.data.DirectStore(Ext.apply({
            api: this.api,
            root: '',
            fields: this.fields || ['text', 'id']
        }, this.storeConfig));
        
        Imgorg.DirectCombo.superclass.initComponent.call(this);
    }
});

Imgorg.TagCombo = Ext.extend(Imgorg.DirectCombo,{
    forceSelection: false,
    storeConfig: {
        id: 'tag-store'
    },
    initComponent: function() {
        Ext.apply(this.storeConfig, {
            directFn: Imgorg.ss.Tags.load
        });
        Imgorg.TagCombo.superclass.initComponent.call(this);
    }
});
Ext.reg('img-tagcombo', Imgorg.TagCombo);

Imgorg.TagMultiCombo = Ext.extend(Ext.ux.MultiCombo,{
    listClass: 'label-combo',
    displayField: 'text',
    valueField: 'id',
    
    initComponent: function() {
        this.store = new Ext.data.DirectStore(Ext.apply({
            directFn: Imgorg.ss.Tags.load,
            root: '',
            autoLoad: true,
            fields: this.fields || ['text', 'id']
        }, this.storeConfig));
        this.plugins =new Ext.ux.MultiCombo.Checkable({});
        Imgorg.DirectCombo.superclass.initComponent.call(this);
    }
});
Ext.reg('img-tagmulticombo', Imgorg.TagMultiCombo);

Imgorg.AlbumCombo = Ext.extend(Imgorg.DirectCombo, {
    storeConfig: {
        id: 'album-store'
    },
    initComponent: function() {
        Ext.apply(this.storeConfig, {
            directFn: Imgorg.ss.Albums.getAllInfo
        });
        Imgorg.AlbumCombo.superclass.initComponent.call(this);
    }
});
Ext.reg('img-albumcombo', Imgorg.AlbumCombo);
