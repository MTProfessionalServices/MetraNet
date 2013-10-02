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
 * Plugin for PagingToolbar which replaces the textfield input with a slider 
 */
Ext.ux.SlidingPager = Ext.extend(Object, {
    init : function(pbar){
        var idx = pbar.items.indexOf(pbar.inputItem);
        Ext.each(pbar.items.getRange(idx - 2, idx + 2), function(c){
            c.hide();
        });
        var slider = new Ext.Slider({
            width: 114,
            minValue: 1,
            maxValue: 1,
            plugins: new Ext.slider.Tip({
                getText : function(thumb) {
                    return String.format('Page <b>{0}</b> of <b>{1}</b>', thumb.value, thumb.slider.maxValue);
                }
            }),
            listeners: {
                changecomplete: function(s, v){
                    pbar.changePage(v);
                }
            }
        });
        pbar.insert(idx + 1, slider);
        pbar.on({
            change: function(pb, data){
                slider.setMaxValue(data.pages);
                slider.setValue(data.activePage);
            }
        });
    }
});