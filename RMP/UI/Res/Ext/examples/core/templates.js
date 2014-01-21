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

    var data = {
        name: 'Jack Slocum',
        company: 'Ext JS, LLC',
        address: '4 Red Bulls Drive',
        city: 'Cleveland',
        state: 'Ohio',
        zip: '44102',
        kids: [{
            name: 'Sara Grace',
            age:3
        },{
            name: 'Zachary',
            age:2
        },{
            name: 'John James',
            age:0
        }]
    };

    var p = new Ext.Panel({
        title: 'Basic Template',
        width: 300,
        html: '<p><i>Apply the template to see results here</i></p>',
        tbar: [{
            text: 'Apply Template',
            handler: function(){

                var tpl = new Ext.Template(
                    '<p>Name: {name}</p>',
                    '<p>Company: {company}</p>',
                    '<p>Location: {city}, {state}</p>'
                );

                tpl.overwrite(p.body, data);
                p.body.highlight('#c3daf9', {block:true});
            }
        }],

        renderTo: document.body
    });


    var p2 = new Ext.Panel({
        title: 'XTemplate',
        width: 300,
        html: '<p><i>Apply the template to see results here</i></p>',
        tbar: [{
            text: 'Apply Template',
            handler: function(){

                var tpl = new Ext.XTemplate(
                    '<p>Name: {name}</p>',
                    '<p>Company: {company}</p>',
                    '<p>Location: {city}, {state}</p>',
                    '<p>Kids: ',
                    '<tpl for="kids" if="name==\'Jack Slocum\'">',
                        '<tpl if="age &gt; 1"><p>{#}. {parent.name}\'s kid - {name}</p></tpl>',
                    '</tpl></p>'
                );
                tpl.overwrite(p2.body, data);
                p2.body.highlight('#c3daf9', {block:true});
            }
        }],

        renderTo: document.body
    });
});