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
FeedViewer = {};

Ext.onReady(function(){
    Ext.QuickTips.init();

    Ext.state.Manager.setProvider(new Ext.state.SessionProvider({state: Ext.appState}));

    var tpl = Ext.Template.from('preview-tpl', {
        compiled:true,
        getBody : function(v, all){
            return Ext.util.Format.stripScripts(v || all.description);
        }
    });
    FeedViewer.getTemplate = function(){
        return tpl;
    }

    var feeds = new FeedPanel();
    var mainPanel = new MainPanel();

    feeds.on('feedselect', function(feed){
        mainPanel.loadFeed(feed);
    });
    
    var viewport = new Ext.Viewport({
        layout:'border',
        items:[
            new Ext.BoxComponent({ // raw element
                region:'north',
                el: 'header',
                height:32
            }),
            feeds,
            mainPanel
         ]
    });
    
    // add some default feeds
    feeds.addFeed({
        url:'http://feeds.feedburner.com/extblog',
        text: 'ExtJS.com Blog'
    }, false, true);

    feeds.addFeed({
        url:'http://extjs.com/forum/external.php?type=RSS2',
        text: 'ExtJS.com Forums'
    }, true);

    feeds.addFeed({
        url:'http://feeds.feedburner.com/ajaxian',
        text: 'Ajaxian'
    }, true);
    
    Ext.get('header').on('click', function() {
        viewport.focus();
    });
    
    feeds.focus();
});

// This is a custom event handler passed to preview panels so link open in a new windw
FeedViewer.LinkInterceptor = {
    render: function(p){
        p.body.on({
            'mousedown': function(e, t){ // try to intercept the easy way
                t.target = '_blank';
            },
            'click': function(e, t){ // if they tab + enter a link, need to do it old fashioned way
                if(String(t.target).toLowerCase() != '_blank'){
                    e.stopEvent();
                    window.open(t.href);
                }
            },
            delegate:'a'
        });
    }
};