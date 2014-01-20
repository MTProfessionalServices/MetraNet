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
(function(){
    var lasts = ['Jones', 'Smith', 'Lee', 'Wilson', 'Black', 'Williams', 'Lewis', 'Johnson', 'Foot', 'Little', 'Vee', 'Train', 'Hot', 'Mutt'];
    var firsts = ['Fred', 'Julie', 'Bill', 'Ted', 'Jack', 'John', 'Mark', 'Mike', 'Chris', 'Bob', 'Travis', 'Kelly', 'Sara'];
    var lastLen = lasts.length, firstLen = firsts.length;

    Ext.ux.getRandomInt = function(min, max){
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    Ext.ux.generateName = function(){
        var name = firsts[Ext.ux.getRandomInt(0, firstLen-1)] + ' ' + lasts[Ext.ux.getRandomInt(0, lastLen-1)];
        if(Ext.ux.generateName.usedNames[name]){
            return Ext.ux.generateName();
        }
        Ext.ux.generateName.usedNames[name] = true;
        return name;
    }
    Ext.ux.generateName.usedNames = {};

})();
