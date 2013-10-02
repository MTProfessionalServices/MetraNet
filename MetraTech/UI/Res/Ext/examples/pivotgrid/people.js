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
/**
 * Multiple PivotGrid examples. Each PivotGrid shares a common Record and Store and simply presents
 * the data in a different way. For full details on using PivotGrid see the API documentation.
 */
Ext.onReady(function() {
    var PersonRecord = Ext.data.Record.create([
        {name: 'eyeColor',    type: 'string'},
        {name: 'birthDecade', type: 'string'},
        {name: 'handedness',  type: 'string'},
        {name: 'gender',      type: 'string'},
        {name: 'height',      type: 'int'},
        {name: 'iq',          type: 'int'}
    ]);
    
    var myStore = new Ext.data.Store({
        url: 'people.json',
        autoLoad: true,
        reader: new Ext.data.JsonReader({
            root: 'rows',
            idProperty: 'id'
        }, PersonRecord)
    });
    
    var averageHeight = new Ext.grid.PivotGrid({
        title     : 'Average height',
        width     : 600,
        height    : 154,
        renderTo  : 'avgHeight',
        store     : myStore,
        aggregator: 'avg',
        measure   : 'height',
        
        //turns a decimal number of feet into feet and inches
        renderer  : function(value) {
            var feet   = Math.floor(value),
                inches = Math.round((value - feet) * 12);
                
            return String.format("{0}' {1}\"", feet, inches);
        },
        
        leftAxis: [
            {
                width: 80,
                dataIndex: 'birthDecade'
            }
        ],
        
        topAxis: [
            {
                dataIndex: 'gender'
            },
            {
                dataIndex: 'handedness'
            }
        ]
    });
    
    var perDecade = new Ext.grid.PivotGrid({
        title     : 'Number of people born per decade',
        width     : 600,
        height    : 91,
        renderTo  : 'perDecade',
        store     : myStore,
        aggregator: 'count',
        
        topAxis: [
            {
                width: 80,
                dataIndex: 'birthDecade'
            }
        ],
        
        leftAxis: [
            {
                dataIndex: 'gender'
            }
        ]
    });
    
    var maxIQ = new Ext.grid.PivotGrid({
        title     : 'Max IQ per decade',
        width     : 600,
        height    : 91,
        renderTo  : 'maxIQ',
        store     : myStore,
        measure   : 'iq',
        aggregator: 'max',
        
        topAxis: [
            {
                width: 80,
                dataIndex: 'birthDecade'
            },
            {
                dataIndex: 'handedness'
            }
        ]
    });
});