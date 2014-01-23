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
Ext.data.JsonP.Ext_WindowMgr({"alternateClassNames":[],"aliases":{},"enum":null,"parentMixins":[],"tagname":"class","subclasses":[],"extends":"Ext.WindowGroup","uses":[],"html":"<div><pre class=\"hierarchy\"><h4>Hierarchy</h4><div class='subclass first-child'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='docClass'>Ext.WindowGroup</a><div class='subclass '><strong>Ext.WindowMgr</strong></div></div><h4>Files</h4><div class='dependency'><a href='source/WindowManager.html#Ext-WindowMgr' target='_blank'>WindowManager.js</a></div></pre><div class='doc-contents'><p>The default global window group that is available automatically.  To have more than one group of windows\nwith separate z-order stacks, create additional instances of <a href=\"#!/api/Ext.WindowGroup\" rel=\"Ext.WindowGroup\" class=\"docClass\">Ext.WindowGroup</a> as needed.</p>\n</div><div class='members'><div class='members-section'><div class='definedBy'>Defined By</div><h3 class='members-title icon-property'>Properties</h3><div class='subsection'><div id='property-zseed' class='member first-child inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-property-zseed' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-property-zseed' class='name expandable'>zseed</a><span> : <a href=\"#!/api/Number\" rel=\"Number\" class=\"docClass\">Number</a></span></div><div class='description'><div class='short'>The starting z-index for windows in this WindowGroup (defaults to 9000) The z-index value ...</div><div class='long'><p>The starting z-index for windows in this WindowGroup (defaults to 9000) The z-index value</p>\n<p>Defaults to: <code>9000</code></p></div></div></div></div></div><div class='members-section'><div class='definedBy'>Defined By</div><h3 class='members-title icon-method'>Methods</h3><div class='subsection'><div id='method-constructor' class='member first-child inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-constructor' target='_blank' class='view-source'>view source</a></div><strong class='new-keyword'>new</strong><a href='#!/api/Ext.WindowGroup-method-constructor' class='name expandable'>Ext.WindowMgr</a>( <span class='pre'></span> ) : <a href=\"#!/api/Ext.WindowGroup\" rel=\"Ext.WindowGroup\" class=\"docClass\">Ext.WindowGroup</a></div><div class='description'><div class='short'> ...</div><div class='long'>\n<h3 class='pa'>Returns</h3><ul><li><span class='pre'><a href=\"#!/api/Ext.WindowGroup\" rel=\"Ext.WindowGroup\" class=\"docClass\">Ext.WindowGroup</a></span><div class='sub-desc'>\n</div></li></ul></div></div></div><div id='method-bringToFront' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-bringToFront' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-bringToFront' class='name expandable'>bringToFront</a>( <span class='pre'>win</span> ) : Boolean</div><div class='description'><div class='short'>Brings the specified window to the front of any other active windows in this WindowGroup. ...</div><div class='long'><p>Brings the specified window to the front of any other active windows in this WindowGroup.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>win</span> : <a href=\"#!/api/String\" rel=\"String\" class=\"docClass\">String</a>/Object<div class='sub-desc'><p>The id of the window or a <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a> instance</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'>Boolean</span><div class='sub-desc'><p>True if the dialog was brought to the front, else false\nif it was already in front</p>\n</div></li></ul></div></div></div><div id='method-each' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-each' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-each' class='name expandable'>each</a>( <span class='pre'>fn, [scope]</span> )</div><div class='description'><div class='short'>Executes the specified function once for every window in this WindowGroup, passing each\nwindow as the only parameter. ...</div><div class='long'><p>Executes the specified function once for every window in this WindowGroup, passing each\nwindow as the only parameter. Returning false from the function will stop the iteration.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>fn</span> : <a href=\"#!/api/Function\" rel=\"Function\" class=\"docClass\">Function</a><div class='sub-desc'><p>The function to execute for each item</p>\n</div></li><li><span class='pre'>scope</span> : Object (optional)<div class='sub-desc'><p>The scope (<code>this</code> reference) in which the function is executed. Defaults to the current Window in the iteration.</p>\n</div></li></ul></div></div></div><div id='method-get' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-get' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-get' class='name expandable'>get</a>( <span class='pre'>id</span> ) : <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a></div><div class='description'><div class='short'>Gets a registered window by id. ...</div><div class='long'><p>Gets a registered window by id.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>id</span> : <a href=\"#!/api/String\" rel=\"String\" class=\"docClass\">String</a>/Object<div class='sub-desc'><p>The id of the window or a <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a> instance</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'><a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a></span><div class='sub-desc'>\n</div></li></ul></div></div></div><div id='method-getActive' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-getActive' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-getActive' class='name expandable'>getActive</a>( <span class='pre'></span> ) : <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a></div><div class='description'><div class='short'>Gets the currently-active window in this WindowGroup. ...</div><div class='long'><p>Gets the currently-active window in this WindowGroup.</p>\n<h3 class='pa'>Returns</h3><ul><li><span class='pre'><a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a></span><div class='sub-desc'><p>The active window</p>\n</div></li></ul></div></div></div><div id='method-getBy' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-getBy' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-getBy' class='name expandable'>getBy</a>( <span class='pre'>fn, [scope]</span> ) : <a href=\"#!/api/Array\" rel=\"Array\" class=\"docClass\">Array</a></div><div class='description'><div class='short'>Returns zero or more windows in this WindowGroup using the custom search function passed to this method. ...</div><div class='long'><p>Returns zero or more windows in this WindowGroup using the custom search function passed to this method.\nThe function should accept a single <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a> reference as its only argument and should\nreturn true if the window matches the search criteria, otherwise it should return false.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>fn</span> : <a href=\"#!/api/Function\" rel=\"Function\" class=\"docClass\">Function</a><div class='sub-desc'><p>The search function</p>\n</div></li><li><span class='pre'>scope</span> : Object (optional)<div class='sub-desc'><p>The scope (<code>this</code> reference) in which the function is executed. Defaults to the Window being tested.\nthat gets passed to the function if not specified)</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'><a href=\"#!/api/Array\" rel=\"Array\" class=\"docClass\">Array</a></span><div class='sub-desc'><p>An array of zero or more matching windows</p>\n</div></li></ul></div></div></div><div id='method-hideAll' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-hideAll' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-hideAll' class='name expandable'>hideAll</a>( <span class='pre'></span> )</div><div class='description'><div class='short'>Hides all windows in this WindowGroup. ...</div><div class='long'><p>Hides all windows in this WindowGroup.</p>\n</div></div></div><div id='method-register' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-register' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-register' class='name expandable'>register</a>( <span class='pre'>win</span> )</div><div class='description'><div class='short'>Registers a Window with this WindowManager. ...</div><div class='long'><p>Registers a <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Window</a> with this WindowManager. This should not\nneed to be called under normal circumstances. Windows are automatically registered\nwith a <a href=\"#!/api/Ext.Window-cfg-manager\" rel=\"Ext.Window-cfg-manager\" class=\"docClass\">manager</a> at construction time.</p>\n\n\n<p>Where this may be useful is moving Windows between two WindowManagers. For example,\nto bring the <a href=\"#!/api/Ext.MessageBox\" rel=\"Ext.MessageBox\" class=\"docClass\">Ext.MessageBox</a> dialog under the same manager as the Desktop's\nWindowManager in the desktop sample app:</p>\n\n\n<p><code></p>\n\n<pre>var msgWin = <a href=\"#!/api/Ext.MessageBox-method-getDialog\" rel=\"Ext.MessageBox-method-getDialog\" class=\"docClass\">Ext.MessageBox.getDialog</a>();\nMyDesktop.getDesktop().getManager().register(msgWin);\n</pre>\n\n\n<p></code></p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>win</span> : Window<div class='sub-desc'><p>The Window to register.</p>\n</div></li></ul></div></div></div><div id='method-sendToBack' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-sendToBack' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-sendToBack' class='name expandable'>sendToBack</a>( <span class='pre'>win</span> ) : <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a></div><div class='description'><div class='short'>Sends the specified window to the back of other active windows in this WindowGroup. ...</div><div class='long'><p>Sends the specified window to the back of other active windows in this WindowGroup.</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>win</span> : <a href=\"#!/api/String\" rel=\"String\" class=\"docClass\">String</a>/Object<div class='sub-desc'><p>The id of the window or a <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a> instance</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'><a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Ext.Window</a></span><div class='sub-desc'><p>The window</p>\n</div></li></ul></div></div></div><div id='method-unregister' class='member  inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><a href='#!/api/Ext.WindowGroup' rel='Ext.WindowGroup' class='defined-in docClass'>Ext.WindowGroup</a><br/><a href='source/WindowManager.html#Ext-WindowGroup-method-unregister' target='_blank' class='view-source'>view source</a></div><a href='#!/api/Ext.WindowGroup-method-unregister' class='name expandable'>unregister</a>( <span class='pre'>win</span> )</div><div class='description'><div class='short'>Unregisters a Window from this WindowManager. ...</div><div class='long'><p>Unregisters a <a href=\"#!/api/Ext.Window\" rel=\"Ext.Window\" class=\"docClass\">Window</a> from this WindowManager. This should not\nneed to be called. Windows are automatically unregistered upon destruction.\nSee <a href=\"#!/api/Ext.WindowGroup-method-register\" rel=\"Ext.WindowGroup-method-register\" class=\"docClass\">register</a>.</p>\n\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>win</span> : Window<div class='sub-desc'><p>The Window to unregister.</p>\n</div></li></ul></div></div></div></div></div></div></div>","superclasses":["Ext.WindowGroup"],"meta":{},"requires":[],"html_meta":{},"statics":{"property":[],"cfg":[],"css_var":[],"method":[],"event":[],"css_mixin":[]},"files":[{"href":"WindowManager.html#Ext-WindowMgr","filename":"WindowManager.js"}],"linenr":196,"members":{"property":[{"tagname":"property","owner":"Ext.WindowGroup","meta":{},"name":"zseed","id":"property-zseed"}],"cfg":[],"css_var":[],"method":[{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"constructor","id":"method-constructor"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"bringToFront","id":"method-bringToFront"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"each","id":"method-each"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"get","id":"method-get"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"getActive","id":"method-getActive"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"getBy","id":"method-getBy"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"hideAll","id":"method-hideAll"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"register","id":"method-register"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"sendToBack","id":"method-sendToBack"},{"tagname":"method","owner":"Ext.WindowGroup","meta":{},"name":"unregister","id":"method-unregister"}],"event":[],"css_mixin":[]},"inheritable":null,"private":null,"component":false,"name":"Ext.WindowMgr","singleton":true,"override":null,"inheritdoc":null,"id":"class-Ext.WindowMgr","mixins":[],"mixedInto":[]});