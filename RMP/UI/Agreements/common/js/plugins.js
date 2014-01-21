/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Javascript Plugins - Metanga Web Application
    Concatenated plugins to be included globally.

Author: Above The Fold, LLC - http://www.abovethefolddesign.com

Table of Contents
    Note: Equals signs (=) are search flags
-----------------------------------------------------------
	=jQuery UI
	=Cookie
	=Equal Height Columns
	=DataTables
	=DataTables Extras
	=ShowHide
	=Multiselect
	=Validate
	=Reveal Modal
	=BlockUI
	=TextFill
	=Placeholder
	=jCarousel
	=Tooltip
	=SuperToggle
  =Hovermenu
  =Timeline
  =Dropdown Menu
	=End
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=jQuery UI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*! jQuery UI - v1.9.2 - 2012-11-23
* http://jqueryui.com
* Includes: jquery.ui.core.js, jquery.ui.widget.js, jquery.ui.mouse.js, jquery.ui.position.js, jquery.ui.accordion.js, jquery.ui.autocomplete.js, jquery.ui.button.js, jquery.ui.datepicker.js, jquery.ui.dialog.js, jquery.ui.draggable.js, jquery.ui.droppable.js, jquery.ui.effect.js, jquery.ui.effect-blind.js, jquery.ui.effect-bounce.js, jquery.ui.effect-clip.js, jquery.ui.effect-drop.js, jquery.ui.effect-explode.js, jquery.ui.effect-fade.js, jquery.ui.effect-fold.js, jquery.ui.effect-highlight.js, jquery.ui.effect-pulsate.js, jquery.ui.effect-scale.js, jquery.ui.effect-shake.js, jquery.ui.effect-slide.js, jquery.ui.effect-transfer.js, jquery.ui.menu.js, jquery.ui.progressbar.js, jquery.ui.resizable.js, jquery.ui.selectable.js, jquery.ui.slider.js, jquery.ui.sortable.js, jquery.ui.spinner.js, jquery.ui.tabs.js, jquery.ui.tooltip.js
* Copyright (c) 2012 jQuery Foundation and other contributors Licensed MIT */

(function(e,t){function i(t,n){var r,i,o,u=t.nodeName.toLowerCase();return"area"===u?(r=t.parentNode,i=r.name,!t.href||!i||r.nodeName.toLowerCase()!=="map"?!1:(o=e("img[usemap=#"+i+"]")[0],!!o&&s(o))):(/input|select|textarea|button|object/.test(u)?!t.disabled:"a"===u?t.href||n:n)&&s(t)}function s(t){return e.expr.filters.visible(t)&&!e(t).parents().andSelf().filter(function(){return e.css(this,"visibility")==="hidden"}).length}var n=0,r=/^ui-id-\d+$/;e.ui=e.ui||{};if(e.ui.version)return;e.extend(e.ui,{version:"1.9.2",keyCode:{BACKSPACE:8,COMMA:188,DELETE:46,DOWN:40,END:35,ENTER:13,ESCAPE:27,HOME:36,LEFT:37,NUMPAD_ADD:107,NUMPAD_DECIMAL:110,NUMPAD_DIVIDE:111,NUMPAD_ENTER:108,NUMPAD_MULTIPLY:106,NUMPAD_SUBTRACT:109,PAGE_DOWN:34,PAGE_UP:33,PERIOD:190,RIGHT:39,SPACE:32,TAB:9,UP:38}}),e.fn.extend({_focus:e.fn.focus,focus:function(t,n){return typeof t=="number"?this.each(function(){var r=this;setTimeout(function(){e(r).focus(),n&&n.call(r)},t)}):this._focus.apply(this,arguments)},scrollParent:function(){var t;return e.ui.ie&&/(static|relative)/.test(this.css("position"))||/absolute/.test(this.css("position"))?t=this.parents().filter(function(){return/(relative|absolute|fixed)/.test(e.css(this,"position"))&&/(auto|scroll)/.test(e.css(this,"overflow")+e.css(this,"overflow-y")+e.css(this,"overflow-x"))}).eq(0):t=this.parents().filter(function(){return/(auto|scroll)/.test(e.css(this,"overflow")+e.css(this,"overflow-y")+e.css(this,"overflow-x"))}).eq(0),/fixed/.test(this.css("position"))||!t.length?e(document):t},zIndex:function(n){if(n!==t)return this.css("zIndex",n);if(this.length){var r=e(this[0]),i,s;while(r.length&&r[0]!==document){i=r.css("position");if(i==="absolute"||i==="relative"||i==="fixed"){s=parseInt(r.css("zIndex"),10);if(!isNaN(s)&&s!==0)return s}r=r.parent()}}return 0},uniqueId:function(){return this.each(function(){this.id||(this.id="ui-id-"+ ++n)})},removeUniqueId:function(){return this.each(function(){r.test(this.id)&&e(this).removeAttr("id")})}}),e.extend(e.expr[":"],{data:e.expr.createPseudo?e.expr.createPseudo(function(t){return function(n){return!!e.data(n,t)}}):function(t,n,r){return!!e.data(t,r[3])},focusable:function(t){return i(t,!isNaN(e.attr(t,"tabindex")))},tabbable:function(t){var n=e.attr(t,"tabindex"),r=isNaN(n);return(r||n>=0)&&i(t,!r)}}),e(function(){var t=document.body,n=t.appendChild(n=document.createElement("div"));n.offsetHeight,e.extend(n.style,{minHeight:"100px",height:"auto",padding:0,borderWidth:0}),e.support.minHeight=n.offsetHeight===100,e.support.selectstart="onselectstart"in n,t.removeChild(n).style.display="none"}),e("<a>").outerWidth(1).jquery||e.each(["Width","Height"],function(n,r){function u(t,n,r,s){return e.each(i,function(){n-=parseFloat(e.css(t,"padding"+this))||0,r&&(n-=parseFloat(e.css(t,"border"+this+"Width"))||0),s&&(n-=parseFloat(e.css(t,"margin"+this))||0)}),n}var i=r==="Width"?["Left","Right"]:["Top","Bottom"],s=r.toLowerCase(),o={innerWidth:e.fn.innerWidth,innerHeight:e.fn.innerHeight,outerWidth:e.fn.outerWidth,outerHeight:e.fn.outerHeight};e.fn["inner"+r]=function(n){return n===t?o["inner"+r].call(this):this.each(function(){e(this).css(s,u(this,n)+"px")})},e.fn["outer"+r]=function(t,n){return typeof t!="number"?o["outer"+r].call(this,t):this.each(function(){e(this).css(s,u(this,t,!0,n)+"px")})}}),e("<a>").data("a-b","a").removeData("a-b").data("a-b")&&(e.fn.removeData=function(t){return function(n){return arguments.length?t.call(this,e.camelCase(n)):t.call(this)}}(e.fn.removeData)),function(){var t=/msie ([\w.]+)/.exec(navigator.userAgent.toLowerCase())||[];e.ui.ie=t.length?!0:!1,e.ui.ie6=parseFloat(t[1],10)===6}(),e.fn.extend({disableSelection:function(){return this.bind((e.support.selectstart?"selectstart":"mousedown")+".ui-disableSelection",function(e){e.preventDefault()})},enableSelection:function(){return this.unbind(".ui-disableSelection")}}),e.extend(e.ui,{plugin:{add:function(t,n,r){var i,s=e.ui[t].prototype;for(i in r)s.plugins[i]=s.plugins[i]||[],s.plugins[i].push([n,r[i]])},call:function(e,t,n){var r,i=e.plugins[t];if(!i||!e.element[0].parentNode||e.element[0].parentNode.nodeType===11)return;for(r=0;r<i.length;r++)e.options[i[r][0]]&&i[r][1].apply(e.element,n)}},contains:e.contains,hasScroll:function(t,n){if(e(t).css("overflow")==="hidden")return!1;var r=n&&n==="left"?"scrollLeft":"scrollTop",i=!1;return t[r]>0?!0:(t[r]=1,i=t[r]>0,t[r]=0,i)},isOverAxis:function(e,t,n){return e>t&&e<t+n},isOver:function(t,n,r,i,s,o){return e.ui.isOverAxis(t,r,s)&&e.ui.isOverAxis(n,i,o)}})})(jQuery);(function(e,t){var n=0,r=Array.prototype.slice,i=e.cleanData;e.cleanData=function(t){for(var n=0,r;(r=t[n])!=null;n++)try{e(r).triggerHandler("remove")}catch(s){}i(t)},e.widget=function(t,n,r){var i,s,o,u,a=t.split(".")[0];t=t.split(".")[1],i=a+"-"+t,r||(r=n,n=e.Widget),e.expr[":"][i.toLowerCase()]=function(t){return!!e.data(t,i)},e[a]=e[a]||{},s=e[a][t],o=e[a][t]=function(e,t){if(!this._createWidget)return new o(e,t);arguments.length&&this._createWidget(e,t)},e.extend(o,s,{version:r.version,_proto:e.extend({},r),_childConstructors:[]}),u=new n,u.options=e.widget.extend({},u.options),e.each(r,function(t,i){e.isFunction(i)&&(r[t]=function(){var e=function(){return n.prototype[t].apply(this,arguments)},r=function(e){return n.prototype[t].apply(this,e)};return function(){var t=this._super,n=this._superApply,s;return this._super=e,this._superApply=r,s=i.apply(this,arguments),this._super=t,this._superApply=n,s}}())}),o.prototype=e.widget.extend(u,{widgetEventPrefix:s?u.widgetEventPrefix:t},r,{constructor:o,namespace:a,widgetName:t,widgetBaseClass:i,widgetFullName:i}),s?(e.each(s._childConstructors,function(t,n){var r=n.prototype;e.widget(r.namespace+"."+r.widgetName,o,n._proto)}),delete s._childConstructors):n._childConstructors.push(o),e.widget.bridge(t,o)},e.widget.extend=function(n){var i=r.call(arguments,1),s=0,o=i.length,u,a;for(;s<o;s++)for(u in i[s])a=i[s][u],i[s].hasOwnProperty(u)&&a!==t&&(e.isPlainObject(a)?n[u]=e.isPlainObject(n[u])?e.widget.extend({},n[u],a):e.widget.extend({},a):n[u]=a);return n},e.widget.bridge=function(n,i){var s=i.prototype.widgetFullName||n;e.fn[n]=function(o){var u=typeof o=="string",a=r.call(arguments,1),f=this;return o=!u&&a.length?e.widget.extend.apply(null,[o].concat(a)):o,u?this.each(function(){var r,i=e.data(this,s);if(!i)return e.error("cannot call methods on "+n+" prior to initialization; "+"attempted to call method '"+o+"'");if(!e.isFunction(i[o])||o.charAt(0)==="_")return e.error("no such method '"+o+"' for "+n+" widget instance");r=i[o].apply(i,a);if(r!==i&&r!==t)return f=r&&r.jquery?f.pushStack(r.get()):r,!1}):this.each(function(){var t=e.data(this,s);t?t.option(o||{})._init():e.data(this,s,new i(o,this))}),f}},e.Widget=function(){},e.Widget._childConstructors=[],e.Widget.prototype={widgetName:"widget",widgetEventPrefix:"",defaultElement:"<div>",options:{disabled:!1,create:null},_createWidget:function(t,r){r=e(r||this.defaultElement||this)[0],this.element=e(r),this.uuid=n++,this.eventNamespace="."+this.widgetName+this.uuid,this.options=e.widget.extend({},this.options,this._getCreateOptions(),t),this.bindings=e(),this.hoverable=e(),this.focusable=e(),r!==this&&(e.data(r,this.widgetName,this),e.data(r,this.widgetFullName,this),this._on(!0,this.element,{remove:function(e){e.target===r&&this.destroy()}}),this.document=e(r.style?r.ownerDocument:r.document||r),this.window=e(this.document[0].defaultView||this.document[0].parentWindow)),this._create(),this._trigger("create",null,this._getCreateEventData()),this._init()},_getCreateOptions:e.noop,_getCreateEventData:e.noop,_create:e.noop,_init:e.noop,destroy:function(){this._destroy(),this.element.unbind(this.eventNamespace).removeData(this.widgetName).removeData(this.widgetFullName).removeData(e.camelCase(this.widgetFullName)),this.widget().unbind(this.eventNamespace).removeAttr("aria-disabled").removeClass(this.widgetFullName+"-disabled "+"ui-state-disabled"),this.bindings.unbind(this.eventNamespace),this.hoverable.removeClass("ui-state-hover"),this.focusable.removeClass("ui-state-focus")},_destroy:e.noop,widget:function(){return this.element},option:function(n,r){var i=n,s,o,u;if(arguments.length===0)return e.widget.extend({},this.options);if(typeof n=="string"){i={},s=n.split("."),n=s.shift();if(s.length){o=i[n]=e.widget.extend({},this.options[n]);for(u=0;u<s.length-1;u++)o[s[u]]=o[s[u]]||{},o=o[s[u]];n=s.pop();if(r===t)return o[n]===t?null:o[n];o[n]=r}else{if(r===t)return this.options[n]===t?null:this.options[n];i[n]=r}}return this._setOptions(i),this},_setOptions:function(e){var t;for(t in e)this._setOption(t,e[t]);return this},_setOption:function(e,t){return this.options[e]=t,e==="disabled"&&(this.widget().toggleClass(this.widgetFullName+"-disabled ui-state-disabled",!!t).attr("aria-disabled",t),this.hoverable.removeClass("ui-state-hover"),this.focusable.removeClass("ui-state-focus")),this},enable:function(){return this._setOption("disabled",!1)},disable:function(){return this._setOption("disabled",!0)},_on:function(t,n,r){var i,s=this;typeof t!="boolean"&&(r=n,n=t,t=!1),r?(n=i=e(n),this.bindings=this.bindings.add(n)):(r=n,n=this.element,i=this.widget()),e.each(r,function(r,o){function u(){if(!t&&(s.options.disabled===!0||e(this).hasClass("ui-state-disabled")))return;return(typeof o=="string"?s[o]:o).apply(s,arguments)}typeof o!="string"&&(u.guid=o.guid=o.guid||u.guid||e.guid++);var a=r.match(/^(\w+)\s*(.*)$/),f=a[1]+s.eventNamespace,l=a[2];l?i.delegate(l,f,u):n.bind(f,u)})},_off:function(e,t){t=(t||"").split(" ").join(this.eventNamespace+" ")+this.eventNamespace,e.unbind(t).undelegate(t)},_delay:function(e,t){function n(){return(typeof e=="string"?r[e]:e).apply(r,arguments)}var r=this;return setTimeout(n,t||0)},_hoverable:function(t){this.hoverable=this.hoverable.add(t),this._on(t,{mouseenter:function(t){e(t.currentTarget).addClass("ui-state-hover")},mouseleave:function(t){e(t.currentTarget).removeClass("ui-state-hover")}})},_focusable:function(t){this.focusable=this.focusable.add(t),this._on(t,{focusin:function(t){e(t.currentTarget).addClass("ui-state-focus")},focusout:function(t){e(t.currentTarget).removeClass("ui-state-focus")}})},_trigger:function(t,n,r){var i,s,o=this.options[t];r=r||{},n=e.Event(n),n.type=(t===this.widgetEventPrefix?t:this.widgetEventPrefix+t).toLowerCase(),n.target=this.element[0],s=n.originalEvent;if(s)for(i in s)i in n||(n[i]=s[i]);return this.element.trigger(n,r),!(e.isFunction(o)&&o.apply(this.element[0],[n].concat(r))===!1||n.isDefaultPrevented())}},e.each({show:"fadeIn",hide:"fadeOut"},function(t,n){e.Widget.prototype["_"+t]=function(r,i,s){typeof i=="string"&&(i={effect:i});var o,u=i?i===!0||typeof i=="number"?n:i.effect||n:t;i=i||{},typeof i=="number"&&(i={duration:i}),o=!e.isEmptyObject(i),i.complete=s,i.delay&&r.delay(i.delay),o&&e.effects&&(e.effects.effect[u]||e.uiBackCompat!==!1&&e.effects[u])?r[t](i):u!==t&&r[u]?r[u](i.duration,i.easing,s):r.queue(function(n){e(this)[t](),s&&s.call(r[0]),n()})}}),e.uiBackCompat!==!1&&(e.Widget.prototype._getCreateOptions=function(){return e.metadata&&e.metadata.get(this.element[0])[this.widgetName]})})(jQuery);(function(e,t){var n=!1;e(document).mouseup(function(e){n=!1}),e.widget("ui.mouse",{version:"1.9.2",options:{cancel:"input,textarea,button,select,option",distance:1,delay:0},_mouseInit:function(){var t=this;this.element.bind("mousedown."+this.widgetName,function(e){return t._mouseDown(e)}).bind("click."+this.widgetName,function(n){if(!0===e.data(n.target,t.widgetName+".preventClickEvent"))return e.removeData(n.target,t.widgetName+".preventClickEvent"),n.stopImmediatePropagation(),!1}),this.started=!1},_mouseDestroy:function(){this.element.unbind("."+this.widgetName),this._mouseMoveDelegate&&e(document).unbind("mousemove."+this.widgetName,this._mouseMoveDelegate).unbind("mouseup."+this.widgetName,this._mouseUpDelegate)},_mouseDown:function(t){if(n)return;this._mouseStarted&&this._mouseUp(t),this._mouseDownEvent=t;var r=this,i=t.which===1,s=typeof this.options.cancel=="string"&&t.target.nodeName?e(t.target).closest(this.options.cancel).length:!1;if(!i||s||!this._mouseCapture(t))return!0;this.mouseDelayMet=!this.options.delay,this.mouseDelayMet||(this._mouseDelayTimer=setTimeout(function(){r.mouseDelayMet=!0},this.options.delay));if(this._mouseDistanceMet(t)&&this._mouseDelayMet(t)){this._mouseStarted=this._mouseStart(t)!==!1;if(!this._mouseStarted)return t.preventDefault(),!0}return!0===e.data(t.target,this.widgetName+".preventClickEvent")&&e.removeData(t.target,this.widgetName+".preventClickEvent"),this._mouseMoveDelegate=function(e){return r._mouseMove(e)},this._mouseUpDelegate=function(e){return r._mouseUp(e)},e(document).bind("mousemove."+this.widgetName,this._mouseMoveDelegate).bind("mouseup."+this.widgetName,this._mouseUpDelegate),t.preventDefault(),n=!0,!0},_mouseMove:function(t){return!e.ui.ie||document.documentMode>=9||!!t.button?this._mouseStarted?(this._mouseDrag(t),t.preventDefault()):(this._mouseDistanceMet(t)&&this._mouseDelayMet(t)&&(this._mouseStarted=this._mouseStart(this._mouseDownEvent,t)!==!1,this._mouseStarted?this._mouseDrag(t):this._mouseUp(t)),!this._mouseStarted):this._mouseUp(t)},_mouseUp:function(t){return e(document).unbind("mousemove."+this.widgetName,this._mouseMoveDelegate).unbind("mouseup."+this.widgetName,this._mouseUpDelegate),this._mouseStarted&&(this._mouseStarted=!1,t.target===this._mouseDownEvent.target&&e.data(t.target,this.widgetName+".preventClickEvent",!0),this._mouseStop(t)),!1},_mouseDistanceMet:function(e){return Math.max(Math.abs(this._mouseDownEvent.pageX-e.pageX),Math.abs(this._mouseDownEvent.pageY-e.pageY))>=this.options.distance},_mouseDelayMet:function(e){return this.mouseDelayMet},_mouseStart:function(e){},_mouseDrag:function(e){},_mouseStop:function(e){},_mouseCapture:function(e){return!0}})})(jQuery);(function(e,t){function h(e,t,n){return[parseInt(e[0],10)*(l.test(e[0])?t/100:1),parseInt(e[1],10)*(l.test(e[1])?n/100:1)]}function p(t,n){return parseInt(e.css(t,n),10)||0}e.ui=e.ui||{};var n,r=Math.max,i=Math.abs,s=Math.round,o=/left|center|right/,u=/top|center|bottom/,a=/[\+\-]\d+%?/,f=/^\w+/,l=/%$/,c=e.fn.position;e.position={scrollbarWidth:function(){if(n!==t)return n;var r,i,s=e("<div style='display:block;width:50px;height:50px;overflow:hidden;'><div style='height:100px;width:auto;'></div></div>"),o=s.children()[0];return e("body").append(s),r=o.offsetWidth,s.css("overflow","scroll"),i=o.offsetWidth,r===i&&(i=s[0].clientWidth),s.remove(),n=r-i},getScrollInfo:function(t){var n=t.isWindow?"":t.element.css("overflow-x"),r=t.isWindow?"":t.element.css("overflow-y"),i=n==="scroll"||n==="auto"&&t.width<t.element[0].scrollWidth,s=r==="scroll"||r==="auto"&&t.height<t.element[0].scrollHeight;return{width:i?e.position.scrollbarWidth():0,height:s?e.position.scrollbarWidth():0}},getWithinInfo:function(t){var n=e(t||window),r=e.isWindow(n[0]);return{element:n,isWindow:r,offset:n.offset()||{left:0,top:0},scrollLeft:n.scrollLeft(),scrollTop:n.scrollTop(),width:r?n.width():n.outerWidth(),height:r?n.height():n.outerHeight()}}},e.fn.position=function(t){if(!t||!t.of)return c.apply(this,arguments);t=e.extend({},t);var n,l,d,v,m,g=e(t.of),y=e.position.getWithinInfo(t.within),b=e.position.getScrollInfo(y),w=g[0],E=(t.collision||"flip").split(" "),S={};return w.nodeType===9?(l=g.width(),d=g.height(),v={top:0,left:0}):e.isWindow(w)?(l=g.width(),d=g.height(),v={top:g.scrollTop(),left:g.scrollLeft()}):w.preventDefault?(t.at="left top",l=d=0,v={top:w.pageY,left:w.pageX}):(l=g.outerWidth(),d=g.outerHeight(),v=g.offset()),m=e.extend({},v),e.each(["my","at"],function(){var e=(t[this]||"").split(" "),n,r;e.length===1&&(e=o.test(e[0])?e.concat(["center"]):u.test(e[0])?["center"].concat(e):["center","center"]),e[0]=o.test(e[0])?e[0]:"center",e[1]=u.test(e[1])?e[1]:"center",n=a.exec(e[0]),r=a.exec(e[1]),S[this]=[n?n[0]:0,r?r[0]:0],t[this]=[f.exec(e[0])[0],f.exec(e[1])[0]]}),E.length===1&&(E[1]=E[0]),t.at[0]==="right"?m.left+=l:t.at[0]==="center"&&(m.left+=l/2),t.at[1]==="bottom"?m.top+=d:t.at[1]==="center"&&(m.top+=d/2),n=h(S.at,l,d),m.left+=n[0],m.top+=n[1],this.each(function(){var o,u,a=e(this),f=a.outerWidth(),c=a.outerHeight(),w=p(this,"marginLeft"),x=p(this,"marginTop"),T=f+w+p(this,"marginRight")+b.width,N=c+x+p(this,"marginBottom")+b.height,C=e.extend({},m),k=h(S.my,a.outerWidth(),a.outerHeight());t.my[0]==="right"?C.left-=f:t.my[0]==="center"&&(C.left-=f/2),t.my[1]==="bottom"?C.top-=c:t.my[1]==="center"&&(C.top-=c/2),C.left+=k[0],C.top+=k[1],e.support.offsetFractions||(C.left=s(C.left),C.top=s(C.top)),o={marginLeft:w,marginTop:x},e.each(["left","top"],function(r,i){e.ui.position[E[r]]&&e.ui.position[E[r]][i](C,{targetWidth:l,targetHeight:d,elemWidth:f,elemHeight:c,collisionPosition:o,collisionWidth:T,collisionHeight:N,offset:[n[0]+k[0],n[1]+k[1]],my:t.my,at:t.at,within:y,elem:a})}),e.fn.bgiframe&&a.bgiframe(),t.using&&(u=function(e){var n=v.left-C.left,s=n+l-f,o=v.top-C.top,u=o+d-c,h={target:{element:g,left:v.left,top:v.top,width:l,height:d},element:{element:a,left:C.left,top:C.top,width:f,height:c},horizontal:s<0?"left":n>0?"right":"center",vertical:u<0?"top":o>0?"bottom":"middle"};l<f&&i(n+s)<l&&(h.horizontal="center"),d<c&&i(o+u)<d&&(h.vertical="middle"),r(i(n),i(s))>r(i(o),i(u))?h.important="horizontal":h.important="vertical",t.using.call(this,e,h)}),a.offset(e.extend(C,{using:u}))})},e.ui.position={fit:{left:function(e,t){var n=t.within,i=n.isWindow?n.scrollLeft:n.offset.left,s=n.width,o=e.left-t.collisionPosition.marginLeft,u=i-o,a=o+t.collisionWidth-s-i,f;t.collisionWidth>s?u>0&&a<=0?(f=e.left+u+t.collisionWidth-s-i,e.left+=u-f):a>0&&u<=0?e.left=i:u>a?e.left=i+s-t.collisionWidth:e.left=i:u>0?e.left+=u:a>0?e.left-=a:e.left=r(e.left-o,e.left)},top:function(e,t){var n=t.within,i=n.isWindow?n.scrollTop:n.offset.top,s=t.within.height,o=e.top-t.collisionPosition.marginTop,u=i-o,a=o+t.collisionHeight-s-i,f;t.collisionHeight>s?u>0&&a<=0?(f=e.top+u+t.collisionHeight-s-i,e.top+=u-f):a>0&&u<=0?e.top=i:u>a?e.top=i+s-t.collisionHeight:e.top=i:u>0?e.top+=u:a>0?e.top-=a:e.top=r(e.top-o,e.top)}},flip:{left:function(e,t){var n=t.within,r=n.offset.left+n.scrollLeft,s=n.width,o=n.isWindow?n.scrollLeft:n.offset.left,u=e.left-t.collisionPosition.marginLeft,a=u-o,f=u+t.collisionWidth-s-o,l=t.my[0]==="left"?-t.elemWidth:t.my[0]==="right"?t.elemWidth:0,c=t.at[0]==="left"?t.targetWidth:t.at[0]==="right"?-t.targetWidth:0,h=-2*t.offset[0],p,d;if(a<0){p=e.left+l+c+h+t.collisionWidth-s-r;if(p<0||p<i(a))e.left+=l+c+h}else if(f>0){d=e.left-t.collisionPosition.marginLeft+l+c+h-o;if(d>0||i(d)<f)e.left+=l+c+h}},top:function(e,t){var n=t.within,r=n.offset.top+n.scrollTop,s=n.height,o=n.isWindow?n.scrollTop:n.offset.top,u=e.top-t.collisionPosition.marginTop,a=u-o,f=u+t.collisionHeight-s-o,l=t.my[1]==="top",c=l?-t.elemHeight:t.my[1]==="bottom"?t.elemHeight:0,h=t.at[1]==="top"?t.targetHeight:t.at[1]==="bottom"?-t.targetHeight:0,p=-2*t.offset[1],d,v;a<0?(v=e.top+c+h+p+t.collisionHeight-s-r,e.top+c+h+p>a&&(v<0||v<i(a))&&(e.top+=c+h+p)):f>0&&(d=e.top-t.collisionPosition.marginTop+c+h+p-o,e.top+c+h+p>f&&(d>0||i(d)<f)&&(e.top+=c+h+p))}},flipfit:{left:function(){e.ui.position.flip.left.apply(this,arguments),e.ui.position.fit.left.apply(this,arguments)},top:function(){e.ui.position.flip.top.apply(this,arguments),e.ui.position.fit.top.apply(this,arguments)}}},function(){var t,n,r,i,s,o=document.getElementsByTagName("body")[0],u=document.createElement("div");t=document.createElement(o?"div":"body"),r={visibility:"hidden",width:0,height:0,border:0,margin:0,background:"none"},o&&e.extend(r,{position:"absolute",left:"-1000px",top:"-1000px"});for(s in r)t.style[s]=r[s];t.appendChild(u),n=o||document.documentElement,n.insertBefore(t,n.firstChild),u.style.cssText="position: absolute; left: 10.7432222px;",i=e(u).offset().left,e.support.offsetFractions=i>10&&i<11,t.innerHTML="",n.removeChild(t)}(),e.uiBackCompat!==!1&&function(e){var n=e.fn.position;e.fn.position=function(r){if(!r||!r.offset)return n.call(this,r);var i=r.offset.split(" "),s=r.at.split(" ");return i.length===1&&(i[1]=i[0]),/^\d/.test(i[0])&&(i[0]="+"+i[0]),/^\d/.test(i[1])&&(i[1]="+"+i[1]),s.length===1&&(/left|center|right/.test(s[0])?s[1]="center":(s[1]=s[0],s[0]="center")),n.call(this,e.extend(r,{at:s[0]+i[0]+" "+s[1]+i[1],offset:t}))}}(jQuery)})(jQuery);(function(e,t){var n=0,r={},i={};r.height=r.paddingTop=r.paddingBottom=r.borderTopWidth=r.borderBottomWidth="hide",i.height=i.paddingTop=i.paddingBottom=i.borderTopWidth=i.borderBottomWidth="show",e.widget("ui.accordion",{version:"1.9.2",options:{active:0,animate:{},collapsible:!1,event:"click",header:"> li > :first-child,> :not(li):even",heightStyle:"auto",icons:{activeHeader:"ui-icon-triangle-1-s",header:"ui-icon-triangle-1-e"},activate:null,beforeActivate:null},_create:function(){var t=this.accordionId="ui-accordion-"+(this.element.attr("id")||++n),r=this.options;this.prevShow=this.prevHide=e(),this.element.addClass("ui-accordion ui-widget ui-helper-reset"),this.headers=this.element.find(r.header).addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-all"),this._hoverable(this.headers),this._focusable(this.headers),this.headers.next().addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom").hide(),!r.collapsible&&(r.active===!1||r.active==null)&&(r.active=0),r.active<0&&(r.active+=this.headers.length),this.active=this._findActive(r.active).addClass("ui-accordion-header-active ui-state-active").toggleClass("ui-corner-all ui-corner-top"),this.active.next().addClass("ui-accordion-content-active").show(),this._createIcons(),this.refresh(),this.element.attr("role","tablist"),this.headers.attr("role","tab").each(function(n){var r=e(this),i=r.attr("id"),s=r.next(),o=s.attr("id");i||(i=t+"-header-"+n,r.attr("id",i)),o||(o=t+"-panel-"+n,s.attr("id",o)),r.attr("aria-controls",o),s.attr("aria-labelledby",i)}).next().attr("role","tabpanel"),this.headers.not(this.active).attr({"aria-selected":"false",tabIndex:-1}).next().attr({"aria-expanded":"false","aria-hidden":"true"}).hide(),this.active.length?this.active.attr({"aria-selected":"true",tabIndex:0}).next().attr({"aria-expanded":"true","aria-hidden":"false"}):this.headers.eq(0).attr("tabIndex",0),this._on(this.headers,{keydown:"_keydown"}),this._on(this.headers.next(),{keydown:"_panelKeyDown"}),this._setupEvents(r.event)},_getCreateEventData:function(){return{header:this.active,content:this.active.length?this.active.next():e()}},_createIcons:function(){var t=this.options.icons;t&&(e("<span>").addClass("ui-accordion-header-icon ui-icon "+t.header).prependTo(this.headers),this.active.children(".ui-accordion-header-icon").removeClass(t.header).addClass(t.activeHeader),this.headers.addClass("ui-accordion-icons"))},_destroyIcons:function(){this.headers.removeClass("ui-accordion-icons").children(".ui-accordion-header-icon").remove()},_destroy:function(){var e;this.element.removeClass("ui-accordion ui-widget ui-helper-reset").removeAttr("role"),this.headers.removeClass("ui-accordion-header ui-accordion-header-active ui-helper-reset ui-state-default ui-corner-all ui-state-active ui-state-disabled ui-corner-top").removeAttr("role").removeAttr("aria-selected").removeAttr("aria-controls").removeAttr("tabIndex").each(function(){/^ui-accordion/.test(this.id)&&this.removeAttribute("id")}),this._destroyIcons(),e=this.headers.next().css("display","").removeAttr("role").removeAttr("aria-expanded").removeAttr("aria-hidden").removeAttr("aria-labelledby").removeClass("ui-helper-reset ui-widget-content ui-corner-bottom ui-accordion-content ui-accordion-content-active ui-state-disabled").each(function(){/^ui-accordion/.test(this.id)&&this.removeAttribute("id")}),this.options.heightStyle!=="content"&&e.css("height","")},_setOption:function(e,t){if(e==="active"){this._activate(t);return}e==="event"&&(this.options.event&&this._off(this.headers,this.options.event),this._setupEvents(t)),this._super(e,t),e==="collapsible"&&!t&&this.options.active===!1&&this._activate(0),e==="icons"&&(this._destroyIcons(),t&&this._createIcons()),e==="disabled"&&this.headers.add(this.headers.next()).toggleClass("ui-state-disabled",!!t)},_keydown:function(t){if(t.altKey||t.ctrlKey)return;var n=e.ui.keyCode,r=this.headers.length,i=this.headers.index(t.target),s=!1;switch(t.keyCode){case n.RIGHT:case n.DOWN:s=this.headers[(i+1)%r];break;case n.LEFT:case n.UP:s=this.headers[(i-1+r)%r];break;case n.SPACE:case n.ENTER:this._eventHandler(t);break;case n.HOME:s=this.headers[0];break;case n.END:s=this.headers[r-1]}s&&(e(t.target).attr("tabIndex",-1),e(s).attr("tabIndex",0),s.focus(),t.preventDefault())},_panelKeyDown:function(t){t.keyCode===e.ui.keyCode.UP&&t.ctrlKey&&e(t.currentTarget).prev().focus()},refresh:function(){var t,n,r=this.options.heightStyle,i=this.element.parent();r==="fill"?(e.support.minHeight||(n=i.css("overflow"),i.css("overflow","hidden")),t=i.height(),this.element.siblings(":visible").each(function(){var n=e(this),r=n.css("position");if(r==="absolute"||r==="fixed")return;t-=n.outerHeight(!0)}),n&&i.css("overflow",n),this.headers.each(function(){t-=e(this).outerHeight(!0)}),this.headers.next().each(function(){e(this).height(Math.max(0,t-e(this).innerHeight()+e(this).height()))}).css("overflow","auto")):r==="auto"&&(t=0,this.headers.next().each(function(){t=Math.max(t,e(this).css("height","").height())}).height(t))},_activate:function(t){var n=this._findActive(t)[0];if(n===this.active[0])return;n=n||this.active[0],this._eventHandler({target:n,currentTarget:n,preventDefault:e.noop})},_findActive:function(t){return typeof t=="number"?this.headers.eq(t):e()},_setupEvents:function(t){var n={};if(!t)return;e.each(t.split(" "),function(e,t){n[t]="_eventHandler"}),this._on(this.headers,n)},_eventHandler:function(t){var n=this.options,r=this.active,i=e(t.currentTarget),s=i[0]===r[0],o=s&&n.collapsible,u=o?e():i.next(),a=r.next(),f={oldHeader:r,oldPanel:a,newHeader:o?e():i,newPanel:u};t.preventDefault();if(s&&!n.collapsible||this._trigger("beforeActivate",t,f)===!1)return;n.active=o?!1:this.headers.index(i),this.active=s?e():i,this._toggle(f),r.removeClass("ui-accordion-header-active ui-state-active"),n.icons&&r.children(".ui-accordion-header-icon").removeClass(n.icons.activeHeader).addClass(n.icons.header),s||(i.removeClass("ui-corner-all").addClass("ui-accordion-header-active ui-state-active ui-corner-top"),n.icons&&i.children(".ui-accordion-header-icon").removeClass(n.icons.header).addClass(n.icons.activeHeader),i.next().addClass("ui-accordion-content-active"))},_toggle:function(t){var n=t.newPanel,r=this.prevShow.length?this.prevShow:t.oldPanel;this.prevShow.add(this.prevHide).stop(!0,!0),this.prevShow=n,this.prevHide=r,this.options.animate?this._animate(n,r,t):(r.hide(),n.show(),this._toggleComplete(t)),r.attr({"aria-expanded":"false","aria-hidden":"true"}),r.prev().attr("aria-selected","false"),n.length&&r.length?r.prev().attr("tabIndex",-1):n.length&&this.headers.filter(function(){return e(this).attr("tabIndex")===0}).attr("tabIndex",-1),n.attr({"aria-expanded":"true","aria-hidden":"false"}).prev().attr({"aria-selected":"true",tabIndex:0})},_animate:function(e,t,n){var s,o,u,a=this,f=0,l=e.length&&(!t.length||e.index()<t.index()),c=this.options.animate||{},h=l&&c.down||c,p=function(){a._toggleComplete(n)};typeof h=="number"&&(u=h),typeof h=="string"&&(o=h),o=o||h.easing||c.easing,u=u||h.duration||c.duration;if(!t.length)return e.animate(i,u,o,p);if(!e.length)return t.animate(r,u,o,p);s=e.show().outerHeight(),t.animate(r,{duration:u,easing:o,step:function(e,t){t.now=Math.round(e)}}),e.hide().animate(i,{duration:u,easing:o,complete:p,step:function(e,n){n.now=Math.round(e),n.prop!=="height"?f+=n.now:a.options.heightStyle!=="content"&&(n.now=Math.round(s-t.outerHeight()-f),f=0)}})},_toggleComplete:function(e){var t=e.oldPanel;t.removeClass("ui-accordion-content-active").prev().removeClass("ui-corner-top").addClass("ui-corner-all"),t.length&&(t.parent()[0].className=t.parent()[0].className),this._trigger("activate",null,e)}}),e.uiBackCompat!==!1&&(function(e,t){e.extend(t.options,{navigation:!1,navigationFilter:function(){return this.href.toLowerCase()===location.href.toLowerCase()}});var n=t._create;t._create=function(){if(this.options.navigation){var t=this,r=this.element.find(this.options.header),i=r.next(),s=r.add(i).find("a").filter(this.options.navigationFilter)[0];s&&r.add(i).each(function(n){if(e.contains(this,s))return t.options.active=Math.floor(n/2),!1})}n.call(this)}}(jQuery,jQuery.ui.accordion.prototype),function(e,t){e.extend(t.options,{heightStyle:null,autoHeight:!0,clearStyle:!1,fillSpace:!1});var n=t._create,r=t._setOption;e.extend(t,{_create:function(){this.options.heightStyle=this.options.heightStyle||this._mergeHeightStyle(),n.call(this)},_setOption:function(e){if(e==="autoHeight"||e==="clearStyle"||e==="fillSpace")this.options.heightStyle=this._mergeHeightStyle();r.apply(this,arguments)},_mergeHeightStyle:function(){var e=this.options;if(e.fillSpace)return"fill";if(e.clearStyle)return"content";if(e.autoHeight)return"auto"}})}(jQuery,jQuery.ui.accordion.prototype),function(e,t){e.extend(t.options.icons,{activeHeader:null,headerSelected:"ui-icon-triangle-1-s"});var n=t._createIcons;t._createIcons=function(){this.options.icons&&(this.options.icons.activeHeader=this.options.icons.activeHeader||this.options.icons.headerSelected),n.call(this)}}(jQuery,jQuery.ui.accordion.prototype),function(e,t){t.activate=t._activate;var n=t._findActive;t._findActive=function(e){return e===-1&&(e=!1),e&&typeof e!="number"&&(e=this.headers.index(this.headers.filter(e)),e===-1&&(e=!1)),n.call(this,e)}}(jQuery,jQuery.ui.accordion.prototype),jQuery.ui.accordion.prototype.resize=jQuery.ui.accordion.prototype.refresh,function(e,t){e.extend(t.options,{change:null,changestart:null});var n=t._trigger;t._trigger=function(e,t,r){var i=n.apply(this,arguments);return i?(e==="beforeActivate"?i=n.call(this,"changestart",t,{oldHeader:r.oldHeader,oldContent:r.oldPanel,newHeader:r.newHeader,newContent:r.newPanel}):e==="activate"&&(i=n.call(this,"change",t,{oldHeader:r.oldHeader,oldContent:r.oldPanel,newHeader:r.newHeader,newContent:r.newPanel})),i):!1}}(jQuery,jQuery.ui.accordion.prototype),function(e,t){e.extend(t.options,{animate:null,animated:"slide"});var n=t._create;t._create=function(){var e=this.options;e.animate===null&&(e.animated?e.animated==="slide"?e.animate=300:e.animated==="bounceslide"?e.animate={duration:200,down:{easing:"easeOutBounce",duration:1e3}}:e.animate=e.animated:e.animate=!1),n.call(this)}}(jQuery,jQuery.ui.accordion.prototype))})(jQuery);(function(e,t){var n=0;e.widget("ui.autocomplete",{version:"1.9.2",defaultElement:"<input>",options:{appendTo:"body",autoFocus:!1,delay:300,minLength:1,position:{my:"left top",at:"left bottom",collision:"none"},source:null,change:null,close:null,focus:null,open:null,response:null,search:null,select:null},pending:0,_create:function(){var t,n,r;this.isMultiLine=this._isMultiLine(),this.valueMethod=this.element[this.element.is("input,textarea")?"val":"text"],this.isNewMenu=!0,this.element.addClass("ui-autocomplete-input").attr("autocomplete","off"),this._on(this.element,{keydown:function(i){if(this.element.prop("readOnly")){t=!0,r=!0,n=!0;return}t=!1,r=!1,n=!1;var s=e.ui.keyCode;switch(i.keyCode){case s.PAGE_UP:t=!0,this._move("previousPage",i);break;case s.PAGE_DOWN:t=!0,this._move("nextPage",i);break;case s.UP:t=!0,this._keyEvent("previous",i);break;case s.DOWN:t=!0,this._keyEvent("next",i);break;case s.ENTER:case s.NUMPAD_ENTER:this.menu.active&&(t=!0,i.preventDefault(),this.menu.select(i));break;case s.TAB:this.menu.active&&this.menu.select(i);break;case s.ESCAPE:this.menu.element.is(":visible")&&(this._value(this.term),this.close(i),i.preventDefault());break;default:n=!0,this._searchTimeout(i)}},keypress:function(r){if(t){t=!1,r.preventDefault();return}if(n)return;var i=e.ui.keyCode;switch(r.keyCode){case i.PAGE_UP:this._move("previousPage",r);break;case i.PAGE_DOWN:this._move("nextPage",r);break;case i.UP:this._keyEvent("previous",r);break;case i.DOWN:this._keyEvent("next",r)}},input:function(e){if(r){r=!1,e.preventDefault();return}this._searchTimeout(e)},focus:function(){this.selectedItem=null,this.previous=this._value()},blur:function(e){if(this.cancelBlur){delete this.cancelBlur;return}clearTimeout(this.searching),this.close(e),this._change(e)}}),this._initSource(),this.menu=e("<ul>").addClass("ui-autocomplete").appendTo(this.document.find(this.options.appendTo||"body")[0]).menu({input:e(),role:null}).zIndex(this.element.zIndex()+1).hide().data("menu"),this._on(this.menu.element,{mousedown:function(t){t.preventDefault(),this.cancelBlur=!0,this._delay(function(){delete this.cancelBlur});var n=this.menu.element[0];e(t.target).closest(".ui-menu-item").length||this._delay(function(){var t=this;this.document.one("mousedown",function(r){r.target!==t.element[0]&&r.target!==n&&!e.contains(n,r.target)&&t.close()})})},menufocus:function(t,n){if(this.isNewMenu){this.isNewMenu=!1;if(t.originalEvent&&/^mouse/.test(t.originalEvent.type)){this.menu.blur(),this.document.one("mousemove",function(){e(t.target).trigger(t.originalEvent)});return}}var r=n.item.data("ui-autocomplete-item")||n.item.data("item.autocomplete");!1!==this._trigger("focus",t,{item:r})?t.originalEvent&&/^key/.test(t.originalEvent.type)&&this._value(r.value):this.liveRegion.text(r.value)},menuselect:function(e,t){var n=t.item.data("ui-autocomplete-item")||t.item.data("item.autocomplete"),r=this.previous;this.element[0]!==this.document[0].activeElement&&(this.element.focus(),this.previous=r,this._delay(function(){this.previous=r,this.selectedItem=n})),!1!==this._trigger("select",e,{item:n})&&this._value(n.value),this.term=this._value(),this.close(e),this.selectedItem=n}}),this.liveRegion=e("<span>",{role:"status","aria-live":"polite"}).addClass("ui-helper-hidden-accessible").insertAfter(this.element),e.fn.bgiframe&&this.menu.element.bgiframe(),this._on(this.window,{beforeunload:function(){this.element.removeAttr("autocomplete")}})},_destroy:function(){clearTimeout(this.searching),this.element.removeClass("ui-autocomplete-input").removeAttr("autocomplete"),this.menu.element.remove(),this.liveRegion.remove()},_setOption:function(e,t){this._super(e,t),e==="source"&&this._initSource(),e==="appendTo"&&this.menu.element.appendTo(this.document.find(t||"body")[0]),e==="disabled"&&t&&this.xhr&&this.xhr.abort()},_isMultiLine:function(){return this.element.is("textarea")?!0:this.element.is("input")?!1:this.element.prop("isContentEditable")},_initSource:function(){var t,n,r=this;e.isArray(this.options.source)?(t=this.options.source,this.source=function(n,r){r(e.ui.autocomplete.filter(t,n.term))}):typeof this.options.source=="string"?(n=this.options.source,this.source=function(t,i){r.xhr&&r.xhr.abort(),r.xhr=e.ajax({url:n,data:t,dataType:"json",success:function(e){i(e)},error:function(){i([])}})}):this.source=this.options.source},_searchTimeout:function(e){clearTimeout(this.searching),this.searching=this._delay(function(){this.term!==this._value()&&(this.selectedItem=null,this.search(null,e))},this.options.delay)},search:function(e,t){e=e!=null?e:this._value(),this.term=this._value();if(e.length<this.options.minLength)return this.close(t);if(this._trigger("search",t)===!1)return;return this._search(e)},_search:function(e){this.pending++,this.element.addClass("ui-autocomplete-loading"),this.cancelSearch=!1,this.source({term:e},this._response())},_response:function(){var e=this,t=++n;return function(r){t===n&&e.__response(r),e.pending--,e.pending||e.element.removeClass("ui-autocomplete-loading")}},__response:function(e){e&&(e=this._normalize(e)),this._trigger("response",null,{content:e}),!this.options.disabled&&e&&e.length&&!this.cancelSearch?(this._suggest(e),this._trigger("open")):this._close()},close:function(e){this.cancelSearch=!0,this._close(e)},_close:function(e){this.menu.element.is(":visible")&&(this.menu.element.hide(),this.menu.blur(),this.isNewMenu=!0,this._trigger("close",e))},_change:function(e){this.previous!==this._value()&&this._trigger("change",e,{item:this.selectedItem})},_normalize:function(t){return t.length&&t[0].label&&t[0].value?t:e.map(t,function(t){return typeof t=="string"?{label:t,value:t}:e.extend({label:t.label||t.value,value:t.value||t.label},t)})},_suggest:function(t){var n=this.menu.element.empty().zIndex(this.element.zIndex()+1);this._renderMenu(n,t),this.menu.refresh(),n.show(),this._resizeMenu(),n.position(e.extend({of:this.element},this.options.position)),this.options.autoFocus&&this.menu.next()},_resizeMenu:function(){var e=this.menu.element;e.outerWidth(Math.max(e.width("").outerWidth()+1,this.element.outerWidth()))},_renderMenu:function(t,n){var r=this;e.each(n,function(e,n){r._renderItemData(t,n)})},_renderItemData:function(e,t){return this._renderItem(e,t).data("ui-autocomplete-item",t)},_renderItem:function(t,n){return e("<li>").append(e("<a>").text(n.label)).appendTo(t)},_move:function(e,t){if(!this.menu.element.is(":visible")){this.search(null,t);return}if(this.menu.isFirstItem()&&/^previous/.test(e)||this.menu.isLastItem()&&/^next/.test(e)){this._value(this.term),this.menu.blur();return}this.menu[e](t)},widget:function(){return this.menu.element},_value:function(){return this.valueMethod.apply(this.element,arguments)},_keyEvent:function(e,t){if(!this.isMultiLine||this.menu.element.is(":visible"))this._move(e,t),t.preventDefault()}}),e.extend(e.ui.autocomplete,{escapeRegex:function(e){return e.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g,"\\$&")},filter:function(t,n){var r=new RegExp(e.ui.autocomplete.escapeRegex(n),"i");return e.grep(t,function(e){return r.test(e.label||e.value||e)})}}),e.widget("ui.autocomplete",e.ui.autocomplete,{options:{messages:{noResults:"No search results.",results:function(e){return e+(e>1?" results are":" result is")+" available, use up and down arrow keys to navigate."}}},__response:function(e){var t;this._superApply(arguments);if(this.options.disabled||this.cancelSearch)return;e&&e.length?t=this.options.messages.results(e.length):t=this.options.messages.noResults,this.liveRegion.text(t)}})})(jQuery);(function(e,t){var n,r,i,s,o="ui-button ui-widget ui-state-default ui-corner-all",u="ui-state-hover ui-state-active ",a="ui-button-icons-only ui-button-icon-only ui-button-text-icons ui-button-text-icon-primary ui-button-text-icon-secondary ui-button-text-only",f=function(){var t=e(this).find(":ui-button");setTimeout(function(){t.button("refresh")},1)},l=function(t){var n=t.name,r=t.form,i=e([]);return n&&(r?i=e(r).find("[name='"+n+"']"):i=e("[name='"+n+"']",t.ownerDocument).filter(function(){return!this.form})),i};e.widget("ui.button",{version:"1.9.2",defaultElement:"<button>",options:{disabled:null,text:!0,label:null,icons:{primary:null,secondary:null}},_create:function(){this.element.closest("form").unbind("reset"+this.eventNamespace).bind("reset"+this.eventNamespace,f),typeof this.options.disabled!="boolean"?this.options.disabled=!!this.element.prop("disabled"):this.element.prop("disabled",this.options.disabled),this._determineButtonType(),this.hasTitle=!!this.buttonElement.attr("title");var t=this,u=this.options,a=this.type==="checkbox"||this.type==="radio",c=a?"":"ui-state-active",h="ui-state-focus";u.label===null&&(u.label=this.type==="input"?this.buttonElement.val():this.buttonElement.html()),this._hoverable(this.buttonElement),this.buttonElement.addClass(o).attr("role","button").bind("mouseenter"+this.eventNamespace,function(){if(u.disabled)return;this===n&&e(this).addClass("ui-state-active")}).bind("mouseleave"+this.eventNamespace,function(){if(u.disabled)return;e(this).removeClass(c)}).bind("click"+this.eventNamespace,function(e){u.disabled&&(e.preventDefault(),e.stopImmediatePropagation())}),this.element.bind("focus"+this.eventNamespace,function(){t.buttonElement.addClass(h)}).bind("blur"+this.eventNamespace,function(){t.buttonElement.removeClass(h)}),a&&(this.element.bind("change"+this.eventNamespace,function(){if(s)return;t.refresh()}),this.buttonElement.bind("mousedown"+this.eventNamespace,function(e){if(u.disabled)return;s=!1,r=e.pageX,i=e.pageY}).bind("mouseup"+this.eventNamespace,function(e){if(u.disabled)return;if(r!==e.pageX||i!==e.pageY)s=!0})),this.type==="checkbox"?this.buttonElement.bind("click"+this.eventNamespace,function(){if(u.disabled||s)return!1;e(this).toggleClass("ui-state-active"),t.buttonElement.attr("aria-pressed",t.element[0].checked)}):this.type==="radio"?this.buttonElement.bind("click"+this.eventNamespace,function(){if(u.disabled||s)return!1;e(this).addClass("ui-state-active"),t.buttonElement.attr("aria-pressed","true");var n=t.element[0];l(n).not(n).map(function(){return e(this).button("widget")[0]}).removeClass("ui-state-active").attr("aria-pressed","false")}):(this.buttonElement.bind("mousedown"+this.eventNamespace,function(){if(u.disabled)return!1;e(this).addClass("ui-state-active"),n=this,t.document.one("mouseup",function(){n=null})}).bind("mouseup"+this.eventNamespace,function(){if(u.disabled)return!1;e(this).removeClass("ui-state-active")}).bind("keydown"+this.eventNamespace,function(t){if(u.disabled)return!1;(t.keyCode===e.ui.keyCode.SPACE||t.keyCode===e.ui.keyCode.ENTER)&&e(this).addClass("ui-state-active")}).bind("keyup"+this.eventNamespace,function(){e(this).removeClass("ui-state-active")}),this.buttonElement.is("a")&&this.buttonElement.keyup(function(t){t.keyCode===e.ui.keyCode.SPACE&&e(this).click()})),this._setOption("disabled",u.disabled),this._resetButton()},_determineButtonType:function(){var e,t,n;this.element.is("[type=checkbox]")?this.type="checkbox":this.element.is("[type=radio]")?this.type="radio":this.element.is("input")?this.type="input":this.type="button",this.type==="checkbox"||this.type==="radio"?(e=this.element.parents().last(),t="label[for='"+this.element.attr("id")+"']",this.buttonElement=e.find(t),this.buttonElement.length||(e=e.length?e.siblings():this.element.siblings(),this.buttonElement=e.filter(t),this.buttonElement.length||(this.buttonElement=e.find(t))),this.element.addClass("ui-helper-hidden-accessible"),n=this.element.is(":checked"),n&&this.buttonElement.addClass("ui-state-active"),this.buttonElement.prop("aria-pressed",n)):this.buttonElement=this.element},widget:function(){return this.buttonElement},_destroy:function(){this.element.removeClass("ui-helper-hidden-accessible"),this.buttonElement.removeClass(o+" "+u+" "+a).removeAttr("role").removeAttr("aria-pressed").html(this.buttonElement.find(".ui-button-text").html()),this.hasTitle||this.buttonElement.removeAttr("title")},_setOption:function(e,t){this._super(e,t);if(e==="disabled"){t?this.element.prop("disabled",!0):this.element.prop("disabled",!1);return}this._resetButton()},refresh:function(){var t=this.element.is("input, button")?this.element.is(":disabled"):this.element.hasClass("ui-button-disabled");t!==this.options.disabled&&this._setOption("disabled",t),this.type==="radio"?l(this.element[0]).each(function(){e(this).is(":checked")?e(this).button("widget").addClass("ui-state-active").attr("aria-pressed","true"):e(this).button("widget").removeClass("ui-state-active").attr("aria-pressed","false")}):this.type==="checkbox"&&(this.element.is(":checked")?this.buttonElement.addClass("ui-state-active").attr("aria-pressed","true"):this.buttonElement.removeClass("ui-state-active").attr("aria-pressed","false"))},_resetButton:function(){if(this.type==="input"){this.options.label&&this.element.val(this.options.label);return}var t=this.buttonElement.removeClass(a),n=e("<span></span>",this.document[0]).addClass("ui-button-text").html(this.options.label).appendTo(t.empty()).text(),r=this.options.icons,i=r.primary&&r.secondary,s=[];r.primary||r.secondary?(this.options.text&&s.push("ui-button-text-icon"+(i?"s":r.primary?"-primary":"-secondary")),r.primary&&t.prepend("<span class='ui-button-icon-primary ui-icon "+r.primary+"'></span>"),r.secondary&&t.append("<span class='ui-button-icon-secondary ui-icon "+r.secondary+"'></span>"),this.options.text||(s.push(i?"ui-button-icons-only":"ui-button-icon-only"),this.hasTitle||t.attr("title",e.trim(n)))):s.push("ui-button-text-only"),t.addClass(s.join(" "))}}),e.widget("ui.buttonset",{version:"1.9.2",options:{items:"button, input[type=button], input[type=submit], input[type=reset], input[type=checkbox], input[type=radio], a, :data(button)"},_create:function(){this.element.addClass("ui-buttonset")},_init:function(){this.refresh()},_setOption:function(e,t){e==="disabled"&&this.buttons.button("option",e,t),this._super(e,t)},refresh:function(){var t=this.element.css("direction")==="rtl";this.buttons=this.element.find(this.options.items).filter(":ui-button").button("refresh").end().not(":ui-button").button().end().map(function(){return e(this).button("widget")[0]}).removeClass("ui-corner-all ui-corner-left ui-corner-right").filter(":first").addClass(t?"ui-corner-right":"ui-corner-left").end().filter(":last").addClass(t?"ui-corner-left":"ui-corner-right").end().end()},_destroy:function(){this.element.removeClass("ui-buttonset"),this.buttons.map(function(){return e(this).button("widget")[0]}).removeClass("ui-corner-left ui-corner-right").end().button("destroy")}})})(jQuery);(function($,undefined){function Datepicker(){this.debug=!1,this._curInst=null,this._keyEvent=!1,this._disabledInputs=[],this._datepickerShowing=!1,this._inDialog=!1,this._mainDivId="ui-datepicker-div",this._inlineClass="ui-datepicker-inline",this._appendClass="ui-datepicker-append",this._triggerClass="ui-datepicker-trigger",this._dialogClass="ui-datepicker-dialog",this._disableClass="ui-datepicker-disabled",this._unselectableClass="ui-datepicker-unselectable",this._currentClass="ui-datepicker-current-day",this._dayOverClass="ui-datepicker-days-cell-over",this.regional=[],this.regional[""]={closeText:"Done",prevText:"Prev",nextText:"Next",currentText:"Today",monthNames:["January","February","March","April","May","June","July","August","September","October","November","December"],monthNamesShort:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],dayNames:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],dayNamesShort:["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],dayNamesMin:["Su","Mo","Tu","We","Th","Fr","Sa"],weekHeader:"Wk",dateFormat:"mm/dd/yy",firstDay:0,isRTL:!1,showMonthAfterYear:!1,yearSuffix:""},this._defaults={showOn:"focus",showAnim:"fadeIn",showOptions:{},defaultDate:null,appendText:"",buttonText:"...",buttonImage:"",buttonImageOnly:!1,hideIfNoPrevNext:!1,navigationAsDateFormat:!1,gotoCurrent:!1,changeMonth:!1,changeYear:!1,yearRange:"c-10:c+10",showOtherMonths:!1,selectOtherMonths:!1,showWeek:!1,calculateWeek:this.iso8601Week,shortYearCutoff:"+10",minDate:null,maxDate:null,duration:"fast",beforeShowDay:null,beforeShow:null,onSelect:null,onChangeMonthYear:null,onClose:null,numberOfMonths:1,showCurrentAtPos:0,stepMonths:1,stepBigMonths:12,altField:"",altFormat:"",constrainInput:!0,showButtonPanel:!1,autoSize:!1,disabled:!1},$.extend(this._defaults,this.regional[""]),this.dpDiv=bindHover($('<div id="'+this._mainDivId+'" class="ui-datepicker ui-widget ui-widget-content ui-helper-clearfix ui-corner-all"></div>'))}function bindHover(e){var t="button, .ui-datepicker-prev, .ui-datepicker-next, .ui-datepicker-calendar td a";return e.delegate(t,"mouseout",function(){$(this).removeClass("ui-state-hover"),this.className.indexOf("ui-datepicker-prev")!=-1&&$(this).removeClass("ui-datepicker-prev-hover"),this.className.indexOf("ui-datepicker-next")!=-1&&$(this).removeClass("ui-datepicker-next-hover")}).delegate(t,"mouseover",function(){$.datepicker._isDisabledDatepicker(instActive.inline?e.parent()[0]:instActive.input[0])||($(this).parents(".ui-datepicker-calendar").find("a").removeClass("ui-state-hover"),$(this).addClass("ui-state-hover"),this.className.indexOf("ui-datepicker-prev")!=-1&&$(this).addClass("ui-datepicker-prev-hover"),this.className.indexOf("ui-datepicker-next")!=-1&&$(this).addClass("ui-datepicker-next-hover"))})}function extendRemove(e,t){$.extend(e,t);for(var n in t)if(t[n]==null||t[n]==undefined)e[n]=t[n];return e}$.extend($.ui,{datepicker:{version:"1.9.2"}});var PROP_NAME="datepicker",dpuuid=(new Date).getTime(),instActive;$.extend(Datepicker.prototype,{markerClassName:"hasDatepicker",maxRows:4,log:function(){this.debug&&console.log.apply("",arguments)},_widgetDatepicker:function(){return this.dpDiv},setDefaults:function(e){return extendRemove(this._defaults,e||{}),this},_attachDatepicker:function(target,settings){var inlineSettings=null;for(var attrName in this._defaults){var attrValue=target.getAttribute("date:"+attrName);if(attrValue){inlineSettings=inlineSettings||{};try{inlineSettings[attrName]=eval(attrValue)}catch(err){inlineSettings[attrName]=attrValue}}}var nodeName=target.nodeName.toLowerCase(),inline=nodeName=="div"||nodeName=="span";target.id||(this.uuid+=1,target.id="dp"+this.uuid);var inst=this._newInst($(target),inline);inst.settings=$.extend({},settings||{},inlineSettings||{}),nodeName=="input"?this._connectDatepicker(target,inst):inline&&this._inlineDatepicker(target,inst)},_newInst:function(e,t){var n=e[0].id.replace(/([^A-Za-z0-9_-])/g,"\\\\$1");return{id:n,input:e,selectedDay:0,selectedMonth:0,selectedYear:0,drawMonth:0,drawYear:0,inline:t,dpDiv:t?bindHover($('<div class="'+this._inlineClass+' ui-datepicker ui-widget ui-widget-content ui-helper-clearfix ui-corner-all"></div>')):this.dpDiv}},_connectDatepicker:function(e,t){var n=$(e);t.append=$([]),t.trigger=$([]);if(n.hasClass(this.markerClassName))return;this._attachments(n,t),n.addClass(this.markerClassName).keydown(this._doKeyDown).keypress(this._doKeyPress).keyup(this._doKeyUp).bind("setData.datepicker",function(e,n,r){t.settings[n]=r}).bind("getData.datepicker",function(e,n){return this._get(t,n)}),this._autoSize(t),$.data(e,PROP_NAME,t),t.settings.disabled&&this._disableDatepicker(e)},_attachments:function(e,t){var n=this._get(t,"appendText"),r=this._get(t,"isRTL");t.append&&t.append.remove(),n&&(t.append=$('<span class="'+this._appendClass+'">'+n+"</span>"),e[r?"before":"after"](t.append)),e.unbind("focus",this._showDatepicker),t.trigger&&t.trigger.remove();var i=this._get(t,"showOn");(i=="focus"||i=="both")&&e.focus(this._showDatepicker);if(i=="button"||i=="both"){var s=this._get(t,"buttonText"),o=this._get(t,"buttonImage");t.trigger=$(this._get(t,"buttonImageOnly")?$("<img/>").addClass(this._triggerClass).attr({src:o,alt:s,title:s}):$('<button type="button"></button>').addClass(this._triggerClass).html(o==""?s:$("<img/>").attr({src:o,alt:s,title:s}))),e[r?"before":"after"](t.trigger),t.trigger.click(function(){return $.datepicker._datepickerShowing&&$.datepicker._lastInput==e[0]?$.datepicker._hideDatepicker():$.datepicker._datepickerShowing&&$.datepicker._lastInput!=e[0]?($.datepicker._hideDatepicker(),$.datepicker._showDatepicker(e[0])):$.datepicker._showDatepicker(e[0]),!1})}},_autoSize:function(e){if(this._get(e,"autoSize")&&!e.inline){var t=new Date(2009,11,20),n=this._get(e,"dateFormat");if(n.match(/[DM]/)){var r=function(e){var t=0,n=0;for(var r=0;r<e.length;r++)e[r].length>t&&(t=e[r].length,n=r);return n};t.setMonth(r(this._get(e,n.match(/MM/)?"monthNames":"monthNamesShort"))),t.setDate(r(this._get(e,n.match(/DD/)?"dayNames":"dayNamesShort"))+20-t.getDay())}e.input.attr("size",this._formatDate(e,t).length)}},_inlineDatepicker:function(e,t){var n=$(e);if(n.hasClass(this.markerClassName))return;n.addClass(this.markerClassName).append(t.dpDiv).bind("setData.datepicker",function(e,n,r){t.settings[n]=r}).bind("getData.datepicker",function(e,n){return this._get(t,n)}),$.data(e,PROP_NAME,t),this._setDate(t,this._getDefaultDate(t),!0),this._updateDatepicker(t),this._updateAlternate(t),t.settings.disabled&&this._disableDatepicker(e),t.dpDiv.css("display","block")},_dialogDatepicker:function(e,t,n,r,i){var s=this._dialogInst;if(!s){this.uuid+=1;var o="dp"+this.uuid;this._dialogInput=$('<input type="text" id="'+o+'" style="position: absolute; top: -100px; width: 0px;"/>'),this._dialogInput.keydown(this._doKeyDown),$("body").append(this._dialogInput),s=this._dialogInst=this._newInst(this._dialogInput,!1),s.settings={},$.data(this._dialogInput[0],PROP_NAME,s)}extendRemove(s.settings,r||{}),t=t&&t.constructor==Date?this._formatDate(s,t):t,this._dialogInput.val(t),this._pos=i?i.length?i:[i.pageX,i.pageY]:null;if(!this._pos){var u=document.documentElement.clientWidth,a=document.documentElement.clientHeight,f=document.documentElement.scrollLeft||document.body.scrollLeft,l=document.documentElement.scrollTop||document.body.scrollTop;this._pos=[u/2-100+f,a/2-150+l]}return this._dialogInput.css("left",this._pos[0]+20+"px").css("top",this._pos[1]+"px"),s.settings.onSelect=n,this._inDialog=!0,this.dpDiv.addClass(this._dialogClass),this._showDatepicker(this._dialogInput[0]),$.blockUI&&$.blockUI(this.dpDiv),$.data(this._dialogInput[0],PROP_NAME,s),this},_destroyDatepicker:function(e){var t=$(e),n=$.data(e,PROP_NAME);if(!t.hasClass(this.markerClassName))return;var r=e.nodeName.toLowerCase();$.removeData(e,PROP_NAME),r=="input"?(n.append.remove(),n.trigger.remove(),t.removeClass(this.markerClassName).unbind("focus",this._showDatepicker).unbind("keydown",this._doKeyDown).unbind("keypress",this._doKeyPress).unbind("keyup",this._doKeyUp)):(r=="div"||r=="span")&&t.removeClass(this.markerClassName).empty()},_enableDatepicker:function(e){var t=$(e),n=$.data(e,PROP_NAME);if(!t.hasClass(this.markerClassName))return;var r=e.nodeName.toLowerCase();if(r=="input")e.disabled=!1,n.trigger.filter("button").each(function(){this.disabled=!1}).end().filter("img").css({opacity:"1.0",cursor:""});else if(r=="div"||r=="span"){var i=t.children("."+this._inlineClass);i.children().removeClass("ui-state-disabled"),i.find("select.ui-datepicker-month, select.ui-datepicker-year").prop("disabled",!1)}this._disabledInputs=$.map(this._disabledInputs,function(t){return t==e?null:t})},_disableDatepicker:function(e){var t=$(e),n=$.data(e,PROP_NAME);if(!t.hasClass(this.markerClassName))return;var r=e.nodeName.toLowerCase();if(r=="input")e.disabled=!0,n.trigger.filter("button").each(function(){this.disabled=!0}).end().filter("img").css({opacity:"0.5",cursor:"default"});else if(r=="div"||r=="span"){var i=t.children("."+this._inlineClass);i.children().addClass("ui-state-disabled"),i.find("select.ui-datepicker-month, select.ui-datepicker-year").prop("disabled",!0)}this._disabledInputs=$.map(this._disabledInputs,function(t){return t==e?null:t}),this._disabledInputs[this._disabledInputs.length]=e},_isDisabledDatepicker:function(e){if(!e)return!1;for(var t=0;t<this._disabledInputs.length;t++)if(this._disabledInputs[t]==e)return!0;return!1},_getInst:function(e){try{return $.data(e,PROP_NAME)}catch(t){throw"Missing instance data for this datepicker"}},_optionDatepicker:function(e,t,n){var r=this._getInst(e);if(arguments.length==2&&typeof t=="string")return t=="defaults"?$.extend({},$.datepicker._defaults):r?t=="all"?$.extend({},r.settings):this._get(r,t):null;var i=t||{};typeof t=="string"&&(i={},i[t]=n);if(r){this._curInst==r&&this._hideDatepicker();var s=this._getDateDatepicker(e,!0),o=this._getMinMaxDate(r,"min"),u=this._getMinMaxDate(r,"max");extendRemove(r.settings,i),o!==null&&i.dateFormat!==undefined&&i.minDate===undefined&&(r.settings.minDate=this._formatDate(r,o)),u!==null&&i.dateFormat!==undefined&&i.maxDate===undefined&&(r.settings.maxDate=this._formatDate(r,u)),this._attachments($(e),r),this._autoSize(r),this._setDate(r,s),this._updateAlternate(r),this._updateDatepicker(r)}},_changeDatepicker:function(e,t,n){this._optionDatepicker(e,t,n)},_refreshDatepicker:function(e){var t=this._getInst(e);t&&this._updateDatepicker(t)},_setDateDatepicker:function(e,t){var n=this._getInst(e);n&&(this._setDate(n,t),this._updateDatepicker(n),this._updateAlternate(n))},_getDateDatepicker:function(e,t){var n=this._getInst(e);return n&&!n.inline&&this._setDateFromField(n,t),n?this._getDate(n):null},_doKeyDown:function(e){var t=$.datepicker._getInst(e.target),n=!0,r=t.dpDiv.is(".ui-datepicker-rtl");t._keyEvent=!0;if($.datepicker._datepickerShowing)switch(e.keyCode){case 9:$.datepicker._hideDatepicker(),n=!1;break;case 13:var i=$("td."+$.datepicker._dayOverClass+":not(."+$.datepicker._currentClass+")",t.dpDiv);i[0]&&$.datepicker._selectDay(e.target,t.selectedMonth,t.selectedYear,i[0]);var s=$.datepicker._get(t,"onSelect");if(s){var o=$.datepicker._formatDate(t);s.apply(t.input?t.input[0]:null,[o,t])}else $.datepicker._hideDatepicker();return!1;case 27:$.datepicker._hideDatepicker();break;case 33:$.datepicker._adjustDate(e.target,e.ctrlKey?-$.datepicker._get(t,"stepBigMonths"):-$.datepicker._get(t,"stepMonths"),"M");break;case 34:$.datepicker._adjustDate(e.target,e.ctrlKey?+$.datepicker._get(t,"stepBigMonths"):+$.datepicker._get(t,"stepMonths"),"M");break;case 35:(e.ctrlKey||e.metaKey)&&$.datepicker._clearDate(e.target),n=e.ctrlKey||e.metaKey;break;case 36:(e.ctrlKey||e.metaKey)&&$.datepicker._gotoToday(e.target),n=e.ctrlKey||e.metaKey;break;case 37:(e.ctrlKey||e.metaKey)&&$.datepicker._adjustDate(e.target,r?1:-1,"D"),n=e.ctrlKey||e.metaKey,e.originalEvent.altKey&&$.datepicker._adjustDate(e.target,e.ctrlKey?-$.datepicker._get(t,"stepBigMonths"):-$.datepicker._get(t,"stepMonths"),"M");break;case 38:(e.ctrlKey||e.metaKey)&&$.datepicker._adjustDate(e.target,-7,"D"),n=e.ctrlKey||e.metaKey;break;case 39:(e.ctrlKey||e.metaKey)&&$.datepicker._adjustDate(e.target,r?-1:1,"D"),n=e.ctrlKey||e.metaKey,e.originalEvent.altKey&&$.datepicker._adjustDate(e.target,e.ctrlKey?+$.datepicker._get(t,"stepBigMonths"):+$.datepicker._get(t,"stepMonths"),"M");break;case 40:(e.ctrlKey||e.metaKey)&&$.datepicker._adjustDate(e.target,7,"D"),n=e.ctrlKey||e.metaKey;break;default:n=!1}else e.keyCode==36&&e.ctrlKey?$.datepicker._showDatepicker(this):n=!1;n&&(e.preventDefault(),e.stopPropagation())},_doKeyPress:function(e){var t=$.datepicker._getInst(e.target);if($.datepicker._get(t,"constrainInput")){var n=$.datepicker._possibleChars($.datepicker._get(t,"dateFormat")),r=String.fromCharCode(e.charCode==undefined?e.keyCode:e.charCode);return e.ctrlKey||e.metaKey||r<" "||!n||n.indexOf(r)>-1}},_doKeyUp:function(e){var t=$.datepicker._getInst(e.target);if(t.input.val()!=t.lastVal)try{var n=$.datepicker.parseDate($.datepicker._get(t,"dateFormat"),t.input?t.input.val():null,$.datepicker._getFormatConfig(t));n&&($.datepicker._setDateFromField(t),$.datepicker._updateAlternate(t),$.datepicker._updateDatepicker(t))}catch(r){$.datepicker.log(r)}return!0},_showDatepicker:function(e){e=e.target||e,e.nodeName.toLowerCase()!="input"&&(e=$("input",e.parentNode)[0]);if($.datepicker._isDisabledDatepicker(e)||$.datepicker._lastInput==e)return;var t=$.datepicker._getInst(e);$.datepicker._curInst&&$.datepicker._curInst!=t&&($.datepicker._curInst.dpDiv.stop(!0,!0),t&&$.datepicker._datepickerShowing&&$.datepicker._hideDatepicker($.datepicker._curInst.input[0]));var n=$.datepicker._get(t,"beforeShow"),r=n?n.apply(e,[e,t]):{};if(r===!1)return;extendRemove(t.settings,r),t.lastVal=null,$.datepicker._lastInput=e,$.datepicker._setDateFromField(t),$.datepicker._inDialog&&(e.value=""),$.datepicker._pos||($.datepicker._pos=$.datepicker._findPos(e),$.datepicker._pos[1]+=e.offsetHeight);var i=!1;$(e).parents().each(function(){return i|=$(this).css("position")=="fixed",!i});var s={left:$.datepicker._pos[0],top:$.datepicker._pos[1]};$.datepicker._pos=null,t.dpDiv.empty(),t.dpDiv.css({position:"absolute",display:"block",top:"-1000px"}),$.datepicker._updateDatepicker(t),s=$.datepicker._checkOffset(t,s,i),t.dpDiv.css({position:$.datepicker._inDialog&&$.blockUI?"static":i?"fixed":"absolute",display:"none",left:s.left+"px",top:s.top+"px"});if(!t.inline){var o=$.datepicker._get(t,"showAnim"),u=$.datepicker._get(t,"duration"),a=function(){var e=t.dpDiv.find("iframe.ui-datepicker-cover");if(!!e.length){var n=$.datepicker._getBorders(t.dpDiv);e.css({left:-n[0],top:-n[1],width:t.dpDiv.outerWidth(),height:t.dpDiv.outerHeight()})}};t.dpDiv.zIndex($(e).zIndex()+1),$.datepicker._datepickerShowing=!0,$.effects&&($.effects.effect[o]||$.effects[o])?t.dpDiv.show(o,$.datepicker._get(t,"showOptions"),u,a):t.dpDiv[o||"show"](o?u:null,a),(!o||!u)&&a(),t.input.is(":visible")&&!t.input.is(":disabled")&&t.input.focus(),$.datepicker._curInst=t}},_updateDatepicker:function(e){this.maxRows=4;var t=$.datepicker._getBorders(e.dpDiv);instActive=e,e.dpDiv.empty().append(this._generateHTML(e)),this._attachHandlers(e);var n=e.dpDiv.find("iframe.ui-datepicker-cover");!n.length||n.css({left:-t[0],top:-t[1],width:e.dpDiv.outerWidth(),height:e.dpDiv.outerHeight()}),e.dpDiv.find("."+this._dayOverClass+" a").mouseover();var r=this._getNumberOfMonths(e),i=r[1],s=17;e.dpDiv.removeClass("ui-datepicker-multi-2 ui-datepicker-multi-3 ui-datepicker-multi-4").width(""),i>1&&e.dpDiv.addClass("ui-datepicker-multi-"+i).css("width",s*i+"em"),e.dpDiv[(r[0]!=1||r[1]!=1?"add":"remove")+"Class"]("ui-datepicker-multi"),e.dpDiv[(this._get(e,"isRTL")?"add":"remove")+"Class"]("ui-datepicker-rtl"),e==$.datepicker._curInst&&$.datepicker._datepickerShowing&&e.input&&e.input.is(":visible")&&!e.input.is(":disabled")&&e.input[0]!=document.activeElement&&e.input.focus();if(e.yearshtml){var o=e.yearshtml;setTimeout(function(){o===e.yearshtml&&e.yearshtml&&e.dpDiv.find("select.ui-datepicker-year:first").replaceWith(e.yearshtml),o=e.yearshtml=null},0)}},_getBorders:function(e){var t=function(e){return{thin:1,medium:2,thick:3}[e]||e};return[parseFloat(t(e.css("border-left-width"))),parseFloat(t(e.css("border-top-width")))]},_checkOffset:function(e,t,n){var r=e.dpDiv.outerWidth(),i=e.dpDiv.outerHeight(),s=e.input?e.input.outerWidth():0,o=e.input?e.input.outerHeight():0,u=document.documentElement.clientWidth+(n?0:$(document).scrollLeft()),a=document.documentElement.clientHeight+(n?0:$(document).scrollTop());return t.left-=this._get(e,"isRTL")?r-s:0,t.left-=n&&t.left==e.input.offset().left?$(document).scrollLeft():0,t.top-=n&&t.top==e.input.offset().top+o?$(document).scrollTop():0,t.left-=Math.min(t.left,t.left+r>u&&u>r?Math.abs(t.left+r-u):0),t.top-=Math.min(t.top,t.top+i>a&&a>i?Math.abs(i+o):0),t},_findPos:function(e){var t=this._getInst(e),n=this._get(t,"isRTL");while(e&&(e.type=="hidden"||e.nodeType!=1||$.expr.filters.hidden(e)))e=e[n?"previousSibling":"nextSibling"];var r=$(e).offset();return[r.left,r.top]},_hideDatepicker:function(e){var t=this._curInst;if(!t||e&&t!=$.data(e,PROP_NAME))return;if(this._datepickerShowing){var n=this._get(t,"showAnim"),r=this._get(t,"duration"),i=function(){$.datepicker._tidyDialog(t)};$.effects&&($.effects.effect[n]||$.effects[n])?t.dpDiv.hide(n,$.datepicker._get(t,"showOptions"),r,i):t.dpDiv[n=="slideDown"?"slideUp":n=="fadeIn"?"fadeOut":"hide"](n?r:null,i),n||i(),this._datepickerShowing=!1;var s=this._get(t,"onClose");s&&s.apply(t.input?t.input[0]:null,[t.input?t.input.val():"",t]),this._lastInput=null,this._inDialog&&(this._dialogInput.css({position:"absolute",left:"0",top:"-100px"}),$.blockUI&&($.unblockUI(),$("body").append(this.dpDiv))),this._inDialog=!1}},_tidyDialog:function(e){e.dpDiv.removeClass(this._dialogClass).unbind(".ui-datepicker-calendar")},_checkExternalClick:function(e){if(!$.datepicker._curInst)return;var t=$(e.target),n=$.datepicker._getInst(t[0]);(t[0].id!=$.datepicker._mainDivId&&t.parents("#"+$.datepicker._mainDivId).length==0&&!t.hasClass($.datepicker.markerClassName)&&!t.closest("."+$.datepicker._triggerClass).length&&$.datepicker._datepickerShowing&&(!$.datepicker._inDialog||!$.blockUI)||t.hasClass($.datepicker.markerClassName)&&$.datepicker._curInst!=n)&&$.datepicker._hideDatepicker()},_adjustDate:function(e,t,n){var r=$(e),i=this._getInst(r[0]);if(this._isDisabledDatepicker(r[0]))return;this._adjustInstDate(i,t+(n=="M"?this._get(i,"showCurrentAtPos"):0),n),this._updateDatepicker(i)},_gotoToday:function(e){var t=$(e),n=this._getInst(t[0]);if(this._get(n,"gotoCurrent")&&n.currentDay)n.selectedDay=n.currentDay,n.drawMonth=n.selectedMonth=n.currentMonth,n.drawYear=n.selectedYear=n.currentYear;else{var r=new Date;n.selectedDay=r.getDate(),n.drawMonth=n.selectedMonth=r.getMonth(),n.drawYear=n.selectedYear=r.getFullYear()}this._notifyChange(n),this._adjustDate(t)},_selectMonthYear:function(e,t,n){var r=$(e),i=this._getInst(r[0]);i["selected"+(n=="M"?"Month":"Year")]=i["draw"+(n=="M"?"Month":"Year")]=parseInt(t.options[t.selectedIndex].value,10),this._notifyChange(i),this._adjustDate(r)},_selectDay:function(e,t,n,r){var i=$(e);if($(r).hasClass(this._unselectableClass)||this._isDisabledDatepicker(i[0]))return;var s=this._getInst(i[0]);s.selectedDay=s.currentDay=$("a",r).html(),s.selectedMonth=s.currentMonth=t,s.selectedYear=s.currentYear=n,this._selectDate(e,this._formatDate(s,s.currentDay,s.currentMonth,s.currentYear))},_clearDate:function(e){var t=$(e),n=this._getInst(t[0]);this._selectDate(t,"")},_selectDate:function(e,t){var n=$(e),r=this._getInst(n[0]);t=t!=null?t:this._formatDate(r),r.input&&r.input.val(t),this._updateAlternate(r);var i=this._get(r,"onSelect");i?i.apply(r.input?r.input[0]:null,[t,r]):r.input&&r.input.trigger("change"),r.inline?this._updateDatepicker(r):(this._hideDatepicker(),this._lastInput=r.input[0],typeof r.input[0]!="object"&&r.input.focus(),this._lastInput=null)},_updateAlternate:function(e){var t=this._get(e,"altField");if(t){var n=this._get(e,"altFormat")||this._get(e,"dateFormat"),r=this._getDate(e),i=this.formatDate(n,r,this._getFormatConfig(e));$(t).each(function(){$(this).val(i)})}},noWeekends:function(e){var t=e.getDay();return[t>0&&t<6,""]},iso8601Week:function(e){var t=new Date(e.getTime());t.setDate(t.getDate()+4-(t.getDay()||7));var n=t.getTime();return t.setMonth(0),t.setDate(1),Math.floor(Math.round((n-t)/864e5)/7)+1},parseDate:function(e,t,n){if(e==null||t==null)throw"Invalid arguments";t=typeof t=="object"?t.toString():t+"";if(t=="")return null;var r=(n?n.shortYearCutoff:null)||this._defaults.shortYearCutoff;r=typeof r!="string"?r:(new Date).getFullYear()%100+parseInt(r,10);var i=(n?n.dayNamesShort:null)||this._defaults.dayNamesShort,s=(n?n.dayNames:null)||this._defaults.dayNames,o=(n?n.monthNamesShort:null)||this._defaults.monthNamesShort,u=(n?n.monthNames:null)||this._defaults.monthNames,a=-1,f=-1,l=-1,c=-1,h=!1,p=function(t){var n=y+1<e.length&&e.charAt(y+1)==t;return n&&y++,n},d=function(e){var n=p(e),r=e=="@"?14:e=="!"?20:e=="y"&&n?4:e=="o"?3:2,i=new RegExp("^\\d{1,"+r+"}"),s=t.substring(g).match(i);if(!s)throw"Missing number at position "+g;return g+=s[0].length,parseInt(s[0],10)},v=function(e,n,r){var i=$.map(p(e)?r:n,function(e,t){return[[t,e]]}).sort(function(e,t){return-(e[1].length-t[1].length)}),s=-1;$.each(i,function(e,n){var r=n[1];if(t.substr(g,r.length).toLowerCase()==r.toLowerCase())return s=n[0],g+=r.length,!1});if(s!=-1)return s+1;throw"Unknown name at position "+g},m=function(){if(t.charAt(g)!=e.charAt(y))throw"Unexpected literal at position "+g;g++},g=0;for(var y=0;y<e.length;y++)if(h)e.charAt(y)=="'"&&!p("'")?h=!1:m();else switch(e.charAt(y)){case"d":l=d("d");break;case"D":v("D",i,s);break;case"o":c=d("o");break;case"m":f=d("m");break;case"M":f=v("M",o,u);break;case"y":a=d("y");break;case"@":var b=new Date(d("@"));a=b.getFullYear(),f=b.getMonth()+1,l=b.getDate();break;case"!":var b=new Date((d("!")-this._ticksTo1970)/1e4);a=b.getFullYear(),f=b.getMonth()+1,l=b.getDate();break;case"'":p("'")?m():h=!0;break;default:m()}if(g<t.length){var w=t.substr(g);if(!/^\s+/.test(w))throw"Extra/unparsed characters found in date: "+w}a==-1?a=(new Date).getFullYear():a<100&&(a+=(new Date).getFullYear()-(new Date).getFullYear()%100+(a<=r?0:-100));if(c>-1){f=1,l=c;do{var E=this._getDaysInMonth(a,f-1);if(l<=E)break;f++,l-=E}while(!0)}var b=this._daylightSavingAdjust(new Date(a,f-1,l));if(b.getFullYear()!=a||b.getMonth()+1!=f||b.getDate()!=l)throw"Invalid date";return b},ATOM:"yy-mm-dd",COOKIE:"D, dd M yy",ISO_8601:"yy-mm-dd",RFC_822:"D, d M y",RFC_850:"DD, dd-M-y",RFC_1036:"D, d M y",RFC_1123:"D, d M yy",RFC_2822:"D, d M yy",RSS:"D, d M y",TICKS:"!",TIMESTAMP:"@",W3C:"yy-mm-dd",_ticksTo1970:(718685+Math.floor(492.5)-Math.floor(19.7)+Math.floor(4.925))*24*60*60*1e7,formatDate:function(e,t,n){if(!t)return"";var r=(n?n.dayNamesShort:null)||this._defaults.dayNamesShort,i=(n?n.dayNames:null)||this._defaults.dayNames,s=(n?n.monthNamesShort:null)||this._defaults.monthNamesShort,o=(n?n.monthNames:null)||this._defaults.monthNames,u=function(t){var n=h+1<e.length&&e.charAt(h+1)==t;return n&&h++,n},a=function(e,t,n){var r=""+t;if(u(e))while(r.length<n)r="0"+r;return r},f=function(e,t,n,r){return u(e)?r[t]:n[t]},l="",c=!1;if(t)for(var h=0;h<e.length;h++)if(c)e.charAt(h)=="'"&&!u("'")?c=!1:l+=e.charAt(h);else switch(e.charAt(h)){case"d":l+=a("d",t.getDate(),2);break;case"D":l+=f("D",t.getDay(),r,i);break;case"o":l+=a("o",Math.round(((new Date(t.getFullYear(),t.getMonth(),t.getDate())).getTime()-(new Date(t.getFullYear(),0,0)).getTime())/864e5),3);break;case"m":l+=a("m",t.getMonth()+1,2);break;case"M":l+=f("M",t.getMonth(),s,o);break;case"y":l+=u("y")?t.getFullYear():(t.getYear()%100<10?"0":"")+t.getYear()%100;break;case"@":l+=t.getTime();break;case"!":l+=t.getTime()*1e4+this._ticksTo1970;break;case"'":u("'")?l+="'":c=!0;break;default:l+=e.charAt(h)}return l},_possibleChars:function(e){var t="",n=!1,r=function(t){var n=i+1<e.length&&e.charAt(i+1)==t;return n&&i++,n};for(var i=0;i<e.length;i++)if(n)e.charAt(i)=="'"&&!r("'")?n=!1:t+=e.charAt(i);else switch(e.charAt(i)){case"d":case"m":case"y":case"@":t+="0123456789";break;case"D":case"M":return null;case"'":r("'")?t+="'":n=!0;break;default:t+=e.charAt(i)}return t},_get:function(e,t){return e.settings[t]!==undefined?e.settings[t]:this._defaults[t]},_setDateFromField:function(e,t){if(e.input.val()==e.lastVal)return;var n=this._get(e,"dateFormat"),r=e.lastVal=e.input?e.input.val():null,i,s;i=s=this._getDefaultDate(e);var o=this._getFormatConfig(e);try{i=this.parseDate(n,r,o)||s}catch(u){this.log(u),r=t?"":r}e.selectedDay=i.getDate(),e.drawMonth=e.selectedMonth=i.getMonth(),e.drawYear=e.selectedYear=i.getFullYear(),e.currentDay=r?i.getDate():0,e.currentMonth=r?i.getMonth():0,e.currentYear=r?i.getFullYear():0,this._adjustInstDate(e)},_getDefaultDate:function(e){return this._restrictMinMax(e,this._determineDate(e,this._get(e,"defaultDate"),new Date))},_determineDate:function(e,t,n){var r=function(e){var t=new Date;return t.setDate(t.getDate()+e),t},i=function(t){try{return $.datepicker.parseDate($.datepicker._get(e,"dateFormat"),t,$.datepicker._getFormatConfig(e))}catch(n){}var r=(t.toLowerCase().match(/^c/)?$.datepicker._getDate(e):null)||new Date,i=r.getFullYear(),s=r.getMonth(),o=r.getDate(),u=/([+-]?[0-9]+)\s*(d|D|w|W|m|M|y|Y)?/g,a=u.exec(t);while(a){switch(a[2]||"d"){case"d":case"D":o+=parseInt(a[1],10);break;case"w":case"W":o+=parseInt(a[1],10)*7;break;case"m":case"M":s+=parseInt(a[1],10),o=Math.min(o,$.datepicker._getDaysInMonth(i,s));break;case"y":case"Y":i+=parseInt(a[1],10),o=Math.min(o,$.datepicker._getDaysInMonth(i,s))}a=u.exec(t)}return new Date(i,s,o)},s=t==null||t===""?n:typeof t=="string"?i(t):typeof t=="number"?isNaN(t)?n:r(t):new Date(t.getTime());return s=s&&s.toString()=="Invalid Date"?n:s,s&&(s.setHours(0),s.setMinutes(0),s.setSeconds(0),s.setMilliseconds(0)),this._daylightSavingAdjust(s)},_daylightSavingAdjust:function(e){return e?(e.setHours(e.getHours()>12?e.getHours()+2:0),e):null},_setDate:function(e,t,n){var r=!t,i=e.selectedMonth,s=e.selectedYear,o=this._restrictMinMax(e,this._determineDate(e,t,new Date));e.selectedDay=e.currentDay=o.getDate(),e.drawMonth=e.selectedMonth=e.currentMonth=o.getMonth(),e.drawYear=e.selectedYear=e.currentYear=o.getFullYear(),(i!=e.selectedMonth||s!=e.selectedYear)&&!n&&this._notifyChange(e),this._adjustInstDate(e),e.input&&e.input.val(r?"":this._formatDate(e))},_getDate:function(e){var t=!e.currentYear||e.input&&e.input.val()==""?null:this._daylightSavingAdjust(new Date(e.currentYear,e.currentMonth,e.currentDay));return t},_attachHandlers:function(e){var t=this._get(e,"stepMonths"),n="#"+e.id.replace(/\\\\/g,"\\");e.dpDiv.find("[data-handler]").map(function(){var e={prev:function(){window["DP_jQuery_"+dpuuid].datepicker._adjustDate(n,-t,"M")},next:function(){window["DP_jQuery_"+dpuuid].datepicker._adjustDate(n,+t,"M")},hide:function(){window["DP_jQuery_"+dpuuid].datepicker._hideDatepicker()},today:function(){window["DP_jQuery_"+dpuuid].datepicker._gotoToday(n)},selectDay:function(){return window["DP_jQuery_"+dpuuid].datepicker._selectDay(n,+this.getAttribute("data-month"),+this.getAttribute("data-year"),this),!1},selectMonth:function(){return window["DP_jQuery_"+dpuuid].datepicker._selectMonthYear(n,this,"M"),!1},selectYear:function(){return window["DP_jQuery_"+dpuuid].datepicker._selectMonthYear(n,this,"Y"),!1}};$(this).bind(this.getAttribute("data-event"),e[this.getAttribute("data-handler")])})},_generateHTML:function(e){var t=new Date;t=this._daylightSavingAdjust(new Date(t.getFullYear(),t.getMonth(),t.getDate()));var n=this._get(e,"isRTL"),r=this._get(e,"showButtonPanel"),i=this._get(e,"hideIfNoPrevNext"),s=this._get(e,"navigationAsDateFormat"),o=this._getNumberOfMonths(e),u=this._get(e,"showCurrentAtPos"),a=this._get(e,"stepMonths"),f=o[0]!=1||o[1]!=1,l=this._daylightSavingAdjust(e.currentDay?new Date(e.currentYear,e.currentMonth,e.currentDay):new Date(9999,9,9)),c=this._getMinMaxDate(e,"min"),h=this._getMinMaxDate(e,"max"),p=e.drawMonth-u,d=e.drawYear;p<0&&(p+=12,d--);if(h){var v=this._daylightSavingAdjust(new Date(h.getFullYear(),h.getMonth()-o[0]*o[1]+1,h.getDate()));v=c&&v<c?c:v;while(this._daylightSavingAdjust(new Date(d,p,1))>v)p--,p<0&&(p=11,d--)}e.drawMonth=p,e.drawYear=d;var m=this._get(e,"prevText");m=s?this.formatDate(m,this._daylightSavingAdjust(new Date(d,p-a,1)),this._getFormatConfig(e)):m;var g=this._canAdjustMonth(e,-1,d,p)?'<a class="ui-datepicker-prev ui-corner-all" data-handler="prev" data-event="click" title="'+m+'"><span class="ui-icon ui-icon-circle-triangle-'+(n?"e":"w")+'">'+m+"</span></a>":i?"":'<a class="ui-datepicker-prev ui-corner-all ui-state-disabled" title="'+m+'"><span class="ui-icon ui-icon-circle-triangle-'+(n?"e":"w")+'">'+m+"</span></a>",y=this._get(e,"nextText");y=s?this.formatDate(y,this._daylightSavingAdjust(new Date(d,p+a,1)),this._getFormatConfig(e)):y;var b=this._canAdjustMonth(e,1,d,p)?'<a class="ui-datepicker-next ui-corner-all" data-handler="next" data-event="click" title="'+y+'"><span class="ui-icon ui-icon-circle-triangle-'+(n?"w":"e")+'">'+y+"</span></a>":i?"":'<a class="ui-datepicker-next ui-corner-all ui-state-disabled" title="'+y+'"><span class="ui-icon ui-icon-circle-triangle-'+(n?"w":"e")+'">'+y+"</span></a>",w=this._get(e,"currentText"),E=this._get(e,"gotoCurrent")&&e.currentDay?l:t;w=s?this.formatDate(w,E,this._getFormatConfig(e)):w;var S=e.inline?"":'<button type="button" class="ui-datepicker-close ui-state-default ui-priority-primary ui-corner-all" data-handler="hide" data-event="click">'+this._get(e,"closeText")+"</button>",x=r?'<div class="ui-datepicker-buttonpane ui-widget-content">'+(n?S:"")+(this._isInRange(e,E)?'<button type="button" class="ui-datepicker-current ui-state-default ui-priority-secondary ui-corner-all" data-handler="today" data-event="click">'+w+"</button>":"")+(n?"":S)+"</div>":"",T=parseInt(this._get(e,"firstDay"),10);T=isNaN(T)?0:T;var N=this._get(e,"showWeek"),C=this._get(e,"dayNames"),k=this._get(e,"dayNamesShort"),L=this._get(e,"dayNamesMin"),A=this._get(e,"monthNames"),O=this._get(e,"monthNamesShort"),M=this._get(e,"beforeShowDay"),_=this._get(e,"showOtherMonths"),D=this._get(e,"selectOtherMonths"),P=this._get(e,"calculateWeek")||this.iso8601Week,H=this._getDefaultDate(e),B="";for(var j=0;j<o[0];j++){var F="";this.maxRows=4;for(var I=0;I<o[1];I++){var q=this._daylightSavingAdjust(new Date(d,p,e.selectedDay)),R=" ui-corner-all",U="";if(f){U+='<div class="ui-datepicker-group';if(o[1]>1)switch(I){case 0:U+=" ui-datepicker-group-first",R=" ui-corner-"+(n?"right":"left");break;case o[1]-1:U+=" ui-datepicker-group-last",R=" ui-corner-"+(n?"left":"right");break;default:U+=" ui-datepicker-group-middle",R=""}U+='">'}U+='<div class="ui-datepicker-header ui-widget-header ui-helper-clearfix'+R+'">'+(/all|left/.test(R)&&j==0?n?b:g:"")+(/all|right/.test(R)&&j==0?n?g:b:"")+this._generateMonthYearHeader(e,p,d,c,h,j>0||I>0,A,O)+'</div><table class="ui-datepicker-calendar"><thead>'+"<tr>";var z=N?'<th class="ui-datepicker-week-col">'+this._get(e,"weekHeader")+"</th>":"";for(var W=0;W<7;W++){var X=(W+T)%7;z+="<th"+((W+T+6)%7>=5?' class="ui-datepicker-week-end"':"")+">"+'<span title="'+C[X]+'">'+L[X]+"</span></th>"}U+=z+"</tr></thead><tbody>";var V=this._getDaysInMonth(d,p);d==e.selectedYear&&p==e.selectedMonth&&(e.selectedDay=Math.min(e.selectedDay,V));var J=(this._getFirstDayOfMonth(d,p)-T+7)%7,K=Math.ceil((J+V)/7),Q=f?this.maxRows>K?this.maxRows:K:K;this.maxRows=Q;var G=this._daylightSavingAdjust(new Date(d,p,1-J));for(var Y=0;Y<Q;Y++){U+="<tr>";var Z=N?'<td class="ui-datepicker-week-col">'+this._get(e,"calculateWeek")(G)+"</td>":"";for(var W=0;W<7;W++){var et=M?M.apply(e.input?e.input[0]:null,[G]):[!0,""],tt=G.getMonth()!=p,nt=tt&&!D||!et[0]||c&&G<c||h&&G>h;Z+='<td class="'+((W+T+6)%7>=5?" ui-datepicker-week-end":"")+(tt?" ui-datepicker-other-month":"")+(G.getTime()==q.getTime()&&p==e.selectedMonth&&e._keyEvent||H.getTime()==G.getTime()&&H.getTime()==q.getTime()?" "+this._dayOverClass:"")+(nt?" "+this._unselectableClass+" ui-state-disabled":"")+(tt&&!_?"":" "+et[1]+(G.getTime()==l.getTime()?" "+this._currentClass:"")+(G.getTime()==t.getTime()?" ui-datepicker-today":""))+'"'+((!tt||_)&&et[2]?' title="'+et[2]+'"':"")+(nt?"":' data-handler="selectDay" data-event="click" data-month="'+G.getMonth()+'" data-year="'+G.getFullYear()+'"')+">"+(tt&&!_?"&#xa0;":nt?'<span class="ui-state-default">'+G.getDate()+"</span>":'<a class="ui-state-default'+(G.getTime()==t.getTime()?" ui-state-highlight":"")+(G.getTime()==l.getTime()?" ui-state-active":"")+(tt?" ui-priority-secondary":"")+'" href="#">'+G.getDate()+"</a>")+"</td>",G.setDate(G.getDate()+1),G=this._daylightSavingAdjust(G)}U+=Z+"</tr>"}p++,p>11&&(p=0,d++),U+="</tbody></table>"+(f?"</div>"+(o[0]>0&&I==o[1]-1?'<div class="ui-datepicker-row-break"></div>':""):""),F+=U}B+=F}return B+=x+($.ui.ie6&&!e.inline?'<iframe src="javascript:false;" class="ui-datepicker-cover" frameborder="0"></iframe>':""),e._keyEvent=!1,B},_generateMonthYearHeader:function(e,t,n,r,i,s,o,u){var a=this._get(e,"changeMonth"),f=this._get(e,"changeYear"),l=this._get(e,"showMonthAfterYear"),c='<div class="ui-datepicker-title">',h="";if(s||!a)h+='<span class="ui-datepicker-month">'+o[t]+"</span>";else{var p=r&&r.getFullYear()==n,d=i&&i.getFullYear()==n;h+='<select class="ui-datepicker-month" data-handler="selectMonth" data-event="change">';for(var v=0;v<12;v++)(!p||v>=r.getMonth())&&(!d||v<=i.getMonth())&&(h+='<option value="'+v+'"'+(v==t?' selected="selected"':"")+">"+u[v]+"</option>");h+="</select>"}l||(c+=h+(s||!a||!f?"&#xa0;":""));if(!e.yearshtml){e.yearshtml="";if(s||!f)c+='<span class="ui-datepicker-year">'+n+"</span>";else{var m=this._get(e,"yearRange").split(":"),g=(new Date).getFullYear(),y=function(e){var t=e.match(/c[+-].*/)?n+parseInt(e.substring(1),10):e.match(/[+-].*/)?g+parseInt(e,10):parseInt(e,10);return isNaN(t)?g:t},b=y(m[0]),w=Math.max(b,y(m[1]||""));b=r?Math.max(b,r.getFullYear()):b,w=i?Math.min(w,i.getFullYear()):w,e.yearshtml+='<select class="ui-datepicker-year" data-handler="selectYear" data-event="change">';for(;b<=w;b++)e.yearshtml+='<option value="'+b+'"'+(b==n?' selected="selected"':"")+">"+b+"</option>";e.yearshtml+="</select>",c+=e.yearshtml,e.yearshtml=null}}return c+=this._get(e,"yearSuffix"),l&&(c+=(s||!a||!f?"&#xa0;":"")+h),c+="</div>",c},_adjustInstDate:function(e,t,n){var r=e.drawYear+(n=="Y"?t:0),i=e.drawMonth+(n=="M"?t:0),s=Math.min(e.selectedDay,this._getDaysInMonth(r,i))+(n=="D"?t:0),o=this._restrictMinMax(e,this._daylightSavingAdjust(new Date(r,i,s)));e.selectedDay=o.getDate(),e.drawMonth=e.selectedMonth=o.getMonth(),e.drawYear=e.selectedYear=o.getFullYear(),(n=="M"||n=="Y")&&this._notifyChange(e)},_restrictMinMax:function(e,t){var n=this._getMinMaxDate(e,"min"),r=this._getMinMaxDate(e,"max"),i=n&&t<n?n:t;return i=r&&i>r?r:i,i},_notifyChange:function(e){var t=this._get(e,"onChangeMonthYear");t&&t.apply(e.input?e.input[0]:null,[e.selectedYear,e.selectedMonth+1,e])},_getNumberOfMonths:function(e){var t=this._get(e,"numberOfMonths");return t==null?[1,1]:typeof t=="number"?[1,t]:t},_getMinMaxDate:function(e,t){return this._determineDate(e,this._get(e,t+"Date"),null)},_getDaysInMonth:function(e,t){return 32-this._daylightSavingAdjust(new Date(e,t,32)).getDate()},_getFirstDayOfMonth:function(e,t){return(new Date(e,t,1)).getDay()},_canAdjustMonth:function(e,t,n,r){var i=this._getNumberOfMonths(e),s=this._daylightSavingAdjust(new Date(n,r+(t<0?t:i[0]*i[1]),1));return t<0&&s.setDate(this._getDaysInMonth(s.getFullYear(),s.getMonth())),this._isInRange(e,s)},_isInRange:function(e,t){var n=this._getMinMaxDate(e,"min"),r=this._getMinMaxDate(e,"max");return(!n||t.getTime()>=n.getTime())&&(!r||t.getTime()<=r.getTime())},_getFormatConfig:function(e){var t=this._get(e,"shortYearCutoff");return t=typeof t!="string"?t:(new Date).getFullYear()%100+parseInt(t,10),{shortYearCutoff:t,dayNamesShort:this._get(e,"dayNamesShort"),dayNames:this._get(e,"dayNames"),monthNamesShort:this._get(e,"monthNamesShort"),monthNames:this._get(e,"monthNames")}},_formatDate:function(e,t,n,r){t||(e.currentDay=e.selectedDay,e.currentMonth=e.selectedMonth,e.currentYear=e.selectedYear);var i=t?typeof t=="object"?t:this._daylightSavingAdjust(new Date(r,n,t)):this._daylightSavingAdjust(new Date(e.currentYear,e.currentMonth,e.currentDay));return this.formatDate(this._get(e,"dateFormat"),i,this._getFormatConfig(e))}}),$.fn.datepicker=function(e){if(!this.length)return this;$.datepicker.initialized||($(document).mousedown($.datepicker._checkExternalClick).find(document.body).append($.datepicker.dpDiv),$.datepicker.initialized=!0);var t=Array.prototype.slice.call(arguments,1);return typeof e!="string"||e!="isDisabled"&&e!="getDate"&&e!="widget"?e=="option"&&arguments.length==2&&typeof arguments[1]=="string"?$.datepicker["_"+e+"Datepicker"].apply($.datepicker,[this[0]].concat(t)):this.each(function(){typeof e=="string"?$.datepicker["_"+e+"Datepicker"].apply($.datepicker,[this].concat(t)):$.datepicker._attachDatepicker(this,e)}):$.datepicker["_"+e+"Datepicker"].apply($.datepicker,[this[0]].concat(t))},$.datepicker=new Datepicker,$.datepicker.initialized=!1,$.datepicker.uuid=(new Date).getTime(),$.datepicker.version="1.9.2",window["DP_jQuery_"+dpuuid]=$})(jQuery);(function(e,t){var n="ui-dialog ui-widget ui-widget-content ui-corner-all ",r={buttons:!0,height:!0,maxHeight:!0,maxWidth:!0,minHeight:!0,minWidth:!0,width:!0},i={maxHeight:!0,maxWidth:!0,minHeight:!0,minWidth:!0};e.widget("ui.dialog",{version:"1.9.2",options:{autoOpen:!0,buttons:{},closeOnEscape:!0,closeText:"close",dialogClass:"",draggable:!0,hide:null,height:"auto",maxHeight:!1,maxWidth:!1,minHeight:150,minWidth:150,modal:!1,position:{my:"center",at:"center",of:window,collision:"fit",using:function(t){var n=e(this).css(t).offset().top;n<0&&e(this).css("top",t.top-n)}},resizable:!0,show:null,stack:!0,title:"",width:300,zIndex:1e3},_create:function(){this.originalTitle=this.element.attr("title"),typeof this.originalTitle!="string"&&(this.originalTitle=""),this.oldPosition={parent:this.element.parent(),index:this.element.parent().children().index(this.element)},this.options.title=this.options.title||this.originalTitle;var t=this,r=this.options,i=r.title||"&#160;",s,o,u,a,f;s=(this.uiDialog=e("<div>")).addClass(n+r.dialogClass).css({display:"none",outline:0,zIndex:r.zIndex}).attr("tabIndex",-1).keydown(function(n){r.closeOnEscape&&!n.isDefaultPrevented()&&n.keyCode&&n.keyCode===e.ui.keyCode.ESCAPE&&(t.close(n),n.preventDefault())}).mousedown(function(e){t.moveToTop(!1,e)}).appendTo("body"),this.element.show().removeAttr("title").addClass("ui-dialog-content ui-widget-content").appendTo(s),o=(this.uiDialogTitlebar=e("<div>")).addClass("ui-dialog-titlebar  ui-widget-header  ui-corner-all  ui-helper-clearfix").bind("mousedown",function(){s.focus()}).prependTo(s),u=e("<a href='#'></a>").addClass("ui-dialog-titlebar-close  ui-corner-all").attr("role","button").click(function(e){e.preventDefault(),t.close(e)}).appendTo(o),(this.uiDialogTitlebarCloseText=e("<span>")).addClass("ui-icon ui-icon-closethick").text(r.closeText).appendTo(u),a=e("<span>").uniqueId().addClass("ui-dialog-title").html(i).prependTo(o),f=(this.uiDialogButtonPane=e("<div>")).addClass("ui-dialog-buttonpane ui-widget-content ui-helper-clearfix"),(this.uiButtonSet=e("<div>")).addClass("ui-dialog-buttonset").appendTo(f),s.attr({role:"dialog","aria-labelledby":a.attr("id")}),o.find("*").add(o).disableSelection(),this._hoverable(u),this._focusable(u),r.draggable&&e.fn.draggable&&this._makeDraggable(),r.resizable&&e.fn.resizable&&this._makeResizable(),this._createButtons(r.buttons),this._isOpen=!1,e.fn.bgiframe&&s.bgiframe(),this._on(s,{keydown:function(t){if(!r.modal||t.keyCode!==e.ui.keyCode.TAB)return;var n=e(":tabbable",s),i=n.filter(":first"),o=n.filter(":last");if(t.target===o[0]&&!t.shiftKey)return i.focus(1),!1;if(t.target===i[0]&&t.shiftKey)return o.focus(1),!1}})},_init:function(){this.options.autoOpen&&this.open()},_destroy:function(){var e,t=this.oldPosition;this.overlay&&this.overlay.destroy(),this.uiDialog.hide(),this.element.removeClass("ui-dialog-content ui-widget-content").hide().appendTo("body"),this.uiDialog.remove(),this.originalTitle&&this.element.attr("title",this.originalTitle),e=t.parent.children().eq(t.index),e.length&&e[0]!==this.element[0]?e.before(this.element):t.parent.append(this.element)},widget:function(){return this.uiDialog},close:function(t){var n=this,r,i;if(!this._isOpen)return;if(!1===this._trigger("beforeClose",t))return;return this._isOpen=!1,this.overlay&&this.overlay.destroy(),this.options.hide?this._hide(this.uiDialog,this.options.hide,function(){n._trigger("close",t)}):(this.uiDialog.hide(),this._trigger("close",t)),e.ui.dialog.overlay.resize(),this.options.modal&&(r=0,e(".ui-dialog").each(function(){this!==n.uiDialog[0]&&(i=e(this).css("z-index"),isNaN(i)||(r=Math.max(r,i)))}),e.ui.dialog.maxZ=r),this},isOpen:function(){return this._isOpen},moveToTop:function(t,n){var r=this.options,i;return r.modal&&!t||!r.stack&&!r.modal?this._trigger("focus",n):(r.zIndex>e.ui.dialog.maxZ&&(e.ui.dialog.maxZ=r.zIndex),this.overlay&&(e.ui.dialog.maxZ+=1,e.ui.dialog.overlay.maxZ=e.ui.dialog.maxZ,this.overlay.$el.css("z-index",e.ui.dialog.overlay.maxZ)),i={scrollTop:this.element.scrollTop(),scrollLeft:this.element.scrollLeft()},e.ui.dialog.maxZ+=1,this.uiDialog.css("z-index",e.ui.dialog.maxZ),this.element.attr(i),this._trigger("focus",n),this)},open:function(){if(this._isOpen)return;var t,n=this.options,r=this.uiDialog;return this._size(),this._position(n.position),r.show(n.show),this.overlay=n.modal?new e.ui.dialog.overlay(this):null,this.moveToTop(!0),t=this.element.find(":tabbable"),t.length||(t=this.uiDialogButtonPane.find(":tabbable"),t.length||(t=r)),t.eq(0).focus(),this._isOpen=!0,this._trigger("open"),this},_createButtons:function(t){var n=this,r=!1;this.uiDialogButtonPane.remove(),this.uiButtonSet.empty(),typeof t=="object"&&t!==null&&e.each(t,function(){return!(r=!0)}),r?(e.each(t,function(t,r){var i,s;r=e.isFunction(r)?{click:r,text:t}:r,r=e.extend({type:"button"},r),s=r.click,r.click=function(){s.apply(n.element[0],arguments)},i=e("<button></button>",r).appendTo(n.uiButtonSet),e.fn.button&&i.button()}),this.uiDialog.addClass("ui-dialog-buttons"),this.uiDialogButtonPane.appendTo(this.uiDialog)):this.uiDialog.removeClass("ui-dialog-buttons")},_makeDraggable:function(){function r(e){return{position:e.position,offset:e.offset}}var t=this,n=this.options;this.uiDialog.draggable({cancel:".ui-dialog-content, .ui-dialog-titlebar-close",handle:".ui-dialog-titlebar",containment:"document",start:function(n,i){e(this).addClass("ui-dialog-dragging"),t._trigger("dragStart",n,r(i))},drag:function(e,n){t._trigger("drag",e,r(n))},stop:function(i,s){n.position=[s.position.left-t.document.scrollLeft(),s.position.top-t.document.scrollTop()],e(this).removeClass("ui-dialog-dragging"),t._trigger("dragStop",i,r(s)),e.ui.dialog.overlay.resize()}})},_makeResizable:function(n){function u(e){return{originalPosition:e.originalPosition,originalSize:e.originalSize,position:e.position,size:e.size}}n=n===t?this.options.resizable:n;var r=this,i=this.options,s=this.uiDialog.css("position"),o=typeof n=="string"?n:"n,e,s,w,se,sw,ne,nw";this.uiDialog.resizable({cancel:".ui-dialog-content",containment:"document",alsoResize:this.element,maxWidth:i.maxWidth,maxHeight:i.maxHeight,minWidth:i.minWidth,minHeight:this._minHeight(),handles:o,start:function(t,n){e(this).addClass("ui-dialog-resizing"),r._trigger("resizeStart",t,u(n))},resize:function(e,t){r._trigger("resize",e,u(t))},stop:function(t,n){e(this).removeClass("ui-dialog-resizing"),i.height=e(this).height(),i.width=e(this).width(),r._trigger("resizeStop",t,u(n)),e.ui.dialog.overlay.resize()}}).css("position",s).find(".ui-resizable-se").addClass("ui-icon ui-icon-grip-diagonal-se")},_minHeight:function(){var e=this.options;return e.height==="auto"?e.minHeight:Math.min(e.minHeight,e.height)},_position:function(t){var n=[],r=[0,0],i;if(t){if(typeof t=="string"||typeof t=="object"&&"0"in t)n=t.split?t.split(" "):[t[0],t[1]],n.length===1&&(n[1]=n[0]),e.each(["left","top"],function(e,t){+n[e]===n[e]&&(r[e]=n[e],n[e]=t)}),t={my:n[0]+(r[0]<0?r[0]:"+"+r[0])+" "+n[1]+(r[1]<0?r[1]:"+"+r[1]),at:n.join(" ")};t=e.extend({},e.ui.dialog.prototype.options.position,t)}else t=e.ui.dialog.prototype.options.position;i=this.uiDialog.is(":visible"),i||this.uiDialog.show(),this.uiDialog.position(t),i||this.uiDialog.hide()},_setOptions:function(t){var n=this,s={},o=!1;e.each(t,function(e,t){n._setOption(e,t),e in r&&(o=!0),e in i&&(s[e]=t)}),o&&this._size(),this.uiDialog.is(":data(resizable)")&&this.uiDialog.resizable("option",s)},_setOption:function(t,r){var i,s,o=this.uiDialog;switch(t){case"buttons":this._createButtons(r);break;case"closeText":this.uiDialogTitlebarCloseText.text(""+r);break;case"dialogClass":o.removeClass(this.options.dialogClass).addClass(n+r);break;case"disabled":r?o.addClass("ui-dialog-disabled"):o.removeClass("ui-dialog-disabled");break;case"draggable":i=o.is(":data(draggable)"),i&&!r&&o.draggable("destroy"),!i&&r&&this._makeDraggable();break;case"position":this._position(r);break;case"resizable":s=o.is(":data(resizable)"),s&&!r&&o.resizable("destroy"),s&&typeof r=="string"&&o.resizable("option","handles",r),!s&&r!==!1&&this._makeResizable(r);break;case"title":e(".ui-dialog-title",this.uiDialogTitlebar).html(""+(r||"&#160;"))}this._super(t,r)},_size:function(){var t,n,r,i=this.options,s=this.uiDialog.is(":visible");this.element.show().css({width:"auto",minHeight:0,height:0}),i.minWidth>i.width&&(i.width=i.minWidth),t=this.uiDialog.css({height:"auto",width:i.width}).outerHeight(),n=Math.max(0,i.minHeight-t),i.height==="auto"?e.support.minHeight?this.element.css({minHeight:n,height:"auto"}):(this.uiDialog.show(),r=this.element.css("height","auto").height(),s||this.uiDialog.hide(),this.element.height(Math.max(r,n))):this.element.height(Math.max(i.height-t,0)),this.uiDialog.is(":data(resizable)")&&this.uiDialog.resizable("option","minHeight",this._minHeight())}}),e.extend(e.ui.dialog,{uuid:0,maxZ:0,getTitleId:function(e){var t=e.attr("id");return t||(this.uuid+=1,t=this.uuid),"ui-dialog-title-"+t},overlay:function(t){this.$el=e.ui.dialog.overlay.create(t)}}),e.extend(e.ui.dialog.overlay,{instances:[],oldInstances:[],maxZ:0,events:e.map("focus,mousedown,mouseup,keydown,keypress,click".split(","),function(e){return e+".dialog-overlay"}).join(" "),create:function(t){this.instances.length===0&&(setTimeout(function(){e.ui.dialog.overlay.instances.length&&e(document).bind(e.ui.dialog.overlay.events,function(t){if(e(t.target).zIndex()<e.ui.dialog.overlay.maxZ)return!1})},1),e(window).bind("resize.dialog-overlay",e.ui.dialog.overlay.resize));var n=this.oldInstances.pop()||e("<div>").addClass("ui-widget-overlay");return e(document).bind("keydown.dialog-overlay",function(r){var i=e.ui.dialog.overlay.instances;i.length!==0&&i[i.length-1]===n&&t.options.closeOnEscape&&!r.isDefaultPrevented()&&r.keyCode&&r.keyCode===e.ui.keyCode.ESCAPE&&(t.close(r),r.preventDefault())}),n.appendTo(document.body).css({width:this.width(),height:this.height()}),e.fn.bgiframe&&n.bgiframe(),this.instances.push(n),n},destroy:function(t){var n=e.inArray(t,this.instances),r=0;n!==-1&&this.oldInstances.push(this.instances.splice(n,1)[0]),this.instances.length===0&&e([document,window]).unbind(".dialog-overlay"),t.height(0).width(0).remove(),e.each(this.instances,function(){r=Math.max(r,this.css("z-index"))}),this.maxZ=r},height:function(){var t,n;return e.ui.ie?(t=Math.max(document.documentElement.scrollHeight,document.body.scrollHeight),n=Math.max(document.documentElement.offsetHeight,document.body.offsetHeight),t<n?e(window).height()+"px":t+"px"):e(document).height()+"px"},width:function(){var t,n;return e.ui.ie?(t=Math.max(document.documentElement.scrollWidth,document.body.scrollWidth),n=Math.max(document.documentElement.offsetWidth,document.body.offsetWidth),t<n?e(window).width()+"px":t+"px"):e(document).width()+"px"},resize:function(){var t=e([]);e.each(e.ui.dialog.overlay.instances,function(){t=t.add(this)}),t.css({width:0,height:0}).css({width:e.ui.dialog.overlay.width(),height:e.ui.dialog.overlay.height()})}}),e.extend(e.ui.dialog.overlay.prototype,{destroy:function(){e.ui.dialog.overlay.destroy(this.$el)}})})(jQuery);(function(e,t){e.widget("ui.draggable",e.ui.mouse,{version:"1.9.2",widgetEventPrefix:"drag",options:{addClasses:!0,appendTo:"parent",axis:!1,connectToSortable:!1,containment:!1,cursor:"auto",cursorAt:!1,grid:!1,handle:!1,helper:"original",iframeFix:!1,opacity:!1,refreshPositions:!1,revert:!1,revertDuration:500,scope:"default",scroll:!0,scrollSensitivity:20,scrollSpeed:20,snap:!1,snapMode:"both",snapTolerance:20,stack:!1,zIndex:!1},_create:function(){this.options.helper=="original"&&!/^(?:r|a|f)/.test(this.element.css("position"))&&(this.element[0].style.position="relative"),this.options.addClasses&&this.element.addClass("ui-draggable"),this.options.disabled&&this.element.addClass("ui-draggable-disabled"),this._mouseInit()},_destroy:function(){this.element.removeClass("ui-draggable ui-draggable-dragging ui-draggable-disabled"),this._mouseDestroy()},_mouseCapture:function(t){var n=this.options;return this.helper||n.disabled||e(t.target).is(".ui-resizable-handle")?!1:(this.handle=this._getHandle(t),this.handle?(e(n.iframeFix===!0?"iframe":n.iframeFix).each(function(){e('<div class="ui-draggable-iframeFix" style="background: #fff;"></div>').css({width:this.offsetWidth+"px",height:this.offsetHeight+"px",position:"absolute",opacity:"0.001",zIndex:1e3}).css(e(this).offset()).appendTo("body")}),!0):!1)},_mouseStart:function(t){var n=this.options;return this.helper=this._createHelper(t),this.helper.addClass("ui-draggable-dragging"),this._cacheHelperProportions(),e.ui.ddmanager&&(e.ui.ddmanager.current=this),this._cacheMargins(),this.cssPosition=this.helper.css("position"),this.scrollParent=this.helper.scrollParent(),this.offset=this.positionAbs=this.element.offset(),this.offset={top:this.offset.top-this.margins.top,left:this.offset.left-this.margins.left},e.extend(this.offset,{click:{left:t.pageX-this.offset.left,top:t.pageY-this.offset.top},parent:this._getParentOffset(),relative:this._getRelativeOffset()}),this.originalPosition=this.position=this._generatePosition(t),this.originalPageX=t.pageX,this.originalPageY=t.pageY,n.cursorAt&&this._adjustOffsetFromHelper(n.cursorAt),n.containment&&this._setContainment(),this._trigger("start",t)===!1?(this._clear(),!1):(this._cacheHelperProportions(),e.ui.ddmanager&&!n.dropBehaviour&&e.ui.ddmanager.prepareOffsets(this,t),this._mouseDrag(t,!0),e.ui.ddmanager&&e.ui.ddmanager.dragStart(this,t),!0)},_mouseDrag:function(t,n){this.position=this._generatePosition(t),this.positionAbs=this._convertPositionTo("absolute");if(!n){var r=this._uiHash();if(this._trigger("drag",t,r)===!1)return this._mouseUp({}),!1;this.position=r.position}if(!this.options.axis||this.options.axis!="y")this.helper[0].style.left=this.position.left+"px";if(!this.options.axis||this.options.axis!="x")this.helper[0].style.top=this.position.top+"px";return e.ui.ddmanager&&e.ui.ddmanager.drag(this,t),!1},_mouseStop:function(t){var n=!1;e.ui.ddmanager&&!this.options.dropBehaviour&&(n=e.ui.ddmanager.drop(this,t)),this.dropped&&(n=this.dropped,this.dropped=!1);var r=this.element[0],i=!1;while(r&&(r=r.parentNode))r==document&&(i=!0);if(!i&&this.options.helper==="original")return!1;if(this.options.revert=="invalid"&&!n||this.options.revert=="valid"&&n||this.options.revert===!0||e.isFunction(this.options.revert)&&this.options.revert.call(this.element,n)){var s=this;e(this.helper).animate(this.originalPosition,parseInt(this.options.revertDuration,10),function(){s._trigger("stop",t)!==!1&&s._clear()})}else this._trigger("stop",t)!==!1&&this._clear();return!1},_mouseUp:function(t){return e("div.ui-draggable-iframeFix").each(function(){this.parentNode.removeChild(this)}),e.ui.ddmanager&&e.ui.ddmanager.dragStop(this,t),e.ui.mouse.prototype._mouseUp.call(this,t)},cancel:function(){return this.helper.is(".ui-draggable-dragging")?this._mouseUp({}):this._clear(),this},_getHandle:function(t){var n=!this.options.handle||!e(this.options.handle,this.element).length?!0:!1;return e(this.options.handle,this.element).find("*").andSelf().each(function(){this==t.target&&(n=!0)}),n},_createHelper:function(t){var n=this.options,r=e.isFunction(n.helper)?e(n.helper.apply(this.element[0],[t])):n.helper=="clone"?this.element.clone().removeAttr("id"):this.element;return r.parents("body").length||r.appendTo(n.appendTo=="parent"?this.element[0].parentNode:n.appendTo),r[0]!=this.element[0]&&!/(fixed|absolute)/.test(r.css("position"))&&r.css("position","absolute"),r},_adjustOffsetFromHelper:function(t){typeof t=="string"&&(t=t.split(" ")),e.isArray(t)&&(t={left:+t[0],top:+t[1]||0}),"left"in t&&(this.offset.click.left=t.left+this.margins.left),"right"in t&&(this.offset.click.left=this.helperProportions.width-t.right+this.margins.left),"top"in t&&(this.offset.click.top=t.top+this.margins.top),"bottom"in t&&(this.offset.click.top=this.helperProportions.height-t.bottom+this.margins.top)},_getParentOffset:function(){this.offsetParent=this.helper.offsetParent();var t=this.offsetParent.offset();this.cssPosition=="absolute"&&this.scrollParent[0]!=document&&e.contains(this.scrollParent[0],this.offsetParent[0])&&(t.left+=this.scrollParent.scrollLeft(),t.top+=this.scrollParent.scrollTop());if(this.offsetParent[0]==document.body||this.offsetParent[0].tagName&&this.offsetParent[0].tagName.toLowerCase()=="html"&&e.ui.ie)t={top:0,left:0};return{top:t.top+(parseInt(this.offsetParent.css("borderTopWidth"),10)||0),left:t.left+(parseInt(this.offsetParent.css("borderLeftWidth"),10)||0)}},_getRelativeOffset:function(){if(this.cssPosition=="relative"){var e=this.element.position();return{top:e.top-(parseInt(this.helper.css("top"),10)||0)+this.scrollParent.scrollTop(),left:e.left-(parseInt(this.helper.css("left"),10)||0)+this.scrollParent.scrollLeft()}}return{top:0,left:0}},_cacheMargins:function(){this.margins={left:parseInt(this.element.css("marginLeft"),10)||0,top:parseInt(this.element.css("marginTop"),10)||0,right:parseInt(this.element.css("marginRight"),10)||0,bottom:parseInt(this.element.css("marginBottom"),10)||0}},_cacheHelperProportions:function(){this.helperProportions={width:this.helper.outerWidth(),height:this.helper.outerHeight()}},_setContainment:function(){var t=this.options;t.containment=="parent"&&(t.containment=this.helper[0].parentNode);if(t.containment=="document"||t.containment=="window")this.containment=[t.containment=="document"?0:e(window).scrollLeft()-this.offset.relative.left-this.offset.parent.left,t.containment=="document"?0:e(window).scrollTop()-this.offset.relative.top-this.offset.parent.top,(t.containment=="document"?0:e(window).scrollLeft())+e(t.containment=="document"?document:window).width()-this.helperProportions.width-this.margins.left,(t.containment=="document"?0:e(window).scrollTop())+(e(t.containment=="document"?document:window).height()||document.body.parentNode.scrollHeight)-this.helperProportions.height-this.margins.top];if(!/^(document|window|parent)$/.test(t.containment)&&t.containment.constructor!=Array){var n=e(t.containment),r=n[0];if(!r)return;var i=n.offset(),s=e(r).css("overflow")!="hidden";this.containment=[(parseInt(e(r).css("borderLeftWidth"),10)||0)+(parseInt(e(r).css("paddingLeft"),10)||0),(parseInt(e(r).css("borderTopWidth"),10)||0)+(parseInt(e(r).css("paddingTop"),10)||0),(s?Math.max(r.scrollWidth,r.offsetWidth):r.offsetWidth)-(parseInt(e(r).css("borderLeftWidth"),10)||0)-(parseInt(e(r).css("paddingRight"),10)||0)-this.helperProportions.width-this.margins.left-this.margins.right,(s?Math.max(r.scrollHeight,r.offsetHeight):r.offsetHeight)-(parseInt(e(r).css("borderTopWidth"),10)||0)-(parseInt(e(r).css("paddingBottom"),10)||0)-this.helperProportions.height-this.margins.top-this.margins.bottom],this.relative_container=n}else t.containment.constructor==Array&&(this.containment=t.containment)},_convertPositionTo:function(t,n){n||(n=this.position);var r=t=="absolute"?1:-1,i=this.options,s=this.cssPosition!="absolute"||this.scrollParent[0]!=document&&!!e.contains(this.scrollParent[0],this.offsetParent[0])?this.scrollParent:this.offsetParent,o=/(html|body)/i.test(s[0].tagName);return{top:n.top+this.offset.relative.top*r+this.offset.parent.top*r-(this.cssPosition=="fixed"?-this.scrollParent.scrollTop():o?0:s.scrollTop())*r,left:n.left+this.offset.relative.left*r+this.offset.parent.left*r-(this.cssPosition=="fixed"?-this.scrollParent.scrollLeft():o?0:s.scrollLeft())*r}},_generatePosition:function(t){var n=this.options,r=this.cssPosition!="absolute"||this.scrollParent[0]!=document&&!!e.contains(this.scrollParent[0],this.offsetParent[0])?this.scrollParent:this.offsetParent,i=/(html|body)/i.test(r[0].tagName),s=t.pageX,o=t.pageY;if(this.originalPosition){var u;if(this.containment){if(this.relative_container){var a=this.relative_container.offset();u=[this.containment[0]+a.left,this.containment[1]+a.top,this.containment[2]+a.left,this.containment[3]+a.top]}else u=this.containment;t.pageX-this.offset.click.left<u[0]&&(s=u[0]+this.offset.click.left),t.pageY-this.offset.click.top<u[1]&&(o=u[1]+this.offset.click.top),t.pageX-this.offset.click.left>u[2]&&(s=u[2]+this.offset.click.left),t.pageY-this.offset.click.top>u[3]&&(o=u[3]+this.offset.click.top)}if(n.grid){var f=n.grid[1]?this.originalPageY+Math.round((o-this.originalPageY)/n.grid[1])*n.grid[1]:this.originalPageY;o=u?f-this.offset.click.top<u[1]||f-this.offset.click.top>u[3]?f-this.offset.click.top<u[1]?f+n.grid[1]:f-n.grid[1]:f:f;var l=n.grid[0]?this.originalPageX+Math.round((s-this.originalPageX)/n.grid[0])*n.grid[0]:this.originalPageX;s=u?l-this.offset.click.left<u[0]||l-this.offset.click.left>u[2]?l-this.offset.click.left<u[0]?l+n.grid[0]:l-n.grid[0]:l:l}}return{top:o-this.offset.click.top-this.offset.relative.top-this.offset.parent.top+(this.cssPosition=="fixed"?-this.scrollParent.scrollTop():i?0:r.scrollTop()),left:s-this.offset.click.left-this.offset.relative.left-this.offset.parent.left+(this.cssPosition=="fixed"?-this.scrollParent.scrollLeft():i?0:r.scrollLeft())}},_clear:function(){this.helper.removeClass("ui-draggable-dragging"),this.helper[0]!=this.element[0]&&!this.cancelHelperRemoval&&this.helper.remove(),this.helper=null,this.cancelHelperRemoval=!1},_trigger:function(t,n,r){return r=r||this._uiHash(),e.ui.plugin.call(this,t,[n,r]),t=="drag"&&(this.positionAbs=this._convertPositionTo("absolute")),e.Widget.prototype._trigger.call(this,t,n,r)},plugins:{},_uiHash:function(e){return{helper:this.helper,position:this.position,originalPosition:this.originalPosition,offset:this.positionAbs}}}),e.ui.plugin.add("draggable","connectToSortable",{start:function(t,n){var r=e(this).data("draggable"),i=r.options,s=e.extend({},n,{item:r.element});r.sortables=[],e(i.connectToSortable).each(function(){var n=e.data(this,"sortable");n&&!n.options.disabled&&(r.sortables.push({instance:n,shouldRevert:n.options.revert}),n.refreshPositions(),n._trigger("activate",t,s))})},stop:function(t,n){var r=e(this).data("draggable"),i=e.extend({},n,{item:r.element});e.each(r.sortables,function(){this.instance.isOver?(this.instance.isOver=0,r.cancelHelperRemoval=!0,this.instance.cancelHelperRemoval=!1,this.shouldRevert&&(this.instance.options.revert=!0),this.instance._mouseStop(t),this.instance.options.helper=this.instance.options._helper,r.options.helper=="original"&&this.instance.currentItem.css({top:"auto",left:"auto"})):(this.instance.cancelHelperRemoval=!1,this.instance._trigger("deactivate",t,i))})},drag:function(t,n){var r=e(this).data("draggable"),i=this,s=function(t){var n=this.offset.click.top,r=this.offset.click.left,i=this.positionAbs.top,s=this.positionAbs.left,o=t.height,u=t.width,a=t.top,f=t.left;return e.ui.isOver(i+n,s+r,a,f,o,u)};e.each(r.sortables,function(s){var o=!1,u=this;this.instance.positionAbs=r.positionAbs,this.instance.helperProportions=r.helperProportions,this.instance.offset.click=r.offset.click,this.instance._intersectsWith(this.instance.containerCache)&&(o=!0,e.each(r.sortables,function(){return this.instance.positionAbs=r.positionAbs,this.instance.helperProportions=r.helperProportions,this.instance.offset.click=r.offset.click,this!=u&&this.instance._intersectsWith(this.instance.containerCache)&&e.ui.contains(u.instance.element[0],this.instance.element[0])&&(o=!1),o})),o?(this.instance.isOver||(this.instance.isOver=1,this.instance.currentItem=e(i).clone().removeAttr("id").appendTo(this.instance.element).data("sortable-item",!0),this.instance.options._helper=this.instance.options.helper,this.instance.options.helper=function(){return n.helper[0]},t.target=this.instance.currentItem[0],this.instance._mouseCapture(t,!0),this.instance._mouseStart(t,!0,!0),this.instance.offset.click.top=r.offset.click.top,this.instance.offset.click.left=r.offset.click.left,this.instance.offset.parent.left-=r.offset.parent.left-this.instance.offset.parent.left,this.instance.offset.parent.top-=r.offset.parent.top-this.instance.offset.parent.top,r._trigger("toSortable",t),r.dropped=this.instance.element,r.currentItem=r.element,this.instance.fromOutside=r),this.instance.currentItem&&this.instance._mouseDrag(t)):this.instance.isOver&&(this.instance.isOver=0,this.instance.cancelHelperRemoval=!0,this.instance.options.revert=!1,this.instance._trigger("out",t,this.instance._uiHash(this.instance)),this.instance._mouseStop(t,!0),this.instance.options.helper=this.instance.options._helper,this.instance.currentItem.remove(),this.instance.placeholder&&this.instance.placeholder.remove(),r._trigger("fromSortable",t),r.dropped=!1)})}}),e.ui.plugin.add("draggable","cursor",{start:function(t,n){var r=e("body"),i=e(this).data("draggable").options;r.css("cursor")&&(i._cursor=r.css("cursor")),r.css("cursor",i.cursor)},stop:function(t,n){var r=e(this).data("draggable").options;r._cursor&&e("body").css("cursor",r._cursor)}}),e.ui.plugin.add("draggable","opacity",{start:function(t,n){var r=e(n.helper),i=e(this).data("draggable").options;r.css("opacity")&&(i._opacity=r.css("opacity")),r.css("opacity",i.opacity)},stop:function(t,n){var r=e(this).data("draggable").options;r._opacity&&e(n.helper).css("opacity",r._opacity)}}),e.ui.plugin.add("draggable","scroll",{start:function(t,n){var r=e(this).data("draggable");r.scrollParent[0]!=document&&r.scrollParent[0].tagName!="HTML"&&(r.overflowOffset=r.scrollParent.offset())},drag:function(t,n){var r=e(this).data("draggable"),i=r.options,s=!1;if(r.scrollParent[0]!=document&&r.scrollParent[0].tagName!="HTML"){if(!i.axis||i.axis!="x")r.overflowOffset.top+r.scrollParent[0].offsetHeight-t.pageY<i.scrollSensitivity?r.scrollParent[0].scrollTop=s=r.scrollParent[0].scrollTop+i.scrollSpeed:t.pageY-r.overflowOffset.top<i.scrollSensitivity&&(r.scrollParent[0].scrollTop=s=r.scrollParent[0].scrollTop-i.scrollSpeed);if(!i.axis||i.axis!="y")r.overflowOffset.left+r.scrollParent[0].offsetWidth-t.pageX<i.scrollSensitivity?r.scrollParent[0].scrollLeft=s=r.scrollParent[0].scrollLeft+i.scrollSpeed:t.pageX-r.overflowOffset.left<i.scrollSensitivity&&(r.scrollParent[0].scrollLeft=s=r.scrollParent[0].scrollLeft-i.scrollSpeed)}else{if(!i.axis||i.axis!="x")t.pageY-e(document).scrollTop()<i.scrollSensitivity?s=e(document).scrollTop(e(document).scrollTop()-i.scrollSpeed):e(window).height()-(t.pageY-e(document).scrollTop())<i.scrollSensitivity&&(s=e(document).scrollTop(e(document).scrollTop()+i.scrollSpeed));if(!i.axis||i.axis!="y")t.pageX-e(document).scrollLeft()<i.scrollSensitivity?s=e(document).scrollLeft(e(document).scrollLeft()-i.scrollSpeed):e(window).width()-(t.pageX-e(document).scrollLeft())<i.scrollSensitivity&&(s=e(document).scrollLeft(e(document).scrollLeft()+i.scrollSpeed))}s!==!1&&e.ui.ddmanager&&!i.dropBehaviour&&e.ui.ddmanager.prepareOffsets(r,t)}}),e.ui.plugin.add("draggable","snap",{start:function(t,n){var r=e(this).data("draggable"),i=r.options;r.snapElements=[],e(i.snap.constructor!=String?i.snap.items||":data(draggable)":i.snap).each(function(){var t=e(this),n=t.offset();this!=r.element[0]&&r.snapElements.push({item:this,width:t.outerWidth(),height:t.outerHeight(),top:n.top,left:n.left})})},drag:function(t,n){var r=e(this).data("draggable"),i=r.options,s=i.snapTolerance,o=n.offset.left,u=o+r.helperProportions.width,a=n.offset.top,f=a+r.helperProportions.height;for(var l=r.snapElements.length-1;l>=0;l--){var c=r.snapElements[l].left,h=c+r.snapElements[l].width,p=r.snapElements[l].top,d=p+r.snapElements[l].height;if(!(c-s<o&&o<h+s&&p-s<a&&a<d+s||c-s<o&&o<h+s&&p-s<f&&f<d+s||c-s<u&&u<h+s&&p-s<a&&a<d+s||c-s<u&&u<h+s&&p-s<f&&f<d+s)){r.snapElements[l].snapping&&r.options.snap.release&&r.options.snap.release.call(r.element,t,e.extend(r._uiHash(),{snapItem:r.snapElements[l].item})),r.snapElements[l].snapping=!1;continue}if(i.snapMode!="inner"){var v=Math.abs(p-f)<=s,m=Math.abs(d-a)<=s,g=Math.abs(c-u)<=s,y=Math.abs(h-o)<=s;v&&(n.position.top=r._convertPositionTo("relative",{top:p-r.helperProportions.height,left:0}).top-r.margins.top),m&&(n.position.top=r._convertPositionTo("relative",{top:d,left:0}).top-r.margins.top),g&&(n.position.left=r._convertPositionTo("relative",{top:0,left:c-r.helperProportions.width}).left-r.margins.left),y&&(n.position.left=r._convertPositionTo("relative",{top:0,left:h}).left-r.margins.left)}var b=v||m||g||y;if(i.snapMode!="outer"){var v=Math.abs(p-a)<=s,m=Math.abs(d-f)<=s,g=Math.abs(c-o)<=s,y=Math.abs(h-u)<=s;v&&(n.position.top=r._convertPositionTo("relative",{top:p,left:0}).top-r.margins.top),m&&(n.position.top=r._convertPositionTo("relative",{top:d-r.helperProportions.height,left:0}).top-r.margins.top),g&&(n.position.left=r._convertPositionTo("relative",{top:0,left:c}).left-r.margins.left),y&&(n.position.left=r._convertPositionTo("relative",{top:0,left:h-r.helperProportions.width}).left-r.margins.left)}!r.snapElements[l].snapping&&(v||m||g||y||b)&&r.options.snap.snap&&r.options.snap.snap.call(r.element,t,e.extend(r._uiHash(),{snapItem:r.snapElements[l].item})),r.snapElements[l].snapping=v||m||g||y||b}}}),e.ui.plugin.add("draggable","stack",{start:function(t,n){var r=e(this).data("draggable").options,i=e.makeArray(e(r.stack)).sort(function(t,n){return(parseInt(e(t).css("zIndex"),10)||0)-(parseInt(e(n).css("zIndex"),10)||0)});if(!i.length)return;var s=parseInt(i[0].style.zIndex)||0;e(i).each(function(e){this.style.zIndex=s+e}),this[0].style.zIndex=s+i.length}}),e.ui.plugin.add("draggable","zIndex",{start:function(t,n){var r=e(n.helper),i=e(this).data("draggable").options;r.css("zIndex")&&(i._zIndex=r.css("zIndex")),r.css("zIndex",i.zIndex)},stop:function(t,n){var r=e(this).data("draggable").options;r._zIndex&&e(n.helper).css("zIndex",r._zIndex)}})})(jQuery);(function(e,t){e.widget("ui.droppable",{version:"1.9.2",widgetEventPrefix:"drop",options:{accept:"*",activeClass:!1,addClasses:!0,greedy:!1,hoverClass:!1,scope:"default",tolerance:"intersect"},_create:function(){var t=this.options,n=t.accept;this.isover=0,this.isout=1,this.accept=e.isFunction(n)?n:function(e){return e.is(n)},this.proportions={width:this.element[0].offsetWidth,height:this.element[0].offsetHeight},e.ui.ddmanager.droppables[t.scope]=e.ui.ddmanager.droppables[t.scope]||[],e.ui.ddmanager.droppables[t.scope].push(this),t.addClasses&&this.element.addClass("ui-droppable")},_destroy:function(){var t=e.ui.ddmanager.droppables[this.options.scope];for(var n=0;n<t.length;n++)t[n]==this&&t.splice(n,1);this.element.removeClass("ui-droppable ui-droppable-disabled")},_setOption:function(t,n){t=="accept"&&(this.accept=e.isFunction(n)?n:function(e){return e.is(n)}),e.Widget.prototype._setOption.apply(this,arguments)},_activate:function(t){var n=e.ui.ddmanager.current;this.options.activeClass&&this.element.addClass(this.options.activeClass),n&&this._trigger("activate",t,this.ui(n))},_deactivate:function(t){var n=e.ui.ddmanager.current;this.options.activeClass&&this.element.removeClass(this.options.activeClass),n&&this._trigger("deactivate",t,this.ui(n))},_over:function(t){var n=e.ui.ddmanager.current;if(!n||(n.currentItem||n.element)[0]==this.element[0])return;this.accept.call(this.element[0],n.currentItem||n.element)&&(this.options.hoverClass&&this.element.addClass(this.options.hoverClass),this._trigger("over",t,this.ui(n)))},_out:function(t){var n=e.ui.ddmanager.current;if(!n||(n.currentItem||n.element)[0]==this.element[0])return;this.accept.call(this.element[0],n.currentItem||n.element)&&(this.options.hoverClass&&this.element.removeClass(this.options.hoverClass),this._trigger("out",t,this.ui(n)))},_drop:function(t,n){var r=n||e.ui.ddmanager.current;if(!r||(r.currentItem||r.element)[0]==this.element[0])return!1;var i=!1;return this.element.find(":data(droppable)").not(".ui-draggable-dragging").each(function(){var t=e.data(this,"droppable");if(t.options.greedy&&!t.options.disabled&&t.options.scope==r.options.scope&&t.accept.call(t.element[0],r.currentItem||r.element)&&e.ui.intersect(r,e.extend(t,{offset:t.element.offset()}),t.options.tolerance))return i=!0,!1}),i?!1:this.accept.call(this.element[0],r.currentItem||r.element)?(this.options.activeClass&&this.element.removeClass(this.options.activeClass),this.options.hoverClass&&this.element.removeClass(this.options.hoverClass),this._trigger("drop",t,this.ui(r)),this.element):!1},ui:function(e){return{draggable:e.currentItem||e.element,helper:e.helper,position:e.position,offset:e.positionAbs}}}),e.ui.intersect=function(t,n,r){if(!n.offset)return!1;var i=(t.positionAbs||t.position.absolute).left,s=i+t.helperProportions.width,o=(t.positionAbs||t.position.absolute).top,u=o+t.helperProportions.height,a=n.offset.left,f=a+n.proportions.width,l=n.offset.top,c=l+n.proportions.height;switch(r){case"fit":return a<=i&&s<=f&&l<=o&&u<=c;case"intersect":return a<i+t.helperProportions.width/2&&s-t.helperProportions.width/2<f&&l<o+t.helperProportions.height/2&&u-t.helperProportions.height/2<c;case"pointer":var h=(t.positionAbs||t.position.absolute).left+(t.clickOffset||t.offset.click).left,p=(t.positionAbs||t.position.absolute).top+(t.clickOffset||t.offset.click).top,d=e.ui.isOver(p,h,l,a,n.proportions.height,n.proportions.width);return d;case"touch":return(o>=l&&o<=c||u>=l&&u<=c||o<l&&u>c)&&(i>=a&&i<=f||s>=a&&s<=f||i<a&&s>f);default:return!1}},e.ui.ddmanager={current:null,droppables:{"default":[]},prepareOffsets:function(t,n){var r=e.ui.ddmanager.droppables[t.options.scope]||[],i=n?n.type:null,s=(t.currentItem||t.element).find(":data(droppable)").andSelf();e:for(var o=0;o<r.length;o++){if(r[o].options.disabled||t&&!r[o].accept.call(r[o].element[0],t.currentItem||t.element))continue;for(var u=0;u<s.length;u++)if(s[u]==r[o].element[0]){r[o].proportions.height=0;continue e}r[o].visible=r[o].element.css("display")!="none";if(!r[o].visible)continue;i=="mousedown"&&r[o]._activate.call(r[o],n),r[o].offset=r[o].element.offset(),r[o].proportions={width:r[o].element[0].offsetWidth,height:r[o].element[0].offsetHeight}}},drop:function(t,n){var r=!1;return e.each(e.ui.ddmanager.droppables[t.options.scope]||[],function(){if(!this.options)return;!this.options.disabled&&this.visible&&e.ui.intersect(t,this,this.options.tolerance)&&(r=this._drop.call(this,n)||r),!this.options.disabled&&this.visible&&this.accept.call(this.element[0],t.currentItem||t.element)&&(this.isout=1,this.isover=0,this._deactivate.call(this,n))}),r},dragStart:function(t,n){t.element.parentsUntil("body").bind("scroll.droppable",function(){t.options.refreshPositions||e.ui.ddmanager.prepareOffsets(t,n)})},drag:function(t,n){t.options.refreshPositions&&e.ui.ddmanager.prepareOffsets(t,n),e.each(e.ui.ddmanager.droppables[t.options.scope]||[],function(){if(this.options.disabled||this.greedyChild||!this.visible)return;var r=e.ui.intersect(t,this,this.options.tolerance),i=!r&&this.isover==1?"isout":r&&this.isover==0?"isover":null;if(!i)return;var s;if(this.options.greedy){var o=this.options.scope,u=this.element.parents(":data(droppable)").filter(function(){return e.data(this,"droppable").options.scope===o});u.length&&(s=e.data(u[0],"droppable"),s.greedyChild=i=="isover"?1:0)}s&&i=="isover"&&(s.isover=0,s.isout=1,s._out.call(s,n)),this[i]=1,this[i=="isout"?"isover":"isout"]=0,this[i=="isover"?"_over":"_out"].call(this,n),s&&i=="isout"&&(s.isout=0,s.isover=1,s._over.call(s,n))})},dragStop:function(t,n){t.element.parentsUntil("body").unbind("scroll.droppable"),t.options.refreshPositions||e.ui.ddmanager.prepareOffsets(t,n)}}})(jQuery);jQuery.effects||function(e,t){var n=e.uiBackCompat!==!1,r="ui-effects-";e.effects={effect:{}},function(t,n){function p(e,t,n){var r=a[t.type]||{};return e==null?n||!t.def?null:t.def:(e=r.floor?~~e:parseFloat(e),isNaN(e)?t.def:r.mod?(e+r.mod)%r.mod:0>e?0:r.max<e?r.max:e)}function d(e){var n=o(),r=n._rgba=[];return e=e.toLowerCase(),h(s,function(t,i){var s,o=i.re.exec(e),a=o&&i.parse(o),f=i.space||"rgba";if(a)return s=n[f](a),n[u[f].cache]=s[u[f].cache],r=n._rgba=s._rgba,!1}),r.length?(r.join()==="0,0,0,0"&&t.extend(r,c.transparent),n):c[e]}function v(e,t,n){return n=(n+1)%1,n*6<1?e+(t-e)*n*6:n*2<1?t:n*3<2?e+(t-e)*(2/3-n)*6:e}var r="backgroundColor borderBottomColor borderLeftColor borderRightColor borderTopColor color columnRuleColor outlineColor textDecorationColor textEmphasisColor".split(" "),i=/^([\-+])=\s*(\d+\.?\d*)/,s=[{re:/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/,parse:function(e){return[e[1],e[2],e[3],e[4]]}},{re:/rgba?\(\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/,parse:function(e){return[e[1]*2.55,e[2]*2.55,e[3]*2.55,e[4]]}},{re:/#([a-f0-9]{2})([a-f0-9]{2})([a-f0-9]{2})/,parse:function(e){return[parseInt(e[1],16),parseInt(e[2],16),parseInt(e[3],16)]}},{re:/#([a-f0-9])([a-f0-9])([a-f0-9])/,parse:function(e){return[parseInt(e[1]+e[1],16),parseInt(e[2]+e[2],16),parseInt(e[3]+e[3],16)]}},{re:/hsla?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/,space:"hsla",parse:function(e){return[e[1],e[2]/100,e[3]/100,e[4]]}}],o=t.Color=function(e,n,r,i){return new t.Color.fn.parse(e,n,r,i)},u={rgba:{props:{red:{idx:0,type:"byte"},green:{idx:1,type:"byte"},blue:{idx:2,type:"byte"}}},hsla:{props:{hue:{idx:0,type:"degrees"},saturation:{idx:1,type:"percent"},lightness:{idx:2,type:"percent"}}}},a={"byte":{floor:!0,max:255},percent:{max:1},degrees:{mod:360,floor:!0}},f=o.support={},l=t("<p>")[0],c,h=t.each;l.style.cssText="background-color:rgba(1,1,1,.5)",f.rgba=l.style.backgroundColor.indexOf("rgba")>-1,h(u,function(e,t){t.cache="_"+e,t.props.alpha={idx:3,type:"percent",def:1}}),o.fn=t.extend(o.prototype,{parse:function(r,i,s,a){if(r===n)return this._rgba=[null,null,null,null],this;if(r.jquery||r.nodeType)r=t(r).css(i),i=n;var f=this,l=t.type(r),v=this._rgba=[];i!==n&&(r=[r,i,s,a],l="array");if(l==="string")return this.parse(d(r)||c._default);if(l==="array")return h(u.rgba.props,function(e,t){v[t.idx]=p(r[t.idx],t)}),this;if(l==="object")return r instanceof o?h(u,function(e,t){r[t.cache]&&(f[t.cache]=r[t.cache].slice())}):h(u,function(t,n){var i=n.cache;h(n.props,function(e,t){if(!f[i]&&n.to){if(e==="alpha"||r[e]==null)return;f[i]=n.to(f._rgba)}f[i][t.idx]=p(r[e],t,!0)}),f[i]&&e.inArray(null,f[i].slice(0,3))<0&&(f[i][3]=1,n.from&&(f._rgba=n.from(f[i])))}),this},is:function(e){var t=o(e),n=!0,r=this;return h(u,function(e,i){var s,o=t[i.cache];return o&&(s=r[i.cache]||i.to&&i.to(r._rgba)||[],h(i.props,function(e,t){if(o[t.idx]!=null)return n=o[t.idx]===s[t.idx],n})),n}),n},_space:function(){var e=[],t=this;return h(u,function(n,r){t[r.cache]&&e.push(n)}),e.pop()},transition:function(e,t){var n=o(e),r=n._space(),i=u[r],s=this.alpha()===0?o("transparent"):this,f=s[i.cache]||i.to(s._rgba),l=f.slice();return n=n[i.cache],h(i.props,function(e,r){var i=r.idx,s=f[i],o=n[i],u=a[r.type]||{};if(o===null)return;s===null?l[i]=o:(u.mod&&(o-s>u.mod/2?s+=u.mod:s-o>u.mod/2&&(s-=u.mod)),l[i]=p((o-s)*t+s,r))}),this[r](l)},blend:function(e){if(this._rgba[3]===1)return this;var n=this._rgba.slice(),r=n.pop(),i=o(e)._rgba;return o(t.map(n,function(e,t){return(1-r)*i[t]+r*e}))},toRgbaString:function(){var e="rgba(",n=t.map(this._rgba,function(e,t){return e==null?t>2?1:0:e});return n[3]===1&&(n.pop(),e="rgb("),e+n.join()+")"},toHslaString:function(){var e="hsla(",n=t.map(this.hsla(),function(e,t){return e==null&&(e=t>2?1:0),t&&t<3&&(e=Math.round(e*100)+"%"),e});return n[3]===1&&(n.pop(),e="hsl("),e+n.join()+")"},toHexString:function(e){var n=this._rgba.slice(),r=n.pop();return e&&n.push(~~(r*255)),"#"+t.map(n,function(e){return e=(e||0).toString(16),e.length===1?"0"+e:e}).join("")},toString:function(){return this._rgba[3]===0?"transparent":this.toRgbaString()}}),o.fn.parse.prototype=o.fn,u.hsla.to=function(e){if(e[0]==null||e[1]==null||e[2]==null)return[null,null,null,e[3]];var t=e[0]/255,n=e[1]/255,r=e[2]/255,i=e[3],s=Math.max(t,n,r),o=Math.min(t,n,r),u=s-o,a=s+o,f=a*.5,l,c;return o===s?l=0:t===s?l=60*(n-r)/u+360:n===s?l=60*(r-t)/u+120:l=60*(t-n)/u+240,f===0||f===1?c=f:f<=.5?c=u/a:c=u/(2-a),[Math.round(l)%360,c,f,i==null?1:i]},u.hsla.from=function(e){if(e[0]==null||e[1]==null||e[2]==null)return[null,null,null,e[3]];var t=e[0]/360,n=e[1],r=e[2],i=e[3],s=r<=.5?r*(1+n):r+n-r*n,o=2*r-s;return[Math.round(v(o,s,t+1/3)*255),Math.round(v(o,s,t)*255),Math.round(v(o,s,t-1/3)*255),i]},h(u,function(e,r){var s=r.props,u=r.cache,a=r.to,f=r.from;o.fn[e]=function(e){a&&!this[u]&&(this[u]=a(this._rgba));if(e===n)return this[u].slice();var r,i=t.type(e),l=i==="array"||i==="object"?e:arguments,c=this[u].slice();return h(s,function(e,t){var n=l[i==="object"?e:t.idx];n==null&&(n=c[t.idx]),c[t.idx]=p(n,t)}),f?(r=o(f(c)),r[u]=c,r):o(c)},h(s,function(n,r){if(o.fn[n])return;o.fn[n]=function(s){var o=t.type(s),u=n==="alpha"?this._hsla?"hsla":"rgba":e,a=this[u](),f=a[r.idx],l;return o==="undefined"?f:(o==="function"&&(s=s.call(this,f),o=t.type(s)),s==null&&r.empty?this:(o==="string"&&(l=i.exec(s),l&&(s=f+parseFloat(l[2])*(l[1]==="+"?1:-1))),a[r.idx]=s,this[u](a)))}})}),h(r,function(e,n){t.cssHooks[n]={set:function(e,r){var i,s,u="";if(t.type(r)!=="string"||(i=d(r))){r=o(i||r);if(!f.rgba&&r._rgba[3]!==1){s=n==="backgroundColor"?e.parentNode:e;while((u===""||u==="transparent")&&s&&s.style)try{u=t.css(s,"backgroundColor"),s=s.parentNode}catch(a){}r=r.blend(u&&u!=="transparent"?u:"_default")}r=r.toRgbaString()}try{e.style[n]=r}catch(l){}}},t.fx.step[n]=function(e){e.colorInit||(e.start=o(e.elem,n),e.end=o(e.end),e.colorInit=!0),t.cssHooks[n].set(e.elem,e.start.transition(e.end,e.pos))}}),t.cssHooks.borderColor={expand:function(e){var t={};return h(["Top","Right","Bottom","Left"],function(n,r){t["border"+r+"Color"]=e}),t}},c=t.Color.names={aqua:"#00ffff",black:"#000000",blue:"#0000ff",fuchsia:"#ff00ff",gray:"#808080",green:"#008000",lime:"#00ff00",maroon:"#800000",navy:"#000080",olive:"#808000",purple:"#800080",red:"#ff0000",silver:"#c0c0c0",teal:"#008080",white:"#ffffff",yellow:"#ffff00",transparent:[null,null,null,0],_default:"#ffffff"}}(jQuery),function(){function i(){var t=this.ownerDocument.defaultView?this.ownerDocument.defaultView.getComputedStyle(this,null):this.currentStyle,n={},r,i;if(t&&t.length&&t[0]&&t[t[0]]){i=t.length;while(i--)r=t[i],typeof t[r]=="string"&&(n[e.camelCase(r)]=t[r])}else for(r in t)typeof t[r]=="string"&&(n[r]=t[r]);return n}function s(t,n){var i={},s,o;for(s in n)o=n[s],t[s]!==o&&!r[s]&&(e.fx.step[s]||!isNaN(parseFloat(o)))&&(i[s]=o);return i}var n=["add","remove","toggle"],r={border:1,borderBottom:1,borderColor:1,borderLeft:1,borderRight:1,borderTop:1,borderWidth:1,margin:1,padding:1};e.each(["borderLeftStyle","borderRightStyle","borderBottomStyle","borderTopStyle"],function(t,n){e.fx.step[n]=function(e){if(e.end!=="none"&&!e.setAttr||e.pos===1&&!e.setAttr)jQuery.style(e.elem,n,e.end),e.setAttr=!0}}),e.effects.animateClass=function(t,r,o,u){var a=e.speed(r,o,u);return this.queue(function(){var r=e(this),o=r.attr("class")||"",u,f=a.children?r.find("*").andSelf():r;f=f.map(function(){var t=e(this);return{el:t,start:i.call(this)}}),u=function(){e.each(n,function(e,n){t[n]&&r[n+"Class"](t[n])})},u(),f=f.map(function(){return this.end=i.call(this.el[0]),this.diff=s(this.start,this.end),this}),r.attr("class",o),f=f.map(function(){var t=this,n=e.Deferred(),r=jQuery.extend({},a,{queue:!1,complete:function(){n.resolve(t)}});return this.el.animate(this.diff,r),n.promise()}),e.when.apply(e,f.get()).done(function(){u(),e.each(arguments,function(){var t=this.el;e.each(this.diff,function(e){t.css(e,"")})}),a.complete.call(r[0])})})},e.fn.extend({_addClass:e.fn.addClass,addClass:function(t,n,r,i){return n?e.effects.animateClass.call(this,{add:t},n,r,i):this._addClass(t)},_removeClass:e.fn.removeClass,removeClass:function(t,n,r,i){return n?e.effects.animateClass.call(this,{remove:t},n,r,i):this._removeClass(t)},_toggleClass:e.fn.toggleClass,toggleClass:function(n,r,i,s,o){return typeof r=="boolean"||r===t?i?e.effects.animateClass.call(this,r?{add:n}:{remove:n},i,s,o):this._toggleClass(n,r):e.effects.animateClass.call(this,{toggle:n},r,i,s)},switchClass:function(t,n,r,i,s){return e.effects.animateClass.call(this,{add:n,remove:t},r,i,s)}})}(),function(){function i(t,n,r,i){e.isPlainObject(t)&&(n=t,t=t.effect),t={effect:t},n==null&&(n={}),e.isFunction(n)&&(i=n,r=null,n={});if(typeof n=="number"||e.fx.speeds[n])i=r,r=n,n={};return e.isFunction(r)&&(i=r,r=null),n&&e.extend(t,n),r=r||n.duration,t.duration=e.fx.off?0:typeof r=="number"?r:r in e.fx.speeds?e.fx.speeds[r]:e.fx.speeds._default,t.complete=i||n.complete,t}function s(t){return!t||typeof t=="number"||e.fx.speeds[t]?!0:typeof t=="string"&&!e.effects.effect[t]?n&&e.effects[t]?!1:!0:!1}e.extend(e.effects,{version:"1.9.2",save:function(e,t){for(var n=0;n<t.length;n++)t[n]!==null&&e.data(r+t[n],e[0].style[t[n]])},restore:function(e,n){var i,s;for(s=0;s<n.length;s++)n[s]!==null&&(i=e.data(r+n[s]),i===t&&(i=""),e.css(n[s],i))},setMode:function(e,t){return t==="toggle"&&(t=e.is(":hidden")?"show":"hide"),t},getBaseline:function(e,t){var n,r;switch(e[0]){case"top":n=0;break;case"middle":n=.5;break;case"bottom":n=1;break;default:n=e[0]/t.height}switch(e[1]){case"left":r=0;break;case"center":r=.5;break;case"right":r=1;break;default:r=e[1]/t.width}return{x:r,y:n}},createWrapper:function(t){if(t.parent().is(".ui-effects-wrapper"))return t.parent();var n={width:t.outerWidth(!0),height:t.outerHeight(!0),"float":t.css("float")},r=e("<div></div>").addClass("ui-effects-wrapper").css({fontSize:"100%",background:"transparent",border:"none",margin:0,padding:0}),i={width:t.width(),height:t.height()},s=document.activeElement;try{s.id}catch(o){s=document.body}return t.wrap(r),(t[0]===s||e.contains(t[0],s))&&e(s).focus(),r=t.parent(),t.css("position")==="static"?(r.css({position:"relative"}),t.css({position:"relative"})):(e.extend(n,{position:t.css("position"),zIndex:t.css("z-index")}),e.each(["top","left","bottom","right"],function(e,r){n[r]=t.css(r),isNaN(parseInt(n[r],10))&&(n[r]="auto")}),t.css({position:"relative",top:0,left:0,right:"auto",bottom:"auto"})),t.css(i),r.css(n).show()},removeWrapper:function(t){var n=document.activeElement;return t.parent().is(".ui-effects-wrapper")&&(t.parent().replaceWith(t),(t[0]===n||e.contains(t[0],n))&&e(n).focus()),t},setTransition:function(t,n,r,i){return i=i||{},e.each(n,function(e,n){var s=t.cssUnit(n);s[0]>0&&(i[n]=s[0]*r+s[1])}),i}}),e.fn.extend({effect:function(){function a(n){function u(){e.isFunction(i)&&i.call(r[0]),e.isFunction(n)&&n()}var r=e(this),i=t.complete,s=t.mode;(r.is(":hidden")?s==="hide":s==="show")?u():o.call(r[0],t,u)}var t=i.apply(this,arguments),r=t.mode,s=t.queue,o=e.effects.effect[t.effect],u=!o&&n&&e.effects[t.effect];return e.fx.off||!o&&!u?r?this[r](t.duration,t.complete):this.each(function(){t.complete&&t.complete.call(this)}):o?s===!1?this.each(a):this.queue(s||"fx",a):u.call(this,{options:t,duration:t.duration,callback:t.complete,mode:t.mode})},_show:e.fn.show,show:function(e){if(s(e))return this._show.apply(this,arguments);var t=i.apply(this,arguments);return t.mode="show",this.effect.call(this,t)},_hide:e.fn.hide,hide:function(e){if(s(e))return this._hide.apply(this,arguments);var t=i.apply(this,arguments);return t.mode="hide",this.effect.call(this,t)},__toggle:e.fn.toggle,toggle:function(t){if(s(t)||typeof t=="boolean"||e.isFunction(t))return this.__toggle.apply(this,arguments);var n=i.apply(this,arguments);return n.mode="toggle",this.effect.call(this,n)},cssUnit:function(t){var n=this.css(t),r=[];return e.each(["em","px","%","pt"],function(e,t){n.indexOf(t)>0&&(r=[parseFloat(n),t])}),r}})}(),function(){var t={};e.each(["Quad","Cubic","Quart","Quint","Expo"],function(e,n){t[n]=function(t){return Math.pow(t,e+2)}}),e.extend(t,{Sine:function(e){return 1-Math.cos(e*Math.PI/2)},Circ:function(e){return 1-Math.sqrt(1-e*e)},Elastic:function(e){return e===0||e===1?e:-Math.pow(2,8*(e-1))*Math.sin(((e-1)*80-7.5)*Math.PI/15)},Back:function(e){return e*e*(3*e-2)},Bounce:function(e){var t,n=4;while(e<((t=Math.pow(2,--n))-1)/11);return 1/Math.pow(4,3-n)-7.5625*Math.pow((t*3-2)/22-e,2)}}),e.each(t,function(t,n){e.easing["easeIn"+t]=n,e.easing["easeOut"+t]=function(e){return 1-n(1-e)},e.easing["easeInOut"+t]=function(e){return e<.5?n(e*2)/2:1-n(e*-2+2)/2}})}()}(jQuery);(function(e,t){var n=/up|down|vertical/,r=/up|left|vertical|horizontal/;e.effects.effect.blind=function(t,i){var s=e(this),o=["position","top","bottom","left","right","height","width"],u=e.effects.setMode(s,t.mode||"hide"),a=t.direction||"up",f=n.test(a),l=f?"height":"width",c=f?"top":"left",h=r.test(a),p={},d=u==="show",v,m,g;s.parent().is(".ui-effects-wrapper")?e.effects.save(s.parent(),o):e.effects.save(s,o),s.show(),v=e.effects.createWrapper(s).css({overflow:"hidden"}),m=v[l](),g=parseFloat(v.css(c))||0,p[l]=d?m:0,h||(s.css(f?"bottom":"right",0).css(f?"top":"left","auto").css({position:"absolute"}),p[c]=d?g:m+g),d&&(v.css(l,0),h||v.css(c,g+m)),v.animate(p,{duration:t.duration,easing:t.easing,queue:!1,complete:function(){u==="hide"&&s.hide(),e.effects.restore(s,o),e.effects.removeWrapper(s),i()}})}})(jQuery);(function(e,t){e.effects.effect.bounce=function(t,n){var r=e(this),i=["position","top","bottom","left","right","height","width"],s=e.effects.setMode(r,t.mode||"effect"),o=s==="hide",u=s==="show",a=t.direction||"up",f=t.distance,l=t.times||5,c=l*2+(u||o?1:0),h=t.duration/c,p=t.easing,d=a==="up"||a==="down"?"top":"left",v=a==="up"||a==="left",m,g,y,b=r.queue(),w=b.length;(u||o)&&i.push("opacity"),e.effects.save(r,i),r.show(),e.effects.createWrapper(r),f||(f=r[d==="top"?"outerHeight":"outerWidth"]()/3),u&&(y={opacity:1},y[d]=0,r.css("opacity",0).css(d,v?-f*2:f*2).animate(y,h,p)),o&&(f/=Math.pow(2,l-1)),y={},y[d]=0;for(m=0;m<l;m++)g={},g[d]=(v?"-=":"+=")+f,r.animate(g,h,p).animate(y,h,p),f=o?f*2:f/2;o&&(g={opacity:0},g[d]=(v?"-=":"+=")+f,r.animate(g,h,p)),r.queue(function(){o&&r.hide(),e.effects.restore(r,i),e.effects.removeWrapper(r),n()}),w>1&&b.splice.apply(b,[1,0].concat(b.splice(w,c+1))),r.dequeue()}})(jQuery);(function(e,t){e.effects.effect.clip=function(t,n){var r=e(this),i=["position","top","bottom","left","right","height","width"],s=e.effects.setMode(r,t.mode||"hide"),o=s==="show",u=t.direction||"vertical",a=u==="vertical",f=a?"height":"width",l=a?"top":"left",c={},h,p,d;e.effects.save(r,i),r.show(),h=e.effects.createWrapper(r).css({overflow:"hidden"}),p=r[0].tagName==="IMG"?h:r,d=p[f](),o&&(p.css(f,0),p.css(l,d/2)),c[f]=o?d:0,c[l]=o?0:d/2,p.animate(c,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){o||r.hide(),e.effects.restore(r,i),e.effects.removeWrapper(r),n()}})}})(jQuery);(function(e,t){e.effects.effect.drop=function(t,n){var r=e(this),i=["position","top","bottom","left","right","opacity","height","width"],s=e.effects.setMode(r,t.mode||"hide"),o=s==="show",u=t.direction||"left",a=u==="up"||u==="down"?"top":"left",f=u==="up"||u==="left"?"pos":"neg",l={opacity:o?1:0},c;e.effects.save(r,i),r.show(),e.effects.createWrapper(r),c=t.distance||r[a==="top"?"outerHeight":"outerWidth"](!0)/2,o&&r.css("opacity",0).css(a,f==="pos"?-c:c),l[a]=(o?f==="pos"?"+=":"-=":f==="pos"?"-=":"+=")+c,r.animate(l,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){s==="hide"&&r.hide(),e.effects.restore(r,i),e.effects.removeWrapper(r),n()}})}})(jQuery);(function(e,t){e.effects.effect.explode=function(t,n){function y(){c.push(this),c.length===r*i&&b()}function b(){s.css({visibility:"visible"}),e(c).remove(),u||s.hide(),n()}var r=t.pieces?Math.round(Math.sqrt(t.pieces)):3,i=r,s=e(this),o=e.effects.setMode(s,t.mode||"hide"),u=o==="show",a=s.show().css("visibility","hidden").offset(),f=Math.ceil(s.outerWidth()/i),l=Math.ceil(s.outerHeight()/r),c=[],h,p,d,v,m,g;for(h=0;h<r;h++){v=a.top+h*l,g=h-(r-1)/2;for(p=0;p<i;p++)d=a.left+p*f,m=p-(i-1)/2,s.clone().appendTo("body").wrap("<div></div>").css({position:"absolute",visibility:"visible",left:-p*f,top:-h*l}).parent().addClass("ui-effects-explode").css({position:"absolute",overflow:"hidden",width:f,height:l,left:d+(u?m*f:0),top:v+(u?g*l:0),opacity:u?0:1}).animate({left:d+(u?0:m*f),top:v+(u?0:g*l),opacity:u?1:0},t.duration||500,t.easing,y)}}})(jQuery);(function(e,t){e.effects.effect.fade=function(t,n){var r=e(this),i=e.effects.setMode(r,t.mode||"toggle");r.animate({opacity:i},{queue:!1,duration:t.duration,easing:t.easing,complete:n})}})(jQuery);(function(e,t){e.effects.effect.fold=function(t,n){var r=e(this),i=["position","top","bottom","left","right","height","width"],s=e.effects.setMode(r,t.mode||"hide"),o=s==="show",u=s==="hide",a=t.size||15,f=/([0-9]+)%/.exec(a),l=!!t.horizFirst,c=o!==l,h=c?["width","height"]:["height","width"],p=t.duration/2,d,v,m={},g={};e.effects.save(r,i),r.show(),d=e.effects.createWrapper(r).css({overflow:"hidden"}),v=c?[d.width(),d.height()]:[d.height(),d.width()],f&&(a=parseInt(f[1],10)/100*v[u?0:1]),o&&d.css(l?{height:0,width:a}:{height:a,width:0}),m[h[0]]=o?v[0]:a,g[h[1]]=o?v[1]:0,d.animate(m,p,t.easing).animate(g,p,t.easing,function(){u&&r.hide(),e.effects.restore(r,i),e.effects.removeWrapper(r),n()})}})(jQuery);(function(e,t){e.effects.effect.highlight=function(t,n){var r=e(this),i=["backgroundImage","backgroundColor","opacity"],s=e.effects.setMode(r,t.mode||"show"),o={backgroundColor:r.css("backgroundColor")};s==="hide"&&(o.opacity=0),e.effects.save(r,i),r.show().css({backgroundImage:"none",backgroundColor:t.color||"#ffff99"}).animate(o,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){s==="hide"&&r.hide(),e.effects.restore(r,i),n()}})}})(jQuery);(function(e,t){e.effects.effect.pulsate=function(t,n){var r=e(this),i=e.effects.setMode(r,t.mode||"show"),s=i==="show",o=i==="hide",u=s||i==="hide",a=(t.times||5)*2+(u?1:0),f=t.duration/a,l=0,c=r.queue(),h=c.length,p;if(s||!r.is(":visible"))r.css("opacity",0).show(),l=1;for(p=1;p<a;p++)r.animate({opacity:l},f,t.easing),l=1-l;r.animate({opacity:l},f,t.easing),r.queue(function(){o&&r.hide(),n()}),h>1&&c.splice.apply(c,[1,0].concat(c.splice(h,a+1))),r.dequeue()}})(jQuery);(function(e,t){e.effects.effect.puff=function(t,n){var r=e(this),i=e.effects.setMode(r,t.mode||"hide"),s=i==="hide",o=parseInt(t.percent,10)||150,u=o/100,a={height:r.height(),width:r.width(),outerHeight:r.outerHeight(),outerWidth:r.outerWidth()};e.extend(t,{effect:"scale",queue:!1,fade:!0,mode:i,complete:n,percent:s?o:100,from:s?a:{height:a.height*u,width:a.width*u,outerHeight:a.outerHeight*u,outerWidth:a.outerWidth*u}}),r.effect(t)},e.effects.effect.scale=function(t,n){var r=e(this),i=e.extend(!0,{},t),s=e.effects.setMode(r,t.mode||"effect"),o=parseInt(t.percent,10)||(parseInt(t.percent,10)===0?0:s==="hide"?0:100),u=t.direction||"both",a=t.origin,f={height:r.height(),width:r.width(),outerHeight:r.outerHeight(),outerWidth:r.outerWidth()},l={y:u!=="horizontal"?o/100:1,x:u!=="vertical"?o/100:1};i.effect="size",i.queue=!1,i.complete=n,s!=="effect"&&(i.origin=a||["middle","center"],i.restore=!0),i.from=t.from||(s==="show"?{height:0,width:0,outerHeight:0,outerWidth:0}:f),i.to={height:f.height*l.y,width:f.width*l.x,outerHeight:f.outerHeight*l.y,outerWidth:f.outerWidth*l.x},i.fade&&(s==="show"&&(i.from.opacity=0,i.to.opacity=1),s==="hide"&&(i.from.opacity=1,i.to.opacity=0)),r.effect(i)},e.effects.effect.size=function(t,n){var r,i,s,o=e(this),u=["position","top","bottom","left","right","width","height","overflow","opacity"],a=["position","top","bottom","left","right","overflow","opacity"],f=["width","height","overflow"],l=["fontSize"],c=["borderTopWidth","borderBottomWidth","paddingTop","paddingBottom"],h=["borderLeftWidth","borderRightWidth","paddingLeft","paddingRight"],p=e.effects.setMode(o,t.mode||"effect"),d=t.restore||p!=="effect",v=t.scale||"both",m=t.origin||["middle","center"],g=o.css("position"),y=d?u:a,b={height:0,width:0,outerHeight:0,outerWidth:0};p==="show"&&o.show(),r={height:o.height(),width:o.width(),outerHeight:o.outerHeight(),outerWidth:o.outerWidth()},t.mode==="toggle"&&p==="show"?(o.from=t.to||b,o.to=t.from||r):(o.from=t.from||(p==="show"?b:r),o.to=t.to||(p==="hide"?b:r)),s={from:{y:o.from.height/r.height,x:o.from.width/r.width},to:{y:o.to.height/r.height,x:o.to.width/r.width}};if(v==="box"||v==="both")s.from.y!==s.to.y&&(y=y.concat(c),o.from=e.effects.setTransition(o,c,s.from.y,o.from),o.to=e.effects.setTransition(o,c,s.to.y,o.to)),s.from.x!==s.to.x&&(y=y.concat(h),o.from=e.effects.setTransition(o,h,s.from.x,o.from),o.to=e.effects.setTransition(o,h,s.to.x,o.to));(v==="content"||v==="both")&&s.from.y!==s.to.y&&(y=y.concat(l).concat(f),o.from=e.effects.setTransition(o,l,s.from.y,o.from),o.to=e.effects.setTransition(o,l,s.to.y,o.to)),e.effects.save(o,y),o.show(),e.effects.createWrapper(o),o.css("overflow","hidden").css(o.from),m&&(i=e.effects.getBaseline(m,r),o.from.top=(r.outerHeight-o.outerHeight())*i.y,o.from.left=(r.outerWidth-o.outerWidth())*i.x,o.to.top=(r.outerHeight-o.to.outerHeight)*i.y,o.to.left=(r.outerWidth-o.to.outerWidth)*i.x),o.css(o.from);if(v==="content"||v==="both")c=c.concat(["marginTop","marginBottom"]).concat(l),h=h.concat(["marginLeft","marginRight"]),f=u.concat(c).concat(h),o.find("*[width]").each(function(){var n=e(this),r={height:n.height(),width:n.width(),outerHeight:n.outerHeight(),outerWidth:n.outerWidth()};d&&e.effects.save(n,f),n.from={height:r.height*s.from.y,width:r.width*s.from.x,outerHeight:r.outerHeight*s.from.y,outerWidth:r.outerWidth*s.from.x},n.to={height:r.height*s.to.y,width:r.width*s.to.x,outerHeight:r.height*s.to.y,outerWidth:r.width*s.to.x},s.from.y!==s.to.y&&(n.from=e.effects.setTransition(n,c,s.from.y,n.from),n.to=e.effects.setTransition(n,c,s.to.y,n.to)),s.from.x!==s.to.x&&(n.from=e.effects.setTransition(n,h,s.from.x,n.from),n.to=e.effects.setTransition(n,h,s.to.x,n.to)),n.css(n.from),n.animate(n.to,t.duration,t.easing,function(){d&&e.effects.restore(n,f)})});o.animate(o.to,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){o.to.opacity===0&&o.css("opacity",o.from.opacity),p==="hide"&&o.hide(),e.effects.restore(o,y),d||(g==="static"?o.css({position:"relative",top:o.to.top,left:o.to.left}):e.each(["top","left"],function(e,t){o.css(t,function(t,n){var r=parseInt(n,10),i=e?o.to.left:o.to.top;return n==="auto"?i+"px":r+i+"px"})})),e.effects.removeWrapper(o),n()}})}})(jQuery);(function(e,t){e.effects.effect.shake=function(t,n){var r=e(this),i=["position","top","bottom","left","right","height","width"],s=e.effects.setMode(r,t.mode||"effect"),o=t.direction||"left",u=t.distance||20,a=t.times||3,f=a*2+1,l=Math.round(t.duration/f),c=o==="up"||o==="down"?"top":"left",h=o==="up"||o==="left",p={},d={},v={},m,g=r.queue(),y=g.length;e.effects.save(r,i),r.show(),e.effects.createWrapper(r),p[c]=(h?"-=":"+=")+u,d[c]=(h?"+=":"-=")+u*2,v[c]=(h?"-=":"+=")+u*2,r.animate(p,l,t.easing);for(m=1;m<a;m++)r.animate(d,l,t.easing).animate(v,l,t.easing);r.animate(d,l,t.easing).animate(p,l/2,t.easing).queue(function(){s==="hide"&&r.hide(),e.effects.restore(r,i),e.effects.removeWrapper(r),n()}),y>1&&g.splice.apply(g,[1,0].concat(g.splice(y,f+1))),r.dequeue()}})(jQuery);(function(e,t){e.effects.effect.slide=function(t,n){var r=e(this),i=["position","top","bottom","left","right","width","height"],s=e.effects.setMode(r,t.mode||"show"),o=s==="show",u=t.direction||"left",a=u==="up"||u==="down"?"top":"left",f=u==="up"||u==="left",l,c={};e.effects.save(r,i),r.show(),l=t.distance||r[a==="top"?"outerHeight":"outerWidth"](!0),e.effects.createWrapper(r).css({overflow:"hidden"}),o&&r.css(a,f?isNaN(l)?"-"+l:-l:l),c[a]=(o?f?"+=":"-=":f?"-=":"+=")+l,r.animate(c,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){s==="hide"&&r.hide(),e.effects.restore(r,i),e.effects.removeWrapper(r),n()}})}})(jQuery);(function(e,t){e.effects.effect.transfer=function(t,n){var r=e(this),i=e(t.to),s=i.css("position")==="fixed",o=e("body"),u=s?o.scrollTop():0,a=s?o.scrollLeft():0,f=i.offset(),l={top:f.top-u,left:f.left-a,height:i.innerHeight(),width:i.innerWidth()},c=r.offset(),h=e('<div class="ui-effects-transfer"></div>').appendTo(document.body).addClass(t.className).css({top:c.top-u,left:c.left-a,height:r.innerHeight(),width:r.innerWidth(),position:s?"fixed":"absolute"}).animate(l,t.duration,t.easing,function(){h.remove(),n()})}})(jQuery);(function(e,t){var n=!1;e.widget("ui.menu",{version:"1.9.2",defaultElement:"<ul>",delay:300,options:{icons:{submenu:"ui-icon-carat-1-e"},menus:"ul",position:{my:"left top",at:"right top"},role:"menu",blur:null,focus:null,select:null},_create:function(){this.activeMenu=this.element,this.element.uniqueId().addClass("ui-menu ui-widget ui-widget-content ui-corner-all").toggleClass("ui-menu-icons",!!this.element.find(".ui-icon").length).attr({role:this.options.role,tabIndex:0}).bind("click"+this.eventNamespace,e.proxy(function(e){this.options.disabled&&e.preventDefault()},this)),this.options.disabled&&this.element.addClass("ui-state-disabled").attr("aria-disabled","true"),this._on({"mousedown .ui-menu-item > a":function(e){e.preventDefault()},"click .ui-state-disabled > a":function(e){e.preventDefault()},"click .ui-menu-item:has(a)":function(t){var r=e(t.target).closest(".ui-menu-item");!n&&r.not(".ui-state-disabled").length&&(n=!0,this.select(t),r.has(".ui-menu").length?this.expand(t):this.element.is(":focus")||(this.element.trigger("focus",[!0]),this.active&&this.active.parents(".ui-menu").length===1&&clearTimeout(this.timer)))},"mouseenter .ui-menu-item":function(t){var n=e(t.currentTarget);n.siblings().children(".ui-state-active").removeClass("ui-state-active"),this.focus(t,n)},mouseleave:"collapseAll","mouseleave .ui-menu":"collapseAll",focus:function(e,t){var n=this.active||this.element.children(".ui-menu-item").eq(0);t||this.focus(e,n)},blur:function(t){this._delay(function(){e.contains(this.element[0],this.document[0].activeElement)||this.collapseAll(t)})},keydown:"_keydown"}),this.refresh(),this._on(this.document,{click:function(t){e(t.target).closest(".ui-menu").length||this.collapseAll(t),n=!1}})},_destroy:function(){this.element.removeAttr("aria-activedescendant").find(".ui-menu").andSelf().removeClass("ui-menu ui-widget ui-widget-content ui-corner-all ui-menu-icons").removeAttr("role").removeAttr("tabIndex").removeAttr("aria-labelledby").removeAttr("aria-expanded").removeAttr("aria-hidden").removeAttr("aria-disabled").removeUniqueId().show(),this.element.find(".ui-menu-item").removeClass("ui-menu-item").removeAttr("role").removeAttr("aria-disabled").children("a").removeUniqueId().removeClass("ui-corner-all ui-state-hover").removeAttr("tabIndex").removeAttr("role").removeAttr("aria-haspopup").children().each(function(){var t=e(this);t.data("ui-menu-submenu-carat")&&t.remove()}),this.element.find(".ui-menu-divider").removeClass("ui-menu-divider ui-widget-content")},_keydown:function(t){function a(e){return e.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g,"\\$&")}var n,r,i,s,o,u=!0;switch(t.keyCode){case e.ui.keyCode.PAGE_UP:this.previousPage(t);break;case e.ui.keyCode.PAGE_DOWN:this.nextPage(t);break;case e.ui.keyCode.HOME:this._move("first","first",t);break;case e.ui.keyCode.END:this._move("last","last",t);break;case e.ui.keyCode.UP:this.previous(t);break;case e.ui.keyCode.DOWN:this.next(t);break;case e.ui.keyCode.LEFT:this.collapse(t);break;case e.ui.keyCode.RIGHT:this.active&&!this.active.is(".ui-state-disabled")&&this.expand(t);break;case e.ui.keyCode.ENTER:case e.ui.keyCode.SPACE:this._activate(t);break;case e.ui.keyCode.ESCAPE:this.collapse(t);break;default:u=!1,r=this.previousFilter||"",i=String.fromCharCode(t.keyCode),s=!1,clearTimeout(this.filterTimer),i===r?s=!0:i=r+i,o=new RegExp("^"+a(i),"i"),n=this.activeMenu.children(".ui-menu-item").filter(function(){return o.test(e(this).children("a").text())}),n=s&&n.index(this.active.next())!==-1?this.active.nextAll(".ui-menu-item"):n,n.length||(i=String.fromCharCode(t.keyCode),o=new RegExp("^"+a(i),"i"),n=this.activeMenu.children(".ui-menu-item").filter(function(){return o.test(e(this).children("a").text())})),n.length?(this.focus(t,n),n.length>1?(this.previousFilter=i,this.filterTimer=this._delay(function(){delete this.previousFilter},1e3)):delete this.previousFilter):delete this.previousFilter}u&&t.preventDefault()},_activate:function(e){this.active.is(".ui-state-disabled")||(this.active.children("a[aria-haspopup='true']").length?this.expand(e):this.select(e))},refresh:function(){var t,n=this.options.icons.submenu,r=this.element.find(this.options.menus);r.filter(":not(.ui-menu)").addClass("ui-menu ui-widget ui-widget-content ui-corner-all").hide().attr({role:this.options.role,"aria-hidden":"true","aria-expanded":"false"}).each(function(){var t=e(this),r=t.prev("a"),i=e("<span>").addClass("ui-menu-icon ui-icon "+n).data("ui-menu-submenu-carat",!0);r.attr("aria-haspopup","true").prepend(i),t.attr("aria-labelledby",r.attr("id"))}),t=r.add(this.element),t.children(":not(.ui-menu-item):has(a)").addClass("ui-menu-item").attr("role","presentation").children("a").uniqueId().addClass("ui-corner-all").attr({tabIndex:-1,role:this._itemRole()}),t.children(":not(.ui-menu-item)").each(function(){var t=e(this);/[^\-—–\s]/.test(t.text())||t.addClass("ui-widget-content ui-menu-divider")}),t.children(".ui-state-disabled").attr("aria-disabled","true"),this.active&&!e.contains(this.element[0],this.active[0])&&this.blur()},_itemRole:function(){return{menu:"menuitem",listbox:"option"}[this.options.role]},focus:function(e,t){var n,r;this.blur(e,e&&e.type==="focus"),this._scrollIntoView(t),this.active=t.first(),r=this.active.children("a").addClass("ui-state-focus"),this.options.role&&this.element.attr("aria-activedescendant",r.attr("id")),this.active.parent().closest(".ui-menu-item").children("a:first").addClass("ui-state-active"),e&&e.type==="keydown"?this._close():this.timer=this._delay(function(){this._close()},this.delay),n=t.children(".ui-menu"),n.length&&/^mouse/.test(e.type)&&this._startOpening(n),this.activeMenu=t.parent(),this._trigger("focus",e,{item:t})},_scrollIntoView:function(t){var n,r,i,s,o,u;this._hasScroll()&&(n=parseFloat(e.css(this.activeMenu[0],"borderTopWidth"))||0,r=parseFloat(e.css(this.activeMenu[0],"paddingTop"))||0,i=t.offset().top-this.activeMenu.offset().top-n-r,s=this.activeMenu.scrollTop(),o=this.activeMenu.height(),u=t.height(),i<0?this.activeMenu.scrollTop(s+i):i+u>o&&this.activeMenu.scrollTop(s+i-o+u))},blur:function(e,t){t||clearTimeout(this.timer);if(!this.active)return;this.active.children("a").removeClass("ui-state-focus"),this.active=null,this._trigger("blur",e,{item:this.active})},_startOpening:function(e){clearTimeout(this.timer);if(e.attr("aria-hidden")!=="true")return;this.timer=this._delay(function(){this._close(),this._open(e)},this.delay)},_open:function(t){var n=e.extend({of:this.active},this.options.position);clearTimeout(this.timer),this.element.find(".ui-menu").not(t.parents(".ui-menu")).hide().attr("aria-hidden","true"),t.show().removeAttr("aria-hidden").attr("aria-expanded","true").position(n)},collapseAll:function(t,n){clearTimeout(this.timer),this.timer=this._delay(function(){var r=n?this.element:e(t&&t.target).closest(this.element.find(".ui-menu"));r.length||(r=this.element),this._close(r),this.blur(t),this.activeMenu=r},this.delay)},_close:function(e){e||(e=this.active?this.active.parent():this.element),e.find(".ui-menu").hide().attr("aria-hidden","true").attr("aria-expanded","false").end().find("a.ui-state-active").removeClass("ui-state-active")},collapse:function(e){var t=this.active&&this.active.parent().closest(".ui-menu-item",this.element);t&&t.length&&(this._close(),this.focus(e,t))},expand:function(e){var t=this.active&&this.active.children(".ui-menu ").children(".ui-menu-item").first();t&&t.length&&(this._open(t.parent()),this._delay(function(){this.focus(e,t)}))},next:function(e){this._move("next","first",e)},previous:function(e){this._move("prev","last",e)},isFirstItem:function(){return this.active&&!this.active.prevAll(".ui-menu-item").length},isLastItem:function(){return this.active&&!this.active.nextAll(".ui-menu-item").length},_move:function(e,t,n){var r;this.active&&(e==="first"||e==="last"?r=this.active[e==="first"?"prevAll":"nextAll"](".ui-menu-item").eq(-1):r=this.active[e+"All"](".ui-menu-item").eq(0));if(!r||!r.length||!this.active)r=this.activeMenu.children(".ui-menu-item")[t]();this.focus(n,r)},nextPage:function(t){var n,r,i;if(!this.active){this.next(t);return}if(this.isLastItem())return;this._hasScroll()?(r=this.active.offset().top,i=this.element.height(),this.active.nextAll(".ui-menu-item").each(function(){return n=e(this),n.offset().top-r-i<0}),this.focus(t,n)):this.focus(t,this.activeMenu.children(".ui-menu-item")[this.active?"last":"first"]())},previousPage:function(t){var n,r,i;if(!this.active){this.next(t);return}if(this.isFirstItem())return;this._hasScroll()?(r=this.active.offset().top,i=this.element.height(),this.active.prevAll(".ui-menu-item").each(function(){return n=e(this),n.offset().top-r+i>0}),this.focus(t,n)):this.focus(t,this.activeMenu.children(".ui-menu-item").first())},_hasScroll:function(){return this.element.outerHeight()<this.element.prop("scrollHeight")},select:function(t){this.active=this.active||e(t.target).closest(".ui-menu-item");var n={item:this.active};this.active.has(".ui-menu").length||this.collapseAll(t,!0),this._trigger("select",t,n)}})})(jQuery);(function(e,t){e.widget("ui.progressbar",{version:"1.9.2",options:{value:0,max:100},min:0,_create:function(){this.element.addClass("ui-progressbar ui-widget ui-widget-content ui-corner-all").attr({role:"progressbar","aria-valuemin":this.min,"aria-valuemax":this.options.max,"aria-valuenow":this._value()}),this.valueDiv=e("<div class='ui-progressbar-value ui-widget-header ui-corner-left'></div>").appendTo(this.element),this.oldValue=this._value(),this._refreshValue()},_destroy:function(){this.element.removeClass("ui-progressbar ui-widget ui-widget-content ui-corner-all").removeAttr("role").removeAttr("aria-valuemin").removeAttr("aria-valuemax").removeAttr("aria-valuenow"),this.valueDiv.remove()},value:function(e){return e===t?this._value():(this._setOption("value",e),this)},_setOption:function(e,t){e==="value"&&(this.options.value=t,this._refreshValue(),this._value()===this.options.max&&this._trigger("complete")),this._super(e,t)},_value:function(){var e=this.options.value;return typeof e!="number"&&(e=0),Math.min(this.options.max,Math.max(this.min,e))},_percentage:function(){return 100*this._value()/this.options.max},_refreshValue:function(){var e=this.value(),t=this._percentage();this.oldValue!==e&&(this.oldValue=e,this._trigger("change")),this.valueDiv.toggle(e>this.min).toggleClass("ui-corner-right",e===this.options.max).width(t.toFixed(0)+"%"),this.element.attr("aria-valuenow",e)}})})(jQuery);(function(e,t){e.widget("ui.resizable",e.ui.mouse,{version:"1.9.2",widgetEventPrefix:"resize",options:{alsoResize:!1,animate:!1,animateDuration:"slow",animateEasing:"swing",aspectRatio:!1,autoHide:!1,containment:!1,ghost:!1,grid:!1,handles:"e,s,se",helper:!1,maxHeight:null,maxWidth:null,minHeight:10,minWidth:10,zIndex:1e3},_create:function(){var t=this,n=this.options;this.element.addClass("ui-resizable"),e.extend(this,{_aspectRatio:!!n.aspectRatio,aspectRatio:n.aspectRatio,originalElement:this.element,_proportionallyResizeElements:[],_helper:n.helper||n.ghost||n.animate?n.helper||"ui-resizable-helper":null}),this.element[0].nodeName.match(/canvas|textarea|input|select|button|img/i)&&(this.element.wrap(e('<div class="ui-wrapper" style="overflow: hidden;"></div>').css({position:this.element.css("position"),width:this.element.outerWidth(),height:this.element.outerHeight(),top:this.element.css("top"),left:this.element.css("left")})),this.element=this.element.parent().data("resizable",this.element.data("resizable")),this.elementIsWrapper=!0,this.element.css({marginLeft:this.originalElement.css("marginLeft"),marginTop:this.originalElement.css("marginTop"),marginRight:this.originalElement.css("marginRight"),marginBottom:this.originalElement.css("marginBottom")}),this.originalElement.css({marginLeft:0,marginTop:0,marginRight:0,marginBottom:0}),this.originalResizeStyle=this.originalElement.css("resize"),this.originalElement.css("resize","none"),this._proportionallyResizeElements.push(this.originalElement.css({position:"static",zoom:1,display:"block"})),this.originalElement.css({margin:this.originalElement.css("margin")}),this._proportionallyResize()),this.handles=n.handles||(e(".ui-resizable-handle",this.element).length?{n:".ui-resizable-n",e:".ui-resizable-e",s:".ui-resizable-s",w:".ui-resizable-w",se:".ui-resizable-se",sw:".ui-resizable-sw",ne:".ui-resizable-ne",nw:".ui-resizable-nw"}:"e,s,se");if(this.handles.constructor==String){this.handles=="all"&&(this.handles="n,e,s,w,se,sw,ne,nw");var r=this.handles.split(",");this.handles={};for(var i=0;i<r.length;i++){var s=e.trim(r[i]),o="ui-resizable-"+s,u=e('<div class="ui-resizable-handle '+o+'"></div>');u.css({zIndex:n.zIndex}),"se"==s&&u.addClass("ui-icon ui-icon-gripsmall-diagonal-se"),this.handles[s]=".ui-resizable-"+s,this.element.append(u)}}this._renderAxis=function(t){t=t||this.element;for(var n in this.handles){this.handles[n].constructor==String&&(this.handles[n]=e(this.handles[n],this.element).show());if(this.elementIsWrapper&&this.originalElement[0].nodeName.match(/textarea|input|select|button/i)){var r=e(this.handles[n],this.element),i=0;i=/sw|ne|nw|se|n|s/.test(n)?r.outerHeight():r.outerWidth();var s=["padding",/ne|nw|n/.test(n)?"Top":/se|sw|s/.test(n)?"Bottom":/^e$/.test(n)?"Right":"Left"].join("");t.css(s,i),this._proportionallyResize()}if(!e(this.handles[n]).length)continue}},this._renderAxis(this.element),this._handles=e(".ui-resizable-handle",this.element).disableSelection(),this._handles.mouseover(function(){if(!t.resizing){if(this.className)var e=this.className.match(/ui-resizable-(se|sw|ne|nw|n|e|s|w)/i);t.axis=e&&e[1]?e[1]:"se"}}),n.autoHide&&(this._handles.hide(),e(this.element).addClass("ui-resizable-autohide").mouseenter(function(){if(n.disabled)return;e(this).removeClass("ui-resizable-autohide"),t._handles.show()}).mouseleave(function(){if(n.disabled)return;t.resizing||(e(this).addClass("ui-resizable-autohide"),t._handles.hide())})),this._mouseInit()},_destroy:function(){this._mouseDestroy();var t=function(t){e(t).removeClass("ui-resizable ui-resizable-disabled ui-resizable-resizing").removeData("resizable").removeData("ui-resizable").unbind(".resizable").find(".ui-resizable-handle").remove()};if(this.elementIsWrapper){t(this.element);var n=this.element;this.originalElement.css({position:n.css("position"),width:n.outerWidth(),height:n.outerHeight(),top:n.css("top"),left:n.css("left")}).insertAfter(n),n.remove()}return this.originalElement.css("resize",this.originalResizeStyle),t(this.originalElement),this},_mouseCapture:function(t){var n=!1;for(var r in this.handles)e(this.handles[r])[0]==t.target&&(n=!0);return!this.options.disabled&&n},_mouseStart:function(t){var r=this.options,i=this.element.position(),s=this.element;this.resizing=!0,this.documentScroll={top:e(document).scrollTop(),left:e(document).scrollLeft()},(s.is(".ui-draggable")||/absolute/.test(s.css("position")))&&s.css({position:"absolute",top:i.top,left:i.left}),this._renderProxy();var o=n(this.helper.css("left")),u=n(this.helper.css("top"));r.containment&&(o+=e(r.containment).scrollLeft()||0,u+=e(r.containment).scrollTop()||0),this.offset=this.helper.offset(),this.position={left:o,top:u},this.size=this._helper?{width:s.outerWidth(),height:s.outerHeight()}:{width:s.width(),height:s.height()},this.originalSize=this._helper?{width:s.outerWidth(),height:s.outerHeight()}:{width:s.width(),height:s.height()},this.originalPosition={left:o,top:u},this.sizeDiff={width:s.outerWidth()-s.width(),height:s.outerHeight()-s.height()},this.originalMousePosition={left:t.pageX,top:t.pageY},this.aspectRatio=typeof r.aspectRatio=="number"?r.aspectRatio:this.originalSize.width/this.originalSize.height||1;var a=e(".ui-resizable-"+this.axis).css("cursor");return e("body").css("cursor",a=="auto"?this.axis+"-resize":a),s.addClass("ui-resizable-resizing"),this._propagate("start",t),!0},_mouseDrag:function(e){var t=this.helper,n=this.options,r={},i=this,s=this.originalMousePosition,o=this.axis,u=e.pageX-s.left||0,a=e.pageY-s.top||0,f=this._change[o];if(!f)return!1;var l=f.apply(this,[e,u,a]);this._updateVirtualBoundaries(e.shiftKey);if(this._aspectRatio||e.shiftKey)l=this._updateRatio(l,e);return l=this._respectSize(l,e),this._propagate("resize",e),t.css({top:this.position.top+"px",left:this.position.left+"px",width:this.size.width+"px",height:this.size.height+"px"}),!this._helper&&this._proportionallyResizeElements.length&&this._proportionallyResize(),this._updateCache(l),this._trigger("resize",e,this.ui()),!1},_mouseStop:function(t){this.resizing=!1;var n=this.options,r=this;if(this._helper){var i=this._proportionallyResizeElements,s=i.length&&/textarea/i.test(i[0].nodeName),o=s&&e.ui.hasScroll(i[0],"left")?0:r.sizeDiff.height,u=s?0:r.sizeDiff.width,a={width:r.helper.width()-u,height:r.helper.height()-o},f=parseInt(r.element.css("left"),10)+(r.position.left-r.originalPosition.left)||null,l=parseInt(r.element.css("top"),10)+(r.position.top-r.originalPosition.top)||null;n.animate||this.element.css(e.extend(a,{top:l,left:f})),r.helper.height(r.size.height),r.helper.width(r.size.width),this._helper&&!n.animate&&this._proportionallyResize()}return e("body").css("cursor","auto"),this.element.removeClass("ui-resizable-resizing"),this._propagate("stop",t),this._helper&&this.helper.remove(),!1},_updateVirtualBoundaries:function(e){var t=this.options,n,i,s,o,u;u={minWidth:r(t.minWidth)?t.minWidth:0,maxWidth:r(t.maxWidth)?t.maxWidth:Infinity,minHeight:r(t.minHeight)?t.minHeight:0,maxHeight:r(t.maxHeight)?t.maxHeight:Infinity};if(this._aspectRatio||e)n=u.minHeight*this.aspectRatio,s=u.minWidth/this.aspectRatio,i=u.maxHeight*this.aspectRatio,o=u.maxWidth/this.aspectRatio,n>u.minWidth&&(u.minWidth=n),s>u.minHeight&&(u.minHeight=s),i<u.maxWidth&&(u.maxWidth=i),o<u.maxHeight&&(u.maxHeight=o);this._vBoundaries=u},_updateCache:function(e){var t=this.options;this.offset=this.helper.offset(),r(e.left)&&(this.position.left=e.left),r(e.top)&&(this.position.top=e.top),r(e.height)&&(this.size.height=e.height),r(e.width)&&(this.size.width=e.width)},_updateRatio:function(e,t){var n=this.options,i=this.position,s=this.size,o=this.axis;return r(e.height)?e.width=e.height*this.aspectRatio:r(e.width)&&(e.height=e.width/this.aspectRatio),o=="sw"&&(e.left=i.left+(s.width-e.width),e.top=null),o=="nw"&&(e.top=i.top+(s.height-e.height),e.left=i.left+(s.width-e.width)),e},_respectSize:function(e,t){var n=this.helper,i=this._vBoundaries,s=this._aspectRatio||t.shiftKey,o=this.axis,u=r(e.width)&&i.maxWidth&&i.maxWidth<e.width,a=r(e.height)&&i.maxHeight&&i.maxHeight<e.height,f=r(e.width)&&i.minWidth&&i.minWidth>e.width,l=r(e.height)&&i.minHeight&&i.minHeight>e.height;f&&(e.width=i.minWidth),l&&(e.height=i.minHeight),u&&(e.width=i.maxWidth),a&&(e.height=i.maxHeight);var c=this.originalPosition.left+this.originalSize.width,h=this.position.top+this.size.height,p=/sw|nw|w/.test(o),d=/nw|ne|n/.test(o);f&&p&&(e.left=c-i.minWidth),u&&p&&(e.left=c-i.maxWidth),l&&d&&(e.top=h-i.minHeight),a&&d&&(e.top=h-i.maxHeight);var v=!e.width&&!e.height;return v&&!e.left&&e.top?e.top=null:v&&!e.top&&e.left&&(e.left=null),e},_proportionallyResize:function(){var t=this.options;if(!this._proportionallyResizeElements.length)return;var n=this.helper||this.element;for(var r=0;r<this._proportionallyResizeElements.length;r++){var i=this._proportionallyResizeElements[r];if(!this.borderDif){var s=[i.css("borderTopWidth"),i.css("borderRightWidth"),i.css("borderBottomWidth"),i.css("borderLeftWidth")],o=[i.css("paddingTop"),i.css("paddingRight"),i.css("paddingBottom"),i.css("paddingLeft")];this.borderDif=e.map(s,function(e,t){var n=parseInt(e,10)||0,r=parseInt(o[t],10)||0;return n+r})}i.css({height:n.height()-this.borderDif[0]-this.borderDif[2]||0,width:n.width()-this.borderDif[1]-this.borderDif[3]||0})}},_renderProxy:function(){var t=this.element,n=this.options;this.elementOffset=t.offset();if(this._helper){this.helper=this.helper||e('<div style="overflow:hidden;"></div>');var r=e.ui.ie6?1:0,i=e.ui.ie6?2:-1;this.helper.addClass(this._helper).css({width:this.element.outerWidth()+i,height:this.element.outerHeight()+i,position:"absolute",left:this.elementOffset.left-r+"px",top:this.elementOffset.top-r+"px",zIndex:++n.zIndex}),this.helper.appendTo("body").disableSelection()}else this.helper=this.element},_change:{e:function(e,t,n){return{width:this.originalSize.width+t}},w:function(e,t,n){var r=this.options,i=this.originalSize,s=this.originalPosition;return{left:s.left+t,width:i.width-t}},n:function(e,t,n){var r=this.options,i=this.originalSize,s=this.originalPosition;return{top:s.top+n,height:i.height-n}},s:function(e,t,n){return{height:this.originalSize.height+n}},se:function(t,n,r){return e.extend(this._change.s.apply(this,arguments),this._change.e.apply(this,[t,n,r]))},sw:function(t,n,r){return e.extend(this._change.s.apply(this,arguments),this._change.w.apply(this,[t,n,r]))},ne:function(t,n,r){return e.extend(this._change.n.apply(this,arguments),this._change.e.apply(this,[t,n,r]))},nw:function(t,n,r){return e.extend(this._change.n.apply(this,arguments),this._change.w.apply(this,[t,n,r]))}},_propagate:function(t,n){e.ui.plugin.call(this,t,[n,this.ui()]),t!="resize"&&this._trigger(t,n,this.ui())},plugins:{},ui:function(){return{originalElement:this.originalElement,element:this.element,helper:this.helper,position:this.position,size:this.size,originalSize:this.originalSize,originalPosition:this.originalPosition}}}),e.ui.plugin.add("resizable","alsoResize",{start:function(t,n){var r=e(this).data("resizable"),i=r.options,s=function(t){e(t).each(function(){var t=e(this);t.data("resizable-alsoresize",{width:parseInt(t.width(),10),height:parseInt(t.height(),10),left:parseInt(t.css("left"),10),top:parseInt(t.css("top"),10)})})};typeof i.alsoResize=="object"&&!i.alsoResize.parentNode?i.alsoResize.length?(i.alsoResize=i.alsoResize[0],s(i.alsoResize)):e.each(i.alsoResize,function(e){s(e)}):s(i.alsoResize)},resize:function(t,n){var r=e(this).data("resizable"),i=r.options,s=r.originalSize,o=r.originalPosition,u={height:r.size.height-s.height||0,width:r.size.width-s.width||0,top:r.position.top-o.top||0,left:r.position.left-o.left||0},a=function(t,r){e(t).each(function(){var t=e(this),i=e(this).data("resizable-alsoresize"),s={},o=r&&r.length?r:t.parents(n.originalElement[0]).length?["width","height"]:["width","height","top","left"];e.each(o,function(e,t){var n=(i[t]||0)+(u[t]||0);n&&n>=0&&(s[t]=n||null)}),t.css(s)})};typeof i.alsoResize=="object"&&!i.alsoResize.nodeType?e.each(i.alsoResize,function(e,t){a(e,t)}):a(i.alsoResize)},stop:function(t,n){e(this).removeData("resizable-alsoresize")}}),e.ui.plugin.add("resizable","animate",{stop:function(t,n){var r=e(this).data("resizable"),i=r.options,s=r._proportionallyResizeElements,o=s.length&&/textarea/i.test(s[0].nodeName),u=o&&e.ui.hasScroll(s[0],"left")?0:r.sizeDiff.height,a=o?0:r.sizeDiff.width,f={width:r.size.width-a,height:r.size.height-u},l=parseInt(r.element.css("left"),10)+(r.position.left-r.originalPosition.left)||null,c=parseInt(r.element.css("top"),10)+(r.position.top-r.originalPosition.top)||null;r.element.animate(e.extend(f,c&&l?{top:c,left:l}:{}),{duration:i.animateDuration,easing:i.animateEasing,step:function(){var n={width:parseInt(r.element.css("width"),10),height:parseInt(r.element.css("height"),10),top:parseInt(r.element.css("top"),10),left:parseInt(r.element.css("left"),10)};s&&s.length&&e(s[0]).css({width:n.width,height:n.height}),r._updateCache(n),r._propagate("resize",t)}})}}),e.ui.plugin.add("resizable","containment",{start:function(t,r){var i=e(this).data("resizable"),s=i.options,o=i.element,u=s.containment,a=u instanceof e?u.get(0):/parent/.test(u)?o.parent().get(0):u;if(!a)return;i.containerElement=e(a);if(/document/.test(u)||u==document)i.containerOffset={left:0,top:0},i.containerPosition={left:0,top:0},i.parentData={element:e(document),left:0,top:0,width:e(document).width(),height:e(document).height()||document.body.parentNode.scrollHeight};else{var f=e(a),l=[];e(["Top","Right","Left","Bottom"]).each(function(e,t){l[e]=n(f.css("padding"+t))}),i.containerOffset=f.offset(),i.containerPosition=f.position(),i.containerSize={height:f.innerHeight()-l[3],width:f.innerWidth()-l[1]};var c=i.containerOffset,h=i.containerSize.height,p=i.containerSize.width,d=e.ui.hasScroll(a,"left")?a.scrollWidth:p,v=e.ui.hasScroll(a)?a.scrollHeight:h;i.parentData={element:a,left:c.left,top:c.top,width:d,height:v}}},resize:function(t,n){var r=e(this).data("resizable"),i=r.options,s=r.containerSize,o=r.containerOffset,u=r.size,a=r.position,f=r._aspectRatio||t.shiftKey,l={top:0,left:0},c=r.containerElement;c[0]!=document&&/static/.test(c.css("position"))&&(l=o),a.left<(r._helper?o.left:0)&&(r.size.width=r.size.width+(r._helper?r.position.left-o.left:r.position.left-l.left),f&&(r.size.height=r.size.width/r.aspectRatio),r.position.left=i.helper?o.left:0),a.top<(r._helper?o.top:0)&&(r.size.height=r.size.height+(r._helper?r.position.top-o.top:r.position.top),f&&(r.size.width=r.size.height*r.aspectRatio),r.position.top=r._helper?o.top:0),r.offset.left=r.parentData.left+r.position.left,r.offset.top=r.parentData.top+r.position.top;var h=Math.abs((r._helper?r.offset.left-l.left:r.offset.left-l.left)+r.sizeDiff.width),p=Math.abs((r._helper?r.offset.top-l.top:r.offset.top-o.top)+r.sizeDiff.height),d=r.containerElement.get(0)==r.element.parent().get(0),v=/relative|absolute/.test(r.containerElement.css("position"));d&&v&&(h-=r.parentData.left),h+r.size.width>=r.parentData.width&&(r.size.width=r.parentData.width-h,f&&(r.size.height=r.size.width/r.aspectRatio)),p+r.size.height>=r.parentData.height&&(r.size.height=r.parentData.height-p,f&&(r.size.width=r.size.height*r.aspectRatio))},stop:function(t,n){var r=e(this).data("resizable"),i=r.options,s=r.position,o=r.containerOffset,u=r.containerPosition,a=r.containerElement,f=e(r.helper),l=f.offset(),c=f.outerWidth()-r.sizeDiff.width,h=f.outerHeight()-r.sizeDiff.height;r._helper&&!i.animate&&/relative/.test(a.css("position"))&&e(this).css({left:l.left-u.left-o.left,width:c,height:h}),r._helper&&!i.animate&&/static/.test(a.css("position"))&&e(this).css({left:l.left-u.left-o.left,width:c,height:h})}}),e.ui.plugin.add("resizable","ghost",{start:function(t,n){var r=e(this).data("resizable"),i=r.options,s=r.size;r.ghost=r.originalElement.clone(),r.ghost.css({opacity:.25,display:"block",position:"relative",height:s.height,width:s.width,margin:0,left:0,top:0}).addClass("ui-resizable-ghost").addClass(typeof i.ghost=="string"?i.ghost:""),r.ghost.appendTo(r.helper)},resize:function(t,n){var r=e(this).data("resizable"),i=r.options;r.ghost&&r.ghost.css({position:"relative",height:r.size.height,width:r.size.width})},stop:function(t,n){var r=e(this).data("resizable"),i=r.options;r.ghost&&r.helper&&r.helper.get(0).removeChild(r.ghost.get(0))}}),e.ui.plugin.add("resizable","grid",{resize:function(t,n){var r=e(this).data("resizable"),i=r.options,s=r.size,o=r.originalSize,u=r.originalPosition,a=r.axis,f=i._aspectRatio||t.shiftKey;i.grid=typeof i.grid=="number"?[i.grid,i.grid]:i.grid;var l=Math.round((s.width-o.width)/(i.grid[0]||1))*(i.grid[0]||1),c=Math.round((s.height-o.height)/(i.grid[1]||1))*(i.grid[1]||1);/^(se|s|e)$/.test(a)?(r.size.width=o.width+l,r.size.height=o.height+c):/^(ne)$/.test(a)?(r.size.width=o.width+l,r.size.height=o.height+c,r.position.top=u.top-c):/^(sw)$/.test(a)?(r.size.width=o.width+l,r.size.height=o.height+c,r.position.left=u.left-l):(r.size.width=o.width+l,r.size.height=o.height+c,r.position.top=u.top-c,r.position.left=u.left-l)}});var n=function(e){return parseInt(e,10)||0},r=function(e){return!isNaN(parseInt(e,10))}})(jQuery);(function(e,t){e.widget("ui.selectable",e.ui.mouse,{version:"1.9.2",options:{appendTo:"body",autoRefresh:!0,distance:0,filter:"*",tolerance:"touch"},_create:function(){var t=this;this.element.addClass("ui-selectable"),this.dragged=!1;var n;this.refresh=function(){n=e(t.options.filter,t.element[0]),n.addClass("ui-selectee"),n.each(function(){var t=e(this),n=t.offset();e.data(this,"selectable-item",{element:this,$element:t,left:n.left,top:n.top,right:n.left+t.outerWidth(),bottom:n.top+t.outerHeight(),startselected:!1,selected:t.hasClass("ui-selected"),selecting:t.hasClass("ui-selecting"),unselecting:t.hasClass("ui-unselecting")})})},this.refresh(),this.selectees=n.addClass("ui-selectee"),this._mouseInit(),this.helper=e("<div class='ui-selectable-helper'></div>")},_destroy:function(){this.selectees.removeClass("ui-selectee").removeData("selectable-item"),this.element.removeClass("ui-selectable ui-selectable-disabled"),this._mouseDestroy()},_mouseStart:function(t){var n=this;this.opos=[t.pageX,t.pageY];if(this.options.disabled)return;var r=this.options;this.selectees=e(r.filter,this.element[0]),this._trigger("start",t),e(r.appendTo).append(this.helper),this.helper.css({left:t.clientX,top:t.clientY,width:0,height:0}),r.autoRefresh&&this.refresh(),this.selectees.filter(".ui-selected").each(function(){var r=e.data(this,"selectable-item");r.startselected=!0,!t.metaKey&&!t.ctrlKey&&(r.$element.removeClass("ui-selected"),r.selected=!1,r.$element.addClass("ui-unselecting"),r.unselecting=!0,n._trigger("unselecting",t,{unselecting:r.element}))}),e(t.target).parents().andSelf().each(function(){var r=e.data(this,"selectable-item");if(r){var i=!t.metaKey&&!t.ctrlKey||!r.$element.hasClass("ui-selected");return r.$element.removeClass(i?"ui-unselecting":"ui-selected").addClass(i?"ui-selecting":"ui-unselecting"),r.unselecting=!i,r.selecting=i,r.selected=i,i?n._trigger("selecting",t,{selecting:r.element}):n._trigger("unselecting",t,{unselecting:r.element}),!1}})},_mouseDrag:function(t){var n=this;this.dragged=!0;if(this.options.disabled)return;var r=this.options,i=this.opos[0],s=this.opos[1],o=t.pageX,u=t.pageY;if(i>o){var a=o;o=i,i=a}if(s>u){var a=u;u=s,s=a}return this.helper.css({left:i,top:s,width:o-i,height:u-s}),this.selectees.each(function(){var a=e.data(this,"selectable-item");if(!a||a.element==n.element[0])return;var f=!1;r.tolerance=="touch"?f=!(a.left>o||a.right<i||a.top>u||a.bottom<s):r.tolerance=="fit"&&(f=a.left>i&&a.right<o&&a.top>s&&a.bottom<u),f?(a.selected&&(a.$element.removeClass("ui-selected"),a.selected=!1),a.unselecting&&(a.$element.removeClass("ui-unselecting"),a.unselecting=!1),a.selecting||(a.$element.addClass("ui-selecting"),a.selecting=!0,n._trigger("selecting",t,{selecting:a.element}))):(a.selecting&&((t.metaKey||t.ctrlKey)&&a.startselected?(a.$element.removeClass("ui-selecting"),a.selecting=!1,a.$element.addClass("ui-selected"),a.selected=!0):(a.$element.removeClass("ui-selecting"),a.selecting=!1,a.startselected&&(a.$element.addClass("ui-unselecting"),a.unselecting=!0),n._trigger("unselecting",t,{unselecting:a.element}))),a.selected&&!t.metaKey&&!t.ctrlKey&&!a.startselected&&(a.$element.removeClass("ui-selected"),a.selected=!1,a.$element.addClass("ui-unselecting"),a.unselecting=!0,n._trigger("unselecting",t,{unselecting:a.element})))}),!1},_mouseStop:function(t){var n=this;this.dragged=!1;var r=this.options;return e(".ui-unselecting",this.element[0]).each(function(){var r=e.data(this,"selectable-item");r.$element.removeClass("ui-unselecting"),r.unselecting=!1,r.startselected=!1,n._trigger("unselected",t,{unselected:r.element})}),e(".ui-selecting",this.element[0]).each(function(){var r=e.data(this,"selectable-item");r.$element.removeClass("ui-selecting").addClass("ui-selected"),r.selecting=!1,r.selected=!0,r.startselected=!0,n._trigger("selected",t,{selected:r.element})}),this._trigger("stop",t),this.helper.remove(),!1}})})(jQuery);(function(e,t){var n=5;e.widget("ui.slider",e.ui.mouse,{version:"1.9.2",widgetEventPrefix:"slide",options:{animate:!1,distance:0,max:100,min:0,orientation:"horizontal",range:!1,step:1,value:0,values:null},_create:function(){var t,r,i=this.options,s=this.element.find(".ui-slider-handle").addClass("ui-state-default ui-corner-all"),o="<a class='ui-slider-handle ui-state-default ui-corner-all' href='#'></a>",u=[];this._keySliding=!1,this._mouseSliding=!1,this._animateOff=!0,this._handleIndex=null,this._detectOrientation(),this._mouseInit(),this.element.addClass("ui-slider ui-slider-"+this.orientation+" ui-widget"+" ui-widget-content"+" ui-corner-all"+(i.disabled?" ui-slider-disabled ui-disabled":"")),this.range=e([]),i.range&&(i.range===!0&&(i.values||(i.values=[this._valueMin(),this._valueMin()]),i.values.length&&i.values.length!==2&&(i.values=[i.values[0],i.values[0]])),this.range=e("<div></div>").appendTo(this.element).addClass("ui-slider-range ui-widget-header"+(i.range==="min"||i.range==="max"?" ui-slider-range-"+i.range:""))),r=i.values&&i.values.length||1;for(t=s.length;t<r;t++)u.push(o);this.handles=s.add(e(u.join("")).appendTo(this.element)),this.handle=this.handles.eq(0),this.handles.add(this.range).filter("a").click(function(e){e.preventDefault()}).mouseenter(function(){i.disabled||e(this).addClass("ui-state-hover")}).mouseleave(function(){e(this).removeClass("ui-state-hover")}).focus(function(){i.disabled?e(this).blur():(e(".ui-slider .ui-state-focus").removeClass("ui-state-focus"),e(this).addClass("ui-state-focus"))}).blur(function(){e(this).removeClass("ui-state-focus")}),this.handles.each(function(t){e(this).data("ui-slider-handle-index",t)}),this._on(this.handles,{keydown:function(t){var r,i,s,o,u=e(t.target).data("ui-slider-handle-index");switch(t.keyCode){case e.ui.keyCode.HOME:case e.ui.keyCode.END:case e.ui.keyCode.PAGE_UP:case e.ui.keyCode.PAGE_DOWN:case e.ui.keyCode.UP:case e.ui.keyCode.RIGHT:case e.ui.keyCode.DOWN:case e.ui.keyCode.LEFT:t.preventDefault();if(!this._keySliding){this._keySliding=!0,e(t.target).addClass("ui-state-active"),r=this._start(t,u);if(r===!1)return}}o=this.options.step,this.options.values&&this.options.values.length?i=s=this.values(u):i=s=this.value();switch(t.keyCode){case e.ui.keyCode.HOME:s=this._valueMin();break;case e.ui.keyCode.END:s=this._valueMax();break;case e.ui.keyCode.PAGE_UP:s=this._trimAlignValue(i+(this._valueMax()-this._valueMin())/n);break;case e.ui.keyCode.PAGE_DOWN:s=this._trimAlignValue(i-(this._valueMax()-this._valueMin())/n);break;case e.ui.keyCode.UP:case e.ui.keyCode.RIGHT:if(i===this._valueMax())return;s=this._trimAlignValue(i+o);break;case e.ui.keyCode.DOWN:case e.ui.keyCode.LEFT:if(i===this._valueMin())return;s=this._trimAlignValue(i-o)}this._slide(t,u,s)},keyup:function(t){var n=e(t.target).data("ui-slider-handle-index");this._keySliding&&(this._keySliding=!1,this._stop(t,n),this._change(t,n),e(t.target).removeClass("ui-state-active"))}}),this._refreshValue(),this._animateOff=!1},_destroy:function(){this.handles.remove(),this.range.remove(),this.element.removeClass("ui-slider ui-slider-horizontal ui-slider-vertical ui-slider-disabled ui-widget ui-widget-content ui-corner-all"),this._mouseDestroy()},_mouseCapture:function(t){var n,r,i,s,o,u,a,f,l=this,c=this.options;return c.disabled?!1:(this.elementSize={width:this.element.outerWidth(),height:this.element.outerHeight()},this.elementOffset=this.element.offset(),n={x:t.pageX,y:t.pageY},r=this._normValueFromMouse(n),i=this._valueMax()-this._valueMin()+1,this.handles.each(function(t){var n=Math.abs(r-l.values(t));i>n&&(i=n,s=e(this),o=t)}),c.range===!0&&this.values(1)===c.min&&(o+=1,s=e(this.handles[o])),u=this._start(t,o),u===!1?!1:(this._mouseSliding=!0,this._handleIndex=o,s.addClass("ui-state-active").focus(),a=s.offset(),f=!e(t.target).parents().andSelf().is(".ui-slider-handle"),this._clickOffset=f?{left:0,top:0}:{left:t.pageX-a.left-s.width()/2,top:t.pageY-a.top-s.height()/2-(parseInt(s.css("borderTopWidth"),10)||0)-(parseInt(s.css("borderBottomWidth"),10)||0)+(parseInt(s.css("marginTop"),10)||0)},this.handles.hasClass("ui-state-hover")||this._slide(t,o,r),this._animateOff=!0,!0))},_mouseStart:function(){return!0},_mouseDrag:function(e){var t={x:e.pageX,y:e.pageY},n=this._normValueFromMouse(t);return this._slide(e,this._handleIndex,n),!1},_mouseStop:function(e){return this.handles.removeClass("ui-state-active"),this._mouseSliding=!1,this._stop(e,this._handleIndex),this._change(e,this._handleIndex),this._handleIndex=null,this._clickOffset=null,this._animateOff=!1,!1},_detectOrientation:function(){this.orientation=this.options.orientation==="vertical"?"vertical":"horizontal"},_normValueFromMouse:function(e){var t,n,r,i,s;return this.orientation==="horizontal"?(t=this.elementSize.width,n=e.x-this.elementOffset.left-(this._clickOffset?this._clickOffset.left:0)):(t=this.elementSize.height,n=e.y-this.elementOffset.top-(this._clickOffset?this._clickOffset.top:0)),r=n/t,r>1&&(r=1),r<0&&(r=0),this.orientation==="vertical"&&(r=1-r),i=this._valueMax()-this._valueMin(),s=this._valueMin()+r*i,this._trimAlignValue(s)},_start:function(e,t){var n={handle:this.handles[t],value:this.value()};return this.options.values&&this.options.values.length&&(n.value=this.values(t),n.values=this.values()),this._trigger("start",e,n)},_slide:function(e,t,n){var r,i,s;this.options.values&&this.options.values.length?(r=this.values(t?0:1),this.options.values.length===2&&this.options.range===!0&&(t===0&&n>r||t===1&&n<r)&&(n=r),n!==this.values(t)&&(i=this.values(),i[t]=n,s=this._trigger("slide",e,{handle:this.handles[t],value:n,values:i}),r=this.values(t?0:1),s!==!1&&this.values(t,n,!0))):n!==this.value()&&(s=this._trigger("slide",e,{handle:this.handles[t],value:n}),s!==!1&&this.value(n))},_stop:function(e,t){var n={handle:this.handles[t],value:this.value()};this.options.values&&this.options.values.length&&(n.value=this.values(t),n.values=this.values()),this._trigger("stop",e,n)},_change:function(e,t){if(!this._keySliding&&!this._mouseSliding){var n={handle:this.handles[t],value:this.value()};this.options.values&&this.options.values.length&&(n.value=this.values(t),n.values=this.values()),this._trigger("change",e,n)}},value:function(e){if(arguments.length){this.options.value=this._trimAlignValue(e),this._refreshValue(),this._change(null,0);return}return this._value()},values:function(t,n){var r,i,s;if(arguments.length>1){this.options.values[t]=this._trimAlignValue(n),this._refreshValue(),this._change(null,t);return}if(!arguments.length)return this._values();if(!e.isArray(arguments[0]))return this.options.values&&this.options.values.length?this._values(t):this.value();r=this.options.values,i=arguments[0];for(s=0;s<r.length;s+=1)r[s]=this._trimAlignValue(i[s]),this._change(null,s);this._refreshValue()},_setOption:function(t,n){var r,i=0;e.isArray(this.options.values)&&(i=this.options.values.length),e.Widget.prototype._setOption.apply(this,arguments);switch(t){case"disabled":n?(this.handles.filter(".ui-state-focus").blur(),this.handles.removeClass("ui-state-hover"),this.handles.prop("disabled",!0),this.element.addClass("ui-disabled")):(this.handles.prop("disabled",!1),this.element.removeClass("ui-disabled"));break;case"orientation":this._detectOrientation(),this.element.removeClass("ui-slider-horizontal ui-slider-vertical").addClass("ui-slider-"+this.orientation),this._refreshValue();break;case"value":this._animateOff=!0,this._refreshValue(),this._change(null,0),this._animateOff=!1;break;case"values":this._animateOff=!0,this._refreshValue();for(r=0;r<i;r+=1)this._change(null,r);this._animateOff=!1;break;case"min":case"max":this._animateOff=!0,this._refreshValue(),this._animateOff=!1}},_value:function(){var e=this.options.value;return e=this._trimAlignValue(e),e},_values:function(e){var t,n,r;if(arguments.length)return t=this.options.values[e],t=this._trimAlignValue(t),t;n=this.options.values.slice();for(r=0;r<n.length;r+=1)n[r]=this._trimAlignValue(n[r]);return n},_trimAlignValue:function(e){if(e<=this._valueMin())return this._valueMin();if(e>=this._valueMax())return this._valueMax();var t=this.options.step>0?this.options.step:1,n=(e-this._valueMin())%t,r=e-n;return Math.abs(n)*2>=t&&(r+=n>0?t:-t),parseFloat(r.toFixed(5))},_valueMin:function(){return this.options.min},_valueMax:function(){return this.options.max},_refreshValue:function(){var t,n,r,i,s,o=this.options.range,u=this.options,a=this,f=this._animateOff?!1:u.animate,l={};this.options.values&&this.options.values.length?this.handles.each(function(r){n=(a.values(r)-a._valueMin())/(a._valueMax()-a._valueMin())*100,l[a.orientation==="horizontal"?"left":"bottom"]=n+"%",e(this).stop(1,1)[f?"animate":"css"](l,u.animate),a.options.range===!0&&(a.orientation==="horizontal"?(r===0&&a.range.stop(1,1)[f?"animate":"css"]({left:n+"%"},u.animate),r===1&&a.range[f?"animate":"css"]({width:n-t+"%"},{queue:!1,duration:u.animate})):(r===0&&a.range.stop(1,1)[f?"animate":"css"]({bottom:n+"%"},u.animate),r===1&&a.range[f?"animate":"css"]({height:n-t+"%"},{queue:!1,duration:u.animate}))),t=n}):(r=this.value(),i=this._valueMin(),s=this._valueMax(),n=s!==i?(r-i)/(s-i)*100:0,l[this.orientation==="horizontal"?"left":"bottom"]=n+"%",this.handle.stop(1,1)[f?"animate":"css"](l,u.animate),o==="min"&&this.orientation==="horizontal"&&this.range.stop(1,1)[f?"animate":"css"]({width:n+"%"},u.animate),o==="max"&&this.orientation==="horizontal"&&this.range[f?"animate":"css"]({width:100-n+"%"},{queue:!1,duration:u.animate}),o==="min"&&this.orientation==="vertical"&&this.range.stop(1,1)[f?"animate":"css"]({height:n+"%"},u.animate),o==="max"&&this.orientation==="vertical"&&this.range[f?"animate":"css"]({height:100-n+"%"},{queue:!1,duration:u.animate}))}})})(jQuery);(function(e,t){e.widget("ui.sortable",e.ui.mouse,{version:"1.9.2",widgetEventPrefix:"sort",ready:!1,options:{appendTo:"parent",axis:!1,connectWith:!1,containment:!1,cursor:"auto",cursorAt:!1,dropOnEmpty:!0,forcePlaceholderSize:!1,forceHelperSize:!1,grid:!1,handle:!1,helper:"original",items:"> *",opacity:!1,placeholder:!1,revert:!1,scroll:!0,scrollSensitivity:20,scrollSpeed:20,scope:"default",tolerance:"intersect",zIndex:1e3},_create:function(){var e=this.options;this.containerCache={},this.element.addClass("ui-sortable"),this.refresh(),this.floating=this.items.length?e.axis==="x"||/left|right/.test(this.items[0].item.css("float"))||/inline|table-cell/.test(this.items[0].item.css("display")):!1,this.offset=this.element.offset(),this._mouseInit(),this.ready=!0},_destroy:function(){this.element.removeClass("ui-sortable ui-sortable-disabled"),this._mouseDestroy();for(var e=this.items.length-1;e>=0;e--)this.items[e].item.removeData(this.widgetName+"-item");return this},_setOption:function(t,n){t==="disabled"?(this.options[t]=n,this.widget().toggleClass("ui-sortable-disabled",!!n)):e.Widget.prototype._setOption.apply(this,arguments)},_mouseCapture:function(t,n){var r=this;if(this.reverting)return!1;if(this.options.disabled||this.options.type=="static")return!1;this._refreshItems(t);var i=null,s=e(t.target).parents().each(function(){if(e.data(this,r.widgetName+"-item")==r)return i=e(this),!1});e.data(t.target,r.widgetName+"-item")==r&&(i=e(t.target));if(!i)return!1;if(this.options.handle&&!n){var o=!1;e(this.options.handle,i).find("*").andSelf().each(function(){this==t.target&&(o=!0)});if(!o)return!1}return this.currentItem=i,this._removeCurrentsFromItems(),!0},_mouseStart:function(t,n,r){var i=this.options;this.currentContainer=this,this.refreshPositions(),this.helper=this._createHelper(t),this._cacheHelperProportions(),this._cacheMargins(),this.scrollParent=this.helper.scrollParent(),this.offset=this.currentItem.offset(),this.offset={top:this.offset.top-this.margins.top,left:this.offset.left-this.margins.left},e.extend(this.offset,{click:{left:t.pageX-this.offset.left,top:t.pageY-this.offset.top},parent:this._getParentOffset(),relative:this._getRelativeOffset()}),this.helper.css("position","absolute"),this.cssPosition=this.helper.css("position"),this.originalPosition=this._generatePosition(t),this.originalPageX=t.pageX,this.originalPageY=t.pageY,i.cursorAt&&this._adjustOffsetFromHelper(i.cursorAt),this.domPosition={prev:this.currentItem.prev()[0],parent:this.currentItem.parent()[0]},this.helper[0]!=this.currentItem[0]&&this.currentItem.hide(),this._createPlaceholder(),i.containment&&this._setContainment(),i.cursor&&(e("body").css("cursor")&&(this._storedCursor=e("body").css("cursor")),e("body").css("cursor",i.cursor)),i.opacity&&(this.helper.css("opacity")&&(this._storedOpacity=this.helper.css("opacity")),this.helper.css("opacity",i.opacity)),i.zIndex&&(this.helper.css("zIndex")&&(this._storedZIndex=this.helper.css("zIndex")),this.helper.css("zIndex",i.zIndex)),this.scrollParent[0]!=document&&this.scrollParent[0].tagName!="HTML"&&(this.overflowOffset=this.scrollParent.offset()),this._trigger("start",t,this._uiHash()),this._preserveHelperProportions||this._cacheHelperProportions();if(!r)for(var s=this.containers.length-1;s>=0;s--)this.containers[s]._trigger("activate",t,this._uiHash(this));return e.ui.ddmanager&&(e.ui.ddmanager.current=this),e.ui.ddmanager&&!i.dropBehaviour&&e.ui.ddmanager.prepareOffsets(this,t),this.dragging=!0,this.helper.addClass("ui-sortable-helper"),this._mouseDrag(t),!0},_mouseDrag:function(t){this.position=this._generatePosition(t),this.positionAbs=this._convertPositionTo("absolute"),this.lastPositionAbs||(this.lastPositionAbs=this.positionAbs);if(this.options.scroll){var n=this.options,r=!1;this.scrollParent[0]!=document&&this.scrollParent[0].tagName!="HTML"?(this.overflowOffset.top+this.scrollParent[0].offsetHeight-t.pageY<n.scrollSensitivity?this.scrollParent[0].scrollTop=r=this.scrollParent[0].scrollTop+n.scrollSpeed:t.pageY-this.overflowOffset.top<n.scrollSensitivity&&(this.scrollParent[0].scrollTop=r=this.scrollParent[0].scrollTop-n.scrollSpeed),this.overflowOffset.left+this.scrollParent[0].offsetWidth-t.pageX<n.scrollSensitivity?this.scrollParent[0].scrollLeft=r=this.scrollParent[0].scrollLeft+n.scrollSpeed:t.pageX-this.overflowOffset.left<n.scrollSensitivity&&(this.scrollParent[0].scrollLeft=r=this.scrollParent[0].scrollLeft-n.scrollSpeed)):(t.pageY-e(document).scrollTop()<n.scrollSensitivity?r=e(document).scrollTop(e(document).scrollTop()-n.scrollSpeed):e(window).height()-(t.pageY-e(document).scrollTop())<n.scrollSensitivity&&(r=e(document).scrollTop(e(document).scrollTop()+n.scrollSpeed)),t.pageX-e(document).scrollLeft()<n.scrollSensitivity?r=e(document).scrollLeft(e(document).scrollLeft()-n.scrollSpeed):e(window).width()-(t.pageX-e(document).scrollLeft())<n.scrollSensitivity&&(r=e(document).scrollLeft(e(document).scrollLeft()+n.scrollSpeed))),r!==!1&&e.ui.ddmanager&&!n.dropBehaviour&&e.ui.ddmanager.prepareOffsets(this,t)}this.positionAbs=this._convertPositionTo("absolute");if(!this.options.axis||this.options.axis!="y")this.helper[0].style.left=this.position.left+"px";if(!this.options.axis||this.options.axis!="x")this.helper[0].style.top=this.position.top+"px";for(var i=this.items.length-1;i>=0;i--){var s=this.items[i],o=s.item[0],u=this._intersectsWithPointer(s);if(!u)continue;if(s.instance!==this.currentContainer)continue;if(o!=this.currentItem[0]&&this.placeholder[u==1?"next":"prev"]()[0]!=o&&!e.contains(this.placeholder[0],o)&&(this.options.type=="semi-dynamic"?!e.contains(this.element[0],o):!0)){this.direction=u==1?"down":"up";if(this.options.tolerance!="pointer"&&!this._intersectsWithSides(s))break;this._rearrange(t,s),this._trigger("change",t,this._uiHash());break}}return this._contactContainers(t),e.ui.ddmanager&&e.ui.ddmanager.drag(this,t),this._trigger("sort",t,this._uiHash()),this.lastPositionAbs=this.positionAbs,!1},_mouseStop:function(t,n){if(!t)return;e.ui.ddmanager&&!this.options.dropBehaviour&&e.ui.ddmanager.drop(this,t);if(this.options.revert){var r=this,i=this.placeholder.offset();this.reverting=!0,e(this.helper).animate({left:i.left-this.offset.parent.left-this.margins.left+(this.offsetParent[0]==document.body?0:this.offsetParent[0].scrollLeft),top:i.top-this.offset.parent.top-this.margins.top+(this.offsetParent[0]==document.body?0:this.offsetParent[0].scrollTop)},parseInt(this.options.revert,10)||500,function(){r._clear(t)})}else this._clear(t,n);return!1},cancel:function(){if(this.dragging){this._mouseUp({target:null}),this.options.helper=="original"?this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper"):this.currentItem.show();for(var t=this.containers.length-1;t>=0;t--)this.containers[t]._trigger("deactivate",null,this._uiHash(this)),this.containers[t].containerCache.over&&(this.containers[t]._trigger("out",null,this._uiHash(this)),this.containers[t].containerCache.over=0)}return this.placeholder&&(this.placeholder[0].parentNode&&this.placeholder[0].parentNode.removeChild(this.placeholder[0]),this.options.helper!="original"&&this.helper&&this.helper[0].parentNode&&this.helper.remove(),e.extend(this,{helper:null,dragging:!1,reverting:!1,_noFinalSort:null}),this.domPosition.prev?e(this.domPosition.prev).after(this.currentItem):e(this.domPosition.parent).prepend(this.currentItem)),this},serialize:function(t){var n=this._getItemsAsjQuery(t&&t.connected),r=[];return t=t||{},e(n).each(function(){var n=(e(t.item||this).attr(t.attribute||"id")||"").match(t.expression||/(.+)[-=_](.+)/);n&&r.push((t.key||n[1]+"[]")+"="+(t.key&&t.expression?n[1]:n[2]))}),!r.length&&t.key&&r.push(t.key+"="),r.join("&")},toArray:function(t){var n=this._getItemsAsjQuery(t&&t.connected),r=[];return t=t||{},n.each(function(){r.push(e(t.item||this).attr(t.attribute||"id")||"")}),r},_intersectsWith:function(e){var t=this.positionAbs.left,n=t+this.helperProportions.width,r=this.positionAbs.top,i=r+this.helperProportions.height,s=e.left,o=s+e.width,u=e.top,a=u+e.height,f=this.offset.click.top,l=this.offset.click.left,c=r+f>u&&r+f<a&&t+l>s&&t+l<o;return this.options.tolerance=="pointer"||this.options.forcePointerForContainers||this.options.tolerance!="pointer"&&this.helperProportions[this.floating?"width":"height"]>e[this.floating?"width":"height"]?c:s<t+this.helperProportions.width/2&&n-this.helperProportions.width/2<o&&u<r+this.helperProportions.height/2&&i-this.helperProportions.height/2<a},_intersectsWithPointer:function(t){var n=this.options.axis==="x"||e.ui.isOverAxis(this.positionAbs.top+this.offset.click.top,t.top,t.height),r=this.options.axis==="y"||e.ui.isOverAxis(this.positionAbs.left+this.offset.click.left,t.left,t.width),i=n&&r,s=this._getDragVerticalDirection(),o=this._getDragHorizontalDirection();return i?this.floating?o&&o=="right"||s=="down"?2:1:s&&(s=="down"?2:1):!1},_intersectsWithSides:function(t){var n=e.ui.isOverAxis(this.positionAbs.top+this.offset.click.top,t.top+t.height/2,t.height),r=e.ui.isOverAxis(this.positionAbs.left+this.offset.click.left,t.left+t.width/2,t.width),i=this._getDragVerticalDirection(),s=this._getDragHorizontalDirection();return this.floating&&s?s=="right"&&r||s=="left"&&!r:i&&(i=="down"&&n||i=="up"&&!n)},_getDragVerticalDirection:function(){var e=this.positionAbs.top-this.lastPositionAbs.top;return e!=0&&(e>0?"down":"up")},_getDragHorizontalDirection:function(){var e=this.positionAbs.left-this.lastPositionAbs.left;return e!=0&&(e>0?"right":"left")},refresh:function(e){return this._refreshItems(e),this.refreshPositions(),this},_connectWith:function(){var e=this.options;return e.connectWith.constructor==String?[e.connectWith]:e.connectWith},_getItemsAsjQuery:function(t){var n=[],r=[],i=this._connectWith();if(i&&t)for(var s=i.length-1;s>=0;s--){var o=e(i[s]);for(var u=o.length-1;u>=0;u--){var a=e.data(o[u],this.widgetName);a&&a!=this&&!a.options.disabled&&r.push([e.isFunction(a.options.items)?a.options.items.call(a.element):e(a.options.items,a.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"),a])}}r.push([e.isFunction(this.options.items)?this.options.items.call(this.element,null,{options:this.options,item:this.currentItem}):e(this.options.items,this.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"),this]);for(var s=r.length-1;s>=0;s--)r[s][0].each(function(){n.push(this)});return e(n)},_removeCurrentsFromItems:function(){var t=this.currentItem.find(":data("+this.widgetName+"-item)");this.items=e.grep(this.items,function(e){for(var n=0;n<t.length;n++)if(t[n]==e.item[0])return!1;return!0})},_refreshItems:function(t){this.items=[],this.containers=[this];var n=this.items,r=[[e.isFunction(this.options.items)?this.options.items.call(this.element[0],t,{item:this.currentItem}):e(this.options.items,this.element),this]],i=this._connectWith();if(i&&this.ready)for(var s=i.length-1;s>=0;s--){var o=e(i[s]);for(var u=o.length-1;u>=0;u--){var a=e.data(o[u],this.widgetName);a&&a!=this&&!a.options.disabled&&(r.push([e.isFunction(a.options.items)?a.options.items.call(a.element[0],t,{item:this.currentItem}):e(a.options.items,a.element),a]),this.containers.push(a))}}for(var s=r.length-1;s>=0;s--){var f=r[s][1],l=r[s][0];for(var u=0,c=l.length;u<c;u++){var h=e(l[u]);h.data(this.widgetName+"-item",f),n.push({item:h,instance:f,width:0,height:0,left:0,top:0})}}},refreshPositions:function(t){this.offsetParent&&this.helper&&(this.offset.parent=this._getParentOffset());for(var n=this.items.length-1;n>=0;n--){var r=this.items[n];if(r.instance!=this.currentContainer&&this.currentContainer&&r.item[0]!=this.currentItem[0])continue;var i=this.options.toleranceElement?e(this.options.toleranceElement,r.item):r.item;t||(r.width=i.outerWidth(),r.height=i.outerHeight());var s=i.offset();r.left=s.left,r.top=s.top}if(this.options.custom&&this.options.custom.refreshContainers)this.options.custom.refreshContainers.call(this);else for(var n=this.containers.length-1;n>=0;n--){var s=this.containers[n].element.offset();this.containers[n].containerCache.left=s.left,this.containers[n].containerCache.top=s.top,this.containers[n].containerCache.width=this.containers[n].element.outerWidth(),this.containers[n].containerCache.height=this.containers[n].element.outerHeight()}return this},_createPlaceholder:function(t){t=t||this;var n=t.options;if(!n.placeholder||n.placeholder.constructor==String){var r=n.placeholder;n.placeholder={element:function(){var n=e(document.createElement(t.currentItem[0].nodeName)).addClass(r||t.currentItem[0].className+" ui-sortable-placeholder").removeClass("ui-sortable-helper")[0];return r||(n.style.visibility="hidden"),n},update:function(e,i){if(r&&!n.forcePlaceholderSize)return;i.height()||i.height(t.currentItem.innerHeight()-parseInt(t.currentItem.css("paddingTop")||0,10)-parseInt(t.currentItem.css("paddingBottom")||0,10)),i.width()||i.width(t.currentItem.innerWidth()-parseInt(t.currentItem.css("paddingLeft")||0,10)-parseInt(t.currentItem.css("paddingRight")||0,10))}}}t.placeholder=e(n.placeholder.element.call(t.element,t.currentItem)),t.currentItem.after(t.placeholder),n.placeholder.update(t,t.placeholder)},_contactContainers:function(t){var n=null,r=null;for(var i=this.containers.length-1;i>=0;i--){if(e.contains(this.currentItem[0],this.containers[i].element[0]))continue;if(this._intersectsWith(this.containers[i].containerCache)){if(n&&e.contains(this.containers[i].element[0],n.element[0]))continue;n=this.containers[i],r=i}else this.containers[i].containerCache.over&&(this.containers[i]._trigger("out",t,this._uiHash(this)),this.containers[i].containerCache.over=0)}if(!n)return;if(this.containers.length===1)this.containers[r]._trigger("over",t,this._uiHash(this)),this.containers[r].containerCache.over=1;else{var s=1e4,o=null,u=this.containers[r].floating?"left":"top",a=this.containers[r].floating?"width":"height",f=this.positionAbs[u]+this.offset.click[u];for(var l=this.items.length-1;l>=0;l--){if(!e.contains(this.containers[r].element[0],this.items[l].item[0]))continue;if(this.items[l].item[0]==this.currentItem[0])continue;var c=this.items[l].item.offset()[u],h=!1;Math.abs(c-f)>Math.abs(c+this.items[l][a]-f)&&(h=!0,c+=this.items[l][a]),Math.abs(c-f)<s&&(s=Math.abs(c-f),o=this.items[l],this.direction=h?"up":"down")}if(!o&&!this.options.dropOnEmpty)return;this.currentContainer=this.containers[r],o?this._rearrange(t,o,null,!0):this._rearrange(t,null,this.containers[r].element,!0),this._trigger("change",t,this._uiHash()),this.containers[r]._trigger("change",t,this._uiHash(this)),this.options.placeholder.update(this.currentContainer,this.placeholder),this.containers[r]._trigger("over",t,this._uiHash(this)),this.containers[r].containerCache.over=1}},_createHelper:function(t){var n=this.options,r=e.isFunction(n.helper)?e(n.helper.apply(this.element[0],[t,this.currentItem])):n.helper=="clone"?this.currentItem.clone():this.currentItem;return r.parents("body").length||e(n.appendTo!="parent"?n.appendTo:this.currentItem[0].parentNode)[0].appendChild(r[0]),r[0]==this.currentItem[0]&&(this._storedCSS={width:this.currentItem[0].style.width,height:this.currentItem[0].style.height,position:this.currentItem.css("position"),top:this.currentItem.css("top"),left:this.currentItem.css("left")}),(r[0].style.width==""||n.forceHelperSize)&&r.width(this.currentItem.width()),(r[0].style.height==""||n.forceHelperSize)&&r.height(this.currentItem.height()),r},_adjustOffsetFromHelper:function(t){typeof t=="string"&&(t=t.split(" ")),e.isArray(t)&&(t={left:+t[0],top:+t[1]||0}),"left"in t&&(this.offset.click.left=t.left+this.margins.left),"right"in t&&(this.offset.click.left=this.helperProportions.width-t.right+this.margins.left),"top"in t&&(this.offset.click.top=t.top+this.margins.top),"bottom"in t&&(this.offset.click.top=this.helperProportions.height-t.bottom+this.margins.top)},_getParentOffset:function(){this.offsetParent=this.helper.offsetParent();var t=this.offsetParent.offset();this.cssPosition=="absolute"&&this.scrollParent[0]!=document&&e.contains(this.scrollParent[0],this.offsetParent[0])&&(t.left+=this.scrollParent.scrollLeft(),t.top+=this.scrollParent.scrollTop());if(this.offsetParent[0]==document.body||this.offsetParent[0].tagName&&this.offsetParent[0].tagName.toLowerCase()=="html"&&e.ui.ie)t={top:0,left:0};return{top:t.top+(parseInt(this.offsetParent.css("borderTopWidth"),10)||0),left:t.left+(parseInt(this.offsetParent.css("borderLeftWidth"),10)||0)}},_getRelativeOffset:function(){if(this.cssPosition=="relative"){var e=this.currentItem.position();return{top:e.top-(parseInt(this.helper.css("top"),10)||0)+this.scrollParent.scrollTop(),left:e.left-(parseInt(this.helper.css("left"),10)||0)+this.scrollParent.scrollLeft()}}return{top:0,left:0}},_cacheMargins:function(){this.margins={left:parseInt(this.currentItem.css("marginLeft"),10)||0,top:parseInt(this.currentItem.css("marginTop"),10)||0}},_cacheHelperProportions:function(){this.helperProportions={width:this.helper.outerWidth(),height:this.helper.outerHeight()}},_setContainment:function(){var t=this.options;t.containment=="parent"&&(t.containment=this.helper[0].parentNode);if(t.containment=="document"||t.containment=="window")this.containment=[0-this.offset.relative.left-this.offset.parent.left,0-this.offset.relative.top-this.offset.parent.top,e(t.containment=="document"?document:window).width()-this.helperProportions.width-this.margins.left,(e(t.containment=="document"?document:window).height()||document.body.parentNode.scrollHeight)-this.helperProportions.height-this.margins.top];if(!/^(document|window|parent)$/.test(t.containment)){var n=e(t.containment)[0],r=e(t.containment).offset(),i=e(n).css("overflow")!="hidden";this.containment=[r.left+(parseInt(e(n).css("borderLeftWidth"),10)||0)+(parseInt(e(n).css("paddingLeft"),10)||0)-this.margins.left,r.top+(parseInt(e(n).css("borderTopWidth"),10)||0)+(parseInt(e(n).css("paddingTop"),10)||0)-this.margins.top,r.left+(i?Math.max(n.scrollWidth,n.offsetWidth):n.offsetWidth)-(parseInt(e(n).css("borderLeftWidth"),10)||0)-(parseInt(e(n).css("paddingRight"),10)||0)-this.helperProportions.width-this.margins.left,r.top+(i?Math.max(n.scrollHeight,n.offsetHeight):n.offsetHeight)-(parseInt(e(n).css("borderTopWidth"),10)||0)-(parseInt(e(n).css("paddingBottom"),10)||0)-this.helperProportions.height-this.margins.top]}},_convertPositionTo:function(t,n){n||(n=this.position);var r=t=="absolute"?1:-1,i=this.options,s=this.cssPosition!="absolute"||this.scrollParent[0]!=document&&!!e.contains(this.scrollParent[0],this.offsetParent[0])?this.scrollParent:this.offsetParent,o=/(html|body)/i.test(s[0].tagName);return{top:n.top+this.offset.relative.top*r+this.offset.parent.top*r-(this.cssPosition=="fixed"?-this.scrollParent.scrollTop():o?0:s.scrollTop())*r,left:n.left+this.offset.relative.left*r+this.offset.parent.left*r-(this.cssPosition=="fixed"?-this.scrollParent.scrollLeft():o?0:s.scrollLeft())*r}},_generatePosition:function(t){var n=this.options,r=this.cssPosition!="absolute"||this.scrollParent[0]!=document&&!!e.contains(this.scrollParent[0],this.offsetParent[0])?this.scrollParent:this.offsetParent,i=/(html|body)/i.test(r[0].tagName);this.cssPosition=="relative"&&(this.scrollParent[0]==document||this.scrollParent[0]==this.offsetParent[0])&&(this.offset.relative=this._getRelativeOffset());var s=t.pageX,o=t.pageY;if(this.originalPosition){this.containment&&(t.pageX-this.offset.click.left<this.containment[0]&&(s=this.containment[0]+this.offset.click.left),t.pageY-this.offset.click.top<this.containment[1]&&(o=this.containment[1]+this.offset.click.top),t.pageX-this.offset.click.left>this.containment[2]&&(s=this.containment[2]+this.offset.click.left),t.pageY-this.offset.click.top>this.containment[3]&&(o=this.containment[3]+this.offset.click.top));if(n.grid){var u=this.originalPageY+Math.round((o-this.originalPageY)/n.grid[1])*n.grid[1];o=this.containment?u-this.offset.click.top<this.containment[1]||u-this.offset.click.top>this.containment[3]?u-this.offset.click.top<this.containment[1]?u+n.grid[1]:u-n.grid[1]:u:u;var a=this.originalPageX+Math.round((s-this.originalPageX)/n.grid[0])*n.grid[0];s=this.containment?a-this.offset.click.left<this.containment[0]||a-this.offset.click.left>this.containment[2]?a-this.offset.click.left<this.containment[0]?a+n.grid[0]:a-n.grid[0]:a:a}}return{top:o-this.offset.click.top-this.offset.relative.top-this.offset.parent.top+(this.cssPosition=="fixed"?-this.scrollParent.scrollTop():i?0:r.scrollTop()),left:s-this.offset.click.left-this.offset.relative.left-this.offset.parent.left+(this.cssPosition=="fixed"?-this.scrollParent.scrollLeft():i?0:r.scrollLeft())}},_rearrange:function(e,t,n,r){n?n[0].appendChild(this.placeholder[0]):t.item[0].parentNode.insertBefore(this.placeholder[0],this.direction=="down"?t.item[0]:t.item[0].nextSibling),this.counter=this.counter?++this.counter:1;var i=this.counter;this._delay(function(){i==this.counter&&this.refreshPositions(!r)})},_clear:function(t,n){this.reverting=!1;var r=[];!this._noFinalSort&&this.currentItem.parent().length&&this.placeholder.before(this.currentItem),this._noFinalSort=null;if(this.helper[0]==this.currentItem[0]){for(var i in this._storedCSS)if(this._storedCSS[i]=="auto"||this._storedCSS[i]=="static")this._storedCSS[i]="";this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper")}else this.currentItem.show();this.fromOutside&&!n&&r.push(function(e){this._trigger("receive",e,this._uiHash(this.fromOutside))}),(this.fromOutside||this.domPosition.prev!=this.currentItem.prev().not(".ui-sortable-helper")[0]||this.domPosition.parent!=this.currentItem.parent()[0])&&!n&&r.push(function(e){this._trigger("update",e,this._uiHash())}),this!==this.currentContainer&&(n||(r.push(function(e){this._trigger("remove",e,this._uiHash())}),r.push(function(e){return function(t){e._trigger("receive",t,this._uiHash(this))}}.call(this,this.currentContainer)),r.push(function(e){return function(t){e._trigger("update",t,this._uiHash(this))}}.call(this,this.currentContainer))));for(var i=this.containers.length-1;i>=0;i--)n||r.push(function(e){return function(t){e._trigger("deactivate",t,this._uiHash(this))}}.call(this,this.containers[i])),this.containers[i].containerCache.over&&(r.push(function(e){return function(t){e._trigger("out",t,this._uiHash(this))}}.call(this,this.containers[i])),this.containers[i].containerCache.over=0);this._storedCursor&&e("body").css("cursor",this._storedCursor),this._storedOpacity&&this.helper.css("opacity",this._storedOpacity),this._storedZIndex&&this.helper.css("zIndex",this._storedZIndex=="auto"?"":this._storedZIndex),this.dragging=!1;if(this.cancelHelperRemoval){if(!n){this._trigger("beforeStop",t,this._uiHash());for(var i=0;i<r.length;i++)r[i].call(this,t);this._trigger("stop",t,this._uiHash())}return this.fromOutside=!1,!1}n||this._trigger("beforeStop",t,this._uiHash()),this.placeholder[0].parentNode.removeChild(this.placeholder[0]),this.helper[0]!=this.currentItem[0]&&this.helper.remove(),this.helper=null;if(!n){for(var i=0;i<r.length;i++)r[i].call(this,t);this._trigger("stop",t,this._uiHash())}return this.fromOutside=!1,!0},_trigger:function(){e.Widget.prototype._trigger.apply(this,arguments)===!1&&this.cancel()},_uiHash:function(t){var n=t||this;return{helper:n.helper,placeholder:n.placeholder||e([]),position:n.position,originalPosition:n.originalPosition,offset:n.positionAbs,item:n.currentItem,sender:t?t.element:null}}})})(jQuery);(function(e){function t(e){return function(){var t=this.element.val();e.apply(this,arguments),this._refresh(),t!==this.element.val()&&this._trigger("change")}}e.widget("ui.spinner",{version:"1.9.2",defaultElement:"<input>",widgetEventPrefix:"spin",options:{culture:null,icons:{down:"ui-icon-triangle-1-s",up:"ui-icon-triangle-1-n"},incremental:!0,max:null,min:null,numberFormat:null,page:10,step:1,change:null,spin:null,start:null,stop:null},_create:function(){this._setOption("max",this.options.max),this._setOption("min",this.options.min),this._setOption("step",this.options.step),this._value(this.element.val(),!0),this._draw(),this._on(this._events),this._refresh(),this._on(this.window,{beforeunload:function(){this.element.removeAttr("autocomplete")}})},_getCreateOptions:function(){var t={},n=this.element;return e.each(["min","max","step"],function(e,r){var i=n.attr(r);i!==undefined&&i.length&&(t[r]=i)}),t},_events:{keydown:function(e){this._start(e)&&this._keydown(e)&&e.preventDefault()},keyup:"_stop",focus:function(){this.previous=this.element.val()},blur:function(e){if(this.cancelBlur){delete this.cancelBlur;return}this._refresh(),this.previous!==this.element.val()&&this._trigger("change",e)},mousewheel:function(e,t){if(!t)return;if(!this.spinning&&!this._start(e))return!1;this._spin((t>0?1:-1)*this.options.step,e),clearTimeout(this.mousewheelTimer),this.mousewheelTimer=this._delay(function(){this.spinning&&this._stop(e)},100),e.preventDefault()},"mousedown .ui-spinner-button":function(t){function r(){var e=this.element[0]===this.document[0].activeElement;e||(this.element.focus(),this.previous=n,this._delay(function(){this.previous=n}))}var n;n=this.element[0]===this.document[0].activeElement?this.previous:this.element.val(),t.preventDefault(),r.call(this),this.cancelBlur=!0,this._delay(function(){delete this.cancelBlur,r.call(this)});if(this._start(t)===!1)return;this._repeat(null,e(t.currentTarget).hasClass("ui-spinner-up")?1:-1,t)},"mouseup .ui-spinner-button":"_stop","mouseenter .ui-spinner-button":function(t){if(!e(t.currentTarget).hasClass("ui-state-active"))return;if(this._start(t)===!1)return!1;this._repeat(null,e(t.currentTarget).hasClass("ui-spinner-up")?1:-1,t)},"mouseleave .ui-spinner-button":"_stop"},_draw:function(){var e=this.uiSpinner=this.element.addClass("ui-spinner-input").attr("autocomplete","off").wrap(this._uiSpinnerHtml()).parent().append(this._buttonHtml());this.element.attr("role","spinbutton"),this.buttons=e.find(".ui-spinner-button").attr("tabIndex",-1).button().removeClass("ui-corner-all"),this.buttons.height()>Math.ceil(e.height()*.5)&&e.height()>0&&e.height(e.height()),this.options.disabled&&this.disable()},_keydown:function(t){var n=this.options,r=e.ui.keyCode;switch(t.keyCode){case r.UP:return this._repeat(null,1,t),!0;case r.DOWN:return this._repeat(null,-1,t),!0;case r.PAGE_UP:return this._repeat(null,n.page,t),!0;case r.PAGE_DOWN:return this._repeat(null,-n.page,t),!0}return!1},_uiSpinnerHtml:function(){return"<span class='ui-spinner ui-widget ui-widget-content ui-corner-all'></span>"},_buttonHtml:function(){return"<a class='ui-spinner-button ui-spinner-up ui-corner-tr'><span class='ui-icon "+this.options.icons.up+"'>&#9650;</span>"+"</a>"+"<a class='ui-spinner-button ui-spinner-down ui-corner-br'>"+"<span class='ui-icon "+this.options.icons.down+"'>&#9660;</span>"+"</a>"},_start:function(e){return!this.spinning&&this._trigger("start",e)===!1?!1:(this.counter||(this.counter=1),this.spinning=!0,!0)},_repeat:function(e,t,n){e=e||500,clearTimeout(this.timer),this.timer=this._delay(function(){this._repeat(40,t,n)},e),this._spin(t*this.options.step,n)},_spin:function(e,t){var n=this.value()||0;this.counter||(this.counter=1),n=this._adjustValue(n+e*this._increment(this.counter));if(!this.spinning||this._trigger("spin",t,{value:n})!==!1)this._value(n),this.counter++},_increment:function(t){var n=this.options.incremental;return n?e.isFunction(n)?n(t):Math.floor(t*t*t/5e4-t*t/500+17*t/200+1):1},_precision:function(){var e=this._precisionOf(this.options.step);return this.options.min!==null&&(e=Math.max(e,this._precisionOf(this.options.min))),e},_precisionOf:function(e){var t=e.toString(),n=t.indexOf(".");return n===-1?0:t.length-n-1},_adjustValue:function(e){var t,n,r=this.options;return t=r.min!==null?r.min:0,n=e-t,n=Math.round(n/r.step)*r.step,e=t+n,e=parseFloat(e.toFixed(this._precision())),r.max!==null&&e>r.max?r.max:r.min!==null&&e<r.min?r.min:e},_stop:function(e){if(!this.spinning)return;clearTimeout(this.timer),clearTimeout(this.mousewheelTimer),this.counter=0,this.spinning=!1,this._trigger("stop",e)},_setOption:function(e,t){if(e==="culture"||e==="numberFormat"){var n=this._parse(this.element.val());this.options[e]=t,this.element.val(this._format(n));return}(e==="max"||e==="min"||e==="step")&&typeof t=="string"&&(t=this._parse(t)),this._super(e,t),e==="disabled"&&(t?(this.element.prop("disabled",!0),this.buttons.button("disable")):(this.element.prop("disabled",!1),this.buttons.button("enable")))},_setOptions:t(function(e){this._super(e),this._value(this.element.val())}),_parse:function(e){return typeof e=="string"&&e!==""&&(e=window.Globalize&&this.options.numberFormat?Globalize.parseFloat(e,10,this.options.culture):+e),e===""||isNaN(e)?null:e},_format:function(e){return e===""?"":window.Globalize&&this.options.numberFormat?Globalize.format(e,this.options.numberFormat,this.options.culture):e},_refresh:function(){this.element.attr({"aria-valuemin":this.options.min,"aria-valuemax":this.options.max,"aria-valuenow":this._parse(this.element.val())})},_value:function(e,t){var n;e!==""&&(n=this._parse(e),n!==null&&(t||(n=this._adjustValue(n)),e=this._format(n))),this.element.val(e),this._refresh()},_destroy:function(){this.element.removeClass("ui-spinner-input").prop("disabled",!1).removeAttr("autocomplete").removeAttr("role").removeAttr("aria-valuemin").removeAttr("aria-valuemax").removeAttr("aria-valuenow"),this.uiSpinner.replaceWith(this.element)},stepUp:t(function(e){this._stepUp(e)}),_stepUp:function(e){this._spin((e||1)*this.options.step)},stepDown:t(function(e){this._stepDown(e)}),_stepDown:function(e){this._spin((e||1)*-this.options.step)},pageUp:t(function(e){this._stepUp((e||1)*this.options.page)}),pageDown:t(function(e){this._stepDown((e||1)*this.options.page)}),value:function(e){if(!arguments.length)return this._parse(this.element.val());t(this._value).call(this,e)},widget:function(){return this.uiSpinner}})})(jQuery);(function(e,t){function i(){return++n}function s(e){return e.hash.length>1&&e.href.replace(r,"")===location.href.replace(r,"").replace(/\s/g,"%20")}var n=0,r=/#.*$/;e.widget("ui.tabs",{version:"1.9.2",delay:300,options:{active:null,collapsible:!1,event:"click",heightStyle:"content",hide:null,show:null,activate:null,beforeActivate:null,beforeLoad:null,load:null},_create:function(){var t=this,n=this.options,r=n.active,i=location.hash.substring(1);this.running=!1,this.element.addClass("ui-tabs ui-widget ui-widget-content ui-corner-all").toggleClass("ui-tabs-collapsible",n.collapsible).delegate(".ui-tabs-nav > li","mousedown"+this.eventNamespace,function(t){e(this).is(".ui-state-disabled")&&t.preventDefault()}).delegate(".ui-tabs-anchor","focus"+this.eventNamespace,function(){e(this).closest("li").is(".ui-state-disabled")&&this.blur()}),this._processTabs();if(r===null){i&&this.tabs.each(function(t,n){if(e(n).attr("aria-controls")===i)return r=t,!1}),r===null&&(r=this.tabs.index(this.tabs.filter(".ui-tabs-active")));if(r===null||r===-1)r=this.tabs.length?0:!1}r!==!1&&(r=this.tabs.index(this.tabs.eq(r)),r===-1&&(r=n.collapsible?!1:0)),n.active=r,!n.collapsible&&n.active===!1&&this.anchors.length&&(n.active=0),e.isArray(n.disabled)&&(n.disabled=e.unique(n.disabled.concat(e.map(this.tabs.filter(".ui-state-disabled"),function(e){return t.tabs.index(e)}))).sort()),this.options.active!==!1&&this.anchors.length?this.active=this._findActive(this.options.active):this.active=e(),this._refresh(),this.active.length&&this.load(n.active)},_getCreateEventData:function(){return{tab:this.active,panel:this.active.length?this._getPanelForTab(this.active):e()}},_tabKeydown:function(t){var n=e(this.document[0].activeElement).closest("li"),r=this.tabs.index(n),i=!0;if(this._handlePageNav(t))return;switch(t.keyCode){case e.ui.keyCode.RIGHT:case e.ui.keyCode.DOWN:r++;break;case e.ui.keyCode.UP:case e.ui.keyCode.LEFT:i=!1,r--;break;case e.ui.keyCode.END:r=this.anchors.length-1;break;case e.ui.keyCode.HOME:r=0;break;case e.ui.keyCode.SPACE:t.preventDefault(),clearTimeout(this.activating),this._activate(r);return;case e.ui.keyCode.ENTER:t.preventDefault(),clearTimeout(this.activating),this._activate(r===this.options.active?!1:r);return;default:return}t.preventDefault(),clearTimeout(this.activating),r=this._focusNextTab(r,i),t.ctrlKey||(n.attr("aria-selected","false"),this.tabs.eq(r).attr("aria-selected","true"),this.activating=this._delay(function(){this.option("active",r)},this.delay))},_panelKeydown:function(t){if(this._handlePageNav(t))return;t.ctrlKey&&t.keyCode===e.ui.keyCode.UP&&(t.preventDefault(),this.active.focus())},_handlePageNav:function(t){if(t.altKey&&t.keyCode===e.ui.keyCode.PAGE_UP)return this._activate(this._focusNextTab(this.options.active-1,!1)),!0;if(t.altKey&&t.keyCode===e.ui.keyCode.PAGE_DOWN)return this._activate(this._focusNextTab(this.options.active+1,!0)),!0},_findNextTab:function(t,n){function i(){return t>r&&(t=0),t<0&&(t=r),t}var r=this.tabs.length-1;while(e.inArray(i(),this.options.disabled)!==-1)t=n?t+1:t-1;return t},_focusNextTab:function(e,t){return e=this._findNextTab(e,t),this.tabs.eq(e).focus(),e},_setOption:function(e,t){if(e==="active"){this._activate(t);return}if(e==="disabled"){this._setupDisabled(t);return}this._super(e,t),e==="collapsible"&&(this.element.toggleClass("ui-tabs-collapsible",t),!t&&this.options.active===!1&&this._activate(0)),e==="event"&&this._setupEvents(t),e==="heightStyle"&&this._setupHeightStyle(t)},_tabId:function(e){return e.attr("aria-controls")||"ui-tabs-"+i()},_sanitizeSelector:function(e){return e?e.replace(/[!"$%&'()*+,.\/:;<=>?@\[\]\^`{|}~]/g,"\\$&"):""},refresh:function(){var t=this.options,n=this.tablist.children(":has(a[href])");t.disabled=e.map(n.filter(".ui-state-disabled"),function(e){return n.index(e)}),this._processTabs(),t.active===!1||!this.anchors.length?(t.active=!1,this.active=e()):this.active.length&&!e.contains(this.tablist[0],this.active[0])?this.tabs.length===t.disabled.length?(t.active=!1,this.active=e()):this._activate(this._findNextTab(Math.max(0,t.active-1),!1)):t.active=this.tabs.index(this.active),this._refresh()},_refresh:function(){this._setupDisabled(this.options.disabled),this._setupEvents(this.options.event),this._setupHeightStyle(this.options.heightStyle),this.tabs.not(this.active).attr({"aria-selected":"false",tabIndex:-1}),this.panels.not(this._getPanelForTab(this.active)).hide().attr({"aria-expanded":"false","aria-hidden":"true"}),this.active.length?(this.active.addClass("ui-tabs-active ui-state-active").attr({"aria-selected":"true",tabIndex:0}),this._getPanelForTab(this.active).show().attr({"aria-expanded":"true","aria-hidden":"false"})):this.tabs.eq(0).attr("tabIndex",0)},_processTabs:function(){var t=this;this.tablist=this._getList().addClass("ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all").attr("role","tablist"),this.tabs=this.tablist.find("> li:has(a[href])").addClass("ui-state-default ui-corner-top").attr({role:"tab",tabIndex:-1}),this.anchors=this.tabs.map(function(){return e("a",this)[0]}).addClass("ui-tabs-anchor").attr({role:"presentation",tabIndex:-1}),this.panels=e(),this.anchors.each(function(n,r){var i,o,u,a=e(r).uniqueId().attr("id"),f=e(r).closest("li"),l=f.attr("aria-controls");s(r)?(i=r.hash,o=t.element.find(t._sanitizeSelector(i))):(u=t._tabId(f),i="#"+u,o=t.element.find(i),o.length||(o=t._createPanel(u),o.insertAfter(t.panels[n-1]||t.tablist)),o.attr("aria-live","polite")),o.length&&(t.panels=t.panels.add(o)),l&&f.data("ui-tabs-aria-controls",l),f.attr({"aria-controls":i.substring(1),"aria-labelledby":a}),o.attr("aria-labelledby",a)}),this.panels.addClass("ui-tabs-panel ui-widget-content ui-corner-bottom").attr("role","tabpanel")},_getList:function(){return this.element.find("ol,ul").eq(0)},_createPanel:function(t){return e("<div>").attr("id",t).addClass("ui-tabs-panel ui-widget-content ui-corner-bottom").data("ui-tabs-destroy",!0)},_setupDisabled:function(t){e.isArray(t)&&(t.length?t.length===this.anchors.length&&(t=!0):t=!1);for(var n=0,r;r=this.tabs[n];n++)t===!0||e.inArray(n,t)!==-1?e(r).addClass("ui-state-disabled").attr("aria-disabled","true"):e(r).removeClass("ui-state-disabled").removeAttr("aria-disabled");this.options.disabled=t},_setupEvents:function(t){var n={click:function(e){e.preventDefault()}};t&&e.each(t.split(" "),function(e,t){n[t]="_eventHandler"}),this._off(this.anchors.add(this.tabs).add(this.panels)),this._on(this.anchors,n),this._on(this.tabs,{keydown:"_tabKeydown"}),this._on(this.panels,{keydown:"_panelKeydown"}),this._focusable(this.tabs),this._hoverable(this.tabs)},_setupHeightStyle:function(t){var n,r,i=this.element.parent();t==="fill"?(e.support.minHeight||(r=i.css("overflow"),i.css("overflow","hidden")),n=i.height(),this.element.siblings(":visible").each(function(){var t=e(this),r=t.css("position");if(r==="absolute"||r==="fixed")return;n-=t.outerHeight(!0)}),r&&i.css("overflow",r),this.element.children().not(this.panels).each(function(){n-=e(this).outerHeight(!0)}),this.panels.each(function(){e(this).height(Math.max(0,n-e(this).innerHeight()+e(this).height()))}).css("overflow","auto")):t==="auto"&&(n=0,this.panels.each(function(){n=Math.max(n,e(this).height("").height())}).height(n))},_eventHandler:function(t){var n=this.options,r=this.active,i=e(t.currentTarget),s=i.closest("li"),o=s[0]===r[0],u=o&&n.collapsible,a=u?e():this._getPanelForTab(s),f=r.length?this._getPanelForTab(r):e(),l={oldTab:r,oldPanel:f,newTab:u?e():s,newPanel:a};t.preventDefault();if(s.hasClass("ui-state-disabled")||s.hasClass("ui-tabs-loading")||this.running||o&&!n.collapsible||this._trigger("beforeActivate",t,l)===!1)return;n.active=u?!1:this.tabs.index(s),this.active=o?e():s,this.xhr&&this.xhr.abort(),!f.length&&!a.length&&e.error("jQuery UI Tabs: Mismatching fragment identifier."),a.length&&this.load(this.tabs.index(s),t),this._toggle(t,l)},_toggle:function(t,n){function o(){r.running=!1,r._trigger("activate",t,n)}function u(){n.newTab.closest("li").addClass("ui-tabs-active ui-state-active"),i.length&&r.options.show?r._show(i,r.options.show,o):(i.show(),o())}var r=this,i=n.newPanel,s=n.oldPanel;this.running=!0,s.length&&this.options.hide?this._hide(s,this.options.hide,function(){n.oldTab.closest("li").removeClass("ui-tabs-active ui-state-active"),u()}):(n.oldTab.closest("li").removeClass("ui-tabs-active ui-state-active"),s.hide(),u()),s.attr({"aria-expanded":"false","aria-hidden":"true"}),n.oldTab.attr("aria-selected","false"),i.length&&s.length?n.oldTab.attr("tabIndex",-1):i.length&&this.tabs.filter(function(){return e(this).attr("tabIndex")===0}).attr("tabIndex",-1),i.attr({"aria-expanded":"true","aria-hidden":"false"}),n.newTab.attr({"aria-selected":"true",tabIndex:0})},_activate:function(t){var n,r=this._findActive(t);if(r[0]===this.active[0])return;r.length||(r=this.active),n=r.find(".ui-tabs-anchor")[0],this._eventHandler({target:n,currentTarget:n,preventDefault:e.noop})},_findActive:function(t){return t===!1?e():this.tabs.eq(t)},_getIndex:function(e){return typeof e=="string"&&(e=this.anchors.index(this.anchors.filter("[href$='"+e+"']"))),e},_destroy:function(){this.xhr&&this.xhr.abort(),this.element.removeClass("ui-tabs ui-widget ui-widget-content ui-corner-all ui-tabs-collapsible"),this.tablist.removeClass("ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all").removeAttr("role"),this.anchors.removeClass("ui-tabs-anchor").removeAttr("role").removeAttr("tabIndex").removeData("href.tabs").removeData("load.tabs").removeUniqueId(),this.tabs.add(this.panels).each(function(){e.data(this,"ui-tabs-destroy")?e(this).remove():e(this).removeClass("ui-state-default ui-state-active ui-state-disabled ui-corner-top ui-corner-bottom ui-widget-content ui-tabs-active ui-tabs-panel").removeAttr("tabIndex").removeAttr("aria-live").removeAttr("aria-busy").removeAttr("aria-selected").removeAttr("aria-labelledby").removeAttr("aria-hidden").removeAttr("aria-expanded").removeAttr("role")}),this.tabs.each(function(){var t=e(this),n=t.data("ui-tabs-aria-controls");n?t.attr("aria-controls",n):t.removeAttr("aria-controls")}),this.panels.show(),this.options.heightStyle!=="content"&&this.panels.css("height","")},enable:function(n){var r=this.options.disabled;if(r===!1)return;n===t?r=!1:(n=this._getIndex(n),e.isArray(r)?r=e.map(r,function(e){return e!==n?e:null}):r=e.map(this.tabs,function(e,t){return t!==n?t:null})),this._setupDisabled(r)},disable:function(n){var r=this.options.disabled;if(r===!0)return;if(n===t)r=!0;else{n=this._getIndex(n);if(e.inArray(n,r)!==-1)return;e.isArray(r)?r=e.merge([n],r).sort():r=[n]}this._setupDisabled(r)},load:function(t,n){t=this._getIndex(t);var r=this,i=this.tabs.eq(t),o=i.find(".ui-tabs-anchor"),u=this._getPanelForTab(i),a={tab:i,panel:u};if(s(o[0]))return;this.xhr=e.ajax(this._ajaxSettings(o,n,a)),this.xhr&&this.xhr.statusText!=="canceled"&&(i.addClass("ui-tabs-loading"),u.attr("aria-busy","true"),this.xhr.success(function(e){setTimeout(function(){u.html(e),r._trigger("load",n,a)},1)}).complete(function(e,t){setTimeout(function(){t==="abort"&&r.panels.stop(!1,!0),i.removeClass("ui-tabs-loading"),u.removeAttr("aria-busy"),e===r.xhr&&delete r.xhr},1)}))},_ajaxSettings:function(t,n,r){var i=this;return{url:t.attr("href"),beforeSend:function(t,s){return i._trigger("beforeLoad",n,e.extend({jqXHR:t,ajaxSettings:s},r))}}},_getPanelForTab:function(t){var n=e(t).attr("aria-controls");return this.element.find(this._sanitizeSelector("#"+n))}}),e.uiBackCompat!==!1&&(e.ui.tabs.prototype._ui=function(e,t){return{tab:e,panel:t,index:this.anchors.index(e)}},e.widget("ui.tabs",e.ui.tabs,{url:function(e,t){this.anchors.eq(e).attr("href",t)}}),e.widget("ui.tabs",e.ui.tabs,{options:{ajaxOptions:null,cache:!1},_create:function(){this._super();var t=this;this._on({tabsbeforeload:function(n,r){if(e.data(r.tab[0],"cache.tabs")){n.preventDefault();return}r.jqXHR.success(function(){t.options.cache&&e.data(r.tab[0],"cache.tabs",!0)})}})},_ajaxSettings:function(t,n,r){var i=this.options.ajaxOptions;return e.extend({},i,{error:function(e,t){try{i.error(e,t,r.tab.closest("li").index(),r.tab[0])}catch(n){}}},this._superApply(arguments))},_setOption:function(e,t){e==="cache"&&t===!1&&this.anchors.removeData("cache.tabs"),this._super(e,t)},_destroy:function(){this.anchors.removeData("cache.tabs"),this._super()},url:function(e){this.anchors.eq(e).removeData("cache.tabs"),this._superApply(arguments)}}),e.widget("ui.tabs",e.ui.tabs,{abort:function(){this.xhr&&this.xhr.abort()}}),e.widget("ui.tabs",e.ui.tabs,{options:{spinner:"<em>Loading&#8230;</em>"},_create:function(){this._super(),this._on({tabsbeforeload:function(e,t){if(e.target!==this.element[0]||!this.options.spinner)return;var n=t.tab.find("span"),r=n.html();n.html(this.options.spinner),t.jqXHR.complete(function(){n.html(r)})}})}}),e.widget("ui.tabs",e.ui.tabs,{options:{enable:null,disable:null},enable:function(t){var n=this.options,r;if(t&&n.disabled===!0||e.isArray(n.disabled)&&e.inArray(t,n.disabled)!==-1)r=!0;this._superApply(arguments),r&&this._trigger("enable",null,this._ui(this.anchors[t],this.panels[t]))},disable:function(t){var n=this.options,r;if(t&&n.disabled===!1||e.isArray(n.disabled)&&e.inArray(t,n.disabled)===-1)r=!0;this._superApply(arguments),r&&this._trigger("disable",null,this._ui(this.anchors[t],this.panels[t]))}}),e.widget("ui.tabs",e.ui.tabs,{options:{add:null,remove:null,tabTemplate:"<li><a href='#{href}'><span>#{label}</span></a></li>"},add:function(n,r,i){i===t&&(i=this.anchors.length);var s,o,u=this.options,a=e(u.tabTemplate.replace(/#\{href\}/g,n).replace(/#\{label\}/g,r)),f=n.indexOf("#")?this._tabId(a):n.replace("#","");return a.addClass("ui-state-default ui-corner-top").data("ui-tabs-destroy",!0),a.attr("aria-controls",f),s=i>=this.tabs.length,o=this.element.find("#"+f),o.length||(o=this._createPanel(f),s?i>0?o.insertAfter(this.panels.eq(-1)):o.appendTo(this.element):o.insertBefore(this.panels[i])),o.addClass("ui-tabs-panel ui-widget-content ui-corner-bottom").hide(),s?a.appendTo(this.tablist):a.insertBefore(this.tabs[i]),u.disabled=e.map(u.disabled,function(e){return e>=i?++e:e}),this.refresh(),this.tabs.length===1&&u.active===!1&&this.option("active",0),this._trigger("add",null,this._ui(this.anchors[i],this.panels[i])),this},remove:function(t){t=this._getIndex(t);var n=this.options,r=this.tabs.eq(t).remove(),i=this._getPanelForTab(r).remove();return r.hasClass("ui-tabs-active")&&this.anchors.length>2&&this._activate(t+(t+1<this.anchors.length?1:-1)),n.disabled=e.map(e.grep(n.disabled,function(e){return e!==t}),function(e){return e>=t?--e:e}),this.refresh(),this._trigger("remove",null,this._ui(r.find("a")[0],i[0])),this}}),e.widget("ui.tabs",e.ui.tabs,{length:function(){return this.anchors.length}}),e.widget("ui.tabs",e.ui.tabs,{options:{idPrefix:"ui-tabs-"},_tabId:function(t){var n=t.is("li")?t.find("a[href]"):t;return n=n[0],e(n).closest("li").attr("aria-controls")||n.title&&n.title.replace(/\s/g,"_").replace(/[^\w\u00c0-\uFFFF\-]/g,"")||this.options.idPrefix+i()}}),e.widget("ui.tabs",e.ui.tabs,{options:{panelTemplate:"<div></div>"},_createPanel:function(t){return e(this.options.panelTemplate).attr("id",t).addClass("ui-tabs-panel ui-widget-content ui-corner-bottom").data("ui-tabs-destroy",!0)}}),e.widget("ui.tabs",e.ui.tabs,{_create:function(){var e=this.options;e.active===null&&e.selected!==t&&(e.active=e.selected===-1?!1:e.selected),this._super(),e.selected=e.active,e.selected===!1&&(e.selected=-1)},_setOption:function(e,t){if(e!=="selected")return this._super(e,t);var n=this.options;this._super("active",t===-1?!1:t),n.selected=n.active,n.selected===!1&&(n.selected=-1)},_eventHandler:function(){this._superApply(arguments),this.options.selected=this.options.active,this.options.selected===!1&&(this.options.selected=-1)}}),e.widget("ui.tabs",e.ui.tabs,{options:{show:null,select:null},_create:function(){this._super(),this.options.active!==!1&&this._trigger("show",null,this._ui(this.active.find(".ui-tabs-anchor")[0],this._getPanelForTab(this.active)[0]))},_trigger:function(e,t,n){var r,i,s=this._superApply(arguments);return s?(e==="beforeActivate"?(r=n.newTab.length?n.newTab:n.oldTab,i=n.newPanel.length?n.newPanel:n.oldPanel,s=this._super("select",t,{tab:r.find(".ui-tabs-anchor")[0],panel:i[0],index:r.closest("li").index()})):e==="activate"&&n.newTab.length&&(s=this._super("show",t,{tab:n.newTab.find(".ui-tabs-anchor")[0],panel:n.newPanel[0],index:n.newTab.closest("li").index()})),s):!1}}),e.widget("ui.tabs",e.ui.tabs,{select:function(e){e=this._getIndex(e);if(e===-1){if(!this.options.collapsible||this.options.selected===-1)return;e=this.options.selected}this.anchors.eq(e).trigger(this.options.event+this.eventNamespace)}}),function(){var t=0;e.widget("ui.tabs",e.ui.tabs,{options:{cookie:null},_create:function(){var e=this.options,t;e.active==null&&e.cookie&&(t=parseInt(this._cookie(),10),t===-1&&(t=!1),e.active=t),this._super()},_cookie:function(n){var r=[this.cookie||(this.cookie=this.options.cookie.name||"ui-tabs-"+ ++t)];return arguments.length&&(r.push(n===!1?-1:n),r.push(this.options.cookie)),e.cookie.apply(null,r)},_refresh:function(){this._super(),this.options.cookie&&this._cookie(this.options.active,this.options.cookie)},_eventHandler:function(){this._superApply(arguments),this.options.cookie&&this._cookie(this.options.active,this.options.cookie)},_destroy:function(){this._super(),this.options.cookie&&this._cookie(null,this.options.cookie)}})}(),e.widget("ui.tabs",e.ui.tabs,{_trigger:function(t,n,r){var i=e.extend({},r);return t==="load"&&(i.panel=i.panel[0],i.tab=i.tab.find(".ui-tabs-anchor")[0]),this._super(t,n,i)}}),e.widget("ui.tabs",e.ui.tabs,{options:{fx:null},_getFx:function(){var t,n,r=this.options.fx;return r&&(e.isArray(r)?(t=r[0],n=r[1]):t=n=r),r?{show:n,hide:t}:null},_toggle:function(e,t){function o(){n.running=!1,n._trigger("activate",e,t)}function u(){t.newTab.closest("li").addClass("ui-tabs-active ui-state-active"),r.length&&s.show?r.animate(s.show,s.show.duration,function(){o()}):(r.show(),o())}var n=this,r=t.newPanel,i=t.oldPanel,s=this._getFx();if(!s)return this._super(e,t);n.running=!0,i.length&&s.hide?i.animate(s.hide,s.hide.duration,function(){t.oldTab.closest("li").removeClass("ui-tabs-active ui-state-active"),u()}):(t.oldTab.closest("li").removeClass("ui-tabs-active ui-state-active"),i.hide(),u())}}))})(jQuery);(function(e){function n(t,n){var r=(t.attr("aria-describedby")||"").split(/\s+/);r.push(n),t.data("ui-tooltip-id",n).attr("aria-describedby",e.trim(r.join(" ")))}function r(t){var n=t.data("ui-tooltip-id"),r=(t.attr("aria-describedby")||"").split(/\s+/),i=e.inArray(n,r);i!==-1&&r.splice(i,1),t.removeData("ui-tooltip-id"),r=e.trim(r.join(" ")),r?t.attr("aria-describedby",r):t.removeAttr("aria-describedby")}var t=0;e.widget("ui.tooltip",{version:"1.9.2",options:{content:function(){return e(this).attr("title")},hide:!0,items:"[title]:not([disabled])",position:{my:"left top+15",at:"left bottom",collision:"flipfit flip"},show:!0,tooltipClass:null,track:!1,close:null,open:null},_create:function(){this._on({mouseover:"open",focusin:"open"}),this.tooltips={},this.parents={},this.options.disabled&&this._disable()},_setOption:function(t,n){var r=this;if(t==="disabled"){this[n?"_disable":"_enable"](),this.options[t]=n;return}this._super(t,n),t==="content"&&e.each(this.tooltips,function(e,t){r._updateContent(t)})},_disable:function(){var t=this;e.each(this.tooltips,function(n,r){var i=e.Event("blur");i.target=i.currentTarget=r[0],t.close(i,!0)}),this.element.find(this.options.items).andSelf().each(function(){var t=e(this);t.is("[title]")&&t.data("ui-tooltip-title",t.attr("title")).attr("title","")})},_enable:function(){this.element.find(this.options.items).andSelf().each(function(){var t=e(this);t.data("ui-tooltip-title")&&t.attr("title",t.data("ui-tooltip-title"))})},open:function(t){var n=this,r=e(t?t.target:this.element).closest(this.options.items);if(!r.length||r.data("ui-tooltip-id"))return;r.attr("title")&&r.data("ui-tooltip-title",r.attr("title")),r.data("ui-tooltip-open",!0),t&&t.type==="mouseover"&&r.parents().each(function(){var t=e(this),r;t.data("ui-tooltip-open")&&(r=e.Event("blur"),r.target=r.currentTarget=this,n.close(r,!0)),t.attr("title")&&(t.uniqueId(),n.parents[this.id]={element:this,title:t.attr("title")},t.attr("title",""))}),this._updateContent(r,t)},_updateContent:function(e,t){var n,r=this.options.content,i=this,s=t?t.type:null;if(typeof r=="string")return this._open(t,e,r);n=r.call(e[0],function(n){if(!e.data("ui-tooltip-open"))return;i._delay(function(){t&&(t.type=s),this._open(t,e,n)})}),n&&this._open(t,e,n)},_open:function(t,r,i){function f(e){a.of=e;if(s.is(":hidden"))return;s.position(a)}var s,o,u,a=e.extend({},this.options.position);if(!i)return;s=this._find(r);if(s.length){s.find(".ui-tooltip-content").html(i);return}r.is("[title]")&&(t&&t.type==="mouseover"?r.attr("title",""):r.removeAttr("title")),s=this._tooltip(r),n(r,s.attr("id")),s.find(".ui-tooltip-content").html(i),this.options.track&&t&&/^mouse/.test(t.type)?(this._on(this.document,{mousemove:f}),f(t)):s.position(e.extend({of:r},this.options.position)),s.hide(),this._show(s,this.options.show),this.options.show&&this.options.show.delay&&(u=setInterval(function(){s.is(":visible")&&(f(a.of),clearInterval(u))},e.fx.interval)),this._trigger("open",t,{tooltip:s}),o={keyup:function(t){if(t.keyCode===e.ui.keyCode.ESCAPE){var n=e.Event(t);n.currentTarget=r[0],this.close(n,!0)}},remove:function(){this._removeTooltip(s)}};if(!t||t.type==="mouseover")o.mouseleave="close";if(!t||t.type==="focusin")o.focusout="close";this._on(!0,r,o)},close:function(t){var n=this,i=e(t?t.currentTarget:this.element),s=this._find(i);if(this.closing)return;i.data("ui-tooltip-title")&&i.attr("title",i.data("ui-tooltip-title")),r(i),s.stop(!0),this._hide(s,this.options.hide,function(){n._removeTooltip(e(this))}),i.removeData("ui-tooltip-open"),this._off(i,"mouseleave focusout keyup"),i[0]!==this.element[0]&&this._off(i,"remove"),this._off(this.document,"mousemove"),t&&t.type==="mouseleave"&&e.each(this.parents,function(t,r){e(r.element).attr("title",r.title),delete n.parents[t]}),this.closing=!0,this._trigger("close",t,{tooltip:s}),this.closing=!1},_tooltip:function(n){var r="ui-tooltip-"+t++,i=e("<div>").attr({id:r,role:"tooltip"}).addClass("ui-tooltip ui-widget ui-corner-all ui-widget-content "+(this.options.tooltipClass||""));return e("<div>").addClass("ui-tooltip-content").appendTo(i),i.appendTo(this.document[0].body),e.fn.bgiframe&&i.bgiframe(),this.tooltips[r]=n,i},_find:function(t){var n=t.data("ui-tooltip-id");return n?e("#"+n):e()},_removeTooltip:function(e){e.remove(),delete this.tooltips[e.attr("id")]},_destroy:function(){var t=this;e.each(this.tooltips,function(n,r){var i=e.Event("blur");i.target=i.currentTarget=r[0],t.close(i,!0),e("#"+n).remove(),r.data("ui-tooltip-title")&&(r.attr("title",r.data("ui-tooltip-title")),r.removeData("ui-tooltip-title"))})}})})(jQuery);
/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Cookie
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/**
 * Cookie plugin
 *
 * Copyright (c) 2006 Klaus Hartl (stilbuero.de)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

/**
 * Create a cookie with the given name and value and other optional parameters.
 *
 * @example $.cookie('the_cookie', 'the_value');
 * @desc Set the value of a cookie.
 * @example $.cookie('the_cookie', 'the_value', { expires: 7, path: '/', domain: 'jquery.com', secure: true });
 * @desc Create a cookie with all available options.
 * @example $.cookie('the_cookie', 'the_value');
 * @desc Create a session cookie.
 * @example $.cookie('the_cookie', null);
 * @desc Delete a cookie by passing null as value. Keep in mind that you have to use the same path and domain
 *       used when the cookie was set.
 *
 * @param String name The name of the cookie.
 * @param String value The value of the cookie.
 * @param Object options An object literal containing key/value pairs to provide optional cookie attributes.
 * @option Number|Date expires Either an integer specifying the expiration date from now on in days or a Date object.
 *                             If a negative value is specified (e.g. a date in the past), the cookie will be deleted.
 *                             If set to null or omitted, the cookie will be a session cookie and will not be retained
 *                             when the the browser exits.
 * @option String path The value of the path atribute of the cookie (default: path of page that created the cookie).
 * @option String domain The value of the domain attribute of the cookie (default: domain of page that created the cookie).
 * @option Boolean secure If true, the secure attribute of the cookie will be set and the cookie transmission will
 *                        require a secure protocol (like HTTPS).
 * @type undefined
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */

/**
 * Get the value of a cookie with the given name.
 *
 * @example $.cookie('the_cookie');
 * @desc Get the value of a cookie.
 *
 * @param String name The name of the cookie.
 * @return The value of the cookie.
 * @type String
 *
 * @name $.cookie
 * @cat Plugins/Cookie
 * @author Klaus Hartl/klaus.hartl@stilbuero.de
 */
jQuery.cookie = function(name, value, options) {
    if (typeof value != 'undefined') { // name and value given, set cookie
        options = options || {};
        if (value === null) {
            value = '';
            options.expires = -1;
        }
        var expires = '';
        if (options.expires && (typeof options.expires == 'number' || options.expires.toUTCString)) {
            var date;
            if (typeof options.expires == 'number') {
                date = new Date();
                date.setTime(date.getTime() + (options.expires * 24 * 60 * 60 * 1000));
            } else {
                date = options.expires;
            }
            expires = '; expires=' + date.toUTCString(); // use expires attribute, max-age is not supported by IE
        }
        // CAUTION: Needed to parenthesize options.path and options.domain
        // in the following expressions, otherwise they evaluate to undefined
        // in the packed version for some reason...
        var path = options.path ? '; path=' + (options.path) : '';
        var domain = options.domain ? '; domain=' + (options.domain) : '';
        var secure = options.secure ? '; secure' : '';
        document.cookie = [name, '=', encodeURIComponent(value), expires, path, domain, secure].join('');
    } else { // only name given, get cookie
        var cookieValue = null;
        if (document.cookie && document.cookie != '') {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = jQuery.trim(cookies[i]);
                // Does this cookie string begin with the name we want?
                if (cookie.substring(0, name.length + 1) == (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }
};


/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Equal Height Columns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/**
 * Set all passed elements to the same height as the highest element.
 * 
 * Copyright (c) 2010 Ewen Elder
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * @author: Ewen Elder <glomainn at yahoo dot co dot uk> <ewen at jainaewen dot com>
 * @version: 1.0
**/ 
(function($){$.fn.equalHeightColumns=function(e){var J,a;e=$.extend({},$.equalHeightColumns.defaults,e);a=$(this);J=e.height;$(this).each(function(){if(e.children)a=$(this).children(e.children);if(!e.height){if(e.children){a.each(function(){if($(this).height()>J)J=$(this).height()})}else{if($(this).height()>J)J=$(this).height()}}});if(e.minHeight&&J<e.minHeight)J=e.minHeight;if(e.maxHeight&&J>e.maxHeight)J=e.maxHeight;a.animate({height:J},e.speed);return $(this)};$.equalHeightColumns={version:1.0,defaults:{children:false,height:0,minHeight:0,maxHeight:0,speed:0}}})(jQuery);

/*
 * File:        jquery.dataTables.min.js
 * Version:     1.9.1
 * Author:      Allan Jardine (www.sprymedia.co.uk)
 * Info:        www.datatables.net
 * 
 * Copyright 2008-2012 Allan Jardine, all rights reserved.
 *
 * This source file is free software, under either the GPL v2 license or a
 * BSD style license, available at:
 *   http://datatables.net/license_gpl2
 *   http://datatables.net/license_bsd
 * 
 * This source file is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the license files for details.
 */
(function (X, l, n) {
    var L = function (h) {
        var j = function (e) {
            function o(a, b) {
                var c = j.defaults.columns, d = a.aoColumns.length, c = h.extend({}, j.models.oColumn, c, { sSortingClass: a.oClasses.sSortable, sSortingClassJUI: a.oClasses.sSortJUI, nTh: b ? b : l.createElement("th"), sTitle: c.sTitle ? c.sTitle : b ? b.innerHTML : "", aDataSort: c.aDataSort ? c.aDataSort : [d], mData: c.mData ? c.oDefaults : d }); a.aoColumns.push(c); if (a.aoPreSearchCols[d] === n || null === a.aoPreSearchCols[d]) a.aoPreSearchCols[d] = h.extend({}, j.models.oSearch); else if (c = a.aoPreSearchCols[d],
c.bRegex === n && (c.bRegex = !0), c.bSmart === n && (c.bSmart = !0), c.bCaseInsensitive === n) c.bCaseInsensitive = !0; m(a, d, null)
            } function m(a, b, c) {
                var d = a.aoColumns[b]; c !== n && null !== c && (c.mDataProp && !c.mData && (c.mData = c.mDataProp), c.sType !== n && (d.sType = c.sType, d._bAutoType = !1), h.extend(d, c), p(d, c, "sWidth", "sWidthOrig"), c.iDataSort !== n && (d.aDataSort = [c.iDataSort]), p(d, c, "aDataSort")); var i = d.mRender ? Q(d.mRender) : null, f = Q(d.mData); d.fnGetData = function (a, b) { var c = f(a, b); return d.mRender && b && "" !== b ? i(c, b, a) : c }; d.fnSetData =
L(d.mData); a.oFeatures.bSort || (d.bSortable = !1); !d.bSortable || -1 == h.inArray("asc", d.asSorting) && -1 == h.inArray("desc", d.asSorting) ? (d.sSortingClass = a.oClasses.sSortableNone, d.sSortingClassJUI = "") : -1 == h.inArray("asc", d.asSorting) && -1 == h.inArray("desc", d.asSorting) ? (d.sSortingClass = a.oClasses.sSortable, d.sSortingClassJUI = a.oClasses.sSortJUI) : -1 != h.inArray("asc", d.asSorting) && -1 == h.inArray("desc", d.asSorting) ? (d.sSortingClass = a.oClasses.sSortableAsc, d.sSortingClassJUI = a.oClasses.sSortJUIAscAllowed) : -1 ==
h.inArray("asc", d.asSorting) && -1 != h.inArray("desc", d.asSorting) && (d.sSortingClass = a.oClasses.sSortableDesc, d.sSortingClassJUI = a.oClasses.sSortJUIDescAllowed)
            } function k(a) { if (!1 === a.oFeatures.bAutoWidth) return !1; da(a); for (var b = 0, c = a.aoColumns.length; b < c; b++) a.aoColumns[b].nTh.style.width = a.aoColumns[b].sWidth } function G(a, b) { var c = r(a, "bVisible"); return "number" === typeof c[b] ? c[b] : null } function R(a, b) { var c = r(a, "bVisible"), c = h.inArray(b, c); return -1 !== c ? c : null } function t(a) { return r(a, "bVisible").length }
            function r(a, b) { var c = []; h.map(a.aoColumns, function (a, i) { a[b] && c.push(i) }); return c } function B(a) { for (var b = j.ext.aTypes, c = b.length, d = 0; d < c; d++) { var i = b[d](a); if (null !== i) return i } return "string" } function u(a, b) { for (var c = b.split(","), d = [], i = 0, f = a.aoColumns.length; i < f; i++) for (var g = 0; g < f; g++) if (a.aoColumns[i].sName == c[g]) { d.push(g); break } return d } function M(a) { for (var b = "", c = 0, d = a.aoColumns.length; c < d; c++) b += a.aoColumns[c].sName + ","; return b.length == d ? "" : b.slice(0, -1) } function ta(a, b, c, d) {
                var i, f,
g, e, w; if (b) for (i = b.length - 1; 0 <= i; i--) { var j = b[i].aTargets; h.isArray(j) || D(a, 1, "aTargets must be an array of targets, not a " + typeof j); f = 0; for (g = j.length; f < g; f++) if ("number" === typeof j[f] && 0 <= j[f]) { for (; a.aoColumns.length <= j[f]; ) o(a); d(j[f], b[i]) } else if ("number" === typeof j[f] && 0 > j[f]) d(a.aoColumns.length + j[f], b[i]); else if ("string" === typeof j[f]) { e = 0; for (w = a.aoColumns.length; e < w; e++) ("_all" == j[f] || h(a.aoColumns[e].nTh).hasClass(j[f])) && d(e, b[i]) } } if (c) { i = 0; for (a = c.length; i < a; i++) d(i, c[i]) } 
            } function H(a,
b) {
                var c; c = h.isArray(b) ? b.slice() : h.extend(!0, {}, b); var d = a.aoData.length, i = h.extend(!0, {}, j.models.oRow); i._aData = c; a.aoData.push(i); for (var f, i = 0, g = a.aoColumns.length; i < g; i++) c = a.aoColumns[i], "function" === typeof c.fnRender && c.bUseRendered && null !== c.mData ? F(a, d, i, S(a, d, i)) : F(a, d, i, v(a, d, i)), c._bAutoType && "string" != c.sType && (f = v(a, d, i, "type"), null !== f && "" !== f && (f = B(f), null === c.sType ? c.sType = f : c.sType != f && "html" != c.sType && (c.sType = "string"))); a.aiDisplayMaster.push(d); a.oFeatures.bDeferRender || ea(a,
d); return d
            } function ua(a) {
                var b, c, d, i, f, g, e; if (a.bDeferLoading || null === a.sAjaxSource) for (b = a.nTBody.firstChild; b; ) { if ("TR" == b.nodeName.toUpperCase()) { c = a.aoData.length; b._DT_RowIndex = c; a.aoData.push(h.extend(!0, {}, j.models.oRow, { nTr: b })); a.aiDisplayMaster.push(c); f = b.firstChild; for (d = 0; f; ) { g = f.nodeName.toUpperCase(); if ("TD" == g || "TH" == g) F(a, c, d, h.trim(f.innerHTML)), d++; f = f.nextSibling } } b = b.nextSibling } i = T(a); d = []; b = 0; for (c = i.length; b < c; b++) for (f = i[b].firstChild; f; ) g = f.nodeName.toUpperCase(), ("TD" ==
g || "TH" == g) && d.push(f), f = f.nextSibling; c = 0; for (i = a.aoColumns.length; c < i; c++) {
                    e = a.aoColumns[c]; null === e.sTitle && (e.sTitle = e.nTh.innerHTML); var w = e._bAutoType, o = "function" === typeof e.fnRender, k = null !== e.sClass, n = e.bVisible, m, p; if (w || o || k || !n) {
                        g = 0; for (b = a.aoData.length; g < b; g++) f = a.aoData[g], m = d[g * i + c], w && "string" != e.sType && (p = v(a, g, c, "type"), "" !== p && (p = B(p), null === e.sType ? e.sType = p : e.sType != p && "html" != e.sType && (e.sType = "string"))), e.mRender ? m.innerHTML = v(a, g, c, "display") : e.mData !== c && (m.innerHTML = v(a,
g, c, "display")), o && (p = S(a, g, c), m.innerHTML = p, e.bUseRendered && F(a, g, c, p)), k && (m.className += " " + e.sClass), n ? f._anHidden[c] = null : (f._anHidden[c] = m, m.parentNode.removeChild(m)), e.fnCreatedCell && e.fnCreatedCell.call(a.oInstance, m, v(a, g, c, "display"), f._aData, g, c)
                    } 
                } if (0 !== a.aoRowCreatedCallback.length) { b = 0; for (c = a.aoData.length; b < c; b++) f = a.aoData[b], A(a, "aoRowCreatedCallback", null, [f.nTr, f._aData, b]) } 
            } function I(a, b) { return b._DT_RowIndex !== n ? b._DT_RowIndex : null } function fa(a, b, c) {
                for (var b = J(a, b), d = 0, a =
a.aoColumns.length; d < a; d++) if (b[d] === c) return d; return -1
            } function Y(a, b, c, d) { for (var i = [], f = 0, g = d.length; f < g; f++) i.push(v(a, b, d[f], c)); return i } function v(a, b, c, d) {
                var i = a.aoColumns[c]; if ((c = i.fnGetData(a.aoData[b]._aData, d)) === n) return a.iDrawError != a.iDraw && null === i.sDefaultContent && (D(a, 0, "Requested unknown parameter " + ("function" == typeof i.mData ? "{mData function}" : "'" + i.mData + "'") + " from the data source for row " + b), a.iDrawError = a.iDraw), i.sDefaultContent; if (null === c && null !== i.sDefaultContent) c =
i.sDefaultContent; else if ("function" === typeof c) return c(); return "display" == d && null === c ? "" : c
            } function F(a, b, c, d) { a.aoColumns[c].fnSetData(a.aoData[b]._aData, d) } function Q(a) {
                if (null === a) return function () { return null }; if ("function" === typeof a) return function (b, d, i) { return a(b, d, i) }; if ("string" === typeof a && (-1 !== a.indexOf(".") || -1 !== a.indexOf("["))) {
                    var b = function (a, d, i) {
                        var f = i.split("."), g; if ("" !== i) {
                            var e = 0; for (g = f.length; e < g; e++) {
                                if (i = f[e].match(U)) {
                                    f[e] = f[e].replace(U, ""); "" !== f[e] && (a = a[f[e]]);
                                    g = []; f.splice(0, e + 1); for (var f = f.join("."), e = 0, h = a.length; e < h; e++) g.push(b(a[e], d, f)); a = i[0].substring(1, i[0].length - 1); a = "" === a ? g : g.join(a); break
                                } if (null === a || a[f[e]] === n) return n; a = a[f[e]]
                            } 
                        } return a
                    }; return function (c, d) { return b(c, d, a) } 
                } return function (b) { return b[a] } 
            } function L(a) {
                if (null === a) return function () { }; if ("function" === typeof a) return function (b, d) { a(b, "set", d) }; if ("string" === typeof a && (-1 !== a.indexOf(".") || -1 !== a.indexOf("["))) {
                    var b = function (a, d, i) {
                        var i = i.split("."), f, g, e = 0; for (g =
i.length - 1; e < g; e++) { if (f = i[e].match(U)) { i[e] = i[e].replace(U, ""); a[i[e]] = []; f = i.slice(); f.splice(0, e + 1); g = f.join("."); for (var h = 0, j = d.length; h < j; h++) f = {}, b(f, d[h], g), a[i[e]].push(f); return } if (null === a[i[e]] || a[i[e]] === n) a[i[e]] = {}; a = a[i[e]] } a[i[i.length - 1].replace(U, "")] = d
                    }; return function (c, d) { return b(c, d, a) } 
                } return function (b, d) { b[a] = d } 
            } function Z(a) { for (var b = [], c = a.aoData.length, d = 0; d < c; d++) b.push(a.aoData[d]._aData); return b } function ga(a) {
                a.aoData.splice(0, a.aoData.length); a.aiDisplayMaster.splice(0,
a.aiDisplayMaster.length); a.aiDisplay.splice(0, a.aiDisplay.length); y(a)
            } function ha(a, b) { for (var c = -1, d = 0, i = a.length; d < i; d++) a[d] == b ? c = d : a[d] > b && a[d]--; -1 != c && a.splice(c, 1) } function S(a, b, c) { var d = a.aoColumns[c]; return d.fnRender({ iDataRow: b, iDataColumn: c, oSettings: a, aData: a.aoData[b]._aData, mDataProp: d.mData }, v(a, b, c, "display")) } function ea(a, b) {
                var c = a.aoData[b], d; if (null === c.nTr) {
                    c.nTr = l.createElement("tr"); c.nTr._DT_RowIndex = b; c._aData.DT_RowId && (c.nTr.id = c._aData.DT_RowId); c._aData.DT_RowClass &&
(c.nTr.className = c._aData.DT_RowClass); for (var i = 0, f = a.aoColumns.length; i < f; i++) { var g = a.aoColumns[i]; d = l.createElement(g.sCellType); d.innerHTML = "function" === typeof g.fnRender && (!g.bUseRendered || null === g.mData) ? S(a, b, i) : v(a, b, i, "display"); null !== g.sClass && (d.className = g.sClass); g.bVisible ? (c.nTr.appendChild(d), c._anHidden[i] = null) : c._anHidden[i] = d; g.fnCreatedCell && g.fnCreatedCell.call(a.oInstance, d, v(a, b, i, "display"), c._aData, b, i) } A(a, "aoRowCreatedCallback", null, [c.nTr, c._aData, b])
                } 
            } function va(a) {
                var b,
c, d; if (0 !== h("th, td", a.nTHead).length) { b = 0; for (d = a.aoColumns.length; b < d; b++) if (c = a.aoColumns[b].nTh, c.setAttribute("role", "columnheader"), a.aoColumns[b].bSortable && (c.setAttribute("tabindex", a.iTabIndex), c.setAttribute("aria-controls", a.sTableId)), null !== a.aoColumns[b].sClass && h(c).addClass(a.aoColumns[b].sClass), a.aoColumns[b].sTitle != c.innerHTML) c.innerHTML = a.aoColumns[b].sTitle } else {
                    var i = l.createElement("tr"); b = 0; for (d = a.aoColumns.length; b < d; b++) c = a.aoColumns[b].nTh, c.innerHTML = a.aoColumns[b].sTitle,
c.setAttribute("tabindex", "0"), null !== a.aoColumns[b].sClass && h(c).addClass(a.aoColumns[b].sClass), i.appendChild(c); h(a.nTHead).html("")[0].appendChild(i); V(a.aoHeader, a.nTHead)
                } h(a.nTHead).children("tr").attr("role", "row"); if (a.bJUI) { b = 0; for (d = a.aoColumns.length; b < d; b++) { c = a.aoColumns[b].nTh; i = l.createElement("div"); i.className = a.oClasses.sSortJUIWrapper; h(c).contents().appendTo(i); var f = l.createElement("span"); f.className = a.oClasses.sSortIcon; i.appendChild(f); c.appendChild(i) } } if (a.oFeatures.bSort) for (b =
0; b < a.aoColumns.length; b++) !1 !== a.aoColumns[b].bSortable ? ia(a, a.aoColumns[b].nTh, b) : h(a.aoColumns[b].nTh).addClass(a.oClasses.sSortableNone); "" !== a.oClasses.sFooterTH && h(a.nTFoot).children("tr").children("th").addClass(a.oClasses.sFooterTH); if (null !== a.nTFoot) { c = N(a, null, a.aoFooter); b = 0; for (d = a.aoColumns.length; b < d; b++) c[b] && (a.aoColumns[b].nTf = c[b], a.aoColumns[b].sClass && h(c[b]).addClass(a.aoColumns[b].sClass)) } 
            } function W(a, b, c) {
                var d, i, f, g = [], e = [], h = a.aoColumns.length, j; c === n && (c = !1); d = 0; for (i =
b.length; d < i; d++) { g[d] = b[d].slice(); g[d].nTr = b[d].nTr; for (f = h - 1; 0 <= f; f--) !a.aoColumns[f].bVisible && !c && g[d].splice(f, 1); e.push([]) } d = 0; for (i = g.length; d < i; d++) { if (a = g[d].nTr) for (; f = a.firstChild; ) a.removeChild(f); f = 0; for (b = g[d].length; f < b; f++) if (j = h = 1, e[d][f] === n) { a.appendChild(g[d][f].cell); for (e[d][f] = 1; g[d + h] !== n && g[d][f].cell == g[d + h][f].cell; ) e[d + h][f] = 1, h++; for (; g[d][f + j] !== n && g[d][f].cell == g[d][f + j].cell; ) { for (c = 0; c < h; c++) e[d + c][f + j] = 1; j++ } g[d][f].cell.rowSpan = h; g[d][f].cell.colSpan = j } } 
            } function x(a) {
                var b =
A(a, "aoPreDrawCallback", "preDraw", [a]); if (-1 !== h.inArray(!1, b)) E(a, !1); else {
                    var c, d, b = [], i = 0, f = a.asStripeClasses.length; c = a.aoOpenRows.length; a.bDrawing = !0; a.iInitDisplayStart !== n && -1 != a.iInitDisplayStart && (a._iDisplayStart = a.oFeatures.bServerSide ? a.iInitDisplayStart : a.iInitDisplayStart >= a.fnRecordsDisplay() ? 0 : a.iInitDisplayStart, a.iInitDisplayStart = -1, y(a)); if (a.bDeferLoading) a.bDeferLoading = !1, a.iDraw++; else if (a.oFeatures.bServerSide) { if (!a.bDestroying && !wa(a)) return } else a.iDraw++; if (0 !== a.aiDisplay.length) {
                        var g =
a._iDisplayStart; d = a._iDisplayEnd; a.oFeatures.bServerSide && (g = 0, d = a.aoData.length); for (; g < d; g++) { var e = a.aoData[a.aiDisplay[g]]; null === e.nTr && ea(a, a.aiDisplay[g]); var j = e.nTr; if (0 !== f) { var o = a.asStripeClasses[i % f]; e._sRowStripe != o && (h(j).removeClass(e._sRowStripe).addClass(o), e._sRowStripe = o) } A(a, "aoRowCallback", null, [j, a.aoData[a.aiDisplay[g]]._aData, i, g]); b.push(j); i++; if (0 !== c) for (e = 0; e < c; e++) if (j == a.aoOpenRows[e].nParent) { b.push(a.aoOpenRows[e].nTr); break } } 
                    } else b[0] = l.createElement("tr"), a.asStripeClasses[0] &&
(b[0].className = a.asStripeClasses[0]), c = a.oLanguage, f = c.sZeroRecords, 1 == a.iDraw && null !== a.sAjaxSource && !a.oFeatures.bServerSide ? f = c.sLoadingRecords : c.sEmptyTable && 0 === a.fnRecordsTotal() && (f = c.sEmptyTable), c = l.createElement("td"), c.setAttribute("valign", "top"), c.colSpan = t(a), c.className = a.oClasses.sRowEmpty, c.innerHTML = ja(a, f), b[i].appendChild(c); A(a, "aoHeaderCallback", "header", [h(a.nTHead).children("tr")[0], Z(a), a._iDisplayStart, a.fnDisplayEnd(), a.aiDisplay]); A(a, "aoFooterCallback", "footer", [h(a.nTFoot).children("tr")[0],
Z(a), a._iDisplayStart, a.fnDisplayEnd(), a.aiDisplay]); i = l.createDocumentFragment(); c = l.createDocumentFragment(); if (a.nTBody) { f = a.nTBody.parentNode; c.appendChild(a.nTBody); if (!a.oScroll.bInfinite || !a._bInitComplete || a.bSorted || a.bFiltered) for (; c = a.nTBody.firstChild; ) a.nTBody.removeChild(c); c = 0; for (d = b.length; c < d; c++) i.appendChild(b[c]); a.nTBody.appendChild(i); null !== f && f.appendChild(a.nTBody) } A(a, "aoDrawCallback", "draw", [a]); a.bSorted = !1; a.bFiltered = !1; a.bDrawing = !1; a.oFeatures.bServerSide && (E(a, !1),
a._bInitComplete || $(a))
                } 
            } function aa(a) { a.oFeatures.bSort ? O(a, a.oPreviousSearch) : a.oFeatures.bFilter ? K(a, a.oPreviousSearch) : (y(a), x(a)) } function xa(a) {
                var b = h("<div></div>")[0]; a.nTable.parentNode.insertBefore(b, a.nTable); a.nTableWrapper = h('<div id="' + a.sTableId + '_wrapper" class="' + a.oClasses.sWrapper + '" role="grid"></div>')[0]; a.nTableReinsertBefore = a.nTable.nextSibling; for (var c = a.nTableWrapper, d = a.sDom.split(""), i, f, g, e, w, o, k, m = 0; m < d.length; m++) {
                    f = 0; g = d[m]; if ("<" == g) {
                        e = h("<div></div>")[0]; w = d[m +
1]; if ("'" == w || '"' == w) { o = ""; for (k = 2; d[m + k] != w; ) o += d[m + k], k++; "H" == o ? o = a.oClasses.sJUIHeader : "F" == o && (o = a.oClasses.sJUIFooter); -1 != o.indexOf(".") ? (w = o.split("."), e.id = w[0].substr(1, w[0].length - 1), e.className = w[1]) : "#" == o.charAt(0) ? e.id = o.substr(1, o.length - 1) : e.className = o; m += k } c.appendChild(e); c = e
                    } else if (">" == g) c = c.parentNode; else if ("l" == g && a.oFeatures.bPaginate && a.oFeatures.bLengthChange) i = ya(a), f = 1; else if ("f" == g && a.oFeatures.bFilter) i = za(a), f = 1; else if ("r" == g && a.oFeatures.bProcessing) i = Aa(a), f =
1; else if ("t" == g) i = Ba(a), f = 1; else if ("i" == g && a.oFeatures.bInfo) i = Ca(a), f = 1; else if ("p" == g && a.oFeatures.bPaginate) i = Da(a), f = 1; else if (0 !== j.ext.aoFeatures.length) { e = j.ext.aoFeatures; k = 0; for (w = e.length; k < w; k++) if (g == e[k].cFeature) { (i = e[k].fnInit(a)) && (f = 1); break } } 1 == f && null !== i && ("object" !== typeof a.aanFeatures[g] && (a.aanFeatures[g] = []), a.aanFeatures[g].push(i), c.appendChild(i))
                } b.parentNode.replaceChild(a.nTableWrapper, b)
            } function V(a, b) {
                var c = h(b).children("tr"), d, i, f, g, e, j, o, k, m, p; a.splice(0, a.length);
                f = 0; for (j = c.length; f < j; f++) a.push([]); f = 0; for (j = c.length; f < j; f++) { d = c[f]; for (i = d.firstChild; i; ) { if ("TD" == i.nodeName.toUpperCase() || "TH" == i.nodeName.toUpperCase()) { k = 1 * i.getAttribute("colspan"); m = 1 * i.getAttribute("rowspan"); k = !k || 0 === k || 1 === k ? 1 : k; m = !m || 0 === m || 1 === m ? 1 : m; g = 0; for (e = a[f]; e[g]; ) g++; o = g; p = 1 === k ? !0 : !1; for (e = 0; e < k; e++) for (g = 0; g < m; g++) a[f + g][o + e] = { cell: i, unique: p }, a[f + g].nTr = d } i = i.nextSibling } } 
            } function N(a, b, c) {
                var d = []; c || (c = a.aoHeader, b && (c = [], V(c, b))); for (var b = 0, i = c.length; b < i; b++) for (var f =
0, g = c[b].length; f < g; f++) if (c[b][f].unique && (!d[f] || !a.bSortCellsTop)) d[f] = c[b][f].cell; return d
            } function wa(a) { if (a.bAjaxDataGet) { a.iDraw++; E(a, !0); var b = Ea(a); ka(a, b); a.fnServerData.call(a.oInstance, a.sAjaxSource, b, function (b) { Fa(a, b) }, a); return !1 } return !0 } function Ea(a) {
                var b = a.aoColumns.length, c = [], d, i, f, g; c.push({ name: "sEcho", value: a.iDraw }); c.push({ name: "iColumns", value: b }); c.push({ name: "sColumns", value: M(a) }); c.push({ name: "iDisplayStart", value: a._iDisplayStart }); c.push({ name: "iDisplayLength",
                    value: !1 !== a.oFeatures.bPaginate ? a._iDisplayLength : -1
                }); for (f = 0; f < b; f++) d = a.aoColumns[f].mData, c.push({ name: "mDataProp_" + f, value: "function" === typeof d ? "function" : d }); if (!1 !== a.oFeatures.bFilter) { c.push({ name: "sSearch", value: a.oPreviousSearch.sSearch }); c.push({ name: "bRegex", value: a.oPreviousSearch.bRegex }); for (f = 0; f < b; f++) c.push({ name: "sSearch_" + f, value: a.aoPreSearchCols[f].sSearch }), c.push({ name: "bRegex_" + f, value: a.aoPreSearchCols[f].bRegex }), c.push({ name: "bSearchable_" + f, value: a.aoColumns[f].bSearchable }) } if (!1 !==
a.oFeatures.bSort) { var e = 0; d = null !== a.aaSortingFixed ? a.aaSortingFixed.concat(a.aaSorting) : a.aaSorting.slice(); for (f = 0; f < d.length; f++) { i = a.aoColumns[d[f][0]].aDataSort; for (g = 0; g < i.length; g++) c.push({ name: "iSortCol_" + e, value: i[g] }), c.push({ name: "sSortDir_" + e, value: d[f][1] }), e++ } c.push({ name: "iSortingCols", value: e }); for (f = 0; f < b; f++) c.push({ name: "bSortable_" + f, value: a.aoColumns[f].bSortable }) } return c
            } function ka(a, b) { A(a, "aoServerParams", "serverParams", [b]) } function Fa(a, b) {
                if (b.sEcho !== n) {
                    if (1 * b.sEcho <
a.iDraw) return; a.iDraw = 1 * b.sEcho
                } (!a.oScroll.bInfinite || a.oScroll.bInfinite && (a.bSorted || a.bFiltered)) && ga(a); a._iRecordsTotal = parseInt(b.iTotalRecords, 10); a._iRecordsDisplay = parseInt(b.iTotalDisplayRecords, 10); var c = M(a), c = b.sColumns !== n && "" !== c && b.sColumns != c, d; c && (d = u(a, b.sColumns)); for (var i = Q(a.sAjaxDataProp)(b), f = 0, g = i.length; f < g; f++) if (c) { for (var e = [], h = 0, j = a.aoColumns.length; h < j; h++) e.push(i[f][d[h]]); H(a, e) } else H(a, i[f]); a.aiDisplay = a.aiDisplayMaster.slice(); a.bAjaxDataGet = !1; x(a); a.bAjaxDataGet =
!0; E(a, !1)
            } function za(a) {
                var b = a.oPreviousSearch, c = a.oLanguage.sSearch, c = -1 !== c.indexOf("_INPUT_") ? c.replace("_INPUT_", '<input type="text" />') : "" === c ? '<input type="text" />' : c + ' <input type="text" />', d = l.createElement("div"); d.className = a.oClasses.sFilter; d.innerHTML = "<label>" + c + "</label>"; a.aanFeatures.f || (d.id = a.sTableId + "_filter"); c = h('input[type="text"]', d); d._DT_Input = c[0]; c.val(b.sSearch.replace('"', "&quot;")); c.bind("keyup.DT", function () {
                    for (var c = a.aanFeatures.f, d = this.value === "" ? "" : this.value,
g = 0, e = c.length; g < e; g++) c[g] != h(this).parents("div.dataTables_filter")[0] && h(c[g]._DT_Input).val(d); d != b.sSearch && K(a, { sSearch: d, bRegex: b.bRegex, bSmart: b.bSmart, bCaseInsensitive: b.bCaseInsensitive })
                }); c.attr("aria-controls", a.sTableId).bind("keypress.DT", function (a) { if (a.keyCode == 13) return false }); return d
            } function K(a, b, c) {
                var d = a.oPreviousSearch, i = a.aoPreSearchCols, f = function (a) { d.sSearch = a.sSearch; d.bRegex = a.bRegex; d.bSmart = a.bSmart; d.bCaseInsensitive = a.bCaseInsensitive }; if (a.oFeatures.bServerSide) f(b);
                else { Ga(a, b.sSearch, c, b.bRegex, b.bSmart, b.bCaseInsensitive); f(b); for (b = 0; b < a.aoPreSearchCols.length; b++) Ha(a, i[b].sSearch, b, i[b].bRegex, i[b].bSmart, i[b].bCaseInsensitive); Ia(a) } a.bFiltered = !0; h(a.oInstance).trigger("filter", a); a._iDisplayStart = 0; y(a); x(a); la(a, 0)
            } function Ia(a) { for (var b = j.ext.afnFiltering, c = r(a, "bSearchable"), d = 0, i = b.length; d < i; d++) for (var f = 0, g = 0, e = a.aiDisplay.length; g < e; g++) { var h = a.aiDisplay[g - f]; b[d](a, Y(a, h, "filter", c), h) || (a.aiDisplay.splice(g - f, 1), f++) } } function Ha(a, b, c,
d, i, f) { if ("" !== b) for (var g = 0, b = ma(b, d, i, f), d = a.aiDisplay.length - 1; 0 <= d; d--) i = Ja(v(a, a.aiDisplay[d], c, "filter"), a.aoColumns[c].sType), b.test(i) || (a.aiDisplay.splice(d, 1), g++) } function Ga(a, b, c, d, i, f) {
    d = ma(b, d, i, f); i = a.oPreviousSearch; c || (c = 0); 0 !== j.ext.afnFiltering.length && (c = 1); if (0 >= b.length) a.aiDisplay.splice(0, a.aiDisplay.length), a.aiDisplay = a.aiDisplayMaster.slice(); else if (a.aiDisplay.length == a.aiDisplayMaster.length || i.sSearch.length > b.length || 1 == c || 0 !== b.indexOf(i.sSearch)) {
        a.aiDisplay.splice(0,
a.aiDisplay.length); la(a, 1); for (b = 0; b < a.aiDisplayMaster.length; b++) d.test(a.asDataSearch[b]) && a.aiDisplay.push(a.aiDisplayMaster[b])
    } else for (b = c = 0; b < a.asDataSearch.length; b++) d.test(a.asDataSearch[b]) || (a.aiDisplay.splice(b - c, 1), c++)
} function la(a, b) { if (!a.oFeatures.bServerSide) { a.asDataSearch = []; for (var c = r(a, "bSearchable"), d = 1 === b ? a.aiDisplayMaster : a.aiDisplay, i = 0, f = d.length; i < f; i++) a.asDataSearch[i] = na(a, Y(a, d[i], "filter", c)) } } function na(a, b) {
    var c = b.join("  "); -1 !== c.indexOf("&") && (c = h("<div>").html(c).text());
    return c.replace(/[\n\r]/g, " ")
} function ma(a, b, c, d) { if (c) return a = b ? a.split(" ") : oa(a).split(" "), a = "^(?=.*?" + a.join(")(?=.*?") + ").*$", RegExp(a, d ? "i" : ""); a = b ? a : oa(a); return RegExp(a, d ? "i" : "") } function Ja(a, b) { return "function" === typeof j.ext.ofnSearch[b] ? j.ext.ofnSearch[b](a) : null === a ? "" : "html" == b ? a.replace(/[\r\n]/g, " ").replace(/<.*?>/g, "") : "string" === typeof a ? a.replace(/[\r\n]/g, " ") : a } function oa(a) {
    return a.replace(RegExp("(\\/|\\.|\\*|\\+|\\?|\\||\\(|\\)|\\[|\\]|\\{|\\}|\\\\|\\$|\\^|\\-)", "g"),
"\\$1")
} function Ca(a) { var b = l.createElement("div"); b.className = a.oClasses.sInfo; a.aanFeatures.i || (a.aoDrawCallback.push({ fn: Ka, sName: "information" }), b.id = a.sTableId + "_info"); a.nTable.setAttribute("aria-describedby", a.sTableId + "_info"); return b } function Ka(a) {
    if (a.oFeatures.bInfo && 0 !== a.aanFeatures.i.length) {
        var b = a.oLanguage, c = a._iDisplayStart + 1, d = a.fnDisplayEnd(), i = a.fnRecordsTotal(), f = a.fnRecordsDisplay(), g; g = 0 === f ? b.sInfoEmpty : b.sInfo; f != i && (g += " " + b.sInfoFiltered); g += b.sInfoPostFix; g = ja(a, g);
        null !== b.fnInfoCallback && (g = b.fnInfoCallback.call(a.oInstance, a, c, d, i, f, g)); a = a.aanFeatures.i; b = 0; for (c = a.length; b < c; b++) h(a[b]).html(g)
    } 
} function ja(a, b) { var c = a.fnFormatNumber(a._iDisplayStart + 1), d = a.fnDisplayEnd(), d = a.fnFormatNumber(d), i = a.fnRecordsDisplay(), i = a.fnFormatNumber(i), f = a.fnRecordsTotal(), f = a.fnFormatNumber(f); a.oScroll.bInfinite && (c = a.fnFormatNumber(1)); return b.replace(/_START_/g, c).replace(/_END_/g, d).replace(/_TOTAL_/g, i).replace(/_MAX_/g, f) } function ba(a) {
    var b, c, d = a.iInitDisplayStart;
    if (!1 === a.bInitialised) setTimeout(function () { ba(a) }, 200); else {
        xa(a); va(a); W(a, a.aoHeader); a.nTFoot && W(a, a.aoFooter); E(a, !0); a.oFeatures.bAutoWidth && da(a); b = 0; for (c = a.aoColumns.length; b < c; b++) null !== a.aoColumns[b].sWidth && (a.aoColumns[b].nTh.style.width = q(a.aoColumns[b].sWidth)); a.oFeatures.bSort ? O(a) : a.oFeatures.bFilter ? K(a, a.oPreviousSearch) : (a.aiDisplay = a.aiDisplayMaster.slice(), y(a), x(a)); null !== a.sAjaxSource && !a.oFeatures.bServerSide ? (c = [], ka(a, c), a.fnServerData.call(a.oInstance, a.sAjaxSource,
c, function (c) { var f = a.sAjaxDataProp !== "" ? Q(a.sAjaxDataProp)(c) : c; for (b = 0; b < f.length; b++) H(a, f[b]); a.iInitDisplayStart = d; if (a.oFeatures.bSort) O(a); else { a.aiDisplay = a.aiDisplayMaster.slice(); y(a); x(a) } E(a, false); $(a, c) }, a)) : a.oFeatures.bServerSide || (E(a, !1), $(a))
    } 
} function $(a, b) { a._bInitComplete = !0; A(a, "aoInitComplete", "init", [a, b]) } function pa(a) {
    var b = j.defaults.oLanguage; !a.sEmptyTable && (a.sZeroRecords && "No data available in table" === b.sEmptyTable) && p(a, a, "sZeroRecords", "sEmptyTable"); !a.sLoadingRecords &&
(a.sZeroRecords && "Loading..." === b.sLoadingRecords) && p(a, a, "sZeroRecords", "sLoadingRecords")
} function ya(a) {
    if (a.oScroll.bInfinite) return null; var b = '<select size="1" ' + ('name="' + a.sTableId + '_length"') + ">", c, d, i = a.aLengthMenu; if (2 == i.length && "object" === typeof i[0] && "object" === typeof i[1]) { c = 0; for (d = i[0].length; c < d; c++) b += '<option value="' + i[0][c] + '">' + i[1][c] + "</option>" } else { c = 0; for (d = i.length; c < d; c++) b += '<option value="' + i[c] + '">' + i[c] + "</option>" } b += "</select>"; i = l.createElement("div"); a.aanFeatures.l ||
(i.id = a.sTableId + "_length"); i.className = a.oClasses.sLength; i.innerHTML = "<label>" + a.oLanguage.sLengthMenu.replace("_MENU_", b) + "</label>"; h('select option[value="' + a._iDisplayLength + '"]', i).attr("selected", !0); h("select", i).bind("change.DT", function () {
    var b = h(this).val(), i = a.aanFeatures.l; c = 0; for (d = i.length; c < d; c++) i[c] != this.parentNode && h("select", i[c]).val(b); a._iDisplayLength = parseInt(b, 10); y(a); if (a.fnDisplayEnd() == a.fnRecordsDisplay()) {
        a._iDisplayStart = a.fnDisplayEnd() - a._iDisplayLength; if (a._iDisplayStart <
0) a._iDisplayStart = 0
    } if (a._iDisplayLength == -1) a._iDisplayStart = 0; x(a)
}); h("select", i).attr("aria-controls", a.sTableId); return i
} function y(a) { a._iDisplayEnd = !1 === a.oFeatures.bPaginate ? a.aiDisplay.length : a._iDisplayStart + a._iDisplayLength > a.aiDisplay.length || -1 == a._iDisplayLength ? a.aiDisplay.length : a._iDisplayStart + a._iDisplayLength } function Da(a) {
    if (a.oScroll.bInfinite) return null; var b = l.createElement("div"); b.className = a.oClasses.sPaging + a.sPaginationType; j.ext.oPagination[a.sPaginationType].fnInit(a,
b, function (a) { y(a); x(a) }); a.aanFeatures.p || a.aoDrawCallback.push({ fn: function (a) { j.ext.oPagination[a.sPaginationType].fnUpdate(a, function (a) { y(a); x(a) }) }, sName: "pagination" }); return b
} function qa(a, b) {
    var c = a._iDisplayStart; if ("number" === typeof b) a._iDisplayStart = b * a._iDisplayLength, a._iDisplayStart > a.fnRecordsDisplay() && (a._iDisplayStart = 0); else if ("first" == b) a._iDisplayStart = 0; else if ("previous" == b) a._iDisplayStart = 0 <= a._iDisplayLength ? a._iDisplayStart - a._iDisplayLength : 0, 0 > a._iDisplayStart && (a._iDisplayStart =
0); else if ("next" == b) 0 <= a._iDisplayLength ? a._iDisplayStart + a._iDisplayLength < a.fnRecordsDisplay() && (a._iDisplayStart += a._iDisplayLength) : a._iDisplayStart = 0; else if ("last" == b) if (0 <= a._iDisplayLength) { var d = parseInt((a.fnRecordsDisplay() - 1) / a._iDisplayLength, 10) + 1; a._iDisplayStart = (d - 1) * a._iDisplayLength } else a._iDisplayStart = 0; else D(a, 0, "Unknown paging action: " + b); h(a.oInstance).trigger("page", a); return c != a._iDisplayStart
} function Aa(a) {
    var b = l.createElement("div"); a.aanFeatures.r || (b.id = a.sTableId +
"_processing"); b.innerHTML = a.oLanguage.sProcessing; b.className = a.oClasses.sProcessing; a.nTable.parentNode.insertBefore(b, a.nTable); return b
} function E(a, b) { if (a.oFeatures.bProcessing) for (var c = a.aanFeatures.r, d = 0, i = c.length; d < i; d++) c[d].style.visibility = b ? "visible" : "hidden"; h(a.oInstance).trigger("processing", [a, b]) } function Ba(a) {
    if ("" === a.oScroll.sX && "" === a.oScroll.sY) return a.nTable; var b = l.createElement("div"), c = l.createElement("div"), d = l.createElement("div"), i = l.createElement("div"), f = l.createElement("div"),
g = l.createElement("div"), e = a.nTable.cloneNode(!1), j = a.nTable.cloneNode(!1), o = a.nTable.getElementsByTagName("thead")[0], k = 0 === a.nTable.getElementsByTagName("tfoot").length ? null : a.nTable.getElementsByTagName("tfoot")[0], m = a.oClasses; c.appendChild(d); f.appendChild(g); i.appendChild(a.nTable); b.appendChild(c); b.appendChild(i); d.appendChild(e); e.appendChild(o); null !== k && (b.appendChild(f), g.appendChild(j), j.appendChild(k)); b.className = m.sScrollWrapper; c.className = m.sScrollHead; d.className = m.sScrollHeadInner;
    i.className = m.sScrollBody; f.className = m.sScrollFoot; g.className = m.sScrollFootInner; a.oScroll.bAutoCss && (c.style.overflow = "hidden", c.style.position = "relative", f.style.overflow = "hidden", i.style.overflow = "auto"); c.style.border = "0"; c.style.width = "100%"; f.style.border = "0"; d.style.width = "" !== a.oScroll.sXInner ? a.oScroll.sXInner : "100%"; e.removeAttribute("id"); e.style.marginLeft = "0"; a.nTable.style.marginLeft = "0"; null !== k && (j.removeAttribute("id"), j.style.marginLeft = "0"); d = h(a.nTable).children("caption"); 0 <
d.length && (d = d[0], "top" === d._captionSide ? e.appendChild(d) : "bottom" === d._captionSide && k && j.appendChild(d)); "" !== a.oScroll.sX && (c.style.width = q(a.oScroll.sX), i.style.width = q(a.oScroll.sX), null !== k && (f.style.width = q(a.oScroll.sX)), h(i).scroll(function () { c.scrollLeft = this.scrollLeft; if (k !== null) f.scrollLeft = this.scrollLeft })); "" !== a.oScroll.sY && (i.style.height = q(a.oScroll.sY)); a.aoDrawCallback.push({ fn: La, sName: "scrolling" }); a.oScroll.bInfinite && h(i).scroll(function () {
    if (!a.bDrawing && h(this).scrollTop() !==
0 && h(this).scrollTop() + h(this).height() > h(a.nTable).height() - a.oScroll.iLoadGap && a.fnDisplayEnd() < a.fnRecordsDisplay()) { qa(a, "next"); y(a); x(a) } 
}); a.nScrollHead = c; a.nScrollFoot = f; return b
} function La(a) {
    var b = a.nScrollHead.getElementsByTagName("div")[0], c = b.getElementsByTagName("table")[0], d = a.nTable.parentNode, i, f, g, e, j, o, k, m, p = [], n = [], l = null !== a.nTFoot ? a.nScrollFoot.getElementsByTagName("div")[0] : null, R = null !== a.nTFoot ? l.getElementsByTagName("table")[0] : null, r = a.oBrowser.bScrollOversize, s = function (a) {
        k =
a.style; k.paddingTop = "0"; k.paddingBottom = "0"; k.borderTopWidth = "0"; k.borderBottomWidth = "0"; k.height = 0
    }; h(a.nTable).children("thead, tfoot").remove(); i = h(a.nTHead).clone()[0]; a.nTable.insertBefore(i, a.nTable.childNodes[0]); g = a.nTHead.getElementsByTagName("tr"); e = i.getElementsByTagName("tr"); null !== a.nTFoot && (j = h(a.nTFoot).clone()[0], a.nTable.insertBefore(j, a.nTable.childNodes[1]), o = a.nTFoot.getElementsByTagName("tr"), j = j.getElementsByTagName("tr")); "" === a.oScroll.sX && (d.style.width = "100%", b.parentNode.style.width =
"100%"); var t = N(a, i); i = 0; for (f = t.length; i < f; i++) m = G(a, i), t[i].style.width = a.aoColumns[m].sWidth; null !== a.nTFoot && C(function (a) { a.style.width = "" }, j); a.oScroll.bCollapse && "" !== a.oScroll.sY && (d.style.height = d.offsetHeight + a.nTHead.offsetHeight + "px"); i = h(a.nTable).outerWidth(); if ("" === a.oScroll.sX) { if (a.nTable.style.width = "100%", r && (h("tbody", d).height() > d.offsetHeight || "scroll" == h(d).css("overflow-y"))) a.nTable.style.width = q(h(a.nTable).outerWidth() - a.oScroll.iBarWidth) } else "" !== a.oScroll.sXInner ? a.nTable.style.width =
q(a.oScroll.sXInner) : i == h(d).width() && h(d).height() < h(a.nTable).height() ? (a.nTable.style.width = q(i - a.oScroll.iBarWidth), h(a.nTable).outerWidth() > i - a.oScroll.iBarWidth && (a.nTable.style.width = q(i))) : a.nTable.style.width = q(i); i = h(a.nTable).outerWidth(); C(s, e); C(function (a) { p.push(q(h(a).width())) }, e); C(function (a, b) { a.style.width = p[b] }, g); h(e).height(0); null !== a.nTFoot && (C(s, j), C(function (a) { n.push(q(h(a).width())) }, j), C(function (a, b) { a.style.width = n[b] }, o), h(j).height(0)); C(function (a, b) {
    a.innerHTML =
""; a.style.width = p[b]
}, e); null !== a.nTFoot && C(function (a, b) { a.innerHTML = ""; a.style.width = n[b] }, j); if (h(a.nTable).outerWidth() < i) {
        g = d.scrollHeight > d.offsetHeight || "scroll" == h(d).css("overflow-y") ? i + a.oScroll.iBarWidth : i; if (r && (d.scrollHeight > d.offsetHeight || "scroll" == h(d).css("overflow-y"))) a.nTable.style.width = q(g - a.oScroll.iBarWidth); d.style.width = q(g); a.nScrollHead.style.width = q(g); null !== a.nTFoot && (a.nScrollFoot.style.width = q(g)); "" === a.oScroll.sX ? D(a, 1, "The table cannot fit into the current element which will cause column misalignment. The table has been drawn at its minimum possible width.") :
"" !== a.oScroll.sXInner && D(a, 1, "The table cannot fit into the current element which will cause column misalignment. Increase the sScrollXInner value or remove it to allow automatic calculation")
    } else d.style.width = q("100%"), a.nScrollHead.style.width = q("100%"), null !== a.nTFoot && (a.nScrollFoot.style.width = q("100%")); "" === a.oScroll.sY && r && (d.style.height = q(a.nTable.offsetHeight + a.oScroll.iBarWidth)); "" !== a.oScroll.sY && a.oScroll.bCollapse && (d.style.height = q(a.oScroll.sY), r = "" !== a.oScroll.sX && a.nTable.offsetWidth >
d.offsetWidth ? a.oScroll.iBarWidth : 0, a.nTable.offsetHeight < d.offsetHeight && (d.style.height = q(a.nTable.offsetHeight + r))); r = h(a.nTable).outerWidth(); c.style.width = q(r); b.style.width = q(r); c = h(a.nTable).height() > d.clientHeight || "scroll" == h(d).css("overflow-y"); b.style.paddingRight = c ? a.oScroll.iBarWidth + "px" : "0px"; null !== a.nTFoot && (R.style.width = q(r), l.style.width = q(r), l.style.paddingRight = c ? a.oScroll.iBarWidth + "px" : "0px"); h(d).scroll(); if (a.bSorted || a.bFiltered) d.scrollTop = 0
} function C(a, b, c) {
    for (var d =
0, i = 0, f = b.length, g, e; i < f; ) { g = b[i].firstChild; for (e = c ? c[i].firstChild : null; g; ) 1 === g.nodeType && (c ? a(g, e, d) : a(g, d), d++), g = g.nextSibling, e = c ? e.nextSibling : null; i++ } 
} function Ma(a, b) { if (!a || null === a || "" === a) return 0; b || (b = l.body); var c, d = l.createElement("div"); d.style.width = q(a); b.appendChild(d); c = d.offsetWidth; b.removeChild(d); return c } function da(a) {
    var b = 0, c, d = 0, i = a.aoColumns.length, f, e, j = h("th", a.nTHead), o = a.nTable.getAttribute("width"); e = a.nTable.parentNode; for (f = 0; f < i; f++) a.aoColumns[f].bVisible &&
(d++, null !== a.aoColumns[f].sWidth && (c = Ma(a.aoColumns[f].sWidthOrig, e), null !== c && (a.aoColumns[f].sWidth = q(c)), b++)); if (i == j.length && 0 === b && d == i && "" === a.oScroll.sX && "" === a.oScroll.sY) for (f = 0; f < a.aoColumns.length; f++) c = h(j[f]).width(), null !== c && (a.aoColumns[f].sWidth = q(c)); else {
        b = a.nTable.cloneNode(!1); f = a.nTHead.cloneNode(!0); d = l.createElement("tbody"); c = l.createElement("tr"); b.removeAttribute("id"); b.appendChild(f); null !== a.nTFoot && (b.appendChild(a.nTFoot.cloneNode(!0)), C(function (a) {
            a.style.width =
""
        }, b.getElementsByTagName("tr"))); b.appendChild(d); d.appendChild(c); d = h("thead th", b); 0 === d.length && (d = h("tbody tr:eq(0)>td", b)); j = N(a, f); for (f = d = 0; f < i; f++) { var k = a.aoColumns[f]; k.bVisible && null !== k.sWidthOrig && "" !== k.sWidthOrig ? j[f - d].style.width = q(k.sWidthOrig) : k.bVisible ? j[f - d].style.width = "" : d++ } for (f = 0; f < i; f++) a.aoColumns[f].bVisible && (d = Na(a, f), null !== d && (d = d.cloneNode(!0), "" !== a.aoColumns[f].sContentPadding && (d.innerHTML += a.aoColumns[f].sContentPadding), c.appendChild(d))); e.appendChild(b);
        "" !== a.oScroll.sX && "" !== a.oScroll.sXInner ? b.style.width = q(a.oScroll.sXInner) : "" !== a.oScroll.sX ? (b.style.width = "", h(b).width() < e.offsetWidth && (b.style.width = q(e.offsetWidth))) : "" !== a.oScroll.sY ? b.style.width = q(e.offsetWidth) : o && (b.style.width = q(o)); b.style.visibility = "hidden"; Oa(a, b); i = h("tbody tr:eq(0)", b).children(); 0 === i.length && (i = N(a, h("thead", b)[0])); if ("" !== a.oScroll.sX) {
            for (f = d = e = 0; f < a.aoColumns.length; f++) a.aoColumns[f].bVisible && (e = null === a.aoColumns[f].sWidthOrig ? e + h(i[d]).outerWidth() :
e + (parseInt(a.aoColumns[f].sWidth.replace("px", ""), 10) + (h(i[d]).outerWidth() - h(i[d]).width())), d++); b.style.width = q(e); a.nTable.style.width = q(e)
        } for (f = d = 0; f < a.aoColumns.length; f++) a.aoColumns[f].bVisible && (e = h(i[d]).width(), null !== e && 0 < e && (a.aoColumns[f].sWidth = q(e)), d++); i = h(b).css("width"); a.nTable.style.width = -1 !== i.indexOf("%") ? i : q(h(b).outerWidth()); b.parentNode.removeChild(b)
    } o && (a.nTable.style.width = q(o))
} function Oa(a, b) {
    "" === a.oScroll.sX && "" !== a.oScroll.sY ? (h(b).width(), b.style.width = q(h(b).outerWidth() -
a.oScroll.iBarWidth)) : "" !== a.oScroll.sX && (b.style.width = q(h(b).outerWidth()))
} function Na(a, b) { var c = Pa(a, b); if (0 > c) return null; if (null === a.aoData[c].nTr) { var d = l.createElement("td"); d.innerHTML = v(a, c, b, ""); return d } return J(a, c)[b] } function Pa(a, b) { for (var c = -1, d = -1, i = 0; i < a.aoData.length; i++) { var e = v(a, i, b, "display") + "", e = e.replace(/<.*?>/g, ""); e.length > c && (c = e.length, d = i) } return d } function q(a) {
    if (null === a) return "0px"; if ("number" == typeof a) return 0 > a ? "0px" : a + "px"; var b = a.charCodeAt(a.length - 1);
    return 48 > b || 57 < b ? a : a + "px"
} function Qa() { var a = l.createElement("p"), b = a.style; b.width = "100%"; b.height = "200px"; b.padding = "0px"; var c = l.createElement("div"), b = c.style; b.position = "absolute"; b.top = "0px"; b.left = "0px"; b.visibility = "hidden"; b.width = "200px"; b.height = "150px"; b.padding = "0px"; b.overflow = "hidden"; c.appendChild(a); l.body.appendChild(c); b = a.offsetWidth; c.style.overflow = "scroll"; a = a.offsetWidth; b == a && (a = c.clientWidth); l.body.removeChild(c); return b - a } function O(a, b) {
    var c, d, i, e, g, k, o = [], m = [], p =
j.ext.oSort, l = a.aoData, q = a.aoColumns, G = a.oLanguage.oAria; if (!a.oFeatures.bServerSide && (0 !== a.aaSorting.length || null !== a.aaSortingFixed)) {
        o = null !== a.aaSortingFixed ? a.aaSortingFixed.concat(a.aaSorting) : a.aaSorting.slice(); for (c = 0; c < o.length; c++) if (d = o[c][0], i = R(a, d), e = a.aoColumns[d].sSortDataType, j.ext.afnSortData[e]) if (g = j.ext.afnSortData[e].call(a.oInstance, a, d, i), g.length === l.length) { i = 0; for (e = l.length; i < e; i++) F(a, i, d, g[i]) } else D(a, 0, "Returned data sort array (col " + d + ") is the wrong length"); c =
0; for (d = a.aiDisplayMaster.length; c < d; c++) m[a.aiDisplayMaster[c]] = c; var r = o.length, s; c = 0; for (d = l.length; c < d; c++) for (i = 0; i < r; i++) { s = q[o[i][0]].aDataSort; g = 0; for (k = s.length; g < k; g++) e = q[s[g]].sType, e = p[(e ? e : "string") + "-pre"], l[c]._aSortData[s[g]] = e ? e(v(a, c, s[g], "sort")) : v(a, c, s[g], "sort") } a.aiDisplayMaster.sort(function (a, b) {
    var c, d, e, i, f; for (c = 0; c < r; c++) {
        f = q[o[c][0]].aDataSort; d = 0; for (e = f.length; d < e; d++) if (i = q[f[d]].sType, i = p[(i ? i : "string") + "-" + o[c][1]](l[a]._aSortData[f[d]], l[b]._aSortData[f[d]]), 0 !==
i) return i
    } return p["numeric-asc"](m[a], m[b])
})
    } (b === n || b) && !a.oFeatures.bDeferRender && P(a); c = 0; for (d = a.aoColumns.length; c < d; c++) e = q[c].sTitle.replace(/<.*?>/g, ""), i = q[c].nTh, i.removeAttribute("aria-sort"), i.removeAttribute("aria-label"), q[c].bSortable ? 0 < o.length && o[0][0] == c ? (i.setAttribute("aria-sort", "asc" == o[0][1] ? "ascending" : "descending"), i.setAttribute("aria-label", e + ("asc" == (q[c].asSorting[o[0][2] + 1] ? q[c].asSorting[o[0][2] + 1] : q[c].asSorting[0]) ? G.sSortAscending : G.sSortDescending))) : i.setAttribute("aria-label",
e + ("asc" == q[c].asSorting[0] ? G.sSortAscending : G.sSortDescending)) : i.setAttribute("aria-label", e); a.bSorted = !0; h(a.oInstance).trigger("sort", a); a.oFeatures.bFilter ? K(a, a.oPreviousSearch, 1) : (a.aiDisplay = a.aiDisplayMaster.slice(), a._iDisplayStart = 0, y(a), x(a))
} function ia(a, b, c, d) {
    Ra(b, {}, function (b) {
        if (!1 !== a.aoColumns[c].bSortable) {
            var e = function () {
                var d, e; if (b.shiftKey) {
                    for (var f = !1, h = 0; h < a.aaSorting.length; h++) if (a.aaSorting[h][0] == c) {
                        f = !0; d = a.aaSorting[h][0]; e = a.aaSorting[h][2] + 1; a.aoColumns[d].asSorting[e] ?
(a.aaSorting[h][1] = a.aoColumns[d].asSorting[e], a.aaSorting[h][2] = e) : a.aaSorting.splice(h, 1); break
                    } !1 === f && a.aaSorting.push([c, a.aoColumns[c].asSorting[0], 0])
                } else 1 == a.aaSorting.length && a.aaSorting[0][0] == c ? (d = a.aaSorting[0][0], e = a.aaSorting[0][2] + 1, a.aoColumns[d].asSorting[e] || (e = 0), a.aaSorting[0][1] = a.aoColumns[d].asSorting[e], a.aaSorting[0][2] = e) : (a.aaSorting.splice(0, a.aaSorting.length), a.aaSorting.push([c, a.aoColumns[c].asSorting[0], 0])); O(a)
            }; a.oFeatures.bProcessing ? (E(a, !0), setTimeout(function () {
                e();
                a.oFeatures.bServerSide || E(a, !1)
            }, 0)) : e(); "function" == typeof d && d(a)
        } 
    })
} function P(a) {
    var b, c, d, e, f, g = a.aoColumns.length, j = a.oClasses; for (b = 0; b < g; b++) a.aoColumns[b].bSortable && h(a.aoColumns[b].nTh).removeClass(j.sSortAsc + " " + j.sSortDesc + " " + a.aoColumns[b].sSortingClass); c = null !== a.aaSortingFixed ? a.aaSortingFixed.concat(a.aaSorting) : a.aaSorting.slice(); for (b = 0; b < a.aoColumns.length; b++) if (a.aoColumns[b].bSortable) {
        f = a.aoColumns[b].sSortingClass; e = -1; for (d = 0; d < c.length; d++) if (c[d][0] == b) {
            f = "asc" == c[d][1] ?
j.sSortAsc : j.sSortDesc; e = d; break
        } h(a.aoColumns[b].nTh).addClass(f); a.bJUI && (f = h("span." + j.sSortIcon, a.aoColumns[b].nTh), f.removeClass(j.sSortJUIAsc + " " + j.sSortJUIDesc + " " + j.sSortJUI + " " + j.sSortJUIAscAllowed + " " + j.sSortJUIDescAllowed), f.addClass(-1 == e ? a.aoColumns[b].sSortingClassJUI : "asc" == c[e][1] ? j.sSortJUIAsc : j.sSortJUIDesc))
    } else h(a.aoColumns[b].nTh).addClass(a.aoColumns[b].sSortingClass); f = j.sSortColumn; if (a.oFeatures.bSort && a.oFeatures.bSortClasses) {
        a = J(a); e = []; for (b = 0; b < g; b++) e.push(""); b = 0;
        for (d = 1; b < c.length; b++) j = parseInt(c[b][0], 10), e[j] = f + d, 3 > d && d++; f = RegExp(f + "[123]"); var o; b = 0; for (c = a.length; b < c; b++) j = b % g, d = a[b].className, o = e[j], j = d.replace(f, o), j != d ? a[b].className = h.trim(j) : 0 < o.length && -1 == d.indexOf(o) && (a[b].className = d + " " + o)
    } 
} function ra(a) {
    if (a.oFeatures.bStateSave && !a.bDestroying) {
        var b, c; b = a.oScroll.bInfinite; var d = { iCreate: (new Date).getTime(), iStart: b ? 0 : a._iDisplayStart, iEnd: b ? a._iDisplayLength : a._iDisplayEnd, iLength: a._iDisplayLength, aaSorting: h.extend(!0, [], a.aaSorting),
            oSearch: h.extend(!0, {}, a.oPreviousSearch), aoSearchCols: h.extend(!0, [], a.aoPreSearchCols), abVisCols: []
        }; b = 0; for (c = a.aoColumns.length; b < c; b++) d.abVisCols.push(a.aoColumns[b].bVisible); A(a, "aoStateSaveParams", "stateSaveParams", [a, d]); a.fnStateSave.call(a.oInstance, a, d)
    } 
} function Sa(a, b) {
    if (a.oFeatures.bStateSave) {
        var c = a.fnStateLoad.call(a.oInstance, a); if (c) {
            var d = A(a, "aoStateLoadParams", "stateLoadParams", [a, c]); if (-1 === h.inArray(!1, d)) {
                a.oLoadedState = h.extend(!0, {}, c); a._iDisplayStart = c.iStart; a.iInitDisplayStart =
c.iStart; a._iDisplayEnd = c.iEnd; a._iDisplayLength = c.iLength; a.aaSorting = c.aaSorting.slice(); a.saved_aaSorting = c.aaSorting.slice(); h.extend(a.oPreviousSearch, c.oSearch); h.extend(!0, a.aoPreSearchCols, c.aoSearchCols); b.saved_aoColumns = []; for (d = 0; d < c.abVisCols.length; d++) b.saved_aoColumns[d] = {}, b.saved_aoColumns[d].bVisible = c.abVisCols[d]; A(a, "aoStateLoaded", "stateLoaded", [a, c])
            } 
        } 
    } 
} function s(a) { for (var b = 0; b < j.settings.length; b++) if (j.settings[b].nTable === a) return j.settings[b]; return null } function T(a) {
    for (var b =
[], a = a.aoData, c = 0, d = a.length; c < d; c++) null !== a[c].nTr && b.push(a[c].nTr); return b
} function J(a, b) { var c = [], d, e, f, g, h, j; e = 0; var o = a.aoData.length; b !== n && (e = b, o = b + 1); for (f = e; f < o; f++) if (j = a.aoData[f], null !== j.nTr) { e = []; for (d = j.nTr.firstChild; d; ) g = d.nodeName.toLowerCase(), ("td" == g || "th" == g) && e.push(d), d = d.nextSibling; g = d = 0; for (h = a.aoColumns.length; g < h; g++) a.aoColumns[g].bVisible ? c.push(e[g - d]) : (c.push(j._anHidden[g]), d++) } return c } function D(a, b, c) {
    a = null === a ? "DataTables warning: " + c : "DataTables warning (table id = '" +
a.sTableId + "'): " + c; if (0 === b) if ("alert" == j.ext.sErrMode) alert(a); else throw Error(a); else X.console && console.log && console.log(a)
} function p(a, b, c, d) { d === n && (d = c); b[c] !== n && (a[d] = b[c]) } function Ta(a, b) { var c, d; for (d in b) b.hasOwnProperty(d) && (c = b[d], "object" === typeof e[d] && null !== c && !1 === h.isArray(c) ? h.extend(!0, a[d], c) : a[d] = c); return a } function Ra(a, b, c) { h(a).bind("click.DT", b, function (b) { a.blur(); c(b) }).bind("keypress.DT", b, function (a) { 13 === a.which && c(a) }).bind("selectstart.DT", function () { return !1 }) }
            function z(a, b, c, d) { c && a[b].push({ fn: c, sName: d }) } function A(a, b, c, d) { for (var b = a[b], e = [], f = b.length - 1; 0 <= f; f--) e.push(b[f].fn.apply(a.oInstance, d)); null !== c && h(a.oInstance).trigger(c, d); return e } function Ua(a) {
                var b = h('<div style="position:absolute; top:0; left:0; height:1px; width:1px; overflow:hidden"><div style="position:absolute; top:1px; left:1px; width:100px; overflow:scroll;"><div id="DT_BrowserTest" style="width:100%; height:10px;"></div></div></div>')[0]; l.body.appendChild(b); a.oBrowser.bScrollOversize =
100 === h("#DT_BrowserTest", b)[0].offsetWidth ? !0 : !1; l.body.removeChild(b)
            } function Va(a) { return function () { var b = [s(this[j.ext.iApiIndex])].concat(Array.prototype.slice.call(arguments)); return j.ext.oApi[a].apply(this, b) } } var U = /\[.*?\]$/, Wa = X.JSON ? JSON.stringify : function (a) {
                var b = typeof a; if ("object" !== b || null === a) return "string" === b && (a = '"' + a + '"'), a + ""; var c, d, e = [], f = h.isArray(a); for (c in a) d = a[c], b = typeof d, "string" === b ? d = '"' + d + '"' : "object" === b && null !== d && (d = Wa(d)), e.push((f ? "" : '"' + c + '":') + d); return (f ?
"[" : "{") + e + (f ? "]" : "}")
            }; this.$ = function (a, b) {
                var c, d, e = [], f; d = s(this[j.ext.iApiIndex]); var g = d.aoData, o = d.aiDisplay, k = d.aiDisplayMaster; b || (b = {}); b = h.extend({}, { filter: "none", order: "current", page: "all" }, b); if ("current" == b.page) { c = d._iDisplayStart; for (d = d.fnDisplayEnd(); c < d; c++) (f = g[o[c]].nTr) && e.push(f) } else if ("current" == b.order && "none" == b.filter) { c = 0; for (d = k.length; c < d; c++) (f = g[k[c]].nTr) && e.push(f) } else if ("current" == b.order && "applied" == b.filter) { c = 0; for (d = o.length; c < d; c++) (f = g[o[c]].nTr) && e.push(f) } else if ("original" ==
b.order && "none" == b.filter) { c = 0; for (d = g.length; c < d; c++) (f = g[c].nTr) && e.push(f) } else if ("original" == b.order && "applied" == b.filter) { c = 0; for (d = g.length; c < d; c++) f = g[c].nTr, -1 !== h.inArray(c, o) && f && e.push(f) } else D(d, 1, "Unknown selection options"); e = h(e); c = e.filter(a); e = e.find(a); return h([].concat(h.makeArray(c), h.makeArray(e)))
            }; this._ = function (a, b) { var c = [], d, e, f = this.$(a, b); d = 0; for (e = f.length; d < e; d++) c.push(this.fnGetData(f[d])); return c }; this.fnAddData = function (a, b) {
                if (0 === a.length) return []; var c = [],
d, e = s(this[j.ext.iApiIndex]); if ("object" === typeof a[0] && null !== a[0]) for (var f = 0; f < a.length; f++) { d = H(e, a[f]); if (-1 == d) return c; c.push(d) } else { d = H(e, a); if (-1 == d) return c; c.push(d) } e.aiDisplay = e.aiDisplayMaster.slice(); (b === n || b) && aa(e); return c
            }; this.fnAdjustColumnSizing = function (a) { var b = s(this[j.ext.iApiIndex]); k(b); a === n || a ? this.fnDraw(!1) : ("" !== b.oScroll.sX || "" !== b.oScroll.sY) && this.oApi._fnScrollDraw(b) }; this.fnClearTable = function (a) { var b = s(this[j.ext.iApiIndex]); ga(b); (a === n || a) && x(b) }; this.fnClose =
function (a) { for (var b = s(this[j.ext.iApiIndex]), c = 0; c < b.aoOpenRows.length; c++) if (b.aoOpenRows[c].nParent == a) return (a = b.aoOpenRows[c].nTr.parentNode) && a.removeChild(b.aoOpenRows[c].nTr), b.aoOpenRows.splice(c, 1), 0; return 1 }; this.fnDeleteRow = function (a, b, c) {
    var d = s(this[j.ext.iApiIndex]), e, f, a = "object" === typeof a ? I(d, a) : a, g = d.aoData.splice(a, 1); e = 0; for (f = d.aoData.length; e < f; e++) null !== d.aoData[e].nTr && (d.aoData[e].nTr._DT_RowIndex = e); e = h.inArray(a, d.aiDisplay); d.asDataSearch.splice(e, 1); ha(d.aiDisplayMaster,
a); ha(d.aiDisplay, a); "function" === typeof b && b.call(this, d, g); d._iDisplayStart >= d.fnRecordsDisplay() && (d._iDisplayStart -= d._iDisplayLength, 0 > d._iDisplayStart && (d._iDisplayStart = 0)); if (c === n || c) y(d), x(d); return g
}; this.fnDestroy = function (a) {
    var b = s(this[j.ext.iApiIndex]), c = b.nTableWrapper.parentNode, d = b.nTBody, i, f, a = a === n ? !1 : a; b.bDestroying = !0; A(b, "aoDestroyCallback", "destroy", [b]); if (!a) { i = 0; for (f = b.aoColumns.length; i < f; i++) !1 === b.aoColumns[i].bVisible && this.fnSetColumnVis(i, !0) } h(b.nTableWrapper).find("*").andSelf().unbind(".DT");
    h("tbody>tr>td." + b.oClasses.sRowEmpty, b.nTable).parent().remove(); b.nTable != b.nTHead.parentNode && (h(b.nTable).children("thead").remove(), b.nTable.appendChild(b.nTHead)); b.nTFoot && b.nTable != b.nTFoot.parentNode && (h(b.nTable).children("tfoot").remove(), b.nTable.appendChild(b.nTFoot)); b.nTable.parentNode.removeChild(b.nTable); h(b.nTableWrapper).remove(); b.aaSorting = []; b.aaSortingFixed = []; P(b); h(T(b)).removeClass(b.asStripeClasses.join(" ")); h("th, td", b.nTHead).removeClass([b.oClasses.sSortable, b.oClasses.sSortableAsc,
b.oClasses.sSortableDesc, b.oClasses.sSortableNone].join(" ")); b.bJUI && (h("th span." + b.oClasses.sSortIcon + ", td span." + b.oClasses.sSortIcon, b.nTHead).remove(), h("th, td", b.nTHead).each(function () { var a = h("div." + b.oClasses.sSortJUIWrapper, this), c = a.contents(); h(this).append(c); a.remove() })); !a && b.nTableReinsertBefore ? c.insertBefore(b.nTable, b.nTableReinsertBefore) : a || c.appendChild(b.nTable); i = 0; for (f = b.aoData.length; i < f; i++) null !== b.aoData[i].nTr && d.appendChild(b.aoData[i].nTr); !0 === b.oFeatures.bAutoWidth &&
(b.nTable.style.width = q(b.sDestroyWidth)); if (f = b.asDestroyStripes.length) { a = h(d).children("tr"); for (i = 0; i < f; i++) a.filter(":nth-child(" + f + "n + " + i + ")").addClass(b.asDestroyStripes[i]) } i = 0; for (f = j.settings.length; i < f; i++) j.settings[i] == b && j.settings.splice(i, 1); e = b = null
}; this.fnDraw = function (a) { var b = s(this[j.ext.iApiIndex]); !1 === a ? (y(b), x(b)) : aa(b) }; this.fnFilter = function (a, b, c, d, e, f) {
    var g = s(this[j.ext.iApiIndex]); if (g.oFeatures.bFilter) {
        if (c === n || null === c) c = !1; if (d === n || null === d) d = !0; if (e === n || null ===
e) e = !0; if (f === n || null === f) f = !0; if (b === n || null === b) { if (K(g, { sSearch: a + "", bRegex: c, bSmart: d, bCaseInsensitive: f }, 1), e && g.aanFeatures.f) { b = g.aanFeatures.f; c = 0; for (d = b.length; c < d; c++) try { b[c]._DT_Input != l.activeElement && h(b[c]._DT_Input).val(a) } catch (o) { h(b[c]._DT_Input).val(a) } } } else h.extend(g.aoPreSearchCols[b], { sSearch: a + "", bRegex: c, bSmart: d, bCaseInsensitive: f }), K(g, g.oPreviousSearch, 1)
    } 
}; this.fnGetData = function (a, b) {
    var c = s(this[j.ext.iApiIndex]); if (a !== n) {
        var d = a; if ("object" === typeof a) {
            var e = a.nodeName.toLowerCase();
            "tr" === e ? d = I(c, a) : "td" === e && (d = I(c, a.parentNode), b = fa(c, d, a))
        } return b !== n ? v(c, d, b, "") : c.aoData[d] !== n ? c.aoData[d]._aData : null
    } return Z(c)
}; this.fnGetNodes = function (a) { var b = s(this[j.ext.iApiIndex]); return a !== n ? b.aoData[a] !== n ? b.aoData[a].nTr : null : T(b) }; this.fnGetPosition = function (a) { var b = s(this[j.ext.iApiIndex]), c = a.nodeName.toUpperCase(); return "TR" == c ? I(b, a) : "TD" == c || "TH" == c ? (c = I(b, a.parentNode), a = fa(b, c, a), [c, R(b, a), a]) : null }; this.fnIsOpen = function (a) {
    for (var b = s(this[j.ext.iApiIndex]), c = 0; c <
b.aoOpenRows.length; c++) if (b.aoOpenRows[c].nParent == a) return !0; return !1
}; this.fnOpen = function (a, b, c) { var d = s(this[j.ext.iApiIndex]), e = T(d); if (-1 !== h.inArray(a, e)) { this.fnClose(a); var e = l.createElement("tr"), f = l.createElement("td"); e.appendChild(f); f.className = c; f.colSpan = t(d); "string" === typeof b ? f.innerHTML = b : h(f).html(b); b = h("tr", d.nTBody); -1 != h.inArray(a, b) && h(e).insertAfter(a); d.aoOpenRows.push({ nTr: e, nParent: a }); return e } }; this.fnPageChange = function (a, b) {
    var c = s(this[j.ext.iApiIndex]); qa(c, a);
    y(c); (b === n || b) && x(c)
}; this.fnSetColumnVis = function (a, b, c) {
    var d = s(this[j.ext.iApiIndex]), e, f, g = d.aoColumns, h = d.aoData, o, m; if (g[a].bVisible != b) {
        if (b) { for (e = f = 0; e < a; e++) g[e].bVisible && f++; m = f >= t(d); if (!m) for (e = a; e < g.length; e++) if (g[e].bVisible) { o = e; break } e = 0; for (f = h.length; e < f; e++) null !== h[e].nTr && (m ? h[e].nTr.appendChild(h[e]._anHidden[a]) : h[e].nTr.insertBefore(h[e]._anHidden[a], J(d, e)[o])) } else { e = 0; for (f = h.length; e < f; e++) null !== h[e].nTr && (o = J(d, e)[a], h[e]._anHidden[a] = o, o.parentNode.removeChild(o)) } g[a].bVisible =
b; W(d, d.aoHeader); d.nTFoot && W(d, d.aoFooter); e = 0; for (f = d.aoOpenRows.length; e < f; e++) d.aoOpenRows[e].nTr.colSpan = t(d); if (c === n || c) k(d), x(d); ra(d)
    } 
}; this.fnSettings = function () { return s(this[j.ext.iApiIndex]) }; this.fnSort = function (a) { var b = s(this[j.ext.iApiIndex]); b.aaSorting = a; O(b) }; this.fnSortListener = function (a, b, c) { ia(s(this[j.ext.iApiIndex]), a, b, c) }; this.fnUpdate = function (a, b, c, d, e) {
    var f = s(this[j.ext.iApiIndex]), b = "object" === typeof b ? I(f, b) : b; if (h.isArray(a) && c === n) {
        f.aoData[b]._aData = a.slice();
        for (c = 0; c < f.aoColumns.length; c++) this.fnUpdate(v(f, b, c), b, c, !1, !1)
    } else if (h.isPlainObject(a) && c === n) { f.aoData[b]._aData = h.extend(!0, {}, a); for (c = 0; c < f.aoColumns.length; c++) this.fnUpdate(v(f, b, c), b, c, !1, !1) } else { F(f, b, c, a); var a = v(f, b, c, "display"), g = f.aoColumns[c]; null !== g.fnRender && (a = S(f, b, c), g.bUseRendered && F(f, b, c, a)); null !== f.aoData[b].nTr && (J(f, b)[c].innerHTML = a) } c = h.inArray(b, f.aiDisplay); f.asDataSearch[c] = na(f, Y(f, b, "filter", r(f, "bSearchable"))); (e === n || e) && k(f); (d === n || d) && aa(f); return 0
};
            this.fnVersionCheck = j.ext.fnVersionCheck; this.oApi = { _fnExternApiFunc: Va, _fnInitialise: ba, _fnInitComplete: $, _fnLanguageCompat: pa, _fnAddColumn: o, _fnColumnOptions: m, _fnAddData: H, _fnCreateTr: ea, _fnGatherData: ua, _fnBuildHead: va, _fnDrawHead: W, _fnDraw: x, _fnReDraw: aa, _fnAjaxUpdate: wa, _fnAjaxParameters: Ea, _fnAjaxUpdateDraw: Fa, _fnServerParams: ka, _fnAddOptionsHtml: xa, _fnFeatureHtmlTable: Ba, _fnScrollDraw: La, _fnAdjustColumnSizing: k, _fnFeatureHtmlFilter: za, _fnFilterComplete: K, _fnFilterCustom: Ia, _fnFilterColumn: Ha,
                _fnFilter: Ga, _fnBuildSearchArray: la, _fnBuildSearchRow: na, _fnFilterCreateSearch: ma, _fnDataToSearch: Ja, _fnSort: O, _fnSortAttachListener: ia, _fnSortingClasses: P, _fnFeatureHtmlPaginate: Da, _fnPageChange: qa, _fnFeatureHtmlInfo: Ca, _fnUpdateInfo: Ka, _fnFeatureHtmlLength: ya, _fnFeatureHtmlProcessing: Aa, _fnProcessingDisplay: E, _fnVisibleToColumnIndex: G, _fnColumnIndexToVisible: R, _fnNodeToDataIndex: I, _fnVisbleColumns: t, _fnCalculateEnd: y, _fnConvertToWidth: Ma, _fnCalculateColumnWidths: da, _fnScrollingWidthAdjust: Oa, _fnGetWidestNode: Na,
                _fnGetMaxLenString: Pa, _fnStringToCss: q, _fnDetectType: B, _fnSettingsFromNode: s, _fnGetDataMaster: Z, _fnGetTrNodes: T, _fnGetTdNodes: J, _fnEscapeRegex: oa, _fnDeleteIndex: ha, _fnReOrderIndex: u, _fnColumnOrdering: M, _fnLog: D, _fnClearTable: ga, _fnSaveState: ra, _fnLoadState: Sa, _fnCreateCookie: function (a, b, c, d, e) {
                    var f = new Date; f.setTime(f.getTime() + 1E3 * c); var c = X.location.pathname.split("/"), a = a + "_" + c.pop().replace(/[\/:]/g, "").toLowerCase(), g; null !== e ? (g = "function" === typeof h.parseJSON ? h.parseJSON(b) : eval("(" + b + ")"),
b = e(a, g, f.toGMTString(), c.join("/") + "/")) : b = a + "=" + encodeURIComponent(b) + "; expires=" + f.toGMTString() + "; path=" + c.join("/") + "/"; a = l.cookie.split(";"); e = b.split(";")[0].length; f = []; if (4096 < e + l.cookie.length + 10) {
                        for (var j = 0, o = a.length; j < o; j++) if (-1 != a[j].indexOf(d)) { var k = a[j].split("="); try { (g = eval("(" + decodeURIComponent(k[1]) + ")")) && g.iCreate && f.push({ name: k[0], time: g.iCreate }) } catch (m) { } } for (f.sort(function (a, b) { return b.time - a.time }); 4096 < e + l.cookie.length + 10; ) {
                            if (0 === f.length) return; d = f.pop(); l.cookie =
d.name + "=; expires=Thu, 01-Jan-1970 00:00:01 GMT; path=" + c.join("/") + "/"
                        } 
                    } l.cookie = b
                }, _fnReadCookie: function (a) { for (var b = X.location.pathname.split("/"), a = a + "_" + b[b.length - 1].replace(/[\/:]/g, "").toLowerCase() + "=", b = l.cookie.split(";"), c = 0; c < b.length; c++) { for (var d = b[c]; " " == d.charAt(0); ) d = d.substring(1, d.length); if (0 === d.indexOf(a)) return decodeURIComponent(d.substring(a.length, d.length)) } return null }, _fnDetectHeader: V, _fnGetUniqueThs: N, _fnScrollBarWidth: Qa, _fnApplyToChildren: C, _fnMap: p, _fnGetRowData: Y,
                _fnGetCellData: v, _fnSetCellData: F, _fnGetObjectDataFn: Q, _fnSetObjectDataFn: L, _fnApplyColumnDefs: ta, _fnBindAction: Ra, _fnExtend: Ta, _fnCallbackReg: z, _fnCallbackFire: A, _fnJsonString: Wa, _fnRender: S, _fnNodeToColumnIndex: fa, _fnInfoMacros: ja, _fnBrowserDetect: Ua, _fnGetColumns: r
            }; h.extend(j.ext.oApi, this.oApi); for (var sa in j.ext.oApi) sa && (this[sa] = Va(sa)); var ca = this; this.each(function () {
                var a = 0, b, c, d; c = this.getAttribute("id"); var i = !1, f = !1; if ("table" != this.nodeName.toLowerCase()) D(null, 0, "Attempted to initialise DataTables on a node which is not a table: " +
this.nodeName); else {
                    a = 0; for (b = j.settings.length; a < b; a++) { if (j.settings[a].nTable == this) { if (e === n || e.bRetrieve) return j.settings[a].oInstance; if (e.bDestroy) { j.settings[a].oInstance.fnDestroy(); break } else { D(j.settings[a], 0, "Cannot reinitialise DataTable.\n\nTo retrieve the DataTables object for this table, pass no arguments or see the docs for bRetrieve and bDestroy"); return } } if (j.settings[a].sTableId == this.id) { j.settings.splice(a, 1); break } } if (null === c || "" === c) this.id = c = "DataTables_Table_" + j.ext._oExternConfig.iNextUnique++;
                    var g = h.extend(!0, {}, j.models.oSettings, { nTable: this, oApi: ca.oApi, oInit: e, sDestroyWidth: h(this).width(), sInstance: c, sTableId: c }); j.settings.push(g); g.oInstance = 1 === ca.length ? ca : h(this).dataTable(); e || (e = {}); e.oLanguage && pa(e.oLanguage); e = Ta(h.extend(!0, {}, j.defaults), e); p(g.oFeatures, e, "bPaginate"); p(g.oFeatures, e, "bLengthChange"); p(g.oFeatures, e, "bFilter"); p(g.oFeatures, e, "bSort"); p(g.oFeatures, e, "bInfo"); p(g.oFeatures, e, "bProcessing"); p(g.oFeatures, e, "bAutoWidth"); p(g.oFeatures, e, "bSortClasses");
                    p(g.oFeatures, e, "bServerSide"); p(g.oFeatures, e, "bDeferRender"); p(g.oScroll, e, "sScrollX", "sX"); p(g.oScroll, e, "sScrollXInner", "sXInner"); p(g.oScroll, e, "sScrollY", "sY"); p(g.oScroll, e, "bScrollCollapse", "bCollapse"); p(g.oScroll, e, "bScrollInfinite", "bInfinite"); p(g.oScroll, e, "iScrollLoadGap", "iLoadGap"); p(g.oScroll, e, "bScrollAutoCss", "bAutoCss"); p(g, e, "asStripeClasses"); p(g, e, "asStripClasses", "asStripeClasses"); p(g, e, "fnServerData"); p(g, e, "fnFormatNumber"); p(g, e, "sServerMethod"); p(g, e, "aaSorting"); p(g,
e, "aaSortingFixed"); p(g, e, "aLengthMenu"); p(g, e, "sPaginationType"); p(g, e, "sAjaxSource"); p(g, e, "sAjaxDataProp"); p(g, e, "iCookieDuration"); p(g, e, "sCookiePrefix"); p(g, e, "sDom"); p(g, e, "bSortCellsTop"); p(g, e, "iTabIndex"); p(g, e, "oSearch", "oPreviousSearch"); p(g, e, "aoSearchCols", "aoPreSearchCols"); p(g, e, "iDisplayLength", "_iDisplayLength"); p(g, e, "bJQueryUI", "bJUI"); p(g, e, "fnCookieCallback"); p(g, e, "fnStateLoad"); p(g, e, "fnStateSave"); p(g.oLanguage, e, "fnInfoCallback"); z(g, "aoDrawCallback", e.fnDrawCallback, "user");
                    z(g, "aoServerParams", e.fnServerParams, "user"); z(g, "aoStateSaveParams", e.fnStateSaveParams, "user"); z(g, "aoStateLoadParams", e.fnStateLoadParams, "user"); z(g, "aoStateLoaded", e.fnStateLoaded, "user"); z(g, "aoRowCallback", e.fnRowCallback, "user"); z(g, "aoRowCreatedCallback", e.fnCreatedRow, "user"); z(g, "aoHeaderCallback", e.fnHeaderCallback, "user"); z(g, "aoFooterCallback", e.fnFooterCallback, "user"); z(g, "aoInitComplete", e.fnInitComplete, "user"); z(g, "aoPreDrawCallback", e.fnPreDrawCallback, "user"); g.oFeatures.bServerSide &&
g.oFeatures.bSort && g.oFeatures.bSortClasses ? z(g, "aoDrawCallback", P, "server_side_sort_classes") : g.oFeatures.bDeferRender && z(g, "aoDrawCallback", P, "defer_sort_classes"); e.bJQueryUI ? (h.extend(g.oClasses, j.ext.oJUIClasses), e.sDom === j.defaults.sDom && "lfrtip" === j.defaults.sDom && (g.sDom = '<"H"lfr>t<"F"ip>')) : h.extend(g.oClasses, j.ext.oStdClasses); h(this).addClass(g.oClasses.sTable); if ("" !== g.oScroll.sX || "" !== g.oScroll.sY) g.oScroll.iBarWidth = Qa(); g.iInitDisplayStart === n && (g.iInitDisplayStart = e.iDisplayStart,
g._iDisplayStart = e.iDisplayStart); e.bStateSave && (g.oFeatures.bStateSave = !0, Sa(g, e), z(g, "aoDrawCallback", ra, "state_save")); null !== e.iDeferLoading && (g.bDeferLoading = !0, a = h.isArray(e.iDeferLoading), g._iRecordsDisplay = a ? e.iDeferLoading[0] : e.iDeferLoading, g._iRecordsTotal = a ? e.iDeferLoading[1] : e.iDeferLoading); null !== e.aaData && (f = !0); "" !== e.oLanguage.sUrl ? (g.oLanguage.sUrl = e.oLanguage.sUrl, h.getJSON(g.oLanguage.sUrl, null, function (a) { pa(a); h.extend(true, g.oLanguage, e.oLanguage, a); ba(g) }), i = !0) : h.extend(!0,
g.oLanguage, e.oLanguage); null === e.asStripeClasses && (g.asStripeClasses = [g.oClasses.sStripeOdd, g.oClasses.sStripeEven]); b = g.asStripeClasses.length; g.asDestroyStripes = []; if (b) { c = !1; d = h(this).children("tbody").children("tr:lt(" + b + ")"); for (a = 0; a < b; a++) d.hasClass(g.asStripeClasses[a]) && (c = !0, g.asDestroyStripes.push(g.asStripeClasses[a])); c && d.removeClass(g.asStripeClasses.join(" ")) } c = []; a = this.getElementsByTagName("thead"); 0 !== a.length && (V(g.aoHeader, a[0]), c = N(g)); if (null === e.aoColumns) {
                        d = []; a = 0; for (b =
c.length; a < b; a++) d.push(null)
                    } else d = e.aoColumns; a = 0; for (b = d.length; a < b; a++) e.saved_aoColumns !== n && e.saved_aoColumns.length == b && (null === d[a] && (d[a] = {}), d[a].bVisible = e.saved_aoColumns[a].bVisible), o(g, c ? c[a] : null); ta(g, e.aoColumnDefs, d, function (a, b) { m(g, a, b) }); a = 0; for (b = g.aaSorting.length; a < b; a++) {
                        g.aaSorting[a][0] >= g.aoColumns.length && (g.aaSorting[a][0] = 0); var k = g.aoColumns[g.aaSorting[a][0]]; g.aaSorting[a][2] === n && (g.aaSorting[a][2] = 0); e.aaSorting === n && g.saved_aaSorting === n && (g.aaSorting[a][1] =
k.asSorting[0]); c = 0; for (d = k.asSorting.length; c < d; c++) if (g.aaSorting[a][1] == k.asSorting[c]) { g.aaSorting[a][2] = c; break } 
                    } P(g); Ua(g); a = h(this).children("caption").each(function () { this._captionSide = h(this).css("caption-side") }); b = h(this).children("thead"); 0 === b.length && (b = [l.createElement("thead")], this.appendChild(b[0])); g.nTHead = b[0]; b = h(this).children("tbody"); 0 === b.length && (b = [l.createElement("tbody")], this.appendChild(b[0])); g.nTBody = b[0]; g.nTBody.setAttribute("role", "alert"); g.nTBody.setAttribute("aria-live",
"polite"); g.nTBody.setAttribute("aria-relevant", "all"); b = h(this).children("tfoot"); if (0 === b.length && 0 < a.length && ("" !== g.oScroll.sX || "" !== g.oScroll.sY)) b = [l.createElement("tfoot")], this.appendChild(b[0]); 0 < b.length && (g.nTFoot = b[0], V(g.aoFooter, g.nTFoot)); if (f) for (a = 0; a < e.aaData.length; a++) H(g, e.aaData[a]); else ua(g); g.aiDisplay = g.aiDisplayMaster.slice(); g.bInitialised = !0; !1 === i && ba(g)
                } 
            }); ca = null; return this
        }; j.fnVersionCheck = function (e) {
            for (var h = function (e, h) { for (; e.length < h; ) e += "0"; return e }, m = j.ext.sVersion.split("."),
e = e.split("."), k = "", n = "", l = 0, t = e.length; l < t; l++) k += h(m[l], 3), n += h(e[l], 3); return parseInt(k, 10) >= parseInt(n, 10)
        }; j.fnIsDataTable = function (e) { for (var h = j.settings, m = 0; m < h.length; m++) if (h[m].nTable === e || h[m].nScrollHead === e || h[m].nScrollFoot === e) return !0; return !1 }; j.fnTables = function (e) { var o = []; jQuery.each(j.settings, function (j, k) { (!e || !0 === e && h(k.nTable).is(":visible")) && o.push(k.nTable) }); return o }; j.version = "1.9.4"; j.settings = []; j.models = {}; j.models.ext = { afnFiltering: [], afnSortData: [], aoFeatures: [],
            aTypes: [], fnVersionCheck: j.fnVersionCheck, iApiIndex: 0, ofnSearch: {}, oApi: {}, oStdClasses: {}, oJUIClasses: {}, oPagination: {}, oSort: {}, sVersion: j.version, sErrMode: "alert", _oExternConfig: { iNextUnique: 0}
        }; j.models.oSearch = { bCaseInsensitive: !0, sSearch: "", bRegex: !1, bSmart: !0 }; j.models.oRow = { nTr: null, _aData: [], _aSortData: [], _anHidden: [], _sRowStripe: "" }; j.models.oColumn = { aDataSort: null, asSorting: null, bSearchable: null, bSortable: null, bUseRendered: null, bVisible: null, _bAutoType: !0, fnCreatedCell: null, fnGetData: null,
            fnRender: null, fnSetData: null, mData: null, mRender: null, nTh: null, nTf: null, sClass: null, sContentPadding: null, sDefaultContent: null, sName: null, sSortDataType: "std", sSortingClass: null, sSortingClassJUI: null, sTitle: null, sType: null, sWidth: null, sWidthOrig: null
        }; j.defaults = { aaData: null, aaSorting: [[0, "asc"]], aaSortingFixed: null, aLengthMenu: [10, 25, 50, 100], aoColumns: null, aoColumnDefs: null, aoSearchCols: [], asStripeClasses: null, bAutoWidth: !0, bDeferRender: !1, bDestroy: !1, bFilter: !0, bInfo: !0, bJQueryUI: !1, bLengthChange: !0,
            bPaginate: !0, bProcessing: !1, bRetrieve: !1, bScrollAutoCss: !0, bScrollCollapse: !1, bScrollInfinite: !1, bServerSide: !1, bSort: !0, bSortCellsTop: !1, bSortClasses: !0, bStateSave: !1, fnCookieCallback: null, fnCreatedRow: null, fnDrawCallback: null, fnFooterCallback: null, fnFormatNumber: function (e) { if (1E3 > e) return e; for (var h = e + "", e = h.split(""), j = "", h = h.length, k = 0; k < h; k++) 0 === k % 3 && 0 !== k && (j = this.oLanguage.sInfoThousands + j), j = e[h - k - 1] + j; return j }, fnHeaderCallback: null, fnInfoCallback: null, fnInitComplete: null, fnPreDrawCallback: null,
            fnRowCallback: null, fnServerData: function (e, j, m, k) { k.jqXHR = h.ajax({ url: e, data: j, success: function (e) { e.sError && k.oApi._fnLog(k, 0, e.sError); h(k.oInstance).trigger("xhr", [k, e]); m(e) }, dataType: "json", cache: !1, type: k.sServerMethod, error: function (e, h) { "parsererror" == h && k.oApi._fnLog(k, 0, "DataTables warning: JSON data from server could not be parsed. This is caused by a JSON formatting error.") } }) }, fnServerParams: null, fnStateLoad: function (e) {
                var e = this.oApi._fnReadCookie(e.sCookiePrefix + e.sInstance), j; try {
                    j =
"function" === typeof h.parseJSON ? h.parseJSON(e) : eval("(" + e + ")")
                } catch (m) { j = null } return j
            }, fnStateLoadParams: null, fnStateLoaded: null, fnStateSave: function (e, h) { this.oApi._fnCreateCookie(e.sCookiePrefix + e.sInstance, this.oApi._fnJsonString(h), e.iCookieDuration, e.sCookiePrefix, e.fnCookieCallback) }, fnStateSaveParams: null, iCookieDuration: 7200, iDeferLoading: null, iDisplayLength: 10, iDisplayStart: 0, iScrollLoadGap: 100, iTabIndex: 0, oLanguage: { oAria: { sSortAscending: ": activate to sort column ascending", sSortDescending: ": activate to sort column descending" },
                oPaginate: { sFirst: "First", sLast: "Last", sNext: "Next", sPrevious: "Previous" }, sEmptyTable: "No data available in table", sInfo: "Showing _START_ to _END_ of _TOTAL_ entries", sInfoEmpty: "Showing 0 to 0 of 0 entries", sInfoFiltered: "(filtered from _MAX_ total entries)", sInfoPostFix: "", sInfoThousands: ",", sLengthMenu: "Show _MENU_ entries", sLoadingRecords: "Loading...", sProcessing: "Processing...", sSearch: "Search:", sUrl: "", sZeroRecords: "No matching records found"
            }, oSearch: h.extend({}, j.models.oSearch), sAjaxDataProp: "aaData",
            sAjaxSource: null, sCookiePrefix: "SpryMedia_DataTables_", sDom: "lfrtip", sPaginationType: "two_button", sScrollX: "", sScrollXInner: "", sScrollY: "", sServerMethod: "GET"
        }; j.defaults.columns = { aDataSort: null, asSorting: ["asc", "desc"], bSearchable: !0, bSortable: !0, bUseRendered: !0, bVisible: !0, fnCreatedCell: null, fnRender: null, iDataSort: -1, mData: null, mRender: null, sCellType: "td", sClass: "", sContentPadding: "", sDefaultContent: null, sName: "", sSortDataType: "std", sTitle: null, sType: null, sWidth: null }; j.models.oSettings = { oFeatures: { bAutoWidth: null,
            bDeferRender: null, bFilter: null, bInfo: null, bLengthChange: null, bPaginate: null, bProcessing: null, bServerSide: null, bSort: null, bSortClasses: null, bStateSave: null
        }, oScroll: { bAutoCss: null, bCollapse: null, bInfinite: null, iBarWidth: 0, iLoadGap: null, sX: null, sXInner: null, sY: null }, oLanguage: { fnInfoCallback: null }, oBrowser: { bScrollOversize: !1 }, aanFeatures: [], aoData: [], aiDisplay: [], aiDisplayMaster: [], aoColumns: [], aoHeader: [], aoFooter: [], asDataSearch: [], oPreviousSearch: {}, aoPreSearchCols: [], aaSorting: null, aaSortingFixed: null,
            asStripeClasses: null, asDestroyStripes: [], sDestroyWidth: 0, aoRowCallback: [], aoHeaderCallback: [], aoFooterCallback: [], aoDrawCallback: [], aoRowCreatedCallback: [], aoPreDrawCallback: [], aoInitComplete: [], aoStateSaveParams: [], aoStateLoadParams: [], aoStateLoaded: [], sTableId: "", nTable: null, nTHead: null, nTFoot: null, nTBody: null, nTableWrapper: null, bDeferLoading: !1, bInitialised: !1, aoOpenRows: [], sDom: null, sPaginationType: "two_button", iCookieDuration: 0, sCookiePrefix: "", fnCookieCallback: null, aoStateSave: [], aoStateLoad: [],
            oLoadedState: null, sAjaxSource: null, sAjaxDataProp: null, bAjaxDataGet: !0, jqXHR: null, fnServerData: null, aoServerParams: [], sServerMethod: null, fnFormatNumber: null, aLengthMenu: null, iDraw: 0, bDrawing: !1, iDrawError: -1, _iDisplayLength: 10, _iDisplayStart: 0, _iDisplayEnd: 10, _iRecordsTotal: 0, _iRecordsDisplay: 0, bJUI: null, oClasses: {}, bFiltered: !1, bSorted: !1, bSortCellsTop: null, oInit: null, aoDestroyCallback: [], fnRecordsTotal: function () { return this.oFeatures.bServerSide ? parseInt(this._iRecordsTotal, 10) : this.aiDisplayMaster.length },
            fnRecordsDisplay: function () { return this.oFeatures.bServerSide ? parseInt(this._iRecordsDisplay, 10) : this.aiDisplay.length }, fnDisplayEnd: function () { return this.oFeatures.bServerSide ? !1 === this.oFeatures.bPaginate || -1 == this._iDisplayLength ? this._iDisplayStart + this.aiDisplay.length : Math.min(this._iDisplayStart + this._iDisplayLength, this._iRecordsDisplay) : this._iDisplayEnd }, oInstance: null, sInstance: null, iTabIndex: 0, nScrollHead: null, nScrollFoot: null
        }; j.ext = h.extend(!0, {}, j.models.ext); h.extend(j.ext.oStdClasses,
{ sTable: "dataTable", sPagePrevEnabled: "paginate_enabled_previous", sPagePrevDisabled: "paginate_disabled_previous", sPageNextEnabled: "paginate_enabled_next", sPageNextDisabled: "paginate_disabled_next", sPageJUINext: "", sPageJUIPrev: "", sPageButton: "paginate_button", sPageButtonActive: "paginate_active", sPageButtonStaticDisabled: "paginate_button paginate_button_disabled", sPageFirst: "first", sPagePrevious: "previous", sPageNext: "next", sPageLast: "last", sStripeOdd: "odd", sStripeEven: "even", sRowEmpty: "dataTables_empty",
    sWrapper: "dataTables_wrapper", sFilter: "dataTables_filter", sInfo: "dataTables_info", sPaging: "dataTables_paginate paging_", sLength: "dataTables_length", sProcessing: "dataTables_processing", sSortAsc: "sorting_asc", sSortDesc: "sorting_desc", sSortable: "sorting", sSortableAsc: "sorting_asc_disabled", sSortableDesc: "sorting_desc_disabled", sSortableNone: "sorting_disabled", sSortColumn: "sorting_", sSortJUIAsc: "", sSortJUIDesc: "", sSortJUI: "", sSortJUIAscAllowed: "", sSortJUIDescAllowed: "", sSortJUIWrapper: "", sSortIcon: "",
    sScrollWrapper: "dataTables_scroll", sScrollHead: "dataTables_scrollHead", sScrollHeadInner: "dataTables_scrollHeadInner", sScrollBody: "dataTables_scrollBody", sScrollFoot: "dataTables_scrollFoot", sScrollFootInner: "dataTables_scrollFootInner", sFooterTH: "", sJUIHeader: "", sJUIFooter: ""
}); h.extend(j.ext.oJUIClasses, j.ext.oStdClasses, { sPagePrevEnabled: "fg-button ui-button ui-state-default ui-corner-left", sPagePrevDisabled: "fg-button ui-button ui-state-default ui-corner-left ui-state-disabled", sPageNextEnabled: "fg-button ui-button ui-state-default ui-corner-right",
    sPageNextDisabled: "fg-button ui-button ui-state-default ui-corner-right ui-state-disabled", sPageJUINext: "ui-icon ui-icon-circle-arrow-e", sPageJUIPrev: "ui-icon ui-icon-circle-arrow-w", sPageButton: "fg-button ui-button ui-state-default", sPageButtonActive: "fg-button ui-button ui-state-default ui-state-disabled", sPageButtonStaticDisabled: "fg-button ui-button ui-state-default ui-state-disabled", sPageFirst: "first ui-corner-tl ui-corner-bl", sPageLast: "last ui-corner-tr ui-corner-br", sPaging: "dataTables_paginate fg-buttonset ui-buttonset fg-buttonset-multi ui-buttonset-multi paging_",
    sSortAsc: "ui-state-default", sSortDesc: "ui-state-default", sSortable: "ui-state-default", sSortableAsc: "ui-state-default", sSortableDesc: "ui-state-default", sSortableNone: "ui-state-default", sSortJUIAsc: "css_right ui-icon ui-icon-triangle-1-n", sSortJUIDesc: "css_right ui-icon ui-icon-triangle-1-s", sSortJUI: "css_right ui-icon ui-icon-carat-2-n-s", sSortJUIAscAllowed: "css_right ui-icon ui-icon-carat-1-n", sSortJUIDescAllowed: "css_right ui-icon ui-icon-carat-1-s", sSortJUIWrapper: "DataTables_sort_wrapper", sSortIcon: "DataTables_sort_icon",
    sScrollHead: "dataTables_scrollHead ui-state-default", sScrollFoot: "dataTables_scrollFoot ui-state-default", sFooterTH: "ui-state-default", sJUIHeader: "fg-toolbar ui-toolbar ui-widget-header ui-corner-tl ui-corner-tr ui-helper-clearfix", sJUIFooter: "fg-toolbar ui-toolbar ui-widget-header ui-corner-bl ui-corner-br ui-helper-clearfix"
}); h.extend(j.ext.oPagination, { two_button: { fnInit: function (e, j, m) {
    var k = e.oLanguage.oPaginate, n = function (h) { e.oApi._fnPageChange(e, h.data.action) && m(e) }, k = !e.bJUI ? '<a class="' +
e.oClasses.sPagePrevDisabled + '" tabindex="' + e.iTabIndex + '" role="button">' + k.sPrevious + '</a><a class="' + e.oClasses.sPageNextDisabled + '" tabindex="' + e.iTabIndex + '" role="button">' + k.sNext + "</a>" : '<a class="' + e.oClasses.sPagePrevDisabled + '" tabindex="' + e.iTabIndex + '" role="button"><span class="' + e.oClasses.sPageJUIPrev + '"></span></a><a class="' + e.oClasses.sPageNextDisabled + '" tabindex="' + e.iTabIndex + '" role="button"><span class="' + e.oClasses.sPageJUINext + '"></span></a>'; h(j).append(k); var l = h("a", j),
k = l[0], l = l[1]; e.oApi._fnBindAction(k, { action: "previous" }, n); e.oApi._fnBindAction(l, { action: "next" }, n); e.aanFeatures.p || (j.id = e.sTableId + "_paginate", k.id = e.sTableId + "_previous", l.id = e.sTableId + "_next", k.setAttribute("aria-controls", e.sTableId), l.setAttribute("aria-controls", e.sTableId))
}, fnUpdate: function (e) {
    if (e.aanFeatures.p) for (var h = e.oClasses, j = e.aanFeatures.p, k, l = 0, n = j.length; l < n; l++) if (k = j[l].firstChild) k.className = 0 === e._iDisplayStart ? h.sPagePrevDisabled : h.sPagePrevEnabled, k = k.nextSibling,
k.className = e.fnDisplayEnd() == e.fnRecordsDisplay() ? h.sPageNextDisabled : h.sPageNextEnabled
} 
}, iFullNumbersShowPages: 5, full_numbers: { fnInit: function (e, j, m) {
    var k = e.oLanguage.oPaginate, l = e.oClasses, n = function (h) { e.oApi._fnPageChange(e, h.data.action) && m(e) }; h(j).append('<a  tabindex="' + e.iTabIndex + '" class="' + l.sPageButton + " " + l.sPageFirst + '">' + k.sFirst + '</a><a  tabindex="' + e.iTabIndex + '" class="' + l.sPageButton + " " + l.sPagePrevious + '">' + k.sPrevious + '</a><span></span><a tabindex="' + e.iTabIndex + '" class="' +
l.sPageButton + " " + l.sPageNext + '">' + k.sNext + '</a><a tabindex="' + e.iTabIndex + '" class="' + l.sPageButton + " " + l.sPageLast + '">' + k.sLast + "</a>"); var t = h("a", j), k = t[0], l = t[1], r = t[2], t = t[3]; e.oApi._fnBindAction(k, { action: "first" }, n); e.oApi._fnBindAction(l, { action: "previous" }, n); e.oApi._fnBindAction(r, { action: "next" }, n); e.oApi._fnBindAction(t, { action: "last" }, n); e.aanFeatures.p || (j.id = e.sTableId + "_paginate", k.id = e.sTableId + "_first", l.id = e.sTableId + "_previous", r.id = e.sTableId + "_next", t.id = e.sTableId + "_last")
},
    fnUpdate: function (e, o) {
        if (e.aanFeatures.p) {
            var m = j.ext.oPagination.iFullNumbersShowPages, k = Math.floor(m / 2), l = Math.ceil(e.fnRecordsDisplay() / e._iDisplayLength), n = Math.ceil(e._iDisplayStart / e._iDisplayLength) + 1, t = "", r, B = e.oClasses, u, M = e.aanFeatures.p, L = function (h) { e.oApi._fnBindAction(this, { page: h + r - 1 }, function (h) { e.oApi._fnPageChange(e, h.data.page); o(e); h.preventDefault() }) }; -1 === e._iDisplayLength ? n = k = r = 1 : l < m ? (r = 1, k = l) : n <= k ? (r = 1, k = m) : n >= l - k ? (r = l - m + 1, k = l) : (r = n - Math.ceil(m / 2) + 1, k = r + m - 1); for (m = r; m <= k; m++) t +=
n !== m ? '<a tabindex="' + e.iTabIndex + '" class="' + B.sPageButton + '">' + e.fnFormatNumber(m) + "</a>" : '<a tabindex="' + e.iTabIndex + '" class="' + B.sPageButtonActive + '">' + e.fnFormatNumber(m) + "</a>"; m = 0; for (k = M.length; m < k; m++) u = M[m], u.hasChildNodes() && (h("span:eq(0)", u).html(t).children("a").each(L), u = u.getElementsByTagName("a"), u = [u[0], u[1], u[u.length - 2], u[u.length - 1]], h(u).removeClass(B.sPageButton + " " + B.sPageButtonActive + " " + B.sPageButtonStaticDisabled), h([u[0], u[1]]).addClass(1 == n ? B.sPageButtonStaticDisabled :
B.sPageButton), h([u[2], u[3]]).addClass(0 === l || n === l || -1 === e._iDisplayLength ? B.sPageButtonStaticDisabled : B.sPageButton))
        } 
    } 
}
}); h.extend(j.ext.oSort, { "string-pre": function (e) { "string" != typeof e && (e = null !== e && e.toString ? e.toString() : ""); return e.toLowerCase() }, "string-asc": function (e, h) { return e < h ? -1 : e > h ? 1 : 0 }, "string-desc": function (e, h) { return e < h ? 1 : e > h ? -1 : 0 }, "html-pre": function (e) { return e.replace(/<.*?>/g, "").toLowerCase() }, "html-asc": function (e, h) { return e < h ? -1 : e > h ? 1 : 0 }, "html-desc": function (e, h) {
    return e <
h ? 1 : e > h ? -1 : 0
}, "date-pre": function (e) { e = Date.parse(e); if (isNaN(e) || "" === e) e = Date.parse("01/01/1970 00:00:00"); return e }, "date-asc": function (e, h) { return e - h }, "date-desc": function (e, h) { return h - e }, "numeric-pre": function (e) { return "-" == e || "" === e ? 0 : 1 * e }, "numeric-asc": function (e, h) { return e - h }, "numeric-desc": function (e, h) { return h - e } 
}); h.extend(j.ext.aTypes, [function (e) {
    if ("number" === typeof e) return "numeric"; if ("string" !== typeof e) return null; var h, j = !1; h = e.charAt(0); if (-1 == "0123456789-".indexOf(h)) return null;
    for (var k = 1; k < e.length; k++) { h = e.charAt(k); if (-1 == "0123456789.".indexOf(h)) return null; if ("." == h) { if (j) return null; j = !0 } } return "numeric"
}, function (e) { var h = Date.parse(e); return null !== h && !isNaN(h) || "string" === typeof e && 0 === e.length ? "date" : null }, function (e) { return "string" === typeof e && -1 != e.indexOf("<") && -1 != e.indexOf(">") ? "html" : null } ]); h.fn.DataTable = j; h.fn.dataTable = j; h.fn.dataTableSettings = j.settings; h.fn.dataTableExt = j.ext
    }; "function" === typeof define && define.amd ? define(["jquery"], L) : jQuery && !jQuery.fn.dataTable &&
L(jQuery)
})(window, document);

/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=DataTables Extras
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*
 * File:        ColReorder.min.js
* Version:     1.0.8
* Author:      Allan Jardine (www.sprymedia.co.uk)
* 
* Copyright 2010-2012 Allan Jardine, all rights reserved.
*
* This source file is free software, under either the GPL v2 license or a
* BSD (3 point) style license, as supplied with this software.
* 
* This source file is distributed in the hope that it will be useful, but 
* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
* or FITNESS FOR A PARTICULAR PURPOSE. See the license files for details.
*/
(function (f, o, g) {
    function m(a) { for (var b = [], d = 0, c = a.length; d < c; d++) b[a[d]] = d; return b } function j(a, b, d) { b = a.splice(b, 1)[0]; a.splice(d, 0, b) } function n(a, b, d) { for (var c = [], e = 0, f = a.childNodes.length; e < f; e++) 1 == a.childNodes[e].nodeType && c.push(a.childNodes[e]); b = c[b]; null !== d ? a.insertBefore(b, c[d]) : a.appendChild(b) } f.fn.dataTableExt.oApi.fnColReorder = function (a, b, d) {
        var c, e, h, l, k = a.aoColumns.length, i; if (b != d) if (0 > b || b >= k) this.oApi._fnLog(a, 1, "ColReorder 'from' index is out of bounds: " + b); else if (0 > d ||
d >= k) this.oApi._fnLog(a, 1, "ColReorder 'to' index is out of bounds: " + d); else {
            var g = []; c = 0; for (e = k; c < e; c++) g[c] = c; j(g, b, d); g = m(g); c = 0; for (e = a.aaSorting.length; c < e; c++) a.aaSorting[c][0] = g[a.aaSorting[c][0]]; if (null !== a.aaSortingFixed) { c = 0; for (e = a.aaSortingFixed.length; c < e; c++) a.aaSortingFixed[c][0] = g[a.aaSortingFixed[c][0]] } c = 0; for (e = k; c < e; c++) { i = a.aoColumns[c]; h = 0; for (l = i.aDataSort.length; h < l; h++) i.aDataSort[h] = g[i.aDataSort[h]] } c = 0; for (e = k; c < e; c++) i = a.aoColumns[c], "number" == typeof i.mData && (i.mData =
g[i.mData], i.fnGetData = a.oApi._fnGetObjectDataFn(i.mData), i.fnSetData = a.oApi._fnSetObjectDataFn(i.mData)); if (a.aoColumns[b].bVisible) {
                l = this.oApi._fnColumnIndexToVisible(a, b); i = null; for (c = d < b ? d : d + 1; null === i && c < k; ) i = this.oApi._fnColumnIndexToVisible(a, c), c++; h = a.nTHead.getElementsByTagName("tr"); c = 0; for (e = h.length; c < e; c++) n(h[c], l, i); if (null !== a.nTFoot) { h = a.nTFoot.getElementsByTagName("tr"); c = 0; for (e = h.length; c < e; c++) n(h[c], l, i) } c = 0; for (e = a.aoData.length; c < e; c++) null !== a.aoData[c].nTr && n(a.aoData[c].nTr,
l, i)
            } j(a.aoColumns, b, d); j(a.aoPreSearchCols, b, d); c = 0; for (e = a.aoData.length; c < e; c++) f.isArray(a.aoData[c]._aData) && j(a.aoData[c]._aData, b, d), j(a.aoData[c]._anHidden, b, d); c = 0; for (e = a.aoHeader.length; c < e; c++) j(a.aoHeader[c], b, d); if (null !== a.aoFooter) { c = 0; for (e = a.aoFooter.length; c < e; c++) j(a.aoFooter[c], b, d) } c = 0; for (e = k; c < e; c++) f(a.aoColumns[c].nTh).unbind("click"), this.oApi._fnSortAttachListener(a, a.aoColumns[c].nTh, c); f(a.oInstance).trigger("column-reorder", [a, { iFrom: b, iTo: d, aiInvertMapping: g}]); "undefined" !=
typeof a.oInstance._oPluginFixedHeader && a.oInstance._oPluginFixedHeader.fnUpdate()
        } 
    }; ColReorder = function (a, b) {
        (!this.CLASS || "ColReorder" != this.CLASS) && alert("Warning: ColReorder must be initialised with the keyword 'new'"); "undefined" == typeof b && (b = {}); this.s = { dt: null, init: b, fixed: 0, dropCallback: null, mouse: { startX: -1, startY: -1, offsetX: -1, offsetY: -1, target: -1, targetIndex: -1, fromIndex: -1 }, aoTargets: [] }; this.dom = { drag: null, pointer: null }; this.s.dt = a.oInstance.fnSettings(); this._fnConstruct(); a.oApi._fnCallbackReg(a,
"aoDestroyCallback", jQuery.proxy(this._fnDestroy, this), "ColReorder"); ColReorder.aoInstances.push(this); return this
    }; ColReorder.prototype = { fnReset: function () { for (var a = [], b = 0, d = this.s.dt.aoColumns.length; b < d; b++) a.push(this.s.dt.aoColumns[b]._ColReorder_iOrigCol); this._fnOrderColumns(a) }, _fnConstruct: function () {
        var a = this, b, d; "undefined" != typeof this.s.init.iFixedColumns && (this.s.fixed = this.s.init.iFixedColumns); "undefined" != typeof this.s.init.fnReorderCallback && (this.s.dropCallback = this.s.init.fnReorderCallback);
        b = 0; for (d = this.s.dt.aoColumns.length; b < d; b++) b > this.s.fixed - 1 && this._fnMouseListener(b, this.s.dt.aoColumns[b].nTh), this.s.dt.aoColumns[b]._ColReorder_iOrigCol = b; this.s.dt.oApi._fnCallbackReg(this.s.dt, "aoStateSaveParams", function (c, b) { a._fnStateSave.call(a, b) }, "ColReorder_State"); var c = null; "undefined" != typeof this.s.init.aiOrder && (c = this.s.init.aiOrder.slice()); this.s.dt.oLoadedState && ("undefined" != typeof this.s.dt.oLoadedState.ColReorder && this.s.dt.oLoadedState.ColReorder.length == this.s.dt.aoColumns.length) &&
(c = this.s.dt.oLoadedState.ColReorder); if (c) if (a.s.dt._bInitComplete) b = m(c), a._fnOrderColumns.call(a, b); else { var e = !1; this.s.dt.aoDrawCallback.push({ fn: function () { if (!a.s.dt._bInitComplete && !e) { e = true; var b = m(c); a._fnOrderColumns.call(a, b) } }, sName: "ColReorder_Pre" }) } 
    }, _fnOrderColumns: function (a) {
        if (a.length != this.s.dt.aoColumns.length) this.s.dt.oInstance.oApi._fnLog(this.s.dt, 1, "ColReorder - array reorder does not match known number of columns. Skipping."); else {
            for (var b = 0, d = a.length; b < d; b++) {
                var c =
f.inArray(b, a); b != c && (j(a, c, b), this.s.dt.oInstance.fnColReorder(c, b))
            } ("" !== this.s.dt.oScroll.sX || "" !== this.s.dt.oScroll.sY) && this.s.dt.oInstance.fnAdjustColumnSizing(); this.s.dt.oInstance.oApi._fnSaveState(this.s.dt)
        } 
    }, _fnStateSave: function (a) {
        var b, d, c, e = this.s.dt; for (b = 0; b < a.aaSorting.length; b++) a.aaSorting[b][0] = e.aoColumns[a.aaSorting[b][0]]._ColReorder_iOrigCol; aSearchCopy = f.extend(!0, [], a.aoSearchCols); a.ColReorder = []; b = 0; for (d = e.aoColumns.length; b < d; b++) c = e.aoColumns[b]._ColReorder_iOrigCol,
a.aoSearchCols[c] = aSearchCopy[b], a.abVisCols[c] = e.aoColumns[b].bVisible, a.ColReorder.push(c)
    }, _fnMouseListener: function (a, b) { var d = this; f(b).bind("mousedown.ColReorder", function (a) { a.preventDefault(); d._fnMouseDown.call(d, a, b) }) }, _fnMouseDown: function (a, b) {
        var d = this, c = this.s.dt.aoColumns, e = "TH" == a.target.nodeName ? a.target : f(a.target).parents("TH")[0], e = f(e).offset(); this.s.mouse.startX = a.pageX; this.s.mouse.startY = a.pageY; this.s.mouse.offsetX = a.pageX - e.left; this.s.mouse.offsetY = a.pageY - e.top; this.s.mouse.target =
b; this.s.mouse.targetIndex = f("th", b.parentNode).index(b); this.s.mouse.fromIndex = this.s.dt.oInstance.oApi._fnVisibleToColumnIndex(this.s.dt, this.s.mouse.targetIndex); this.s.aoTargets.splice(0, this.s.aoTargets.length); this.s.aoTargets.push({ x: f(this.s.dt.nTable).offset().left, to: 0 }); for (var h = e = 0, j = c.length; h < j; h++) h != this.s.mouse.fromIndex && e++, c[h].bVisible && this.s.aoTargets.push({ x: f(c[h].nTh).offset().left + f(c[h].nTh).outerWidth(), to: e }); 0 !== this.s.fixed && this.s.aoTargets.splice(0, this.s.fixed);
        f(g).bind("mousemove.ColReorder", function (a) { d._fnMouseMove.call(d, a) }); f(g).bind("mouseup.ColReorder", function (a) { d._fnMouseUp.call(d, a) })
    }, _fnMouseMove: function (a) {
        if (null === this.dom.drag) { if (5 > Math.pow(Math.pow(a.pageX - this.s.mouse.startX, 2) + Math.pow(a.pageY - this.s.mouse.startY, 2), 0.5)) return; this._fnCreateDragNode() } this.dom.drag.style.left = a.pageX - this.s.mouse.offsetX + "px"; this.dom.drag.style.top = a.pageY - this.s.mouse.offsetY + "px"; for (var b = !1, d = 1, c = this.s.aoTargets.length; d < c; d++) if (a.pageX <
this.s.aoTargets[d - 1].x + (this.s.aoTargets[d].x - this.s.aoTargets[d - 1].x) / 2) { this.dom.pointer.style.left = this.s.aoTargets[d - 1].x + "px"; this.s.mouse.toIndex = this.s.aoTargets[d - 1].to; b = !0; break } b || (this.dom.pointer.style.left = this.s.aoTargets[this.s.aoTargets.length - 1].x + "px", this.s.mouse.toIndex = this.s.aoTargets[this.s.aoTargets.length - 1].to)
    }, _fnMouseUp: function () {
        f(g).unbind("mousemove.ColReorder"); f(g).unbind("mouseup.ColReorder"); null !== this.dom.drag && (g.body.removeChild(this.dom.drag), g.body.removeChild(this.dom.pointer),
this.dom.drag = null, this.dom.pointer = null, this.s.dt.oInstance.fnColReorder(this.s.mouse.fromIndex, this.s.mouse.toIndex), ("" !== this.s.dt.oScroll.sX || "" !== this.s.dt.oScroll.sY) && this.s.dt.oInstance.fnAdjustColumnSizing(), null !== this.s.dropCallback && this.s.dropCallback.call(this), this.s.dt.oInstance.oApi._fnSaveState(this.s.dt))
    }, _fnCreateDragNode: function () {
        var a = this; this.dom.drag = f(this.s.dt.nTHead.parentNode).clone(!0)[0]; for (this.dom.drag.className += " DTCR_clonedTable"; 0 < this.dom.drag.getElementsByTagName("caption").length; ) this.dom.drag.removeChild(this.dom.drag.getElementsByTagName("caption")[0]);
        for (; 0 < this.dom.drag.getElementsByTagName("tbody").length; ) this.dom.drag.removeChild(this.dom.drag.getElementsByTagName("tbody")[0]); for (; 0 < this.dom.drag.getElementsByTagName("tfoot").length; ) this.dom.drag.removeChild(this.dom.drag.getElementsByTagName("tfoot")[0]); f("thead tr:eq(0)", this.dom.drag).each(function () { f("th", this).eq(a.s.mouse.targetIndex).siblings().remove() }); f("tr", this.dom.drag).height(f("tr:eq(0)", a.s.dt.nTHead).height()); f("thead tr:gt(0)", this.dom.drag).remove(); f("thead th:eq(0)",
this.dom.drag).each(function () { this.style.width = f("th:eq(" + a.s.mouse.targetIndex + ")", a.s.dt.nTHead).width() + "px" }); this.dom.drag.style.position = "absolute"; this.dom.drag.style.top = "0px"; this.dom.drag.style.left = "0px"; this.dom.drag.style.width = f("th:eq(" + a.s.mouse.targetIndex + ")", a.s.dt.nTHead).outerWidth() + "px"; this.dom.pointer = g.createElement("div"); this.dom.pointer.className = "DTCR_pointer"; this.dom.pointer.style.position = "absolute"; "" === this.s.dt.oScroll.sX && "" === this.s.dt.oScroll.sY ? (this.dom.pointer.style.top =
f(this.s.dt.nTable).offset().top + "px", this.dom.pointer.style.height = f(this.s.dt.nTable).height() + "px") : (this.dom.pointer.style.top = f("div.dataTables_scroll", this.s.dt.nTableWrapper).offset().top + "px", this.dom.pointer.style.height = f("div.dataTables_scroll", this.s.dt.nTableWrapper).height() + "px"); g.body.appendChild(this.dom.pointer); g.body.appendChild(this.dom.drag)
    }, _fnDestroy: function () {
        for (var a = 0, b = ColReorder.aoInstances.length; a < b; a++) if (ColReorder.aoInstances[a] === this) {
            ColReorder.aoInstances.splice(a,
1); break
        } f(this.s.dt.nTHead).find("*").unbind(".ColReorder"); this.s = this.s.dt.oInstance._oPluginColReorder = null
    } 
    }; ColReorder.aoInstances = []; ColReorder.fnReset = function (a) { for (var b = 0, d = ColReorder.aoInstances.length; b < d; b++) ColReorder.aoInstances[b].s.dt.oInstance == a && ColReorder.aoInstances[b].fnReset() }; ColReorder.prototype.CLASS = "ColReorder"; ColReorder.VERSION = "1.0.8"; ColReorder.prototype.VERSION = ColReorder.VERSION; "function" == typeof f.fn.dataTable && "function" == typeof f.fn.dataTableExt.fnVersionCheck &&
f.fn.dataTableExt.fnVersionCheck("1.9.3") ? f.fn.dataTableExt.aoFeatures.push({ fnInit: function (a) { var b = a.oInstance; "undefined" == typeof b._oPluginColReorder ? b._oPluginColReorder = new ColReorder(a, "undefined" != typeof a.oInit.oColReorder ? a.oInit.oColReorder : {}) : b.oApi._fnLog(a, 1, "ColReorder attempted to initialise twice. Ignoring second"); return null }, cFeature: "R", sFeature: "ColReorder" }) : alert("Warning: ColReorder requires DataTables 1.9.3 or greater - www.datatables.net/download")
})(jQuery, window, document);


/* TableTools */
// Simple Set Clipboard System
// Author: Joseph Huckaby
var ZeroClipboard_TableTools = { version: "1.0.4-TableTools2", clients: {}, moviePath: "", nextId: 1, $: function (a) {
    "string" == typeof a && (a = document.getElementById(a)); if (!a.addClass) a.hide = function () { this.style.display = "none" }, a.show = function () { this.style.display = "" }, a.addClass = function (a) { this.removeClass(a); this.className += " " + a }, a.removeClass = function (a) { this.className = this.className.replace(RegExp("\\s*" + a + "\\s*"), " ").replace(/^\s+/, "").replace(/\s+$/, "") }, a.hasClass = function (a) {
        return !!this.className.match(RegExp("\\s*" +
a + "\\s*"))
    }; return a
}, setMoviePath: function (a) { this.moviePath = a }, dispatch: function (a, b, c) { (a = this.clients[a]) && a.receiveEvent(b, c) }, register: function (a, b) { this.clients[a] = b }, getDOMObjectPosition: function (a) { var b = { left: 0, top: 0, width: a.width ? a.width : a.offsetWidth, height: a.height ? a.height : a.offsetHeight }; if ("" != a.style.width) b.width = a.style.width.replace("px", ""); if ("" != a.style.height) b.height = a.style.height.replace("px", ""); for (; a; ) b.left += a.offsetLeft, b.top += a.offsetTop, a = a.offsetParent; return b },
    Client: function (a) { this.handlers = {}; this.id = ZeroClipboard_TableTools.nextId++; this.movieId = "ZeroClipboard_TableToolsMovie_" + this.id; ZeroClipboard_TableTools.register(this.id, this); a && this.glue(a) } 
};
ZeroClipboard_TableTools.Client.prototype = { id: 0, ready: !1, movie: null, clipText: "", fileName: "", action: "copy", handCursorEnabled: !0, cssEffects: !0, handlers: null, sized: !1, glue: function (a, b) {
    this.domElement = ZeroClipboard_TableTools.$(a); var c = 99; this.domElement.style.zIndex && (c = parseInt(this.domElement.style.zIndex) + 1); var d = ZeroClipboard_TableTools.getDOMObjectPosition(this.domElement); this.div = document.createElement("div"); var e = this.div.style; e.position = "absolute"; e.left = this.domElement.offsetLeft + "px";
    e.top = this.domElement.offsetTop + "px"; e.width = d.width + "px"; e.height = d.height + "px"; e.zIndex = c; if ("undefined" != typeof b && "" != b) this.div.title = b; if (0 != d.width && 0 != d.height) this.sized = !0; if (this.domElement.parentNode) this.domElement.parentNode.appendChild(this.div), this.div.innerHTML = this.getHTML(d.width, d.height)
}, positionElement: function () {
    var a = ZeroClipboard_TableTools.getDOMObjectPosition(this.domElement), b = this.div.style; b.position = "absolute"; b.left = this.domElement.offsetLeft + "px"; b.top = this.domElement.offsetTop +
"px"; b.width = a.width + "px"; b.height = a.height + "px"; if (0 != a.width && 0 != a.height) this.sized = !0, b = this.div.childNodes[0], b.width = a.width, b.height = a.height
}, getHTML: function (a, b) {
    var c = "", d = "id=" + this.id + "&width=" + a + "&height=" + b; if (navigator.userAgent.match(/MSIE/)) var e = location.href.match(/^https/i) ? "https://" : "http://", c = c + ('<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="' + e + 'download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" width="' + a + '" height="' +
b + '" id="' + this.movieId + '" align="middle"><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="false" /><param name="movie" value="' + ZeroClipboard_TableTools.moviePath + '" /><param name="loop" value="false" /><param name="menu" value="false" /><param name="quality" value="best" /><param name="bgcolor" value="#ffffff" /><param name="flashvars" value="' + d + '"/><param name="wmode" value="transparent"/></object>'); else c += '<embed id="' + this.movieId + '" src="' + ZeroClipboard_TableTools.moviePath +
'" loop="false" menu="false" quality="best" bgcolor="#ffffff" width="' + a + '" height="' + b + '" name="' + this.movieId + '" align="middle" allowScriptAccess="always" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" flashvars="' + d + '" wmode="transparent" />'; return c
}, hide: function () { if (this.div) this.div.style.left = "-2000px" }, show: function () { this.reposition() }, destroy: function () {
    if (this.domElement && this.div) {
        this.hide(); this.div.innerHTML =
""; var a = document.getElementsByTagName("body")[0]; try { a.removeChild(this.div) } catch (b) { } this.div = this.domElement = null
    } 
}, reposition: function (a) { if (a) (this.domElement = ZeroClipboard_TableTools.$(a)) || this.hide(); if (this.domElement && this.div) { var a = ZeroClipboard_TableTools.getDOMObjectPosition(this.domElement), b = this.div.style; b.left = "" + a.left + "px"; b.top = "" + a.top + "px" } }, clearText: function () { this.clipText = ""; this.ready && this.movie.clearText() }, appendText: function (a) { this.clipText += a; this.ready && this.movie.appendText(a) },
    setText: function (a) { this.clipText = a; this.ready && this.movie.setText(a) }, setCharSet: function (a) { this.charSet = a; this.ready && this.movie.setCharSet(a) }, setBomInc: function (a) { this.incBom = a; this.ready && this.movie.setBomInc(a) }, setFileName: function (a) { this.fileName = a; this.ready && this.movie.setFileName(a) }, setAction: function (a) { this.action = a; this.ready && this.movie.setAction(a) }, addEventListener: function (a, b) { a = a.toString().toLowerCase().replace(/^on/, ""); this.handlers[a] || (this.handlers[a] = []); this.handlers[a].push(b) },
    setHandCursor: function (a) { this.handCursorEnabled = a; this.ready && this.movie.setHandCursor(a) }, setCSSEffects: function (a) { this.cssEffects = !!a }, receiveEvent: function (a, b) {
        a = a.toString().toLowerCase().replace(/^on/, ""); switch (a) {
            case "load": this.movie = document.getElementById(this.movieId); if (!this.movie) { var c = this; setTimeout(function () { c.receiveEvent("load", null) }, 1); return } if (!this.ready && navigator.userAgent.match(/Firefox/) && navigator.userAgent.match(/Windows/)) {
                    c = this; setTimeout(function () {
                        c.receiveEvent("load",
null)
                    }, 100); this.ready = !0; return
                } this.ready = !0; this.movie.clearText(); this.movie.appendText(this.clipText); this.movie.setFileName(this.fileName); this.movie.setAction(this.action); this.movie.setCharSet(this.charSet); this.movie.setBomInc(this.incBom); this.movie.setHandCursor(this.handCursorEnabled); break; case "mouseover": this.domElement && this.cssEffects && this.recoverActive && this.domElement.addClass("active"); break; case "mouseout": if (this.domElement && this.cssEffects && (this.recoverActive = !1, this.domElement.hasClass("active"))) this.domElement.removeClass("active"),
this.recoverActive = !0; break; case "mousedown": this.domElement && this.cssEffects && this.domElement.addClass("active"); break; case "mouseup": if (this.domElement && this.cssEffects) this.domElement.removeClass("active"), this.recoverActive = !1
        } if (this.handlers[a]) for (var d = 0, e = this.handlers[a].length; d < e; d++) { var f = this.handlers[a][d]; if ("function" == typeof f) f(this, b); else if ("object" == typeof f && 2 == f.length) f[0][f[1]](this, b); else if ("string" == typeof f) window[f](this, b) } 
    } 
};


/*
 * File:        TableTools.min.js
 * Version:     2.0.3
 * Author:      Allan Jardine (www.sprymedia.co.uk)
 * 
 * Copyright 2009-2011 Allan Jardine, all rights reserved.
 *
 * This source file is free software, under either the GPL v2 license or a
 * BSD (3 point) style license, as supplied with this software.
 * 
 * This source file is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the license files for details.
 */
var TableTools;
(function(e,m,f){TableTools=function(a,b){(!this.CLASS||"TableTools"!=this.CLASS)&&alert("Warning: TableTools must be initialised with the keyword 'new'");this.s={that:this,dt:null,print:{saveStart:-1,saveLength:-1,saveScroll:-1,funcEnd:function(){}},buttonCounter:0,select:{type:"",selected:[],preRowSelect:null,postSelected:null,postDeselected:null,all:!1,selectedClass:""},custom:{},swfPath:"",buttonSet:[],master:!1};this.dom={container:null,table:null,print:{hidden:[],message:null},collection:{collection:null,
background:null}};this.fnSettings=function(){return this.s};"undefined"==typeof b&&(b={});this.s.dt=a.fnSettings();this._fnConstruct(b);return this};TableTools.prototype={fnGetSelected:function(){return this._fnGetMasterSettings().select.selected},fnGetSelectedData:function(){for(var a=this._fnGetMasterSettings().select.selected,b=[],c=0,d=a.length;c<d;c++)b.push(this.s.dt.oInstance.fnGetData(a[c]));return b},fnIsSelected:function(a){for(var b=this.fnGetSelected(),c=0,d=b.length;c<d;c++)if(a==b[c])return!0;
return!1},fnSelectAll:function(){this._fnGetMasterSettings().that._fnRowSelectAll()},fnSelectNone:function(){this._fnGetMasterSettings().that._fnRowDeselectAll()},fnSelect:function(a){this.fnIsSelected(a)||("single"==this.s.select.type?this._fnRowSelectSingle(a):"multi"==this.s.select.type&&this._fnRowSelectMulti(a))},fnDeselect:function(a){this.fnIsSelected(a)&&("single"==this.s.select.type?this._fnRowSelectSingle(a):"multi"==this.s.select.type&&this._fnRowSelectMulti(a))},fnGetTitle:function(a){var b=
"";if("undefined"!=typeof a.sTitle&&""!==a.sTitle)b=a.sTitle;else if(a=f.getElementsByTagName("title"),0<a.length)b=a[0].innerHTML;return 4>"\u00a1".toString().length?b.replace(/[^a-zA-Z0-9_\u00A1-\uFFFF\.,\-_ !\(\)]/g,""):b.replace(/[^a-zA-Z0-9_\.,\-_ !\(\)]/g,"")},fnCalcColRatios:function(a){var b=this.s.dt.aoColumns,a=this._fnColumnTargets(a.mColumns),c=[],d=0,e=0,g,f;for(g=0,f=a.length;g<f;g++)if(a[g])d=b[g].nTh.offsetWidth,e+=d,c.push(d);for(g=0,f=c.length;g<f;g++)c[g]/=e;return c.join("\t")},
fnGetTableData:function(a){if(this.s.dt)return this._fnGetDataTablesData(a)},fnSetText:function(a,b){this._fnFlashSetText(a,b)},fnResizeButtons:function(){for(var a in ZeroClipboard_TableTools.clients)if(a){var b=ZeroClipboard_TableTools.clients[a];"undefined"!=typeof b.domElement&&b.domElement.parentNode==this.dom.container&&b.positionElement()}},fnResizeRequired:function(){for(var a in ZeroClipboard_TableTools.clients)if(a){var b=ZeroClipboard_TableTools.clients[a];if("undefined"!=typeof b.domElement&&
b.domElement.parentNode==this.dom.container&&!1===b.sized)return!0}return!1},_fnConstruct:function(a){var b=this;this._fnCustomiseSettings(a);this.dom.container=f.createElement("div");this.dom.container.className=!this.s.dt.bJUI?"DTTT_container":"DTTT_container ui-buttonset ui-buttonset-multi";"none"!=this.s.select.type&&this._fnRowSelectConfig();this._fnButtonDefinations(this.s.buttonSet,this.dom.container);this.s.dt.aoDestroyCallback.push({sName:"TableTools",fn:function(){b.dom.container.innerHTML=
""}})},_fnCustomiseSettings:function(a){if("undefined"==typeof this.s.dt._TableToolsInit)this.s.master=!0,this.s.dt._TableToolsInit=!0;this.dom.table=this.s.dt.nTable;this.s.custom=e.extend({},TableTools.DEFAULTS,a);this.s.swfPath=this.s.custom.sSwfPath;if("undefined"!=typeof ZeroClipboard_TableTools)ZeroClipboard_TableTools.moviePath=this.s.swfPath;this.s.select.type=this.s.custom.sRowSelect;this.s.select.preRowSelect=this.s.custom.fnPreRowSelect;this.s.select.postSelected=this.s.custom.fnRowSelected;
this.s.select.postDeselected=this.s.custom.fnRowDeselected;this.s.select.selectedClass=this.s.custom.sSelectedClass;this.s.buttonSet=this.s.custom.aButtons},_fnButtonDefinations:function(a,b){for(var c,d=0,j=a.length;d<j;d++){if("string"==typeof a[d]){if("undefined"==typeof TableTools.BUTTONS[a[d]]){alert("TableTools: Warning - unknown button type: "+a[d]);continue}c=e.extend({},TableTools.BUTTONS[a[d]],!0)}else{if("undefined"==typeof TableTools.BUTTONS[a[d].sExtends]){alert("TableTools: Warning - unknown button type: "+
a[d].sExtends);continue}c=e.extend({},TableTools.BUTTONS[a[d].sExtends],!0);c=e.extend(c,a[d],!0)}this.s.dt.bJUI?(c.sButtonClass+=" ui-button ui-state-default",c.sButtonClassHover+=" ui-state-hover"):c.sButtonClassHover+=" DTTT_button_hover";b.appendChild(this._fnCreateButton(c))}},_fnCreateButton:function(a){var b="div"==a.sAction?this._fnDivBase(a):this._fnButtonBase(a);"print"==a.sAction?this._fnPrintConfig(b,a):a.sAction.match(/flash/)?this._fnFlashConfig(b,a):"text"==a.sAction?this._fnTextConfig(b,
a):"div"==a.sAction?this._fnTextConfig(b,a):"collection"==a.sAction&&(this._fnTextConfig(b,a),this._fnCollectionConfig(b,a));return b},_fnButtonBase:function(a){var b=f.createElement("button"),c=f.createElement("span"),d=this._fnGetMasterSettings();b.className="DTTT_button "+a.sButtonClass;b.setAttribute("id","ToolTables_"+this.s.dt.sInstance+"_"+d.buttonCounter);b.appendChild(c);c.innerHTML=a.sButtonText;d.buttonCounter++;return b},_fnDivBase:function(a){var b=f.createElement("div"),c=this._fnGetMasterSettings();
b.className=a.sButtonClass;b.setAttribute("id","ToolTables_"+this.s.dt.sInstance+"_"+c.buttonCounter);b.innerHTML=a.sButtonText;null!==a.nContent&&b.appendChild(a.nContent);c.buttonCounter++;return b},_fnGetMasterSettings:function(){if(this.s.master)return this.s;for(var a=TableTools._aInstances,b=0,c=a.length;b<c;b++)if(this.dom.table==a[b].s.dt.nTable)return a[b].s},_fnCollectionConfig:function(a,b){var c=f.createElement("div");c.style.display="none";c.className=!this.s.dt.bJUI?"DTTT_collection":
"DTTT_collection ui-buttonset ui-buttonset-multi";b._collection=c;f.body.appendChild(c);this._fnButtonDefinations(b.aButtons,c)},_fnCollectionShow:function(a,b){var c=this,d=e(a).offset(),j=b._collection,g=d.left,d=d.top+e(a).outerHeight(),o=e(m).height(),h=e(f).height(),k=e(m).width(),n=e(f).width();j.style.position="absolute";j.style.left=g+"px";j.style.top=d+"px";j.style.display="block";e(j).css("opacity",0);var l=f.createElement("div");l.style.position="absolute";l.style.left="0px";l.style.top=
"0px";l.style.height=(o>h?o:h)+"px";l.style.width=(k>n?k:n)+"px";l.className="DTTT_collection_background";e(l).css("opacity",0);f.body.appendChild(l);f.body.appendChild(j);o=e(j).outerWidth();k=e(j).outerHeight();if(g+o>n)j.style.left=n-o+"px";if(d+k>h)j.style.top=d-k-e(a).outerHeight()+"px";this.dom.collection.collection=j;this.dom.collection.background=l;setTimeout(function(){e(j).animate({opacity:1},500);e(l).animate({opacity:0.25},500)},10);e(l).click(function(){c._fnCollectionHide.call(c,null,
null)})},_fnCollectionHide:function(a,b){if(!(null!==b&&"collection"==b.sExtends)&&null!==this.dom.collection.collection)e(this.dom.collection.collection).animate({opacity:0},500,function(){this.style.display="none"}),e(this.dom.collection.background).animate({opacity:0},500,function(){this.parentNode.removeChild(this)}),this.dom.collection.collection=null,this.dom.collection.background=null},_fnRowSelectConfig:function(){if(this.s.master){var a=this;e(a.s.dt.nTable).addClass("DTTT_selectable");e("tr",
a.s.dt.nTBody).live("click",function(b){if(this.parentNode==a.s.dt.nTBody){var c=a.s.dt.oInstance.fnGetNodes();-1===e.inArray(this,c)||null!==a.s.select.preRowSelect&&!a.s.select.preRowSelect.call(a,b)||("single"==a.s.select.type?a._fnRowSelectSingle.call(a,this):a._fnRowSelectMulti.call(a,this))}});a.s.dt.aoDrawCallback.push({fn:function(){a.s.select.all&&a.s.dt.oFeatures.bServerSide&&a.fnSelectAll()},sName:"TableTools_select"})}},_fnRowSelectSingle:function(a){this.s.master&&!e("td",a).hasClass(this.s.dt.oClasses.sRowEmpty)&&
(e(a).hasClass(this.s.select.selectedClass)?this._fnRowDeselect(a):(0!==this.s.select.selected.length&&this._fnRowDeselectAll(),this.s.select.selected.push(a),e(a).addClass(this.s.select.selectedClass),null!==this.s.select.postSelected&&this.s.select.postSelected.call(this,a)),TableTools._fnEventDispatch(this,"select",a))},_fnRowSelectMulti:function(a){this.s.master&&!e("td",a).hasClass(this.s.dt.oClasses.sRowEmpty)&&(e(a).hasClass(this.s.select.selectedClass)?this._fnRowDeselect(a):(this.s.select.selected.push(a),
e(a).addClass(this.s.select.selectedClass),null!==this.s.select.postSelected&&this.s.select.postSelected.call(this,a)),TableTools._fnEventDispatch(this,"select",a))},_fnRowSelectAll:function(){if(this.s.master){for(var a,b=0,c=this.s.dt.aiDisplayMaster.length;b<c;b++)a=this.s.dt.aoData[this.s.dt.aiDisplayMaster[b]].nTr,e(a).hasClass(this.s.select.selectedClass)||(this.s.select.selected.push(a),e(a).addClass(this.s.select.selectedClass));null!==this.s.select.postSelected&&this.s.select.postSelected.call(this,
null);this.s.select.all=!0;TableTools._fnEventDispatch(this,"select",null)}},_fnRowDeselectAll:function(){if(this.s.master){for(var a=this.s.select.selected.length-1;0<=a;a--)this._fnRowDeselect(a,!1);null!==this.s.select.postDeselected&&this.s.select.postDeselected.call(this,null);this.s.select.all=!1;TableTools._fnEventDispatch(this,"select",null)}},_fnRowDeselect:function(a,b){"undefined"!=typeof a.nodeName&&(a=e.inArray(a,this.s.select.selected));var c=this.s.select.selected[a];e(c).removeClass(this.s.select.selectedClass);
this.s.select.selected.splice(a,1);("undefined"==typeof b||b)&&null!==this.s.select.postDeselected&&this.s.select.postDeselected.call(this,c);this.s.select.all=!1},_fnTextConfig:function(a,b){var c=this;null!==b.fnInit&&b.fnInit.call(this,a,b);if(""!==b.sToolTip)a.title=b.sToolTip;e(a).hover(function(){e(a).addClass(b.sButtonClassHover);null!==b.fnMouseover&&b.fnMouseover.call(this,a,b,null)},function(){e(a).removeClass(b.sButtonClassHover);null!==b.fnMouseout&&b.fnMouseout.call(this,a,b,null)});
null!==b.fnSelect&&TableTools._fnEventListen(this,"select",function(d){b.fnSelect.call(c,a,b,d)});e(a).click(function(d){d.preventDefault();null!==b.fnClick&&b.fnClick.call(c,a,b,null);null!==b.fnComplete&&b.fnComplete.call(c,a,b,null,null);c._fnCollectionHide(a,b)})},_fnFlashConfig:function(a,b){var c=this,d=new ZeroClipboard_TableTools.Client;null!==b.fnInit&&b.fnInit.call(this,a,b);d.setHandCursor(!0);"flash_save"==b.sAction?(d.setAction("save"),d.setCharSet("utf16le"==b.sCharSet?"UTF16LE":"UTF8"),
d.setBomInc(b.bBomInc),d.setFileName(b.sFileName.replace("*",this.fnGetTitle(b)))):"flash_pdf"==b.sAction?(d.setAction("pdf"),d.setFileName(b.sFileName.replace("*",this.fnGetTitle(b)))):d.setAction("copy");d.addEventListener("mouseOver",function(){e(a).addClass(b.sButtonClassHover);null!==b.fnMouseover&&b.fnMouseover.call(c,a,b,d)});d.addEventListener("mouseOut",function(){e(a).removeClass(b.sButtonClassHover);null!==b.fnMouseout&&b.fnMouseout.call(c,a,b,d)});d.addEventListener("mouseDown",function(){null!==
b.fnClick&&b.fnClick.call(c,a,b,d)});d.addEventListener("complete",function(e,g){null!==b.fnComplete&&b.fnComplete.call(c,a,b,d,g);c._fnCollectionHide(a,b)});this._fnFlashGlue(d,a,b.sToolTip)},_fnFlashGlue:function(a,b,c){var d=this,e=b.getAttribute("id");if(f.getElementById(e)){if(a.glue(b,c),a.domElement.parentNode!=a.div.parentNode&&"undefined"==typeof d.__bZCWarning)d.s.dt.oApi._fnLog(this.s.dt,0,"It looks like you are using the version of ZeroClipboard which came with TableTools 1. Please update to use the version that came with TableTools 2."),
d.__bZCWarning=!0}else setTimeout(function(){d._fnFlashGlue(a,b,c)},100)},_fnFlashSetText:function(a,b){var c=this._fnChunkData(b,8192);a.clearText();for(var d=0,e=c.length;d<e;d++)a.appendText(c[d])},_fnColumnTargets:function(a){var b=[],c=this.s.dt;if("object"==typeof a){for(i=0,iLen=c.aoColumns.length;i<iLen;i++)b.push(!1);for(i=0,iLen=a.length;i<iLen;i++)b[a[i]]=!0}else if("visible"==a)for(i=0,iLen=c.aoColumns.length;i<iLen;i++)b.push(c.aoColumns[i].bVisible?!0:!1);else if("hidden"==a)for(i=0,
iLen=c.aoColumns.length;i<iLen;i++)b.push(c.aoColumns[i].bVisible?!1:!0);else if("sortable"==a)for(i=0,iLen=c.aoColumns.length;i<iLen;i++)b.push(c.aoColumns[i].bSortable?!0:!1);else for(i=0,iLen=c.aoColumns.length;i<iLen;i++)b.push(!0);return b},_fnNewline:function(a){return"auto"==a.sNewLine?navigator.userAgent.match(/Windows/)?"\r\n":"\n":a.sNewLine},_fnGetDataTablesData:function(a){var b,c,d,j,g,f=[],h="",k=this.s.dt,n=RegExp(a.sFieldBoundary,"g"),l=this._fnColumnTargets(a.mColumns),m="undefined"!=
typeof a.bSelectedOnly?a.bSelectedOnly:!1;if(a.bHeader){g=[];for(b=0,c=k.aoColumns.length;b<c;b++)l[b]&&(h=k.aoColumns[b].sTitle.replace(/\n/g," ").replace(/<.*?>/g,"").replace(/^\s+|\s+$/g,""),h=this._fnHtmlDecode(h),g.push(this._fnBoundData(h,a.sFieldBoundary,n)));f.push(g.join(a.sFieldSeperator))}for(d=0,j=k.aiDisplay.length;d<j;d++)if("none"==this.s.select.type||!m||m&&e(k.aoData[k.aiDisplay[d]].nTr).hasClass(this.s.select.selectedClass)||m&&0==this.s.select.selected.length){g=[];for(b=0,c=k.aoColumns.length;b<
c;b++)l[b]&&(h=k.oApi._fnGetCellData(k,k.aiDisplay[d],b,"display"),a.fnCellRender?h=a.fnCellRender(h,b)+"":"string"==typeof h?(h=h.replace(/\n/g," "),h=h.replace(/<img.*?\s+alt\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>]+)).*?>/gi,"$1$2$3"),h=h.replace(/<.*?>/g,"")):h+="",h=h.replace(/^\s+/,"").replace(/\s+$/,""),h=this._fnHtmlDecode(h),g.push(this._fnBoundData(h,a.sFieldBoundary,n)));f.push(g.join(a.sFieldSeperator))}if(a.bFooter&&null!==k.nTFoot){g=[];for(b=0,c=k.aoColumns.length;b<c;b++)l[b]&&null!==
k.aoColumns[b].nTf&&(h=k.aoColumns[b].nTf.innerHTML.replace(/\n/g," ").replace(/<.*?>/g,""),h=this._fnHtmlDecode(h),g.push(this._fnBoundData(h,a.sFieldBoundary,n)));f.push(g.join(a.sFieldSeperator))}return _sLastData=f.join(this._fnNewline(a))},_fnBoundData:function(a,b,c){return""===b?a:b+a.replace(c,b+b)+b},_fnChunkData:function(a,b){for(var c=[],d=a.length,e=0;e<d;e+=b)e+b<d?c.push(a.substring(e,e+b)):c.push(a.substring(e,d));return c},_fnHtmlDecode:function(a){if(-1==a.indexOf("&"))return a;var a=
this._fnChunkData(a,2048),b=f.createElement("div"),c,d,e,g="";for(c=0,d=a.length;c<d;c++)e=a[c].lastIndexOf("&"),-1!=e&&8<=a[c].length&&e>a[c].length-8&&(a[c].substr(e),a[c]=a[c].substr(0,e)),b.innerHTML=a[c],g+=b.childNodes[0].nodeValue;return g},_fnPrintConfig:function(a,b){var c=this;null!==b.fnInit&&b.fnInit.call(this,a,b);if(""!==b.sToolTip)a.title=b.sToolTip;e(a).hover(function(){e(a).addClass(b.sButtonClassHover)},function(){e(a).removeClass(b.sButtonClassHover)});null!==b.fnSelect&&TableTools._fnEventListen(this,
"select",function(d){b.fnSelect.call(c,a,b,d)});e(a).click(function(d){d.preventDefault();c._fnPrintStart.call(c,d,b);null!==b.fnClick&&b.fnClick.call(c,a,b,null);null!==b.fnComplete&&b.fnComplete.call(c,a,b,null,null);c._fnCollectionHide(a,b)})},_fnPrintStart:function(a,b){var c=this,d=this.s.dt;this._fnPrintHideNodes(d.nTable);this.s.print.saveStart=d._iDisplayStart;this.s.print.saveLength=d._iDisplayLength;if(b.bShowAll)d._iDisplayStart=0,d._iDisplayLength=-1,d.oApi._fnCalculateEnd(d),d.oApi._fnDraw(d);
(""!==d.oScroll.sX||""!==d.oScroll.sY)&&this._fnPrintScrollStart(d);var d=d.aanFeatures,j;for(j in d)if("i"!=j&&"t"!=j&&1==j.length)for(var g=0,o=d[j].length;g<o;g++)this.dom.print.hidden.push({node:d[j][g],display:"block"}),d[j][g].style.display="none";e(f.body).addClass("DTTT_Print");if(""!==b.sInfo){var h=f.createElement("div");h.className="DTTT_print_info";h.innerHTML=b.sInfo;f.body.appendChild(h);setTimeout(function(){e(h).fadeOut("normal",function(){f.body.removeChild(h)})},2E3)}if(""!==b.sMessage)this.dom.print.message=
f.createElement("div"),this.dom.print.message.className="DTTT_PrintMessage",this.dom.print.message.innerHTML=b.sMessage,f.body.insertBefore(this.dom.print.message,f.body.childNodes[0]);this.s.print.saveScroll=e(m).scrollTop();m.scrollTo(0,0);this.s.print.funcEnd=function(a){c._fnPrintEnd.call(c,a)};e(f).bind("keydown",null,this.s.print.funcEnd)},_fnPrintEnd:function(a){if(27==a.keyCode){a.preventDefault();var a=this.s.dt,b=this.s.print,c=this.dom.print;this._fnPrintShowNodes();(""!==a.oScroll.sX||
""!==a.oScroll.sY)&&this._fnPrintScrollEnd();m.scrollTo(0,b.saveScroll);if(null!==c.message)f.body.removeChild(c.message),c.message=null;e(f.body).removeClass("DTTT_Print");a._iDisplayStart=b.saveStart;a._iDisplayLength=b.saveLength;a.oApi._fnCalculateEnd(a);a.oApi._fnDraw(a);e(f).unbind("keydown",this.s.print.funcEnd);this.s.print.funcEnd=null}},_fnPrintScrollStart:function(){var a=this.s.dt;a.nScrollHead.getElementsByTagName("div")[0].getElementsByTagName("table");var b=a.nTable.parentNode,c=a.nTable.getElementsByTagName("thead");
0<c.length&&a.nTable.removeChild(c[0]);null!==a.nTFoot&&(c=a.nTable.getElementsByTagName("tfoot"),0<c.length&&a.nTable.removeChild(c[0]));c=a.nTHead.cloneNode(!0);a.nTable.insertBefore(c,a.nTable.childNodes[0]);null!==a.nTFoot&&(c=a.nTFoot.cloneNode(!0),a.nTable.insertBefore(c,a.nTable.childNodes[1]));if(""!==a.oScroll.sX)a.nTable.style.width=e(a.nTable).outerWidth()+"px",b.style.width=e(a.nTable).outerWidth()+"px",b.style.overflow="visible";if(""!==a.oScroll.sY)b.style.height=e(a.nTable).outerHeight()+
"px",b.style.overflow="visible"},_fnPrintScrollEnd:function(){var a=this.s.dt,b=a.nTable.parentNode;if(""!==a.oScroll.sX)b.style.width=a.oApi._fnStringToCss(a.oScroll.sX),b.style.overflow="auto";if(""!==a.oScroll.sY)b.style.height=a.oApi._fnStringToCss(a.oScroll.sY),b.style.overflow="auto"},_fnPrintShowNodes:function(){for(var a=this.dom.print.hidden,b=0,c=a.length;b<c;b++)a[b].node.style.display=a[b].display;a.splice(0,a.length)},_fnPrintHideNodes:function(a){for(var b=this.dom.print.hidden,c=a.parentNode,
d=c.childNodes,j=0,g=d.length;j<g;j++)if(d[j]!=a&&1==d[j].nodeType){var f=e(d[j]).css("display");if("none"!=f)b.push({node:d[j],display:f}),d[j].style.display="none"}"BODY"!=c.nodeName&&this._fnPrintHideNodes(c)}};TableTools._aInstances=[];TableTools._aListeners=[];TableTools.fnGetMasters=function(){for(var a=[],b=0,c=TableTools._aInstances.length;b<c;b++)TableTools._aInstances[b].s.master&&a.push(TableTools._aInstances[b]);return a};TableTools.fnGetInstance=function(a){"object"!=typeof a&&(a=f.getElementById(a));
for(var b=0,c=TableTools._aInstances.length;b<c;b++)if(TableTools._aInstances[b].s.master&&TableTools._aInstances[b].dom.table==a)return TableTools._aInstances[b];return null};TableTools._fnEventListen=function(a,b,c){TableTools._aListeners.push({that:a,type:b,fn:c})};TableTools._fnEventDispatch=function(a,b,c){for(var d=TableTools._aListeners,e=0,f=d.length;e<f;e++)a.dom.table==d[e].that.dom.table&&d[e].type==b&&d[e].fn(c)};TableTools.BUTTONS={csv:{sAction:"flash_save",sCharSet:"utf8",bBomInc:!1,
sFileName:"*.csv",sFieldBoundary:'"',sFieldSeperator:",",sNewLine:"auto",sTitle:"",sToolTip:"",sButtonClass:"DTTT_button_csv",sButtonClassHover:"DTTT_button_csv_hover",sButtonText:"CSV",mColumns:"all",bHeader:!0,bFooter:!0,bSelectedOnly:!1,fnMouseover:null,fnMouseout:null,fnClick:function(a,b,c){this.fnSetText(c,this.fnGetTableData(b))},fnSelect:null,fnComplete:null,fnInit:null,fnCellRender:null},xls:{sAction:"flash_save",sCharSet:"utf16le",bBomInc:!0,sFileName:"*.csv",sFieldBoundary:"",sFieldSeperator:"\t",
sNewLine:"auto",sTitle:"",sToolTip:"",sButtonClass:"DTTT_button_xls",sButtonClassHover:"DTTT_button_xls_hover",sButtonText:"Excel",mColumns:"all",bHeader:!0,bFooter:!0,bSelectedOnly:!1,fnMouseover:null,fnMouseout:null,fnClick:function(a,b,c){this.fnSetText(c,this.fnGetTableData(b))},fnSelect:null,fnComplete:null,fnInit:null,fnCellRender:null},copy:{sAction:"flash_copy",sFieldBoundary:"",sFieldSeperator:"\t",sNewLine:"auto",sToolTip:"",sButtonClass:"DTTT_button_copy",sButtonClassHover:"DTTT_button_copy_hover",
sButtonText:"Copy",mColumns:"all",bHeader:!0,bFooter:!0,bSelectedOnly:!1,fnMouseover:null,fnMouseout:null,fnClick:function(a,b,c){this.fnSetText(c,this.fnGetTableData(b))},fnSelect:null,fnComplete:function(a,b,c,d){a=d.split("\n").length;a=null===this.s.dt.nTFoot?a-1:a-2;alert("Copied "+a+" row"+(1==a?"":"s")+" to the clipboard")},fnInit:null,fnCellRender:null},pdf:{sAction:"flash_pdf",sFieldBoundary:"",sFieldSeperator:"\t",sNewLine:"\n",sFileName:"*.pdf",sToolTip:"",sTitle:"",sButtonClass:"DTTT_button_pdf",
sButtonClassHover:"DTTT_button_pdf_hover",sButtonText:"PDF",mColumns:"all",bHeader:!0,bFooter:!1,bSelectedOnly:!1,fnMouseover:null,fnMouseout:null,sPdfOrientation:"portrait",sPdfSize:"A4",sPdfMessage:"",fnClick:function(a,b,c){this.fnSetText(c,"title:"+this.fnGetTitle(b)+"\nmessage:"+b.sPdfMessage+"\ncolWidth:"+this.fnCalcColRatios(b)+"\norientation:"+b.sPdfOrientation+"\nsize:"+b.sPdfSize+"\n--/TableToolsOpts--\n"+this.fnGetTableData(b))},fnSelect:null,fnComplete:null,fnInit:null,fnCellRender:null},
print:{sAction:"print",sInfo:"<h6>Print view</h6><p>Please use your browser's print function to print this table. Press escape when finished.",sMessage:"",bShowAll:!0,sToolTip:"View print view",sButtonClass:"DTTT_button_print",sButtonClassHover:"DTTT_button_print_hover",sButtonText:"Print",fnMouseover:null,fnMouseout:null,fnClick:null,fnSelect:null,fnComplete:null,fnInit:null,fnCellRender:null},text:{sAction:"text",sToolTip:"",sButtonClass:"DTTT_button_text",sButtonClassHover:"DTTT_button_text_hover",
sButtonText:"Text button",mColumns:"all",bHeader:!0,bFooter:!0,bSelectedOnly:!1,fnMouseover:null,fnMouseout:null,fnClick:null,fnSelect:null,fnComplete:null,fnInit:null,fnCellRender:null},select:{sAction:"text",sToolTip:"",sButtonClass:"DTTT_button_text",sButtonClassHover:"DTTT_button_text_hover",sButtonText:"Select button",mColumns:"all",bHeader:!0,bFooter:!0,fnMouseover:null,fnMouseout:null,fnClick:null,fnSelect:function(a){0!==this.fnGetSelected().length?e(a).removeClass("DTTT_disabled"):e(a).addClass("DTTT_disabled")},
fnComplete:null,fnInit:function(a){e(a).addClass("DTTT_disabled")},fnCellRender:null},select_single:{sAction:"text",sToolTip:"",sButtonClass:"DTTT_button_text",sButtonClassHover:"DTTT_button_text_hover",sButtonText:"Select button",mColumns:"all",bHeader:!0,bFooter:!0,fnMouseover:null,fnMouseout:null,fnClick:null,fnSelect:function(a){1==this.fnGetSelected().length?e(a).removeClass("DTTT_disabled"):e(a).addClass("DTTT_disabled")},fnComplete:null,fnInit:function(a){e(a).addClass("DTTT_disabled")},fnCellRender:null},
select_all:{sAction:"text",sToolTip:"",sButtonClass:"DTTT_button_text",sButtonClassHover:"DTTT_button_text_hover",sButtonText:"Select all",mColumns:"all",bHeader:!0,bFooter:!0,fnMouseover:null,fnMouseout:null,fnClick:function(){this.fnSelectAll()},fnSelect:function(a){this.fnGetSelected().length==this.s.dt.fnRecordsDisplay()?e(a).addClass("DTTT_disabled"):e(a).removeClass("DTTT_disabled")},fnComplete:null,fnInit:null,fnCellRender:null},select_none:{sAction:"text",sToolTip:"",sButtonClass:"DTTT_button_text",
sButtonClassHover:"DTTT_button_text_hover",sButtonText:"Deselect all",mColumns:"all",bHeader:!0,bFooter:!0,fnMouseover:null,fnMouseout:null,fnClick:function(){this.fnSelectNone()},fnSelect:function(a){0!==this.fnGetSelected().length?e(a).removeClass("DTTT_disabled"):e(a).addClass("DTTT_disabled")},fnComplete:null,fnInit:function(a){e(a).addClass("DTTT_disabled")},fnCellRender:null},ajax:{sAction:"text",sFieldBoundary:"",sFieldSeperator:"\t",sNewLine:"\n",sAjaxUrl:"/xhr.php",sToolTip:"",sButtonClass:"DTTT_button_text",
sButtonClassHover:"DTTT_button_text_hover",sButtonText:"Ajax button",mColumns:"all",bHeader:!0,bFooter:!0,bSelectedOnly:!1,fnMouseover:null,fnMouseout:null,fnClick:function(a,b){var c=this.fnGetTableData(b);e.ajax({url:b.sAjaxUrl,data:[{name:"tableData",value:c}],success:b.fnAjaxComplete,dataType:"json",type:"POST",cache:!1,error:function(){alert("Error detected when sending table data to server")}})},fnSelect:null,fnComplete:null,fnInit:null,fnAjaxComplete:function(){alert("Ajax complete")},fnCellRender:null},
div:{sAction:"div",sToolTip:"",sButtonClass:"DTTT_nonbutton",sButtonClassHover:"",sButtonText:"Text button",fnMouseover:null,fnMouseout:null,fnClick:null,fnSelect:null,fnComplete:null,fnInit:null,nContent:null,fnCellRender:null},collection:{sAction:"collection",sToolTip:"",sButtonClass:"DTTT_button_collection",sButtonClassHover:"DTTT_button_collection_hover",sButtonText:"Collection",fnMouseover:null,fnMouseout:null,fnClick:function(a,b){this._fnCollectionShow(a,b)},fnSelect:null,fnComplete:null,fnInit:null,
fnCellRender:null}};TableTools.DEFAULTS={sSwfPath:"media/swf/copy_csv_xls_pdf.swf",sRowSelect:"none",sSelectedClass:"DTTT_selected",fnPreRowSelect:null,fnRowSelected:null,fnRowDeselected:null,aButtons:["copy","csv","xls","pdf","print"]};TableTools.prototype.CLASS="TableTools";TableTools.VERSION="2.0.3";TableTools.prototype.VERSION=TableTools.VERSION;"function"==typeof e.fn.dataTable&&"function"==typeof e.fn.dataTableExt.fnVersionCheck&&e.fn.dataTableExt.fnVersionCheck("1.8.2")?e.fn.dataTableExt.aoFeatures.push({fnInit:function(a){a=
new TableTools(a.oInstance,"undefined"!=typeof a.oInit.oTableTools?a.oInit.oTableTools:{});TableTools._aInstances.push(a);return a.dom.container},cFeature:"T",sFeature:"TableTools"}):alert("Warning: TableTools 2 requires DataTables 1.8.2 or newer - www.datatables.net/download")})(jQuery,window,document);

/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=ShowHide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*

    Copyright (c) 2009 Dana Woodman
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    
*/
(function($) {
    
    $.fn.showhide = function(options) {
        
        // Compile default options and user specified options.
        var opts = $.extend({}, $.fn.showhide.defaults, options);
        
        return $(this).each(function() {
            
            var obj = $(this);
            
            // Build element specific options.
            obj.o = $.meta ? $.extend({}, opts, $this.data()) : opts;
            
            // If there is a custom target object, use that, if not, use ".next()"
            if (obj.o.target_obj) {
                obj.o.target = obj.o.target_obj;
            } else {
                obj.o.target = obj.next();
            };
            
            // Set expiration of cookie, if it exists.
            if (obj.o.cookie_expires) {
                obj.o.cookie_options = {expires: obj.o.cookie_expires};
            }
            
            // Show function.
            show = function(object) {
                object.removeClass(object.o.plus_class);
                object.addClass(object.o.minus_class);
                if (object.o.minus_text) {
                    object.text(object.o.minus_text);
                };
                object.o.target.removeClass(object.o.hide_class);
                object.o.target.addClass(object.o.show_class);
                if (object.o.use_cookie) {
                    $.cookie(object.o.cookie_name, 'visible', object.o.cookie_options);
                };
                if (obj.o.focus_target) {
                    obj.o.focus_target.focus();
                };
            };
            
            // Hide function.
            hide = function(object) {
                object.removeClass(object.o.minus_class);
                object.addClass(object.o.plus_class);
                if (object.o.plus_text) {
                    object.text(object.o.plus_text);
                };
                object.o.target.removeClass(object.o.show_class);
                object.o.target.addClass(object.o.hide_class);
                if (object.o.use_cookie) {
                    $.cookie(object.o.cookie_name, 'hidden', object.o.cookie_options);
                };
            };
            
            // Using cookies.
            if (obj.o.use_cookie) {
                
                // Check for cookie. If set, set default state.
                if ($.cookie(obj.o.cookie_name)) {
                    if ($.cookie(obj.o.cookie_name) == 'visible') {
                        show(obj);
                    }
                    else if ($.cookie(obj.o.cookie_name) == 'hidden') {
                        hide(obj);
                    }
                    
                    // Shouldn't get here. If it does, set value to default.
                    else {
                        $.cookie(obj.o.cookie_name, obj.o.cookie_value);
                        if ($.cookie(obj.o.cookie_name) == 'visible') {
                            show(obj);
                            
                        }
                        else if ($.cookie(obj.o.cookie_name) == 'hidden') {
                            hide(obj);
                            
                        }
                    };
                }
                
                // If no cookie, set default state by setting.
                else {
                    $.cookie(obj.o.cookie_name, obj.o.cookie_value);
                    if (obj.o.default_open) {
                        show(obj);
                    }
                    else {
                        hide(obj);
                    }
                }
                
                // Handle clicks on toggle object.
                obj.click(function() {
                    if ($.cookie(obj.o.cookie_name) == 'visible') {
                        hide(obj);
                        opts.callback_hide.call(this);
                        return false;
                    }
                    else {
                        show(obj);
                        opts.callback_show.call(this);
                        return false;
                    };
                });
            }
            
            // Not using cookies.
            else {
                if (obj.o.default_open) { show(obj); }
                else { hide(obj); }
                
                // Handle clicks on toggle object.
                obj.click(function() {
                    if (obj.o.target.hasClass(obj.o.hide_class)) {
                        show(obj);
                        return false;
                    }
                    else if (obj.o.target.hasClass(obj.o.show_class)) {
                        hide(obj);
                        return false;
                    };
                });
            };
            
        });

    };
    
    $.fn.showhide.defaults = {
        target_obj: null, // An optional target jQuery object that will be show/hidden.
        focus_target: null, // An optional target jQuery object to focus text onto when showing the hidden element.
        default_open: true, // If true, the target will be show, if false it will be hidden by default. This is overridden by the cookie, if it is set.
        show_class: 'shown', // Class name to get applied to the link that shows the target.
        hide_class: 'hidden', // Class name to get applied to the link that hides the target.
        plus_class: 'plus', // Class name to get applied to the link that indicates it is expandable.
        plus_text: null,
        minus_class: 'minus', // Class name to get applied to the link that indicates it is contractable.
        minus_text: null,
        use_cookie: false, // If true, use a cookie to store the last chosen state. If false, do not use a cookie.
        cookie_expires: 365, // Number of days until cookie expires
        cookie_name: 'show_target', // A name for the cookie, this must be unique.
        callback_show: function() {},
        callback_hide: function() {}
    };
})(jQuery);


/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Multiselect
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*
 * jQuery UI Multiselect
 *
 * Authors:
 *  Michael Aufreiter (quasipartikel.at)
 *  Yanick Rochon (yanick.rochon[at]gmail[dot]com)
 * 
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 * 
 * http://www.quasipartikel.at/multiselect/
 *
 * 
 * Depends:
 *	ui.core.js
 *	ui.sortable.js
 *
 * Optional:
 * localization (http://plugins.jquery.com/project/localisation)
 * scrollTo (http://plugins.jquery.com/project/ScrollTo)
 * 
 * Todo:
 *  Make batch actions faster
 *  Implement dynamic insertion through remote calls
 */


(function($) {

$.widget("ui.multiselect", {
  options: {
		sortable: true,
		searchable: true,
		doubleClickable: true,
		animated: 'fast',
		show: 'slideDown',
		hide: 'slideUp',
		dividerLocation: 0.6,
		nodeComparator: function(node1,node2) {
			var text1 = node1.text(),
			    text2 = node2.text();
			return text1 == text2 ? 0 : (text1 < text2 ? -1 : 1);
		}
	},
	_create: function() {
		this.element.hide();
		this.id = this.element.attr("id");
		this.container = $('<div class="ui-multiselect ui-helper-clearfix ui-widget"></div>').insertAfter(this.element);
		this.count = 0; // number of currently selected options
		this.selectedContainer = $('<div class="selected ui-corner-right"></div>').appendTo(this.container);
		this.availableContainer = $('<div class="available ui-corner-left"></div>').appendTo(this.container);
		this.selectedActions = $('<div class="actions ui-widget-header ui-corner-tr ui-helper-clearfix"><span class="count">0 '+$.ui.multiselect.locale.itemsCount+'</span><a href="#" class="remove-all">'+$.ui.multiselect.locale.removeAll+'</a></div>').appendTo(this.selectedContainer);
		this.availableActions = $('<div class="actions ui-widget-header ui-corner-tl ui-helper-clearfix"><input type="text" class="search empty ui-widget-content ui-corner-all"/><a href="#" class="add-all">'+$.ui.multiselect.locale.addAll+'</a></div>').appendTo(this.availableContainer);
		this.selectedList = $('<ul class="selected connected-list"><li class="ui-helper-hidden-accessible"></li></ul>').bind('selectstart', function(){return false;}).appendTo(this.selectedContainer);
		this.availableList = $('<ul class="available connected-list"><li class="ui-helper-hidden-accessible"></li></ul>').bind('selectstart', function(){return false;}).appendTo(this.availableContainer);
		
		var that = this;

		// set dimensions
		// this.container.width(this.element.width()+1);
		// this.selectedContainer.width(Math.floor(this.element.width()*this.options.dividerLocation));
		// this.availableContainer.width(Math.floor(this.element.width()*(1-this.options.dividerLocation)));
		
		/* New dimensions designed for flexible-width containers */
		this.selectedContainer.width(Math.floor(this.container.width()*this.options.dividerLocation));
		this.availableContainer.width(Math.floor((this.container.width()*(1-this.options.dividerLocation))-10));
		
		// fix list height to match <option> depending on their individual header's heights
		this.selectedList.height(Math.max(this.element.height()-this.selectedActions.height(),1));
		this.availableList.height(Math.max(this.element.height()-this.availableActions.height(),1));
		
		if ( !this.options.animated ) {
			this.options.show = 'show';
			this.options.hide = 'hide';
		}
		
		// init lists
		this._populateLists(this.element.find('option'));
		
		// make selection sortable
		if (this.options.sortable) {
			this.selectedList.sortable({
				placeholder: 'ui-state-highlight',
				axis: 'y',
				update: function(event, ui) {
					// apply the new sort order to the original selectbox
					that.selectedList.find('li').each(function() {
						if ($(this).data('optionLink'))
							$(this).data('optionLink').remove().appendTo(that.element);
					});
				},
				receive: function(event, ui) {
					ui.item.data('optionLink').attr('selected', true);
					// increment count
					that.count += 1;
					that._updateCount();
					// workaround, because there's no way to reference 
					// the new element, see http://dev.jqueryui.com/ticket/4303
					that.selectedList.children('.ui-draggable').each(function() {
						$(this).removeClass('ui-draggable');
						$(this).data('optionLink', ui.item.data('optionLink'));
						$(this).data('idx', ui.item.data('idx'));
						that._applyItemState($(this), true);
					});
			
					// workaround according to http://dev.jqueryui.com/ticket/4088
					setTimeout(function() { ui.item.remove(); }, 1);
				}
			});
		}
		
		// set up livesearch
		if (this.options.searchable) {
			this._registerSearchEvents(this.availableContainer.find('input.search'));
		} else {
			$('.search').hide();
		}
		
		// batch actions
		this.container.find(".remove-all").click(function() {
			that._populateLists(that.element.find('option').removeAttr('selected'));
			return false;
		});
		
		this.container.find(".add-all").click(function() {
			var options = that.element.find('option').not(":selected");
			if (that.availableList.children('li:hidden').length > 1) {
				that.availableList.children('li').each(function(i) {
					if ($(this).is(":visible")) $(options[i-1]).attr('selected', 'selected'); 
				});
			} else {
				options.attr('selected', 'selected');
			}
			that._populateLists(that.element.find('option'));
			return false;
		});
	},
	destroy: function() {
		this.element.show();
		this.container.remove();

		$.Widget.prototype.destroy.apply(this, arguments);
	},
	_populateLists: function(options) {
		this.selectedList.children('.ui-element').remove();
		this.availableList.children('.ui-element').remove();
		this.count = 0;

		var that = this;
		var items = $(options.map(function(i) {
	      var item = that._getOptionNode(this).appendTo(this.selected ? that.selectedList : that.availableList).show();

			if (this.selected) that.count += 1;
			that._applyItemState(item, this.selected);
			item.data('idx', i);
			return item[0];
    }));
		
		// update count
		this._updateCount();
		that._filter.apply(this.availableContainer.find('input.search'), [that.availableList]);
  },
	_updateCount: function() {
		this.selectedContainer.find('span.count').text(this.count+" "+$.ui.multiselect.locale.itemsCount);
	},
	_getOptionNode: function(option) {
		option = $(option);
		var node = $('<li class="ui-state-default ui-element" title="'+option.text()+'"><span class="ui-icon"/>'+option.text()+'<a href="#" class="action"><span class="ui-corner-all ui-icon"/></a></li>').hide();
		node.data('optionLink', option);
		return node;
	},
	// clones an item with associated data
	// didn't find a smarter away around this
	_cloneWithData: function(clonee) {
		var clone = clonee.clone(false,false);
		clone.data('optionLink', clonee.data('optionLink'));
		clone.data('idx', clonee.data('idx'));
		return clone;
	},
	_setSelected: function(item, selected) {
		item.data('optionLink').attr('selected', selected);

		if (selected) {
			var selectedItem = this._cloneWithData(item);
			item[this.options.hide](this.options.animated, function() { $(this).remove(); });
			selectedItem.appendTo(this.selectedList).hide()[this.options.show](this.options.animated);
			
			this._applyItemState(selectedItem, true);
			return selectedItem;
		} else {
			
			// look for successor based on initial option index
			var items = this.availableList.find('li'), comparator = this.options.nodeComparator;
			var succ = null, i = item.data('idx'), direction = comparator(item, $(items[i]));

			// TODO: test needed for dynamic list populating
			if ( direction ) {
				while (i>=0 && i<items.length) {
					direction > 0 ? i++ : i--;
					if ( direction != comparator(item, $(items[i])) ) {
						// going up, go back one item down, otherwise leave as is
						succ = items[direction > 0 ? i : i+1];
						break;
					}
				}
			} else {
				succ = items[i];
			}
			
			var availableItem = this._cloneWithData(item);
			succ ? availableItem.insertBefore($(succ)) : availableItem.appendTo(this.availableList);
			item[this.options.hide](this.options.animated, function() { $(this).remove(); });
			availableItem.hide()[this.options.show](this.options.animated);
			
			this._applyItemState(availableItem, false);
			return availableItem;
		}
	},
	_applyItemState: function(item, selected) {
		if (selected) {
			if (this.options.sortable)
				item.children('span').addClass('ui-icon-arrowthick-2-n-s').removeClass('ui-helper-hidden').addClass('ui-icon');
			else
				item.children('span').removeClass('ui-icon-arrowthick-2-n-s').addClass('ui-helper-hidden').removeClass('ui-icon');
			item.find('a.action span').addClass('ui-icon-circle-minus').removeClass('ui-icon-circle-plus');
			this._registerRemoveEvents(item.find('a.action'));
			
		} else {
			item.children('span').removeClass('ui-icon-arrowthick-2-n-s').addClass('ui-helper-hidden').removeClass('ui-icon');
			item.find('a.action span').addClass('ui-icon-circle-plus').removeClass('ui-icon-circle-minus');
			this._registerAddEvents(item.find('a.action'));
		}
		
		this._registerDoubleClickEvents(item);
		this._registerHoverEvents(item);
	},
	// taken from John Resig's liveUpdate script
	_filter: function(list) {
		var input = $(this);
		var rows = list.children('li'),
			cache = rows.map(function(){
				
				return $(this).text().toLowerCase();
			});
		
		var term = $.trim(input.val().toLowerCase()), scores = [];
		
		if (!term) {
			rows.show();
		} else {
			rows.hide();

			cache.each(function(i) {
				if (this.indexOf(term)>-1) { scores.push(i); }
			});

			$.each(scores, function() {
				$(rows[this]).show();
			});
		}
	},
	_registerDoubleClickEvents: function(elements) {
		if (!this.options.doubleClickable) return;
		elements.dblclick(function() {
			elements.find('a.action').click();
		});
	},
	_registerHoverEvents: function(elements) {
		elements.removeClass('ui-state-hover');
		elements.mouseover(function() {
			$(this).addClass('ui-state-hover');
		});
		elements.mouseout(function() {
			$(this).removeClass('ui-state-hover');
		});
	},
	_registerAddEvents: function(elements) {
		var that = this;
		elements.click(function() {
			var item = that._setSelected($(this).parent(), true);
			that.count += 1;
			that._updateCount();
			return false;
		});
		
		// make draggable
		if (this.options.sortable) {
  		elements.each(function() {
  			$(this).parent().draggable({
  	      connectToSortable: that.selectedList,
  				helper: function() {
  					var selectedItem = that._cloneWithData($(this)).width($(this).width() - 50);
  					selectedItem.width($(this).width());
  					return selectedItem;
  				},
  				appendTo: that.container,
  				containment: that.container,
  				revert: 'invalid'
  	    });
  		});		  
		}
	},
	_registerRemoveEvents: function(elements) {
		var that = this;
		elements.click(function() {
			that._setSelected($(this).parent(), false);
			that.count -= 1;
			that._updateCount();
			return false;
		});
 	},
	_registerSearchEvents: function(input) {
		var that = this;

		input.focus(function() {
			$(this).addClass('ui-state-active');
		})
		.blur(function() {
			$(this).removeClass('ui-state-active');
		})
		.keypress(function(e) {
			if (e.keyCode == 13)
				return false;
		})
		.keyup(function() {
			that._filter.apply(this, [that.availableList]);
		});
	}
});
		
$.extend($.ui.multiselect, {
	locale: {
		addAll:'Add all',
		removeAll:'Remove all',
		itemsCount:'items selected'
	}
});		

})(jQuery);


/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Validate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/**
 * jQuery Validation Plugin 1.8.0
 *
 * http://bassistance.de/jquery-plugins/jquery-plugin-validation/
 * http://docs.jquery.com/Plugins/Validation
 *
 * Copyright (c) 2006 - 2011 J�rn Zaefferer
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
(function(c){c.extend(c.fn,{validate:function(a){if(this.length){var b=c.data(this[0],"validator");if(b)return b;b=new c.validator(a,this[0]);c.data(this[0],"validator",b);if(b.settings.onsubmit){this.find("input, button").filter(".cancel").click(function(){b.cancelSubmit=true});b.settings.submitHandler&&this.find("input, button").filter(":submit").click(function(){b.submitButton=this});this.submit(function(d){function e(){if(b.settings.submitHandler){if(b.submitButton)var f=c("<input type='hidden'/>").attr("name",
b.submitButton.name).val(b.submitButton.value).appendTo(b.currentForm);b.settings.submitHandler.call(b,b.currentForm);b.submitButton&&f.remove();return false}return true}b.settings.debug&&d.preventDefault();if(b.cancelSubmit){b.cancelSubmit=false;return e()}if(b.form()){if(b.pendingRequest){b.formSubmitted=true;return false}return e()}else{b.focusInvalid();return false}})}return b}else a&&a.debug&&window.console&&console.warn("nothing selected, can't validate, returning nothing")},valid:function(){if(c(this[0]).is("form"))return this.validate().form();
else{var a=true,b=c(this[0].form).validate();this.each(function(){a&=b.element(this)});return a}},removeAttrs:function(a){var b={},d=this;c.each(a.split(/\s/),function(e,f){b[f]=d.attr(f);d.removeAttr(f)});return b},rules:function(a,b){var d=this[0];if(a){var e=c.data(d.form,"validator").settings,f=e.rules,g=c.validator.staticRules(d);switch(a){case "add":c.extend(g,c.validator.normalizeRule(b));f[d.name]=g;if(b.messages)e.messages[d.name]=c.extend(e.messages[d.name],b.messages);break;case "remove":if(!b){delete f[d.name];
return g}var h={};c.each(b.split(/\s/),function(j,i){h[i]=g[i];delete g[i]});return h}}d=c.validator.normalizeRules(c.extend({},c.validator.metadataRules(d),c.validator.classRules(d),c.validator.attributeRules(d),c.validator.staticRules(d)),d);if(d.required){e=d.required;delete d.required;d=c.extend({required:e},d)}return d}});c.extend(c.expr[":"],{blank:function(a){return!c.trim(""+a.value)},filled:function(a){return!!c.trim(""+a.value)},unchecked:function(a){return!a.checked}});c.validator=function(a,
b){this.settings=c.extend(true,{},c.validator.defaults,a);this.currentForm=b;this.init()};c.validator.format=function(a,b){if(arguments.length==1)return function(){var d=c.makeArray(arguments);d.unshift(a);return c.validator.format.apply(this,d)};if(arguments.length>2&&b.constructor!=Array)b=c.makeArray(arguments).slice(1);if(b.constructor!=Array)b=[b];c.each(b,function(d,e){a=a.replace(RegExp("\\{"+d+"\\}","g"),e)});return a};c.extend(c.validator,{defaults:{messages:{},groups:{},rules:{},errorClass:"error",
validClass:"valid",errorElement:"label",focusInvalid:true,errorContainer:c([]),errorLabelContainer:c([]),onsubmit:true,ignore:[],ignoreTitle:false,onfocusin:function(a){this.lastActive=a;if(this.settings.focusCleanup&&!this.blockFocusCleanup){this.settings.unhighlight&&this.settings.unhighlight.call(this,a,this.settings.errorClass,this.settings.validClass);this.addWrapper(this.errorsFor(a)).hide()}},onfocusout:function(a){if(!this.checkable(a)&&(a.name in this.submitted||!this.optional(a)))this.element(a)},
onkeyup:function(a){if(a.name in this.submitted||a==this.lastElement)this.element(a)},onclick:function(a){if(a.name in this.submitted)this.element(a);else a.parentNode.name in this.submitted&&this.element(a.parentNode)},highlight:function(a,b,d){c(a).addClass(b).removeClass(d)},unhighlight:function(a,b,d){c(a).removeClass(b).addClass(d)}},setDefaults:function(a){c.extend(c.validator.defaults,a)},messages:{required:"This field is required.",remote:"Please fix this field.",email:"Please enter a valid email address.",
url:"Please enter a valid URL.",date:"Please enter a valid date.",dateISO:"Please enter a valid date (ISO).",number:"Please enter a valid number.",digits:"Please enter only digits.",creditcard:"Please enter a valid credit card number.",equalTo:"Please enter the same value again.",accept:"Please enter a value with a valid extension.",maxlength:c.validator.format("Please enter no more than {0} characters."),minlength:c.validator.format("Please enter at least {0} characters."),rangelength:c.validator.format("Please enter a value between {0} and {1} characters long."),
range:c.validator.format("Please enter a value between {0} and {1}."),max:c.validator.format("Please enter a value less than or equal to {0}."),min:c.validator.format("Please enter a value greater than or equal to {0}.")},autoCreateRanges:false,prototype:{init:function(){function a(e){var f=c.data(this[0].form,"validator");e="on"+e.type.replace(/^validate/,"");f.settings[e]&&f.settings[e].call(f,this[0])}this.labelContainer=c(this.settings.errorLabelContainer);this.errorContext=this.labelContainer.length&&
this.labelContainer||c(this.currentForm);this.containers=c(this.settings.errorContainer).add(this.settings.errorLabelContainer);this.submitted={};this.valueCache={};this.pendingRequest=0;this.pending={};this.invalid={};this.reset();var b=this.groups={};c.each(this.settings.groups,function(e,f){c.each(f.split(/\s/),function(g,h){b[h]=e})});var d=this.settings.rules;c.each(d,function(e,f){d[e]=c.validator.normalizeRule(f)});c(this.currentForm).validateDelegate(":text, :password, :file, select, textarea",
"focusin focusout keyup",a).validateDelegate(":radio, :checkbox, select, option","click",a);this.settings.invalidHandler&&c(this.currentForm).bind("invalid-form.validate",this.settings.invalidHandler)},form:function(){this.checkForm();c.extend(this.submitted,this.errorMap);this.invalid=c.extend({},this.errorMap);this.valid()||c(this.currentForm).triggerHandler("invalid-form",[this]);this.showErrors();return this.valid()},checkForm:function(){this.prepareForm();for(var a=0,b=this.currentElements=this.elements();b[a];a++)this.check(b[a]);
return this.valid()},element:function(a){this.lastElement=a=this.clean(a);this.prepareElement(a);this.currentElements=c(a);var b=this.check(a);if(b)delete this.invalid[a.name];else this.invalid[a.name]=true;if(!this.numberOfInvalids())this.toHide=this.toHide.add(this.containers);this.showErrors();return b},showErrors:function(a){if(a){c.extend(this.errorMap,a);this.errorList=[];for(var b in a)this.errorList.push({message:a[b],element:this.findByName(b)[0]});this.successList=c.grep(this.successList,
function(d){return!(d.name in a)})}this.settings.showErrors?this.settings.showErrors.call(this,this.errorMap,this.errorList):this.defaultShowErrors()},resetForm:function(){c.fn.resetForm&&c(this.currentForm).resetForm();this.submitted={};this.prepareForm();this.hideErrors();this.elements().removeClass(this.settings.errorClass)},numberOfInvalids:function(){return this.objectLength(this.invalid)},objectLength:function(a){var b=0,d;for(d in a)b++;return b},hideErrors:function(){this.addWrapper(this.toHide).hide()},
valid:function(){return this.size()==0},size:function(){return this.errorList.length},focusInvalid:function(){if(this.settings.focusInvalid)try{c(this.findLastActive()||this.errorList.length&&this.errorList[0].element||[]).filter(":visible").focus().trigger("focusin")}catch(a){}},findLastActive:function(){var a=this.lastActive;return a&&c.grep(this.errorList,function(b){return b.element.name==a.name}).length==1&&a},elements:function(){var a=this,b={};return c([]).add(this.currentForm.elements).filter(":input").not(":submit, :reset, :image, [disabled]").not(this.settings.ignore).filter(function(){!this.name&&
a.settings.debug&&window.console&&console.error("%o has no name assigned",this);if(this.name in b||!a.objectLength(c(this).rules()))return false;return b[this.name]=true})},clean:function(a){return c(a)[0]},errors:function(){return c(this.settings.errorElement+"."+this.settings.errorClass,this.errorContext)},reset:function(){this.successList=[];this.errorList=[];this.errorMap={};this.toShow=c([]);this.toHide=c([]);this.currentElements=c([])},prepareForm:function(){this.reset();this.toHide=this.errors().add(this.containers)},
prepareElement:function(a){this.reset();this.toHide=this.errorsFor(a)},check:function(a){a=this.clean(a);if(this.checkable(a))a=this.findByName(a.name).not(this.settings.ignore)[0];var b=c(a).rules(),d=false,e;for(e in b){var f={method:e,parameters:b[e]};try{var g=c.validator.methods[e].call(this,a.value.replace(/\r/g,""),a,f.parameters);if(g=="dependency-mismatch")d=true;else{d=false;if(g=="pending"){this.toHide=this.toHide.not(this.errorsFor(a));return}if(!g){this.formatAndAdd(a,f);return false}}}catch(h){this.settings.debug&&
window.console&&console.log("exception occured when checking element "+a.id+", check the '"+f.method+"' method",h);throw h;}}if(!d){this.objectLength(b)&&this.successList.push(a);return true}},customMetaMessage:function(a,b){if(c.metadata){var d=this.settings.meta?c(a).metadata()[this.settings.meta]:c(a).metadata();return d&&d.messages&&d.messages[b]}},customMessage:function(a,b){var d=this.settings.messages[a];return d&&(d.constructor==String?d:d[b])},findDefined:function(){for(var a=0;a<arguments.length;a++)if(arguments[a]!==
undefined)return arguments[a]},defaultMessage:function(a,b){return this.findDefined(this.customMessage(a.name,b),this.customMetaMessage(a,b),!this.settings.ignoreTitle&&a.title||undefined,c.validator.messages[b],"<strong>Warning: No message defined for "+a.name+"</strong>")},formatAndAdd:function(a,b){var d=this.defaultMessage(a,b.method),e=/\$?\{(\d+)\}/g;if(typeof d=="function")d=d.call(this,b.parameters,a);else if(e.test(d))d=jQuery.format(d.replace(e,"{$1}"),b.parameters);this.errorList.push({message:d,
element:a});this.errorMap[a.name]=d;this.submitted[a.name]=d},addWrapper:function(a){if(this.settings.wrapper)a=a.add(a.parent(this.settings.wrapper));return a},defaultShowErrors:function(){for(var a=0;this.errorList[a];a++){var b=this.errorList[a];this.settings.highlight&&this.settings.highlight.call(this,b.element,this.settings.errorClass,this.settings.validClass);this.showLabel(b.element,b.message)}if(this.errorList.length)this.toShow=this.toShow.add(this.containers);if(this.settings.success)for(a=
0;this.successList[a];a++)this.showLabel(this.successList[a]);if(this.settings.unhighlight){a=0;for(b=this.validElements();b[a];a++)this.settings.unhighlight.call(this,b[a],this.settings.errorClass,this.settings.validClass)}this.toHide=this.toHide.not(this.toShow);this.hideErrors();this.addWrapper(this.toShow).show()},validElements:function(){return this.currentElements.not(this.invalidElements())},invalidElements:function(){return c(this.errorList).map(function(){return this.element})},showLabel:function(a,
b){var d=this.errorsFor(a);if(d.length){d.removeClass().addClass(this.settings.errorClass);d.attr("generated")&&d.html(b)}else{d=c("<"+this.settings.errorElement+"/>").attr({"for":this.idOrName(a),generated:true}).addClass(this.settings.errorClass).html(b||"");if(this.settings.wrapper)d=d.hide().show().wrap("<"+this.settings.wrapper+"/>").parent();this.labelContainer.append(d).length||(this.settings.errorPlacement?this.settings.errorPlacement(d,c(a)):d.insertAfter(a))}if(!b&&this.settings.success){d.text("");
typeof this.settings.success=="string"?d.addClass(this.settings.success):this.settings.success(d)}this.toShow=this.toShow.add(d)},errorsFor:function(a){var b=this.idOrName(a);return this.errors().filter(function(){return c(this).attr("for")==b})},idOrName:function(a){return this.groups[a.name]||(this.checkable(a)?a.name:a.id||a.name)},checkable:function(a){return/radio|checkbox/i.test(a.type)},findByName:function(a){var b=this.currentForm;return c(document.getElementsByName(a)).map(function(d,e){return e.form==
b&&e.name==a&&e||null})},getLength:function(a,b){switch(b.nodeName.toLowerCase()){case "select":return c("option:selected",b).length;case "input":if(this.checkable(b))return this.findByName(b.name).filter(":checked").length}return a.length},depend:function(a,b){return this.dependTypes[typeof a]?this.dependTypes[typeof a](a,b):true},dependTypes:{"boolean":function(a){return a},string:function(a,b){return!!c(a,b.form).length},"function":function(a,b){return a(b)}},optional:function(a){return!c.validator.methods.required.call(this,
c.trim(a.value),a)&&"dependency-mismatch"},startRequest:function(a){if(!this.pending[a.name]){this.pendingRequest++;this.pending[a.name]=true}},stopRequest:function(a,b){this.pendingRequest--;if(this.pendingRequest<0)this.pendingRequest=0;delete this.pending[a.name];if(b&&this.pendingRequest==0&&this.formSubmitted&&this.form()){c(this.currentForm).submit();this.formSubmitted=false}else if(!b&&this.pendingRequest==0&&this.formSubmitted){c(this.currentForm).triggerHandler("invalid-form",[this]);this.formSubmitted=
false}},previousValue:function(a){return c.data(a,"previousValue")||c.data(a,"previousValue",{old:null,valid:true,message:this.defaultMessage(a,"remote")})}},classRuleSettings:{required:{required:true},email:{email:true},url:{url:true},date:{date:true},dateISO:{dateISO:true},dateDE:{dateDE:true},number:{number:true},numberDE:{numberDE:true},digits:{digits:true},creditcard:{creditcard:true}},addClassRules:function(a,b){a.constructor==String?this.classRuleSettings[a]=b:c.extend(this.classRuleSettings,
a)},classRules:function(a){var b={};(a=c(a).attr("class"))&&c.each(a.split(" "),function(){this in c.validator.classRuleSettings&&c.extend(b,c.validator.classRuleSettings[this])});return b},attributeRules:function(a){var b={};a=c(a);for(var d in c.validator.methods){var e=a.attr(d);if(e)b[d]=e}b.maxlength&&/-1|2147483647|524288/.test(b.maxlength)&&delete b.maxlength;return b},metadataRules:function(a){if(!c.metadata)return{};var b=c.data(a.form,"validator").settings.meta;return b?c(a).metadata()[b]:
c(a).metadata()},staticRules:function(a){var b={},d=c.data(a.form,"validator");if(d.settings.rules)b=c.validator.normalizeRule(d.settings.rules[a.name])||{};return b},normalizeRules:function(a,b){c.each(a,function(d,e){if(e===false)delete a[d];else if(e.param||e.depends){var f=true;switch(typeof e.depends){case "string":f=!!c(e.depends,b.form).length;break;case "function":f=e.depends.call(b,b)}if(f)a[d]=e.param!==undefined?e.param:true;else delete a[d]}});c.each(a,function(d,e){a[d]=c.isFunction(e)?
e(b):e});c.each(["minlength","maxlength","min","max"],function(){if(a[this])a[this]=Number(a[this])});c.each(["rangelength","range"],function(){if(a[this])a[this]=[Number(a[this][0]),Number(a[this][1])]});if(c.validator.autoCreateRanges){if(a.min&&a.max){a.range=[a.min,a.max];delete a.min;delete a.max}if(a.minlength&&a.maxlength){a.rangelength=[a.minlength,a.maxlength];delete a.minlength;delete a.maxlength}}a.messages&&delete a.messages;return a},normalizeRule:function(a){if(typeof a=="string"){var b=
{};c.each(a.split(/\s/),function(){b[this]=true});a=b}return a},addMethod:function(a,b,d){c.validator.methods[a]=b;c.validator.messages[a]=d!=undefined?d:c.validator.messages[a];b.length<3&&c.validator.addClassRules(a,c.validator.normalizeRule(a))},methods:{required:function(a,b,d){if(!this.depend(d,b))return"dependency-mismatch";switch(b.nodeName.toLowerCase()){case "select":return(a=c(b).val())&&a.length>0;case "input":if(this.checkable(b))return this.getLength(a,b)>0;default:return c.trim(a).length>
0}},remote:function(a,b,d){if(this.optional(b))return"dependency-mismatch";var e=this.previousValue(b);this.settings.messages[b.name]||(this.settings.messages[b.name]={});e.originalMessage=this.settings.messages[b.name].remote;this.settings.messages[b.name].remote=e.message;d=typeof d=="string"&&{url:d}||d;if(this.pending[b.name])return"pending";if(e.old===a)return e.valid;e.old=a;var f=this;this.startRequest(b);var g={};g[b.name]=a;c.ajax(c.extend(true,{url:d,mode:"abort",port:"validate"+b.name,
dataType:"json",data:g,success:function(h){f.settings.messages[b.name].remote=e.originalMessage;var j=h===true;if(j){var i=f.formSubmitted;f.prepareElement(b);f.formSubmitted=i;f.successList.push(b);f.showErrors()}else{i={};h=h||f.defaultMessage(b,"remote");i[b.name]=e.message=c.isFunction(h)?h(a):h;f.showErrors(i)}e.valid=j;f.stopRequest(b,j)}},d));return"pending"},minlength:function(a,b,d){return this.optional(b)||this.getLength(c.trim(a),b)>=d},maxlength:function(a,b,d){return this.optional(b)||
this.getLength(c.trim(a),b)<=d},rangelength:function(a,b,d){a=this.getLength(c.trim(a),b);return this.optional(b)||a>=d[0]&&a<=d[1]},min:function(a,b,d){return this.optional(b)||a>=d},max:function(a,b,d){return this.optional(b)||a<=d},range:function(a,b,d){return this.optional(b)||a>=d[0]&&a<=d[1]},email:function(a,b){return this.optional(b)||/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i.test(a)},
url:function(a,b){return this.optional(b)||/^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(a)},
date:function(a,b){return this.optional(b)||!/Invalid|NaN/.test(new Date(a))},dateISO:function(a,b){return this.optional(b)||/^\d{4}[\/-]\d{1,2}[\/-]\d{1,2}$/.test(a)},number:function(a,b){return this.optional(b)||/^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$/.test(a)},digits:function(a,b){return this.optional(b)||/^\d+$/.test(a)},creditcard:function(a,b){if(this.optional(b))return"dependency-mismatch";if(/[^0-9-]+/.test(a))return false;var d=0,e=0,f=false;a=a.replace(/\D/g,"");for(var g=a.length-1;g>=
0;g--){e=a.charAt(g);e=parseInt(e,10);if(f)if((e*=2)>9)e-=9;d+=e;f=!f}return d%10==0},accept:function(a,b,d){d=typeof d=="string"?d.replace(/,/g,"|"):"png|jpe?g|gif";return this.optional(b)||a.match(RegExp(".("+d+")$","i"))},equalTo:function(a,b,d){d=c(d).unbind(".validate-equalTo").bind("blur.validate-equalTo",function(){c(b).valid()});return a==d.val()}}});c.format=c.validator.format})(jQuery);
(function(c){var a={};if(c.ajaxPrefilter)c.ajaxPrefilter(function(d,e,f){e=d.port;if(d.mode=="abort"){a[e]&&a[e].abort();a[e]=f}});else{var b=c.ajax;c.ajax=function(d){var e=("port"in d?d:c.ajaxSettings).port;if(("mode"in d?d:c.ajaxSettings).mode=="abort"){a[e]&&a[e].abort();return a[e]=b.apply(this,arguments)}return b.apply(this,arguments)}}})(jQuery);
(function(c){!jQuery.event.special.focusin&&!jQuery.event.special.focusout&&document.addEventListener&&c.each({focus:"focusin",blur:"focusout"},function(a,b){function d(e){e=c.event.fix(e);e.type=b;return c.event.handle.call(this,e)}c.event.special[b]={setup:function(){this.addEventListener(a,d,true)},teardown:function(){this.removeEventListener(a,d,true)},handler:function(e){arguments[0]=c.event.fix(e);arguments[0].type=b;return c.event.handle.apply(this,arguments)}}});c.extend(c.fn,{validateDelegate:function(a,
b,d){return this.bind(b,function(e){var f=c(e.target);if(f.is(a))return d.apply(f,arguments)})}})})(jQuery);

/* ' */
/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Reveal Modal
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*
 * jQuery Reveal Plugin 1.0
 * www.ZURB.com
 * Copyright 2010, ZURB
 * Free to use under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
*/


(function($) {

/*---------------------------
 Defaults for Reveal
----------------------------*/
	 
/*---------------------------
 Listener for data-reveal-id attributes
----------------------------*/

	$('a[data-reveal-id]').live('click', function(e) {
		e.preventDefault();
		var modalLocation = $(this).attr('data-reveal-id');
		$('#' + modalLocation).reveal($(this).data());
		//$('#tooltip-sticky').hide();
	});

/*---------------------------
 Extend and Execute
----------------------------*/

    $.fn.reveal = function(options) {
        
        
        var defaults = {  
	    	animation: 'fadeAndPop', //fade, fadeAndPop, none
		    animationspeed: 300, //how fast animtions are
		    closeonbackgroundclick: true, //if you click background will modal close?
		    dismissmodalclass: 'close-reveal-modal' //the class of a button or element that will close an open modal
    	}; 
    	
        //Extend dem options
        var options = $.extend({}, defaults, options); 
	
        return this.each(function() {
        
/*---------------------------
 Global Variables
----------------------------*/
        	var modal = $(this),
        		topMeasure  = parseInt(modal.css('top')),
				topOffset = modal.height() + topMeasure,
          		locked = false,
				modalBG = $('.reveal-modal-bg');

/*---------------------------
 Create Modal BG
----------------------------*/
			if(modalBG.length == 0) {
				modalBG = $('<div class="reveal-modal-bg" />').insertAfter(modal);
			}		    
        	
/*---------------------------
 Open and add Closing Listeners
----------------------------*/
        	//Open Modal Immediately
    		openModal();
			
			//Close Modal Listeners
			var closeButton = $('.' + options.dismissmodalclass).bind('click.modalEvent',closeModal)
			if(options.closeonbackgroundclick) {
				modalBG.css({"cursor":"pointer"})
				modalBG.bind('click.modalEvent',closeModal)
			}
			
    		
/*---------------------------
 Open & Close Animations
----------------------------*/
			//Entrance Animations
			function openModal() {
				$('#tooltip-sticky').hide();
				modalBG.unbind('click.modalEvent');
				$('.' + options.dismissmodalclass).unbind('click.modalEvent');
				if(!locked) {
					lockModal();
					if(options.animation == "fadeAndPop") {
						modal.css({'top': $(document).scrollTop()-topOffset, 'opacity' : 0, 'visibility' : 'visible'});
						modalBG.fadeIn(options.animationspeed/2);
						modal.delay(options.animationspeed/2).animate({
							"top": $(document).scrollTop()+topMeasure,
							"opacity" : 1
						}, options.animationspeed,unlockModal());					
					}
					if(options.animation == "fade") {
						modal.css({'opacity' : 0, 'visibility' : 'visible', 'top': $(document).scrollTop()+topMeasure});
						modalBG.fadeIn(options.animationspeed/2);
						modal.delay(options.animationspeed/2).animate({
							"opacity" : 1
						}, options.animationspeed,unlockModal());					
					} 
					if(options.animation == "none") {
						modal.css({'visibility' : 'visible', 'top':$(document).scrollTop()+topMeasure});
						modalBG.css({"display":"block"});	
						unlockModal()				
					}   
				}
			}
			
			//Closing Animation
			function closeModal() {
				$('#tooltip-sticky').hide();
				if(!locked) {
					lockModal();
					if(options.animation == "fadeAndPop") {
						modalBG.delay(options.animationspeed).fadeOut(options.animationspeed);
						modal.animate({
							"top":  $(document).scrollTop()-topOffset,
							"opacity" : 0
						}, options.animationspeed/2, function() {
							modal.css({'top':topMeasure, 'opacity' : 1, 'visibility' : 'hidden'});
							unlockModal();
						});					
					}  	
					if(options.animation == "fade") {
						modalBG.delay(options.animationspeed).fadeOut(options.animationspeed);
						modal.animate({
							"opacity" : 0
						}, options.animationspeed, function() {
							modal.css({'opacity' : 1, 'visibility' : 'hidden', 'top' : topMeasure});
							unlockModal();
						});					
					}  	
					if(options.animation == "none") {
						modal.css({'visibility' : 'hidden', 'top' : topMeasure});
						modalBG.css({'display' : 'none'});	
					}   			
				}
			}
			
/*---------------------------
 Animations Locks
----------------------------*/
			function unlockModal() { 
				locked = false;
			}
			function lockModal() {
				locked = true;
			}	
			
        });//each call
    }//orbit plugin call
})(jQuery);
        

/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=BlockUI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*!
 * jQuery blockUI plugin
 * Version 2.39 (23-MAY-2011)
 * @requires jQuery v1.2.3 or later
 *
 * Examples at: http://malsup.com/jquery/block/
 * Copyright (c) 2007-2010 M. Alsup
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * Thanks to Amir-Hossein Sobhi for some excellent contributions!
 */

;(function($) {

if (/1\.(0|1|2)\.(0|1|2)/.test($.fn.jquery) || /^1.1/.test($.fn.jquery)) {
	alert('blockUI requires jQuery v1.2.3 or later!  You are using v' + $.fn.jquery);
	return;
}

$.fn._fadeIn = $.fn.fadeIn;

var noOp = function() {};

// this bit is to ensure we don't call setExpression when we shouldn't (with extra muscle to handle
// retarded userAgent strings on Vista)
var mode = document.documentMode || 0;
var setExpr = $.browser.msie && (($.browser.version < 8 && !mode) || mode < 8);
var ie6 = $.browser.msie && /MSIE 6.0/.test(navigator.userAgent) && !mode;

// global $ methods for blocking/unblocking the entire page
$.blockUI   = function(opts) { install(window, opts); };
$.unblockUI = function(opts) { remove(window, opts); };

// convenience method for quick growl-like notifications  (http://www.google.com/search?q=growl)
$.growlUI = function(title, message, timeout, onClose) {
	var $m = $('<div class="growlUI"></div>');
	if (title) $m.append('<h1>'+title+'</h1>');
	if (message) $m.append('<h2>'+message+'</h2>');
	if (timeout == undefined) timeout = 3000;
	$.blockUI({
		message: $m, fadeIn: 700, fadeOut: 1000, centerY: false,
		timeout: timeout, showOverlay: false,
		onUnblock: onClose, 
		css: $.blockUI.defaults.growlCSS
	});
};

// plugin method for blocking element content
$.fn.block = function(opts) {
	return this.unblock({ fadeOut: 0 }).each(function() {
		if ($.css(this,'position') == 'static')
			this.style.position = 'relative';
		if ($.browser.msie)
			this.style.zoom = 1; // force 'hasLayout'
		install(this, opts);
	});
};

// plugin method for unblocking element content
$.fn.unblock = function(opts) {
	return this.each(function() {
		remove(this, opts);
	});
};

$.blockUI.version = 2.39; // 2nd generation blocking at no extra cost!

// override these in your code to change the default behavior and style
$.blockUI.defaults = {
	// message displayed when blocking (use null for no message)
	message:  '<h1>Please wait...</h1>',

	title: null,	  // title string; only used when theme == true
	draggable: true,  // only used when theme == true (requires jquery-ui.js to be loaded)
	
	theme: false, // set to true to use with jQuery UI themes
	
	// styles for the message when blocking; if you wish to disable
	// these and use an external stylesheet then do this in your code:
	// $.blockUI.defaults.css = {};
	css: {
		padding:	0,
		margin:		0,
		width:		'30%',
		top:		'40%',
		left:		'35%',
		textAlign:	'center',
		color:		'#000',
		border:		'3px solid #aaa',
		backgroundColor:'#fff',
		cursor:		'wait'
	},
	
	// minimal style set used when themes are used
	themedCSS: {
		width:	'30%',
		top:	'40%',
		left:	'35%'
	},

	// styles for the overlay
	overlayCSS:  {
		backgroundColor: '#000',
		opacity:	  	 0.6,
		cursor:		  	 'wait'
	},

	// styles applied when using $.growlUI
	growlCSS: {
		width:  	'350px',
		top:		'10px',
		left:   	'',
		right:  	'10px',
		border: 	'none',
		padding:	'5px',
		opacity:	0.6,
		cursor: 	'default',
		color:		'#fff',
		backgroundColor: '#000',
		'-webkit-border-radius': '10px',
		'-moz-border-radius':	 '10px',
		'border-radius': 		 '10px'
	},
	
	// IE issues: 'about:blank' fails on HTTPS and javascript:false is s-l-o-w
	// (hat tip to Jorge H. N. de Vasconcelos)
	iframeSrc: /^https/i.test(window.location.href || '') ? 'javascript:false' : 'about:blank',

	// force usage of iframe in non-IE browsers (handy for blocking applets)
	forceIframe: false,

	// z-index for the blocking overlay
	baseZ: 1000,

	// set these to true to have the message automatically centered
	centerX: true, // <-- only effects element blocking (page block controlled via css above)
	centerY: true,

	// allow body element to be stetched in ie6; this makes blocking look better
	// on "short" pages.  disable if you wish to prevent changes to the body height
	allowBodyStretch: true,

	// enable if you want key and mouse events to be disabled for content that is blocked
	bindEvents: true,

	// be default blockUI will supress tab navigation from leaving blocking content
	// (if bindEvents is true)
	constrainTabKey: true,

	// fadeIn time in millis; set to 0 to disable fadeIn on block
	fadeIn:  200,

	// fadeOut time in millis; set to 0 to disable fadeOut on unblock
	fadeOut:  400,

	// time in millis to wait before auto-unblocking; set to 0 to disable auto-unblock
	timeout: 0,

	// disable if you don't want to show the overlay
	showOverlay: true,

	// if true, focus will be placed in the first available input field when
	// page blocking
	focusInput: true,

	// suppresses the use of overlay styles on FF/Linux (due to performance issues with opacity)
	applyPlatformOpacityRules: true,
	
	// callback method invoked when fadeIn has completed and blocking message is visible
	onBlock: null,

	// callback method invoked when unblocking has completed; the callback is
	// passed the element that has been unblocked (which is the window object for page
	// blocks) and the options that were passed to the unblock call:
	//	 onUnblock(element, options)
	onUnblock: null,

	// don't ask; if you really must know: http://groups.google.com/group/jquery-en/browse_thread/thread/36640a8730503595/2f6a79a77a78e493#2f6a79a77a78e493
	quirksmodeOffsetHack: 4,

	// class name of the message block
	blockMsgClass: 'blockMsg'
};

// private data and functions follow...

var pageBlock = null;
var pageBlockEls = [];

function install(el, opts) {
	var full = (el == window);
	var msg = opts && opts.message !== undefined ? opts.message : undefined;
	opts = $.extend({}, $.blockUI.defaults, opts || {});
	opts.overlayCSS = $.extend({}, $.blockUI.defaults.overlayCSS, opts.overlayCSS || {});
	var css = $.extend({}, $.blockUI.defaults.css, opts.css || {});
	var themedCSS = $.extend({}, $.blockUI.defaults.themedCSS, opts.themedCSS || {});
	msg = msg === undefined ? opts.message : msg;

	// remove the current block (if there is one)
	if (full && pageBlock)
		remove(window, {fadeOut:0});

	// if an existing element is being used as the blocking content then we capture
	// its current place in the DOM (and current display style) so we can restore
	// it when we unblock
	if (msg && typeof msg != 'string' && (msg.parentNode || msg.jquery)) {
		var node = msg.jquery ? msg[0] : msg;
		var data = {};
		$(el).data('blockUI.history', data);
		data.el = node;
		data.parent = node.parentNode;
		data.display = node.style.display;
		data.position = node.style.position;
		if (data.parent)
			data.parent.removeChild(node);
	}

	$(el).data('blockUI.onUnblock', opts.onUnblock);
	var z = opts.baseZ;

	// blockUI uses 3 layers for blocking, for simplicity they are all used on every platform;
	// layer1 is the iframe layer which is used to supress bleed through of underlying content
	// layer2 is the overlay layer which has opacity and a wait cursor (by default)
	// layer3 is the message content that is displayed while blocking

	var lyr1 = ($.browser.msie || opts.forceIframe) 
		? $('<iframe class="blockUI" style="z-index:'+ (z++) +';display:none;border:none;margin:0;padding:0;position:absolute;width:100%;height:100%;top:0;left:0" src="'+opts.iframeSrc+'"></iframe>')
		: $('<div class="blockUI" style="display:none"></div>');
	
	var lyr2 = opts.theme 
	 	? $('<div class="blockUI blockOverlay ui-widget-overlay" style="z-index:'+ (z++) +';display:none"></div>')
	 	: $('<div class="blockUI blockOverlay" style="z-index:'+ (z++) +';display:none;border:none;margin:0;padding:0;width:100%;height:100%;top:0;left:0"></div>');

	var lyr3, s;
	if (opts.theme && full) {
		s = '<div class="blockUI ' + opts.blockMsgClass + ' blockPage ui-dialog ui-widget ui-corner-all" style="z-index:'+(z+10)+';display:none;position:fixed">' +
				'<div class="ui-widget-header ui-dialog-titlebar ui-corner-all blockTitle">'+(opts.title || '&nbsp;')+'</div>' +
				'<div class="ui-widget-content ui-dialog-content"></div>' +
			'</div>';
	}
	else if (opts.theme) {
		s = '<div class="blockUI ' + opts.blockMsgClass + ' blockElement ui-dialog ui-widget ui-corner-all" style="z-index:'+(z+10)+';display:none;position:absolute">' +
				'<div class="ui-widget-header ui-dialog-titlebar ui-corner-all blockTitle">'+(opts.title || '&nbsp;')+'</div>' +
				'<div class="ui-widget-content ui-dialog-content"></div>' +
			'</div>';
	}
	else if (full) {
		s = '<div class="blockUI ' + opts.blockMsgClass + ' blockPage" style="z-index:'+(z+10)+';display:none;position:fixed"></div>';
	}			 
	else {
		s = '<div class="blockUI ' + opts.blockMsgClass + ' blockElement" style="z-index:'+(z+10)+';display:none;position:absolute"></div>';
	}
	lyr3 = $(s);

	// if we have a message, style it
	if (msg) {
		if (opts.theme) {
			lyr3.css(themedCSS);
			lyr3.addClass('ui-widget-content');
		}
		else 
			lyr3.css(css);
	}

	// style the overlay
	if (!opts.theme && (!opts.applyPlatformOpacityRules || !($.browser.mozilla && /Linux/.test(navigator.platform))))
		lyr2.css(opts.overlayCSS);
	lyr2.css('position', full ? 'fixed' : 'absolute');

	// make iframe layer transparent in IE
	if ($.browser.msie || opts.forceIframe)
		lyr1.css('opacity',0.0);

	//$([lyr1[0],lyr2[0],lyr3[0]]).appendTo(full ? 'body' : el);
	var layers = [lyr1,lyr2,lyr3], $par = full ? $('body') : $(el);
	$.each(layers, function() {
		this.appendTo($par);
	});
	
	if (opts.theme && opts.draggable && $.fn.draggable) {
		lyr3.draggable({
			handle: '.ui-dialog-titlebar',
			cancel: 'li'
		});
	}

	// ie7 must use absolute positioning in quirks mode and to account for activex issues (when scrolling)
	var expr = setExpr && (!$.boxModel || $('object,embed', full ? null : el).length > 0);
	if (ie6 || expr) {
		// give body 100% height
		if (full && opts.allowBodyStretch && $.boxModel)
			$('html,body').css('height','100%');

		// fix ie6 issue when blocked element has a border width
		if ((ie6 || !$.boxModel) && !full) {
			var t = sz(el,'borderTopWidth'), l = sz(el,'borderLeftWidth');
			var fixT = t ? '(0 - '+t+')' : 0;
			var fixL = l ? '(0 - '+l+')' : 0;
		}

		// simulate fixed position
		$.each([lyr1,lyr2,lyr3], function(i,o) {
			var s = o[0].style;
			s.position = 'absolute';
			if (i < 2) {
				full ? s.setExpression('height','Math.max(document.body.scrollHeight, document.body.offsetHeight) - (jQuery.boxModel?0:'+opts.quirksmodeOffsetHack+') + "px"')
					 : s.setExpression('height','this.parentNode.offsetHeight + "px"');
				full ? s.setExpression('width','jQuery.boxModel && document.documentElement.clientWidth || document.body.clientWidth + "px"')
					 : s.setExpression('width','this.parentNode.offsetWidth + "px"');
				if (fixL) s.setExpression('left', fixL);
				if (fixT) s.setExpression('top', fixT);
			}
			else if (opts.centerY) {
				if (full) s.setExpression('top','(document.documentElement.clientHeight || document.body.clientHeight) / 2 - (this.offsetHeight / 2) + (blah = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + "px"');
				s.marginTop = 0;
			}
			else if (!opts.centerY && full) {
				var top = (opts.css && opts.css.top) ? parseInt(opts.css.top) : 0;
				var expression = '((document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + '+top+') + "px"';
				s.setExpression('top',expression);
			}
		});
	}

	// show the message
	if (msg) {
		if (opts.theme)
			lyr3.find('.ui-widget-content').append(msg);
		else
			lyr3.append(msg);
		if (msg.jquery || msg.nodeType)
			$(msg).show();
	}

	if (($.browser.msie || opts.forceIframe) && opts.showOverlay)
		lyr1.show(); // opacity is zero
	if (opts.fadeIn) {
		var cb = opts.onBlock ? opts.onBlock : noOp;
		var cb1 = (opts.showOverlay && !msg) ? cb : noOp;
		var cb2 = msg ? cb : noOp;
		if (opts.showOverlay)
			lyr2._fadeIn(opts.fadeIn, cb1);
		if (msg)
			lyr3._fadeIn(opts.fadeIn, cb2);
	}
	else {
		if (opts.showOverlay)
			lyr2.show();
		if (msg)
			lyr3.show();
		if (opts.onBlock)
			opts.onBlock();
	}

	// bind key and mouse events
	bind(1, el, opts);

	if (full) {
		pageBlock = lyr3[0];
		pageBlockEls = $(':input:enabled:visible',pageBlock);
		if (opts.focusInput)
			setTimeout(focus, 20);
	}
	else
		center(lyr3[0], opts.centerX, opts.centerY);

	if (opts.timeout) {
		// auto-unblock
		var to = setTimeout(function() {
			full ? $.unblockUI(opts) : $(el).unblock(opts);
		}, opts.timeout);
		$(el).data('blockUI.timeout', to);
	}
};

// remove the block
function remove(el, opts) {
	var full = (el == window);
	var $el = $(el);
	var data = $el.data('blockUI.history');
	var to = $el.data('blockUI.timeout');
	if (to) {
		clearTimeout(to);
		$el.removeData('blockUI.timeout');
	}
	opts = $.extend({}, $.blockUI.defaults, opts || {});
	bind(0, el, opts); // unbind events

	if (opts.onUnblock === null) {
		opts.onUnblock = $el.data('blockUI.onUnblock');
		$el.removeData('blockUI.onUnblock');
	}

	var els;
	if (full) // crazy selector to handle odd field errors in ie6/7
		els = $('body').children().filter('.blockUI').add('body > .blockUI');
	else
		els = $('.blockUI', el);

	if (full)
		pageBlock = pageBlockEls = null;

	if (opts.fadeOut) {
		els.fadeOut(opts.fadeOut);
		setTimeout(function() { reset(els,data,opts,el); }, opts.fadeOut);
	}
	else
		reset(els, data, opts, el);
};

// move blocking element back into the DOM where it started
function reset(els,data,opts,el) {
	els.each(function(i,o) {
		// remove via DOM calls so we don't lose event handlers
		if (this.parentNode)
			this.parentNode.removeChild(this);
	});

	if (data && data.el) {
		data.el.style.display = data.display;
		data.el.style.position = data.position;
		if (data.parent)
			data.parent.appendChild(data.el);
		$(el).removeData('blockUI.history');
	}

	if (typeof opts.onUnblock == 'function')
		opts.onUnblock(el,opts);
};

// bind/unbind the handler
function bind(b, el, opts) {
	var full = el == window, $el = $(el);

	// don't bother unbinding if there is nothing to unbind
	if (!b && (full && !pageBlock || !full && !$el.data('blockUI.isBlocked')))
		return;
	if (!full)
		$el.data('blockUI.isBlocked', b);

	// don't bind events when overlay is not in use or if bindEvents is false
	if (!opts.bindEvents || (b && !opts.showOverlay)) 
		return;

	// bind anchors and inputs for mouse and key events
	var events = 'mousedown mouseup keydown keypress';
	b ? $(document).bind(events, opts, handler) : $(document).unbind(events, handler);

// former impl...
//	   var $e = $('a,:input');
//	   b ? $e.bind(events, opts, handler) : $e.unbind(events, handler);
};

// event handler to suppress keyboard/mouse events when blocking
function handler(e) {
	// allow tab navigation (conditionally)
	if (e.keyCode && e.keyCode == 9) {
		if (pageBlock && e.data.constrainTabKey) {
			var els = pageBlockEls;
			var fwd = !e.shiftKey && e.target === els[els.length-1];
			var back = e.shiftKey && e.target === els[0];
			if (fwd || back) {
				setTimeout(function(){focus(back)},10);
				return false;
			}
		}
	}
	var opts = e.data;
	// allow events within the message content
	if ($(e.target).parents('div.' + opts.blockMsgClass).length > 0)
		return true;

	// allow events for content that is not being blocked
	return $(e.target).parents().children().filter('div.blockUI').length == 0;
};

function focus(back) {
	if (!pageBlockEls)
		return;
	var e = pageBlockEls[back===true ? pageBlockEls.length-1 : 0];
	if (e)
		e.focus();
};

function center(el, x, y) {
	var p = el.parentNode, s = el.style;
	var l = ((p.offsetWidth - el.offsetWidth)/2) - sz(p,'borderLeftWidth');
	var t = ((p.offsetHeight - el.offsetHeight)/2) - sz(p,'borderTopWidth');
	if (x) s.left = l > 0 ? (l+'px') : '0';
	if (y) s.top  = t > 0 ? (t+'px') : '0';
};

function sz(el, p) {
	return parseInt($.css(el,p))||0;
};

})(jQuery);


/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=TextFill
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*
 * jQuery resize event - v1.1 - 3/14/2010
 * http://benalman.com/projects/jquery-resize-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
(function($,h,c){var a=$([]),e=$.resize=$.extend($.resize,{}),i,k="setTimeout",j="resize",d=j+"-special-event",b="delay",f="throttleWindow";e[b]=250;e[f]=true;$.event.special[j]={setup:function(){if(!e[f]&&this[k]){return false}var l=$(this);a=a.add(l);$.data(this,d,{w:l.width(),h:l.height()});if(a.length===1){g()}},teardown:function(){if(!e[f]&&this[k]){return false}var l=$(this);a=a.not(l);l.removeData(d);if(!a.length){clearTimeout(i)}},add:function(l){if(!e[f]&&this[k]){return false}var n;function m(s,o,p){var q=$(this),r=$.data(this,d);r.w=o!==c?o:q.width();r.h=p!==c?p:q.height();n.apply(this,arguments)}if($.isFunction(l)){n=l;return m}else{n=l.handler;l.handler=m}}};function g(){i=h[k](function(){a.each(function(){var n=$(this),m=n.width(),l=n.height(),o=$.data(this,d);if(m!==o.w||l!==o.h){n.trigger(j,[o.w=m,o.h=l])}});g()},e[b])}})(jQuery,this);

/**
 * @preserve  textfill
 * @name      jquery.textfill.js
 * @author    Russ Painter
 * @author    Yu-Jie Lin
 * @version   0.1.3
 * @date      03-27-2012
 * @copyright (c) 2012 Yu-Jie Lin
 * @copyright (c) 2009 Russ Painter
 * @license   MIT License
 * @homepage  https://github.com/jquery-textfill/jquery-textfill
 * @example   http://jquery-textfill.github.com/jquery-textfill/Example.htm
*/
; (function($) {
  /**
  * Resizes an inner element's font so that the inner element completely fills the outer element.
  * @param {Object} Options which are maxFontPixels (default=40), innerTag (default='span')
  * @return All outer elements processed
  */
  $.fn.textfill = function(options) {
    var defaults = {
      maxFontPixels: 40,
      minFontPixels: 4,
      innerTag: 'span',
      callback: null,
      complete: null
    };
    var Opts = jQuery.extend(defaults, options);
    
    this.each(function() {
      var ourText = $(Opts.innerTag + ':visible:first', this);
      var maxHeight = $(this).height();
      var maxWidth = $(this).width();
      var fontSize;
      
      var minFontPixels = Opts.minFontPixels;
      var maxFontPixels = Opts.maxFontPixels;
      while (fontSize = Math.floor(minFontPixels + maxFontPixels) / 2,
             minFontPixels <= maxFontPixels) {
        ourText.css('font-size', fontSize);
        if (ourText.height() < maxHeight && ourText.width() < maxWidth)
          minFontPixels = fontSize + 1;
        else
          maxFontPixels = fontSize - 1;
      }
      
      // call callback on each result
      if (Opts.callback) Opts.callback(this);
    });
    
    // call complete when all is complete
    if (Opts.complete) Opts.complete(this);
    
    return this;
  };
})(jQuery);

/**
 * jQuery ExpandText
 * Expands or shrinks text until it's height or width hits the edges of it's parent.
 * Michael Botsko (http://www.botsko.net)
 * 1.0 20110523
 */
(function($){
	$.fn.expandText = function(options){
		opts = $.extend({ min: 50, max: 120, increment: 2 },options);
		return this.each(function(){
			var me = $(this), max_w = me.width()-(opts.increment*2), max_y = me.height()-(opts.increment*2), span = me.find('.expandedText'), size = opts.min;
			me.css("font-size", size);
			if(!span.length){
				me.wrapInner('<span class="expandedText" />');
				span = me.find('span');
			}
			while(span.width() < max_w && span.height() < max_y){
				size += opts.increment
			  	me.css("font-size", size);
				if(size == opts.max) break;
			}
		});
	}
})(jQuery);
/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Placeholder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/**
 * jQuery.placeholder - Placeholder plugin for input fields
 * Written by Blair Mitchelmore (blair DOT mitchelmore AT gmail DOT com)
 * Licensed under the WTFPL (http://sam.zoy.org/wtfpl/).
 * Date: 2008/10/14
 *
 * @author Blair Mitchelmore
 * @version 1.0.1
 *
 **/
new function($) {
    $.fn.placeholder = function(settings) {
        settings = settings || {};
        var key = settings.dataKey || "placeholderValue";
        var attr = settings.attr || "placeholder";
        var className = settings.className || "placeholder";
        var values = settings.values || [];
        var block = settings.blockSubmit || false;
        var blank = settings.blankSubmit || false;
        var submit = settings.onSubmit || false;
        var value = settings.value || "";
        var position = settings.cursor_position || 0;

        
        return this.filter(":input").each(function(index) { 
            $.data(this, key, values[index] || $(this).attr(attr)); 
        }).each(function() {
            if ($.trim($(this).val()) === "")
                $(this).addClass(className).val($.data(this, key));
        }).focus(function() {
            if ($.trim($(this).val()) === $.data(this, key)) 
                $(this).removeClass(className).val(value)
                if ($.fn.setCursorPosition) {
                  $(this).setCursorPosition(position);
                }
        }).blur(function() {
            if ($.trim($(this).val()) === value)
                $(this).addClass(className).val($.data(this, key));
        }).each(function(index, elem) {
            if (block)
                new function(e) {
                    $(e.form).submit(function() {
                        return $.trim($(e).val()) != $.data(e, key)
                    });
                }(elem);
            else if (blank)
                new function(e) {
                    $(e.form).submit(function() {
                        if ($.trim($(e).val()) == $.data(e, key)) 
                            $(e).removeClass(className).val("");
                        return true;
                    });
                }(elem);
            else if (submit)
                new function(e) { $(e.form).submit(submit); }(elem);
        });
    };
}(jQuery);


/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=jCarousel
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*!
 * jCarousel - Riding carousels with jQuery
 *   http://sorgalla.com/jcarousel/
 *
 * Copyright (c) 2006 Jan Sorgalla (http://sorgalla.com)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * Built on top of the jQuery library
 *   http://jquery.com
 *
 * Inspired by the "Carousel Component" by Bill Scott
 *   http://billwscott.com/carousel/
 */

(function(i){var q={vertical:false,rtl:false,start:1,offset:1,size:null,scroll:3,visible:null,animation:"normal",easing:"swing",auto:0,wrap:null,initCallback:null,reloadCallback:null,itemLoadCallback:null,itemFirstInCallback:null,itemFirstOutCallback:null,itemLastInCallback:null,itemLastOutCallback:null,itemVisibleInCallback:null,itemVisibleOutCallback:null,buttonNextHTML:"<div></div>",buttonPrevHTML:"<div></div>",buttonNextEvent:"click",buttonPrevEvent:"click",buttonNextCallback:null,buttonPrevCallback:null, itemFallbackDimension:null},r=false;i(window).bind("load.jcarousel",function(){r=true});i.jcarousel=function(a,c){this.options=i.extend({},q,c||{});this.autoStopped=this.locked=false;this.buttonPrevState=this.buttonNextState=this.buttonPrev=this.buttonNext=this.list=this.clip=this.container=null;if(!c||c.rtl===undefined)this.options.rtl=(i(a).attr("dir")||i("html").attr("dir")||"").toLowerCase()=="rtl";this.wh=!this.options.vertical?"width":"height";this.lt=!this.options.vertical?this.options.rtl? "right":"left":"top";for(var b="",d=a.className.split(" "),f=0;f<d.length;f++)if(d[f].indexOf("jcarousel-skin")!=-1){i(a).removeClass(d[f]);b=d[f];break}if(a.nodeName.toUpperCase()=="UL"||a.nodeName.toUpperCase()=="OL"){this.list=i(a);this.container=this.list.parent();if(this.container.hasClass("jcarousel-clip")){if(!this.container.parent().hasClass("jcarousel-container"))this.container=this.container.wrap("<div></div>");this.container=this.container.parent()}else if(!this.container.hasClass("jcarousel-container"))this.container= this.list.wrap("<div></div>").parent()}else{this.container=i(a);this.list=this.container.find("ul,ol").eq(0)}b!==""&&this.container.parent()[0].className.indexOf("jcarousel-skin")==-1&&this.container.wrap('<div class=" '+b+'"></div>');this.clip=this.list.parent();if(!this.clip.length||!this.clip.hasClass("jcarousel-clip"))this.clip=this.list.wrap("<div></div>").parent();this.buttonNext=i(".jcarousel-next",this.container);if(this.buttonNext.size()===0&&this.options.buttonNextHTML!==null)this.buttonNext= this.clip.after(this.options.buttonNextHTML).next();this.buttonNext.addClass(this.className("jcarousel-next"));this.buttonPrev=i(".jcarousel-prev",this.container);if(this.buttonPrev.size()===0&&this.options.buttonPrevHTML!==null)this.buttonPrev=this.clip.after(this.options.buttonPrevHTML).next();this.buttonPrev.addClass(this.className("jcarousel-prev"));this.clip.addClass(this.className("jcarousel-clip")).css({overflow:"hidden",position:"relative"});this.list.addClass(this.className("jcarousel-list")).css({overflow:"hidden", position:"relative",top:0,margin:0,padding:0}).css(this.options.rtl?"right":"left",0);this.container.addClass(this.className("jcarousel-container")).css({position:"relative"});!this.options.vertical&&this.options.rtl&&this.container.addClass("jcarousel-direction-rtl").attr("dir","rtl");var j=this.options.visible!==null?Math.ceil(this.clipping()/this.options.visible):null;b=this.list.children("li");var e=this;if(b.size()>0){var g=0,k=this.options.offset;b.each(function(){e.format(this,k++);g+=e.dimension(this, j)});this.list.css(this.wh,g+100+"px");if(!c||c.size===undefined)this.options.size=b.size()}this.container.css("display","block");this.buttonNext.css("display","block");this.buttonPrev.css("display","block");this.funcNext=function(){e.next()};this.funcPrev=function(){e.prev()};this.funcResize=function(){e.reload()};this.options.initCallback!==null&&this.options.initCallback(this,"init");if(!r&&i.browser.safari){this.buttons(false,false);i(window).bind("load.jcarousel",function(){e.setup()})}else this.setup()}; var h=i.jcarousel;h.fn=h.prototype={jcarousel:"0.2.7"};h.fn.extend=h.extend=i.extend;h.fn.extend({setup:function(){this.prevLast=this.prevFirst=this.last=this.first=null;this.animating=false;this.tail=this.timer=null;this.inTail=false;if(!this.locked){this.list.css(this.lt,this.pos(this.options.offset)+"px");var a=this.pos(this.options.start,true);this.prevFirst=this.prevLast=null;this.animate(a,false);i(window).unbind("resize.jcarousel",this.funcResize).bind("resize.jcarousel",this.funcResize)}}, reset:function(){this.list.empty();this.list.css(this.lt,"0px");this.list.css(this.wh,"10px");this.options.initCallback!==null&&this.options.initCallback(this,"reset");this.setup()},reload:function(){this.tail!==null&&this.inTail&&this.list.css(this.lt,h.intval(this.list.css(this.lt))+this.tail);this.tail=null;this.inTail=false;this.options.reloadCallback!==null&&this.options.reloadCallback(this);if(this.options.visible!==null){var a=this,c=Math.ceil(this.clipping()/this.options.visible),b=0,d=0; this.list.children("li").each(function(f){b+=a.dimension(this,c);if(f+1<a.first)d=b});this.list.css(this.wh,b+"px");this.list.css(this.lt,-d+"px")}this.scroll(this.first,false)},lock:function(){this.locked=true;this.buttons()},unlock:function(){this.locked=false;this.buttons()},size:function(a){if(a!==undefined){this.options.size=a;this.locked||this.buttons()}return this.options.size},has:function(a,c){if(c===undefined||!c)c=a;if(this.options.size!==null&&c>this.options.size)c=this.options.size;for(var b= a;b<=c;b++){var d=this.get(b);if(!d.length||d.hasClass("jcarousel-item-placeholder"))return false}return true},get:function(a){return i(".jcarousel-item-"+a,this.list)},add:function(a,c){var b=this.get(a),d=0,f=i(c);if(b.length===0){var j,e=h.intval(a);for(b=this.create(a);;){j=this.get(--e);if(e<=0||j.length){e<=0?this.list.prepend(b):j.after(b);break}}}else d=this.dimension(b);if(f.get(0).nodeName.toUpperCase()=="LI"){b.replaceWith(f);b=f}else b.empty().append(c);this.format(b.removeClass(this.className("jcarousel-item-placeholder")), a);f=this.options.visible!==null?Math.ceil(this.clipping()/this.options.visible):null;d=this.dimension(b,f)-d;a>0&&a<this.first&&this.list.css(this.lt,h.intval(this.list.css(this.lt))-d+"px");this.list.css(this.wh,h.intval(this.list.css(this.wh))+d+"px");return b},remove:function(a){var c=this.get(a);if(!(!c.length||a>=this.first&&a<=this.last)){var b=this.dimension(c);a<this.first&&this.list.css(this.lt,h.intval(this.list.css(this.lt))+b+"px");c.remove();this.list.css(this.wh,h.intval(this.list.css(this.wh))- b+"px")}},next:function(){this.tail!==null&&!this.inTail?this.scrollTail(false):this.scroll((this.options.wrap=="both"||this.options.wrap=="last")&&this.options.size!==null&&this.last==this.options.size?1:this.first+this.options.scroll)},prev:function(){this.tail!==null&&this.inTail?this.scrollTail(true):this.scroll((this.options.wrap=="both"||this.options.wrap=="first")&&this.options.size!==null&&this.first==1?this.options.size:this.first-this.options.scroll)},scrollTail:function(a){if(!(this.locked|| this.animating||!this.tail)){this.pauseAuto();var c=h.intval(this.list.css(this.lt));c=!a?c-this.tail:c+this.tail;this.inTail=!a;this.prevFirst=this.first;this.prevLast=this.last;this.animate(c)}},scroll:function(a,c){if(!(this.locked||this.animating)){this.pauseAuto();this.animate(this.pos(a),c)}},pos:function(a,c){var b=h.intval(this.list.css(this.lt));if(this.locked||this.animating)return b;if(this.options.wrap!="circular")a=a<1?1:this.options.size&&a>this.options.size?this.options.size:a;for(var d= this.first>a,f=this.options.wrap!="circular"&&this.first<=1?1:this.first,j=d?this.get(f):this.get(this.last),e=d?f:f-1,g=null,k=0,l=false,m=0;d?--e>=a:++e<a;){g=this.get(e);l=!g.length;if(g.length===0){g=this.create(e).addClass(this.className("jcarousel-item-placeholder"));j[d?"before":"after"](g);if(this.first!==null&&this.options.wrap=="circular"&&this.options.size!==null&&(e<=0||e>this.options.size)){j=this.get(this.index(e));if(j.length)g=this.add(e,j.clone(true))}}j=g;m=this.dimension(g);if(l)k+= m;if(this.first!==null&&(this.options.wrap=="circular"||e>=1&&(this.options.size===null||e<=this.options.size)))b=d?b+m:b-m}f=this.clipping();var p=[],o=0,n=0;j=this.get(a-1);for(e=a;++o;){g=this.get(e);l=!g.length;if(g.length===0){g=this.create(e).addClass(this.className("jcarousel-item-placeholder"));j.length===0?this.list.prepend(g):j[d?"before":"after"](g);if(this.first!==null&&this.options.wrap=="circular"&&this.options.size!==null&&(e<=0||e>this.options.size)){j=this.get(this.index(e));if(j.length)g= this.add(e,j.clone(true))}}j=g;m=this.dimension(g);if(m===0)throw Error("jCarousel: No width/height set for items. This will cause an infinite loop. Aborting...");if(this.options.wrap!="circular"&&this.options.size!==null&&e>this.options.size)p.push(g);else if(l)k+=m;n+=m;if(n>=f)break;e++}for(g=0;g<p.length;g++)p[g].remove();if(k>0){this.list.css(this.wh,this.dimension(this.list)+k+"px");if(d){b-=k;this.list.css(this.lt,h.intval(this.list.css(this.lt))-k+"px")}}k=a+o-1;if(this.options.wrap!="circular"&& this.options.size&&k>this.options.size)k=this.options.size;if(e>k){o=0;e=k;for(n=0;++o;){g=this.get(e--);if(!g.length)break;n+=this.dimension(g);if(n>=f)break}}e=k-o+1;if(this.options.wrap!="circular"&&e<1)e=1;if(this.inTail&&d){b+=this.tail;this.inTail=false}this.tail=null;if(this.options.wrap!="circular"&&k==this.options.size&&k-o+1>=1){d=h.margin(this.get(k),!this.options.vertical?"marginRight":"marginBottom");if(n-d>f)this.tail=n-f-d}if(c&&a===this.options.size&&this.tail){b-=this.tail;this.inTail= true}for(;a-- >e;)b+=this.dimension(this.get(a));this.prevFirst=this.first;this.prevLast=this.last;this.first=e;this.last=k;return b},animate:function(a,c){if(!(this.locked||this.animating)){this.animating=true;var b=this,d=function(){b.animating=false;a===0&&b.list.css(b.lt,0);if(!b.autoStopped&&(b.options.wrap=="circular"||b.options.wrap=="both"||b.options.wrap=="last"||b.options.size===null||b.last<b.options.size||b.last==b.options.size&&b.tail!==null&&!b.inTail))b.startAuto();b.buttons();b.notify("onAfterAnimation"); if(b.options.wrap=="circular"&&b.options.size!==null)for(var f=b.prevFirst;f<=b.prevLast;f++)if(f!==null&&!(f>=b.first&&f<=b.last)&&(f<1||f>b.options.size))b.remove(f)};this.notify("onBeforeAnimation");if(!this.options.animation||c===false){this.list.css(this.lt,a+"px");d()}else this.list.animate(!this.options.vertical?this.options.rtl?{right:a}:{left:a}:{top:a},this.options.animation,this.options.easing,d)}},startAuto:function(a){if(a!==undefined)this.options.auto=a;if(this.options.auto===0)return this.stopAuto(); if(this.timer===null){this.autoStopped=false;var c=this;this.timer=window.setTimeout(function(){c.next()},this.options.auto*1E3)}},stopAuto:function(){this.pauseAuto();this.autoStopped=true},pauseAuto:function(){if(this.timer!==null){window.clearTimeout(this.timer);this.timer=null}},buttons:function(a,c){if(a==null){a=!this.locked&&this.options.size!==0&&(this.options.wrap&&this.options.wrap!="first"||this.options.size===null||this.last<this.options.size);if(!this.locked&&(!this.options.wrap||this.options.wrap== "first")&&this.options.size!==null&&this.last>=this.options.size)a=this.tail!==null&&!this.inTail}if(c==null){c=!this.locked&&this.options.size!==0&&(this.options.wrap&&this.options.wrap!="last"||this.first>1);if(!this.locked&&(!this.options.wrap||this.options.wrap=="last")&&this.options.size!==null&&this.first==1)c=this.tail!==null&&this.inTail}var b=this;if(this.buttonNext.size()>0){this.buttonNext.unbind(this.options.buttonNextEvent+".jcarousel",this.funcNext);a&&this.buttonNext.bind(this.options.buttonNextEvent+ ".jcarousel",this.funcNext);this.buttonNext[a?"removeClass":"addClass"](this.className("jcarousel-next-disabled")).attr("disabled",a?false:true);this.options.buttonNextCallback!==null&&this.buttonNext.data("jcarouselstate")!=a&&this.buttonNext.each(function(){b.options.buttonNextCallback(b,this,a)}).data("jcarouselstate",a)}else this.options.buttonNextCallback!==null&&this.buttonNextState!=a&&this.options.buttonNextCallback(b,null,a);if(this.buttonPrev.size()>0){this.buttonPrev.unbind(this.options.buttonPrevEvent+ ".jcarousel",this.funcPrev);c&&this.buttonPrev.bind(this.options.buttonPrevEvent+".jcarousel",this.funcPrev);this.buttonPrev[c?"removeClass":"addClass"](this.className("jcarousel-prev-disabled")).attr("disabled",c?false:true);this.options.buttonPrevCallback!==null&&this.buttonPrev.data("jcarouselstate")!=c&&this.buttonPrev.each(function(){b.options.buttonPrevCallback(b,this,c)}).data("jcarouselstate",c)}else this.options.buttonPrevCallback!==null&&this.buttonPrevState!=c&&this.options.buttonPrevCallback(b, null,c);this.buttonNextState=a;this.buttonPrevState=c},notify:function(a){var c=this.prevFirst===null?"init":this.prevFirst<this.first?"next":"prev";this.callback("itemLoadCallback",a,c);if(this.prevFirst!==this.first){this.callback("itemFirstInCallback",a,c,this.first);this.callback("itemFirstOutCallback",a,c,this.prevFirst)}if(this.prevLast!==this.last){this.callback("itemLastInCallback",a,c,this.last);this.callback("itemLastOutCallback",a,c,this.prevLast)}this.callback("itemVisibleInCallback", a,c,this.first,this.last,this.prevFirst,this.prevLast);this.callback("itemVisibleOutCallback",a,c,this.prevFirst,this.prevLast,this.first,this.last)},callback:function(a,c,b,d,f,j,e){if(!(this.options[a]==null||typeof this.options[a]!="object"&&c!="onAfterAnimation")){var g=typeof this.options[a]=="object"?this.options[a][c]:this.options[a];if(i.isFunction(g)){var k=this;if(d===undefined)g(k,b,c);else if(f===undefined)this.get(d).each(function(){g(k,this,d,b,c)});else{a=function(m){k.get(m).each(function(){g(k, this,m,b,c)})};for(var l=d;l<=f;l++)l!==null&&!(l>=j&&l<=e)&&a(l)}}}},create:function(a){return this.format("<li></li>",a)},format:function(a,c){a=i(a);for(var b=a.get(0).className.split(" "),d=0;d<b.length;d++)b[d].indexOf("jcarousel-")!=-1&&a.removeClass(b[d]);a.addClass(this.className("jcarousel-item")).addClass(this.className("jcarousel-item-"+c)).css({"float":this.options.rtl?"right":"left","list-style":"none"}).attr("jcarouselindex",c);return a},className:function(a){return a+" "+a+(!this.options.vertical? "-horizontal":"-vertical")},dimension:function(a,c){var b=a.jquery!==undefined?a[0]:a,d=!this.options.vertical?(b.offsetWidth||h.intval(this.options.itemFallbackDimension))+h.margin(b,"marginLeft")+h.margin(b,"marginRight"):(b.offsetHeight||h.intval(this.options.itemFallbackDimension))+h.margin(b,"marginTop")+h.margin(b,"marginBottom");if(c==null||d==c)return d;d=!this.options.vertical?c-h.margin(b,"marginLeft")-h.margin(b,"marginRight"):c-h.margin(b,"marginTop")-h.margin(b,"marginBottom");i(b).css(this.wh, d+"px");return this.dimension(b)},clipping:function(){return!this.options.vertical?this.clip[0].offsetWidth-h.intval(this.clip.css("borderLeftWidth"))-h.intval(this.clip.css("borderRightWidth")):this.clip[0].offsetHeight-h.intval(this.clip.css("borderTopWidth"))-h.intval(this.clip.css("borderBottomWidth"))},index:function(a,c){if(c==null)c=this.options.size;return Math.round(((a-1)/c-Math.floor((a-1)/c))*c)+1}});h.extend({defaults:function(a){return i.extend(q,a||{})},margin:function(a,c){if(!a)return 0; var b=a.jquery!==undefined?a[0]:a;if(c=="marginRight"&&i.browser.safari){var d={display:"block","float":"none",width:"auto"},f,j;i.swap(b,d,function(){f=b.offsetWidth});d.marginRight=0;i.swap(b,d,function(){j=b.offsetWidth});return j-f}return h.intval(i.css(b,c))},intval:function(a){a=parseInt(a,10);return isNaN(a)?0:a}});i.fn.jcarousel=function(a){if(typeof a=="string"){var c=i(this).data("jcarousel"),b=Array.prototype.slice.call(arguments,1);return c[a].apply(c,b)}else return this.each(function(){i(this).data("jcarousel", new h(this,a))})}})(jQuery);


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Tooltip
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 * http://bassistance.de/jquery-plugins/jquery-plugin-tooltip/
 * http://docs.jquery.com/Plugins/Tooltip
 *
 * Copyright (c) 2006 - 2008 J�rn Zaefferer
 *
 * $Id: jquery.tooltip.js 5741 2008-06-21 15:22:16Z joern.zaefferer $
 * 
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
/* This first function hides the tooltip when you mouse out of the hovered element */
;(function($){var helper={},current,title,tID,IE=$.browser.msie&&/MSIE\s(5\.5|6\.)/.test(navigator.userAgent),track=false;$.tooltip={blocked:false,defaults:{delay:200,fade:false,showURL:true,extraClass:"",top:15,left:15,id:"tooltip"},block:function(){$.tooltip.blocked=!$.tooltip.blocked;}};$.fn.extend({tooltip:function(settings){settings=$.extend({},$.tooltip.defaults,settings);createHelper(settings);return this.each(function(){$.data(this,"tooltip",settings);this.tOpacity=helper.parent.css("opacity");this.tooltipText=this.title;$(this).removeAttr("title");this.alt="";}).mouseover(save).mouseout(hide).click(hide);},fixPNG:IE?function(){return this.each(function(){var image=$(this).css('backgroundImage');if(image.match(/^url\(["']?(.*\.png)["']?\)$/i)){image=RegExp.$1;$(this).css({'backgroundImage':'none','filter':"progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='"+image+"')"}).each(function(){var position=$(this).css('position');if(position!='absolute'&&position!='relative')$(this).css('position','relative');});}});}:function(){return this;},unfixPNG:IE?function(){return this.each(function(){$(this).css({'filter':'',backgroundImage:''});});}:function(){return this;},hideWhenEmpty:function(){return this.each(function(){$(this)[$(this).html()?"show":"hide"]();});},url:function(){return this.attr('href')||this.attr('src');}});function createHelper(settings){if(helper.parent)return;helper.parent=$('<div id="'+settings.id+'"><h3></h3><div class="body"></div><div class="url"></div></div>').appendTo(document.body).hide();if($.fn.bgiframe)helper.parent.bgiframe();helper.title=$('h3',helper.parent);helper.body=$('div.body',helper.parent);helper.url=$('div.url',helper.parent);}function settings(element){return $.data(element,"tooltip");}function handle(event){if(settings(this).delay)tID=setTimeout(show,settings(this).delay);else
show();track=!!settings(this).track;$(document.body).bind('mousemove',update);update(event);}function save(){if($.tooltip.blocked||this==current||(!this.tooltipText&&!settings(this).bodyHandler))return;current=this;title=this.tooltipText;if(settings(this).bodyHandler){helper.title.hide();var bodyContent=settings(this).bodyHandler.call(this);if(bodyContent.nodeType||bodyContent.jquery){helper.body.empty().append(bodyContent)}else{helper.body.html(bodyContent);}helper.body.show();}else if(settings(this).showBody){var parts=title.split(settings(this).showBody);helper.title.html(parts.shift()).show();helper.body.empty();for(var i=0,part;(part=parts[i]);i++){if(i>0)helper.body.append("<br/>");helper.body.append(part);}helper.body.hideWhenEmpty();}else{helper.title.html(title).show();helper.body.hide();}if(settings(this).showURL&&$(this).url())helper.url.html($(this).url().replace('http://','')).show();else
helper.url.hide();helper.parent.addClass(settings(this).extraClass);if(settings(this).fixPNG)helper.parent.fixPNG();handle.apply(this,arguments);}function show(){tID=null;if((!IE||!$.fn.bgiframe)&&settings(current).fade){if(helper.parent.is(":animated"))helper.parent.stop().show().fadeTo(settings(current).fade,current.tOpacity);else
helper.parent.is(':visible')?helper.parent.fadeTo(settings(current).fade,current.tOpacity):helper.parent.fadeIn(settings(current).fade);}else{helper.parent.show();}update();}function update(event){if($.tooltip.blocked)return;if(event&&event.target.tagName=="OPTION"){return;}if(!track&&helper.parent.is(":visible")){$(document.body).unbind('mousemove',update)}if(current==null){$(document.body).unbind('mousemove',update);return;}helper.parent.removeClass("viewport-right").removeClass("viewport-bottom");var left=helper.parent[0].offsetLeft;var top=helper.parent[0].offsetTop;if(event){left=event.pageX+settings(current).left;top=event.pageY+settings(current).top;var right='auto';if(settings(current).positionLeft){right=$(window).width()-left;left='auto';}helper.parent.css({left:left,right:right,top:top});}var v=viewport(),h=helper.parent[0];if(v.x+v.cx<h.offsetLeft+h.offsetWidth){left-=h.offsetWidth+20+settings(current).left;helper.parent.css({left:left+'px'}).addClass("viewport-right");}if(v.y+v.cy<h.offsetTop+h.offsetHeight){top-=h.offsetHeight+20+settings(current).top;helper.parent.css({top:top+'px'}).addClass("viewport-bottom");}}function viewport(){return{x:$(window).scrollLeft(),y:$(window).scrollTop(),cx:$(window).width(),cy:$(window).height()};}function hide(event){if($.tooltip.blocked)return;if(tID)clearTimeout(tID);current=null;var tsettings=settings(this);function complete(){helper.parent.removeClass(tsettings.extraClass).hide().css("opacity","");}if((!IE||!$.fn.bgiframe)&&tsettings.fade){if(helper.parent.is(':animated'))helper.parent.stop().fadeTo(tsettings.fade,0,complete);else
helper.parent.stop().fadeOut(tsettings.fade,complete);}else
complete();if(settings(this).fixPNG)helper.parent.unfixPNG();}})(jQuery);
 
/*
 * jQuery nex_Tooltip plugin 1.0
 *
 * Modified from:
 * http://bassistance.de/jquery-plugins/jquery-plugin-tooltip/
 * http://docs.jquery.com/Plugins/Tooltip
 *
 * Original:
 * Copyright (c) 2006 - 2008 J�rn Zaefferer
 * 
 * Modified:
 * 2011 Chris Rodriguez, Above the Fold
 *
 * $Id: jquery.nextooltip.js 5741 2008-06-21 15:22:16Z joern.zaefferer $
 * 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 */
 
;(function($){
	var nex_helper = { },
	nex_current,
	nex_title,
	nex_tID,
	IE = $.browser.msie && /MSIE\s(5\.5|6\.)/.test(navigator.userAgent),
	track=false;
	
	$.nex_tooltip = {
		blocked:false,
		defaults:{ 
			delay:200,
			fade:false,
			showURL:true,
			extraClass:"",
			top: 5, 
			left: 10, 
			id: "tooltip-sticky"
		}, 
		block: function() {
			$.nex_tooltip.blocked = !$.nex_tooltip.blocked;
		}
	};
	
	$.fn.extend({
		nex_tooltip: function(settings){
			settings = $.extend(
				{ }, 
				$.nex_tooltip.defaults, 
				settings
			);
			createHelper(settings);
			return this.each(function() {
				$.data(this, "tooltip-sticky", settings);
				this.tOpacity = nex_helper.parent.css("opacity");
				this.nex_tooltipText = this.nex_title;
				$(this).removeAttr("title");
				this.alt = "";
			}).click(save)/*.mouseout().click(hide)*/
		;}, 
		fixPNG: IE ? function() {
			return this.each(function(){
				var image = $(this).css("backgroundImage");
				if(image.match(/^url\(["']?(.*\.png)["']?\)$/i)){
					image = RegExp.$1;
					$(this).css({
						backgroundImage: "none", 
						filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='" + image + "')"
					})
					.each(function(){
						var position = $(this).css("position");
						if(position != "absolute" && position != "relative"){
							$(this).css("position", "relative");
						}
					});
				}
			});
		} : function(){
				return this;
			}, 
			unfixPNG: IE ? function(){
				return this.each(function(){
					$(this).css({
						filter: "", 
						backgroundImage: ""
					});
				});
			} : function(){
				return this;
		}, 
		hideWhenEmpty: function(){
			return this.each(function(){
				$(this)[ $(this).html() ? "show" : "hide" ]();
			});
		}, 
		url: function(){
			return this.attr("href") || this.attr("src");
		}
	});
	
	function createHelper(settings){
		if(nex_helper.parent) {
			return;
		}
		nex_helper.parent = $("<div id=\"" + settings.id + "\"><h3></h3><div class=\"body\"></div><div class=\"url\"></div></div>").appendTo(document.body).hide();
		if($.fn.bgiframe){
			nex_helper.parent.bgiframe();
		}
		nex_helper.nex_title = $("h3", nex_helper.parent);
		nex_helper.body = $("div.body", nex_helper.parent);
		nex_helper.url = $("div.url", nex_helper.parent);
	}
	
	function settings(element){
		return $.data(element, "tooltip-sticky");
	}
	
	function handle(event){
		if(settings(this).delay){
			nex_tID = setTimeout(show, settings(this).delay);
		}
		else
		{
			show();
		}
		track = !!settings(this).track;
		$(document.body).bind("mousemove", update);
		update(event);
	}
	
	function save(){
		if($.nex_tooltip.blocked || this == nex_current || !this.nex_tooltipText && !settings(this).bodyHandler) {
			return;
		}
		nex_current = this;
		nex_title = this.nex_tooltipText;
		if(settings(this).bodyHandler){
			nex_helper.nex_title.hide();
			var bodyContent = settings(this).bodyHandler.call(this);
			if(bodyContent.nodeType || bodyContent.jquery){
				nex_helper.body.empty().append(bodyContent);
			}
			else
			{
				nex_helper.body.html(bodyContent);
			}
			nex_helper.body.show();
		}
		else if(settings(this).showBody)
		{
			var parts = nex_title.split(settings(this).showBody);
			nex_helper.nex_title.html(parts.shift()).show();
			nex_helper.body.empty();
			for(var i = 0, part; part = parts[i]; i++)
			{
				if (i > 0) {nex_helper.body.append("<br/>");
			}
			nex_helper.body.append(part);
		}
		nex_helper.body.hideWhenEmpty();
	}
	else
	{
		nex_helper.nex_title.html(nex_title).show();
		nex_helper.body.hide();
	}
	
	if(settings(this).showURL && $(this).url()) {
		nex_helper.url.html($(this).url().replace("http://", "")).show();
	}
	else
	{
		nex_helper.url.hide();
	}
	nex_helper.parent.addClass(settings(this).extraClass);
	if(settings(this).fixPNG){
		nex_helper.parent.fixPNG();
	}
	handle.apply(this, arguments);
	}
	
	function show(){
		nex_tID = null;
		if ((!IE || !$.fn.bgiframe) && settings(nex_current).fade) {
			if (nex_helper.parent.is(":animated")) {
				nex_helper.parent.stop().show().fadeTo(settings(nex_current).fade, nex_current.tOpacity);
			}
			else
			{
				nex_helper.parent.is(":visible") ? nex_helper.parent.fadeTo(settings(nex_current).fade, nex_current.tOpacity) : nex_helper.parent.fadeIn(settings(nex_current).fade);
			}
		}
		else
		{
			nex_helper.parent.show();
		}
		update();
	}
	
	function update(event) {
		if ($.nex_tooltip.blocked) {
			return;
		}
		if (event && event.target.tagName == "OPTION") {
			return;
		}
		if (!track && nex_helper.parent.is(":visible")) {
			$(document.body).unbind("mousemove", update);
		}
		if (nex_current == null) {
			$(document.body).unbind("mousemove", update);
			return;
		}
		nex_helper.parent.removeClass("viewport-right").removeClass("viewport-bottom");
		var left = nex_helper.parent[0].offsetLeft;
		var top = nex_helper.parent[0].offsetTop;
		if (event) {
			left = event.pageX + settings(nex_current).left;
			top = event.pageY + settings(nex_current).top;
			var right = "auto";
			if (settings(nex_current).positionLeft) {
				right = $(window).width() - left;
				left = "auto";
			}
			nex_helper.parent.css({
				left: left, 
				right: right, 
				top: top
			});
		}
		var v = viewport(), 
		h = nex_helper.parent[0];
		if (v.x + v.cx < h.offsetLeft + h.offsetWidth) {
			left -= h.offsetWidth + 20 + settings(nex_current).left;
			nex_helper.parent.css({
				left: left + "px"
			})
			.addClass("viewport-right");
		}
		if (v.y + v.cy < h.offsetTop + h.offsetHeight) {
			top -= h.offsetHeight + 20 + settings(nex_current).top;
			nex_helper.parent.css({
				top: top + "px"
			})
			.addClass("viewport-bottom");
		}
	}
	
	function viewport() {
		return {
			x: $(window).scrollLeft(), 
			y: $(window).scrollTop(), 
			cx: $(window).width(), 
			cy: $(window).height()
		};
	}
	
	function hide(event) {
		if ($.nex_tooltip.blocked) {
			return;
		}
		if (nex_tID) {
			clearTimeout(nex_tID);
		}
		nex_current = null;
		var tsettings = settings(this);
		function complete() {
			nex_helper.parent.removeClass(tsettings.extraClass).hide().css("opacity", "");
		} 
		if ((!IE || !$.fn.bgiframe) && tsettings.fade) {
			if (nex_helper.parent.is(":animated")) {
				nex_helper.parent.stop().fadeTo(tsettings.fade, 0, complete);
			}
			else
			{
				nex_helper.parent.stop().fadeOut(tsettings.fade, complete);
			}
		}
		else
		{
			complete();
		}
		if (settings(this).fixPNG) {
			nex_helper.parent.unfixPNG();
		}
	}
}
(jQuery));
 


/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=SuperToggle
    Written by Jim O'Neill
    based on ShowHide and Reveal
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

(function($) {
    
    $.fn.supertoggle = function(options) {
        
        var defaults = {
            toggleTarget: null,
            focusTarget: null,
            togglerOnClass: 'on',
            togglerOffClass: 'off',
            togglerOnText: null,
            togglerOffText: null,
            targetOnClass: 'shown',
            targetOffClass: 'hidden',
            defaultOn: false,
            scopeParent: '.tab-section',
            useCookie: false,
            cookieExpires: 365,
            cookieName: 'supertoggle-target',
            callbackShow: function() {},
            callbackHide: function() {}
        };
        var options = $.extend(defaults, options);
        
        // Create an array to store all the toggler elements
        var map = [];
        
        return this.each(function() {
            
            var toggler = $(this);
            
            // Add the current toggler element to our array
            map.push(toggler);
            
            // Create references to the options
            var toggleTarget = options.toggleTarget;
            var focusTarget = options.focusTarget;
            var togglerOnClass = options.togglerOnClass;
            var togglerOffClass = options.togglerOffClass;
            var targetOnClass = options.targetOnClass;
            var targetOffClass = options.targetOffClass;
            var togglerOnText = options.togglerOnText;
            var togglerOffText = options.togglerOffText;
            var defaultOn = options.defaultOn;
            var scopeParent = options.scopeParent;
            var useCookie = options.useCookie;
            var cookieExpires = options.cookieExpires;
            var cookieName = options.cookieName;
            
            // Make sure callbacks are functions first
            if (typeof options.callbackShow == 'function') {
                var callbackShow = options.callbackShow;
            }
            if (typeof options.callbackHide == 'function') {
                var callbackHide = options.callbackHide;
            }
            
            // Set scope/parent - often the current tab, or the body element if tabs don't exist
            if (toggler.closest(scopeParent).length) {
                var parent = scopeParent;
            } else {
                var parent = 'body';
            }
                        
            // Get the target element(s)
            if (toggleTarget) { // First try: toggleTarget from options
                var targetObj = toggleTarget;
            } 
            else if (toggler.attr('data-target-id')) { // Second try: target ID
                var targetObj = '#' + toggler.attr('data-target-id');
            } 
            else if (toggler.attr('data-target-class')) { // Third try: target class
                var targetObj = '.' + toggler.attr('data-target-class');
            } 
            else { // Last try: object next after toggler
                var targetObj = toggler.next();
            }
            
            // Set expiration of cookie, if it exists.
            if (cookieExpires) {
                options.cookieOptions = {expires: cookieExpires};
            }
            
            
            // Turn On function
            var turnOn = function(object) {
            
                // Handle scoping
                var thisparent = $(object).closest(parent);
                var target = thisparent.find(targetObj);
            
                $(target).removeClass(targetOffClass).addClass(targetOnClass);
                // Loop through the array of togglers...
                for(t in map) {
                    // ...but constrain to those inside the current parent
                    if (thisparent.has(map[t]).length) {
                        map[t].removeClass(togglerOffClass).addClass(togglerOnClass);
                    }
                }
                if (togglerOnText) {
                    $(object).text(togglerOnText);
                }
                if (useCookie) {
                    $.cookie(cookieName, 'visible', options.cookieOptions);
                };
                if (focusTarget) {
                    $(focusTarget).focus();
                };
            }
            
            // Turn Off 
            var turnOff = function(object) {
            
                // Handle scoping
                var thisparent = $(object).closest(parent);
                var target = thisparent.find(targetObj);
            
                $(target).removeClass(targetOnClass).addClass(targetOffClass);
                // Loop through the array of togglers...
                for(t in map) {
                     if (thisparent.has(map[t]).length) {
                        // ...but constrain to those inside the current parent
                        map[t].removeClass(togglerOnClass).addClass(togglerOffClass);
                    }
                }
                if (togglerOffText) {
                    $(object).text(togglerOffText);
                }
                if (useCookie) {
                    $.cookie(cookieName, 'hidden', options.cookieOptions);
                };
            }
            
            // Using cookies
            if (useCookie) {     
                       
                // Check for cookie. If set, set default state.
                if ($.cookie(cookieName)) {
                                    
                    if ($.cookie(cookieName) == 'visible') {
                        // Turn on
                        turnOn(toggler);
                    }
                    else if ($.cookie(cookieName) == 'hidden') {
                        // Turn off
                        turnOff(toggler);
                    }
                    
                    // Shouldn't get here. If it does, set value to default.
                    else {
                        $.cookie(cookieName, options.cookieValue);
                        if ($.cookie(cookieName) == 'visible') {
                            // Turn on
                            turnOn(toggler);
                        }
                        else if ($.cookie(cookieName) == 'hidden') {
                            // Turn off
                            turnOff(toggler);
                        }
                    }
                }
                
                // If cookie is not set, set default state by setting.
                else {

                    $.cookie(cookieName, options.cookieValue);
                    
                    if (defaultOn) {
                        // Turn on
                        turnOn(toggler);
                    }
                    else {
                        // Turn off
                        turnOff(toggler);
                    }
                }
                
                // Handle clicks on the toggler
                toggler.click(function() {
                    if ($.cookie(cookieName) == 'visible') {
                        // Turn off
                        turnOff(toggler);
                        callbackHide.call(this);
                        return false;
                    }
                    else {
                        // Turn on
                        turnOn(toggler);
                        callbackShow.call(this);
                        return false;
                    };
                });
                
            } 

            // Not using cookies
            else {
            
                // Handle initial state
                $(toggler).each(function() {
                
                    // Handle scoping
                    var thisparent = $(this).closest(parent);
                    var target = thisparent.find(targetObj);

                    if (target.hasClass(targetOffClass)) { // If initially off
                        
                        turnOff(this);
                        
                    } else { // If initially on
                        
                        // Check the defaultOn option
                        if (defaultOn) { // If defaultOn is true, keep everything the way it is and turn on the toggler
                        
                            turnOn(this);
                        
                        } else { // If defaultOn is false, turn off
                                                
                            turnOff(this);
                        
                        }
                    }
                });
                
                // Handle clicks on the toggler
                toggler.click(function(e){
                    e.preventDefault();
                    
                    // Handle scoping
                    var thisparent = $(this).closest(parent);
                    var target = thisparent.find(targetObj);
                    
                    // Do the toggling
                    if ($(target).hasClass(targetOffClass)) { // Turning on
                        
                        turnOn(this);
                        callbackShow.call(this);
                    
                    } else { // Turning off
                        
                        turnOff(this);
                        callbackHide.call(this);
                    }
                });
            
            }
        });
    };
    
})(jQuery);
/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=Placeholder Input Plugin
http://mths.be/placeholder v2.0.4 by @mathias
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
;(function(f,h,$){var a='placeholder' in h.createElement('input'),d='placeholder' in h.createElement('textarea'),i=$.fn,c=$.valHooks,k,j;if(a&&d){j=i.placeholder=function(){return this};j.input=j.textarea=true}else{j=i.placeholder=function(){return this.filter((a?'textarea':':input')+'[placeholder]').not('.placeholder').bind({'focus.placeholder':b,'blur.placeholder':e}).data('placeholder-enabled',true).trigger('blur.placeholder').end()};j.input=a;j.textarea=d;k={get:function(m){var l=$(m);return l.data('placeholder-enabled')&&l.hasClass('placeholder')?'':m.value},set:function(m,n){var l=$(m);if(!l.data('placeholder-enabled')){return m.value=n}if(n==''){m.value=n;if(m!=h.activeElement){e.call(m)}}else{if(l.hasClass('placeholder')){b.call(m,true,n)||(m.value=n)}else{m.value=n}}return l}};a||(c.input=k);d||(c.textarea=k);$(function(){$(h).delegate('form','submit.placeholder',function(){var l=$('.placeholder',this).each(b);setTimeout(function(){l.each(e)},10)})});$(f).bind('beforeunload.placeholder',function(){$('.placeholder').each(function(){this.value=''})})}function g(m){var l={},n=/^jQuery\d+$/;$.each(m.attributes,function(p,o){if(o.specified&&!n.test(o.name)){l[o.name]=o.value}});return l}function b(m,n){var l=this,o=$(l);if(l.value==o.attr('placeholder')&&o.hasClass('placeholder')){if(o.data('placeholder-password')){o=o.hide().next().show().attr('id',o.removeAttr('id').data('placeholder-id'));if(m===true){return o[0].value=n}o.focus()}else{l.value='';o.removeClass('placeholder')}}}function e(){var q,l=this,p=$(l),m=p,o=this.id;if(l.value==''){if(l.type=='password'){if(!p.data('placeholder-textinput')){try{q=p.clone().attr({type:'text'})}catch(n){q=$('<input>').attr($.extend(g(this),{type:'text'}))}q.removeAttr('name').data({'placeholder-password':true,'placeholder-id':o}).bind('focus.placeholder',b);p.data({'placeholder-textinput':q,'placeholder-id':o}).before(q)}p=p.removeAttr('id').hide().prev().attr('id',o).show()}p.addClass('placeholder');p[0].value=p.attr('placeholder')}else{p.removeClass('placeholder')}}}(this,document,jQuery));

/*!
* JQuery RSS Plugin - FeedEk
* http://www.jquery-plugins.net/FeedEK/FeedEK.html
*/
(function(a){a.fn.FeedEk=function(d,f){var b={FeedUrl:"",MaxCount:5,ShowDesc:!0,ShowPubDate:!0,HiddenDivToShow:""};d&&a.extend(b,d);var c=a(this).attr("id");if(null==b.FeedUrl||""==b.FeedUrl)a("#"+c).empty();else{var g=!1,h;a("#"+c).empty().append('<div style="text-align:left; padding:3px;"><img src="../Images/loader.gif" /></div>');a.ajax({url:"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num="+b.MaxCount+"&output=json&q="+encodeURIComponent(b.FeedUrl)+"&callback=?",dataType:"json",
success:function(d){a("#"+c).empty();a.each(d.responseData.feed.entries,function(d,e){g=!0;a("#"+c).append('<div class="ItemTitle"><a href="'+e.link+'" target="_blank" >'+e.title+"</a></div>");b.ShowPubDate&&(h=new Date(e.publishedDate),a("#"+c).append('<div class="ItemDate">'+h.toLocaleDateString()+"</div>"));b.ShowDesc&&a("#"+c).append('<div class="ItemContent">'+e.content+"</div>")});g&&""!=b.HiddenDivToShow&&a("#"+b.HiddenDivToShow).show()}}).done(function(){"function"==typeof f&&f.call(this)})}}})(jQuery);
/*
	sexy-combo 2.1.3	: A jQuery date time picker.
	Authors: 
		Kadalashvili.Vladimir@gmail.com - Vladimir Kadalashvili
		thetoolman@gmail.com 
	Version: 2.1.3
	Website: http://code.google.com/p/sexy-combo/

  This program is free software; you can redistribute it and/or modify  
  it under the terms of the GNU General Public License as published by  
  the Free Software Foundation; either version 2 of the License, or     
  (at your option) any later version.                                   
                                                                        
  This program is distributed in the hope that it will be useful,       
  but WITHOUT ANY WARRANTY; without even the implied warranty of        
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         
  GNU General Public License for more details.                          
                                                                        
  You should have received a copy of the GNU General Public License     
  along with this program; if not, write to the                         
  Free Software Foundation, Inc.,                                       
  59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                                                                       
*/
(function($){$.fn.sexyCombo=function(config){return this.each(function(){if("SELECT"!=this.tagName.toUpperCase()){return;}new $sc(this,config);});};var defaults={skin:"sexy",suffix:"__sexyCombo",hiddenSuffix:"__sexyComboHidden",renameOriginal:false,initialHiddenValue:"",emptyText:"",autoFill:false,triggerSelected:true,filterFn:null,dropUp:false,separator:",",key:"value",value:"text",showListCallback:null,hideListCallback:null,initCallback:null,initEventsCallback:null,changeCallback:null,textChangeCallback:null,checkWidth:true};$.sexyCombo=function(selectbox,config){if(selectbox.tagName.toUpperCase()!="SELECT")return;this.config=$.extend({},defaults,config||{});this.selectbox=$(selectbox);this.options=this.selectbox.children().filter("option");this.wrapper=this.selectbox.wrap("<div>").hide().parent().addClass("combo").addClass(this.config.skin);this.input=$("<input type='text' />").appendTo(this.wrapper).attr("autocomplete","off").attr("value","").attr("name",this.selectbox.attr("name")+this.config.suffix);var origName=this.selectbox.attr("name");var newName=origName+this.config.hiddenSuffix;if(this.config.renameOriginal){this.selectbox.attr("name",newName);}this.hidden=$("<input type='hidden' />").appendTo(this.wrapper).attr("autocomplete","off").attr("value",this.config.initialHiddenValue).attr("name",this.config.renameOriginal?origName:newName);this.icon=$("<div />").appendTo(this.wrapper).addClass("icon");this.listWrapper=$("<div />").appendTo(this.wrapper).addClass("list-wrapper");this.updateDrop();this.list=$("<ul />").appendTo(this.listWrapper);var self=this;var optWidths=[];this.options.each(function(){var optionText=$.trim($(this).text());if(self.config.checkWidth){optWidths.push($("<li />").appendTo(self.list).html("<span>"+optionText+"</span>").addClass("visible").find("span").outerWidth());}else{$("<li />").appendTo(self.list).html("<span>"+optionText+"</span>").addClass("visible");}});this.listItems=this.list.children();if(optWidths.length){optWidths=optWidths.sort(function(a,b){return a-b;});var maxOptionWidth=optWidths[optWidths.length-1];}this.singleItemHeight=this.listItems.outerHeight();this.listWrapper.addClass("invisible");if($.browser.opera){this.wrapper.css({position:"relative",left:"0",top:"0"});}this.filterFn=("function"==typeof(this.config.filterFn))?this.config.filterFn:this.filterFn;this.lastKey=null;this.multiple=this.selectbox.attr("multiple");var self=this;this.wrapper.data("sc:lastEvent","click");this.overflowCSS="overflowY";if((this.config.checkWidth)&&(this.listWrapper.innerWidth()<maxOptionWidth)){this.overflowCSS="overflow";}this.notify("init");this.initEvents();};var $sc=$.sexyCombo;$sc.fn=$sc.prototype={};$sc.fn.extend=$sc.extend=$.extend;$sc.fn.extend({initEvents:function(){var self=this;this.icon.bind("click",function(e){if(!self.wrapper.data("sc:positionY")){self.wrapper.data("sc:positionY",e.pageY);}});this.input.bind("click",function(e){if(!self.wrapper.data("sc:positionY")){self.wrapper.data("sc:positionY",e.pageY);}});this.wrapper.bind("click",function(e){if(!self.wrapper.data("sc:positionY")){self.wrapper.data("sc:positionY",e.pageY);}});this.icon.bind("click",function(){if(self.input.attr("disabled")){self.input.attr("disabled",false);}self.wrapper.data("sc:lastEvent","click");self.filter();self.iconClick();});this.listItems.bind("mouseover",function(e){if("LI"==e.target.nodeName.toUpperCase()){self.highlight(e.target);}else{self.highlight($(e.target).parent());}});this.listItems.bind("click",function(e){self.listItemClick($(e.target));});this.input.bind("keyup",function(e){self.wrapper.data("sc:lastEvent","key");self.keyUp(e);});this.input.bind("keypress",function(e){if($sc.KEY.RETURN==e.keyCode){e.preventDefault();}if($sc.KEY.TAB==e.keyCode)e.preventDefault();});$(document).bind("click",function(e){if((self.icon.get(0)==e.target)||(self.input.get(0)==e.target))return;self.hideList();});this.triggerSelected();this.applyEmptyText();this.input.bind("click",function(e){self.wrapper.data("sc:lastEvent","click");self.icon.trigger("click");});this.wrapper.bind("click",function(){self.wrapper.data("sc:lastEvent","click");});this.input.bind("keydown",function(e){if(9==e.keyCode){e.preventDefault();}});this.wrapper.bind("keyup",function(e){var k=e.keyCode;for(key in $sc.KEY){if($sc.KEY[key]==k){return;}}self.wrapper.data("sc:lastEvent","key");});this.input.bind("click",function(){self.wrapper.data("sc:lastEvent","click");});this.icon.bind("click",function(e){if(!self.wrapper.data("sc:positionY")){self.wrapper.data("sc:positionY",e.pageY);}});this.input.bind("click",function(e){if(!self.wrapper.data("sc:positionY")){self.wrapper.data("sc:positionY",e.pageY);}});this.wrapper.bind("click",function(e){if(!self.wrapper.data("sc:positionY")){self.wrapper.data("sc:positionY",e.pageY);}});this.notify("initEvents");},getTextValue:function(){return this.__getValue("input");},getCurrentTextValue:function(){return this.__getCurrentValue("input");},getHiddenValue:function(){return this.__getValue("hidden");},getCurrentHiddenValue:function(){return this.__getCurrentValue("hidden");},__getValue:function(prop){prop=this[prop];if(!this.multiple)return $.trim(prop.val());var tmpVals=prop.val().split(this.config.separator);var vals=[];for(var i=0,len=tmpVals.length;i<len;++i){vals.push($.trim(tmpVals[i]));}vals=$sc.normalizeArray(vals);return vals;},__getCurrentValue:function(prop){prop=this[prop];if(!this.multiple)return $.trim(prop.val());return $.trim(prop.val().split(this.config.separator).pop());},iconClick:function(){if(this.listVisible()){this.hideList();this.input.blur();}else{this.showList();this.input.focus();if(this.input.val().length){this.selection(this.input.get(0),0,this.input.val().length);}}},listVisible:function(){return this.listWrapper.hasClass("visible");},showList:function(){if(!this.listItems.filter(".visible").length)return;this.listWrapper.removeClass("invisible").addClass("visible");this.wrapper.css("zIndex","99999");this.listWrapper.css("zIndex","99999");this.setListHeight();var listHeight=this.listWrapper.height();var inputHeight=this.wrapper.height();var bottomPos=parseInt(this.wrapper.data("sc:positionY"))+inputHeight+listHeight;var maxShown=$(window).height()+$(document).scrollTop();if(bottomPos>maxShown){this.setDropUp(true);}else{this.setDropUp(false);}if(""==$.trim(this.input.val())){this.highlightFirst();this.listWrapper.scrollTop(0);}else{this.highlightSelected();}this.notify("showList");},hideList:function(){if(this.listWrapper.hasClass("invisible"))return;this.listWrapper.removeClass("visible").addClass("invisible");this.wrapper.css("zIndex","0");this.listWrapper.css("zIndex","99999");this.notify("hideList");},getListItemsHeight:function(){var itemHeight=this.singleItemHeight;return itemHeight*this.liLen();},setOverflow:function(){var maxHeight=this.getListMaxHeight();if(this.getListItemsHeight()>maxHeight)this.listWrapper.css(this.overflowCSS,"scroll");else
this.listWrapper.css(this.overflowCSS,"hidden");},highlight:function(activeItem){if(($sc.KEY.DOWN==this.lastKey)||($sc.KEY.UP==this.lastKey))return;this.listItems.removeClass("active");$(activeItem).addClass("active");},setComboValue:function(val,pop,hideList){var oldVal=this.input.val();var v="";if(this.multiple){v=this.getTextValue();if(pop)v.pop();v.push($.trim(val));v=$sc.normalizeArray(v);v=v.join(this.config.separator)+this.config.separator;}else{v=$.trim(val);}this.input.val(v);this.setHiddenValue(val);this.filter();if(hideList)this.hideList();this.input.removeClass("empty");if(this.multiple)this.input.focus();if(this.input.val()!=oldVal)this.notify("textChange");},setHiddenValue:function(val){var set=false;val=$.trim(val);var oldVal=this.hidden.val();if(!this.multiple){for(var i=0,len=this.options.length;i<len;++i){if(val==this.options.eq(i).text()){this.hidden.val(this.options.eq(i).val());set=true;break;}}}else{var comboVals=this.getTextValue();var hiddenVals=[];for(var i=0,len=comboVals.length;i<len;++i){for(var j=0,len1=this.options.length;j<len1;++j){if(comboVals[i]==this.options.eq(j).text()){hiddenVals.push(this.options.eq(j).val());}}}if(hiddenVals.length){set=true;this.hidden.val(hiddenVals.join(this.config.separator));}}if(!set){this.hidden.val(this.config.initialHiddenValue);}if(oldVal!=this.hidden.val())this.notify("change");this.selectbox.val(this.hidden.val());this.selectbox.trigger("change");},listItemClick:function(item){this.setComboValue(item.text(),true,true);this.inputFocus();},filter:function(){if("yes"==this.wrapper.data("sc:optionsChanged")){var self=this;this.listItems.remove();this.options=this.selectbox.children().filter("option");this.options.each(function(){var optionText=$.trim($(this).text());$("<li />").appendTo(self.list).text(optionText).addClass("visible");});this.listItems=this.list.children();this.listItems.bind("mouseover",function(e){self.highlight(e.target);});this.listItems.bind("click",function(e){self.listItemClick($(e.target));});self.wrapper.data("sc:optionsChanged","");}var comboValue=this.input.val();var self=this;this.listItems.each(function(){var $this=$(this);var itemValue=$this.text();if(self.filterFn.call(self,self.getCurrentTextValue(),itemValue,self.getTextValue())){$this.removeClass("invisible").addClass("visible");}else{$this.removeClass("visible").addClass("invisible");}});this.setOverflow();this.setListHeight();},filterFn:function(currentComboValue,itemValue,allComboValues){if("click"==this.wrapper.data("sc:lastEvent")){return true;}if(!this.multiple){return itemValue.toLowerCase().indexOf(currentComboValue.toLowerCase())==0;}else{for(var i=0,len=allComboValues.length;i<len;++i){if(itemValue==allComboValues[i]){return false;}}return itemValue.toLowerCase().search(currentComboValue.toLowerCase())==0;}},getListMaxHeight:function(){var result=parseInt(this.listWrapper.css("maxHeight"),10);if(isNaN(result)){result=this.singleItemHeight*10;}return result;},setListHeight:function(){var liHeight=this.getListItemsHeight();var maxHeight=this.getListMaxHeight();var listHeight=this.listWrapper.height();if(liHeight<listHeight){this.listWrapper.height(liHeight);return liHeight;}else if(liHeight>listHeight){this.listWrapper.height(Math.min(maxHeight,liHeight));return Math.min(maxHeight,liHeight);}},getActive:function(){return this.listItems.filter(".active");},keyUp:function(e){this.lastKey=e.keyCode;var k=$sc.KEY;switch(e.keyCode){case k.RETURN:case k.TAB:this.setComboValue(this.getActive().text(),true,true);if(!this.multiple)break;case k.DOWN:this.highlightNext();break;case k.UP:this.highlightPrev();break;case k.ESC:this.hideList();break;default:this.inputChanged();break;}},liLen:function(){return this.listItems.filter(".visible").length;},inputChanged:function(){this.filter();if(this.liLen()){this.showList();this.setOverflow();this.setListHeight();}else{this.hideList();}this.setHiddenValue(this.input.val());this.notify("textChange");},highlightFirst:function(){this.listItems.removeClass("active").filter(".visible:eq(0)").addClass("active");this.autoFill();},highlightSelected:function(){this.listItems.removeClass("active");var val=$.trim(this.input.val());try{this.listItems.each(function(){var $this=$(this);if($this.text()==val){$this.addClass("active");self.listWrapper.scrollTop(0);self.scrollDown();}});this.highlightFirst();}catch(e){}},highlightNext:function(){var $next=this.getActive().next();while($next.hasClass("invisible")&&$next.length){$next=$next.next();}if($next.length){this.listItems.removeClass("active");$next.addClass("active");this.scrollDown();}},scrollDown:function(){if("scroll"!=this.listWrapper.css(this.overflowCSS))return;var beforeActive=this.getActiveIndex()+1;var minScroll=this.listItems.outerHeight()*beforeActive-this.listWrapper.height();if($.browser.msie)minScroll+=beforeActive;if(this.listWrapper.scrollTop()<minScroll)this.listWrapper.scrollTop(minScroll);},highlightPrev:function(){var $prev=this.getActive().prev();while($prev.length&&$prev.hasClass("invisible"))$prev=$prev.prev();if($prev.length){this.getActive().removeClass("active");$prev.addClass("active");this.scrollUp();}},getActiveIndex:function(){return $.inArray(this.getActive().get(0),this.listItems.filter(".visible").get());},scrollUp:function(){if("scroll"!=this.listWrapper.css(this.overflowCSS))return;var maxScroll=this.getActiveIndex()*this.listItems.outerHeight();if(this.listWrapper.scrollTop()>maxScroll){this.listWrapper.scrollTop(maxScroll);}},applyEmptyText:function(){if(!this.config.emptyText.length)return;var self=this;this.input.bind("focus",function(){self.inputFocus();}).bind("blur",function(){self.inputBlur();});if(""==this.input.val()){this.input.addClass("empty").val(this.config.emptyText);}},inputFocus:function(){if(this.input.hasClass("empty")){this.input.removeClass("empty").val("");}},inputBlur:function(){if(""==this.input.val()){this.input.addClass("empty").val(this.config.emptyText);}},triggerSelected:function(){if(!this.config.triggerSelected)return;var self=this;try{this.options.each(function(){if($(this).attr("selected")){self.setComboValue($(this).text(),false,true);throw new Error();}});}catch(e){return;}self.setComboValue(this.options.eq(0).text(),false,false);},autoFill:function(){if(!this.config.autoFill||($sc.KEY.BACKSPACE==this.lastKey)||this.multiple)return;var curVal=this.input.val();var newVal=this.getActive().text();this.input.val(newVal);this.selection(this.input.get(0),curVal.length,newVal.length);},selection:function(field,start,end){if(field.createTextRange){var selRange=field.createTextRange();selRange.collapse(true);selRange.moveStart("character",start);selRange.moveEnd("character",end);selRange.select();}else if(field.setSelectionRange){field.setSelectionRange(start,end);}else{if(field.selectionStart){field.selectionStart=start;field.selectionEnd=end;}}},updateDrop:function(){if(this.config.dropUp)this.listWrapper.addClass("list-wrapper-up");else
this.listWrapper.removeClass("list-wrapper-up");},setDropUp:function(drop){this.config.dropUp=drop;this.updateDrop();},notify:function(evt){if(!$.isFunction(this.config[evt+"Callback"]))return;this.config[evt+"Callback"].call(this);}});$sc.extend({KEY:{UP:38,DOWN:40,DEL:46,TAB:9,RETURN:13,ESC:27,COMMA:188,PAGEUP:33,PAGEDOWN:34,BACKSPACE:8},log:function(msg){var $log=$("#log");$log.html($log.html()+msg+"<br />");},createSelectbox:function(config){var $selectbox=$("<select />").appendTo(config.container).attr({name:config.name,id:config.id,size:"1"});if(config.multiple)$selectbox.attr("multiple",true);var data=config.data;var selected=false;for(var i=0,len=data.length;i<len;++i){selected=data[i].selected||false;$("<option />").appendTo($selectbox).attr("value",data[i][config.key]).text(data[i][config.value]).attr("selected",selected);}return $selectbox.get(0);},create:function(config){var defaults={name:"",id:"",data:[],multiple:false,key:"value",value:"text",container:$(document),url:"",ajaxData:{}};config=$.extend({},defaults,config||{});if(config.url){return $.getJSON(config.url,config.ajaxData,function(data){delete config.url;delete config.ajaxData;config.data=data;return $sc.create(config);});}config.container=$(config.container);var selectbox=$sc.createSelectbox(config);return new $sc(selectbox,config);},deactivate:function($select){$select=$($select);$select.each(function(){if("SELECT"!=this.tagName.toUpperCase()){return;}var $this=$(this);if(!$this.parent().is(".combo")){return;}});},activate:function($select){$select=$($select);$select.each(function(){if("SELECT"!=this.tagName.toUpperCase()){return;}var $this=$(this);if(!$this.parent().is(".combo")){return;}$this.parent().find("input[type='text']").attr("disabled",false);});},changeOptions:function($select){$select=$($select);$select.each(function(){if("SELECT"!=this.tagName.toUpperCase()){return;}var $this=$(this);var $wrapper=$this.parent();var $input=$wrapper.find("input[type='text']");var $listWrapper=$wrapper.find("ul").parent();$listWrapper.removeClass("visible").addClass("invisible");$wrapper.css("zIndex","0");$listWrapper.css("zIndex","99999");$input.val("");$wrapper.data("sc:optionsChanged","yes");var $selectbox=$this;$selectbox.parent().find("input[type='text']").val($selectbox.find("option:eq(0)").text());$selectbox.parent().data("sc:lastEvent","click");$selectbox.find("option:eq(0)").attr('selected','selected');});},normalizeArray:function(arr){var result=[];for(var i=0,len=arr.length;i<len;++i){if(""==arr[i])continue;result.push(arr[i]);}return result;}});})(jQuery);

/*
 * =Dropdown Menu
 * jQuery dropdown: A simple dropdown plugin
 *
 * Inspired by Bootstrap: http://twitter.github.com/bootstrap/javascript.html#dropdowns
 *
 * Copyright 2011 Cory LaViska for A Beautiful Site, LLC. (http://abeautifulsite.net/)
 *
 * Dual licensed under the MIT or GPL Version 2 licenses
 *
*/
if(jQuery) (function($) {	
	$.extend($.fn, {
		dropdown: function(method, data) {
			
			switch( method ) {
				case 'hide':
					hideDropdowns();
					return $(this);
				case 'attach':
					return $(this).attr('data-dropdown', data);
				case 'detach':
					hideDropdowns();
					return $(this).removeAttr('data-dropdown');
				case 'disable':
					return $(this).addClass('dropdown-disabled');
				case 'enable':
					hideDropdowns();
					return $(this).removeClass('dropdown-disabled');
			}			
		}
	});	
	function showMenu(event) {   
		var trigger = $(this),
			dropdown = $( $(this).attr('data-dropdown') ),
			isOpen = trigger.hasClass('dropdown-open');		
    if (trigger != event.target && $(event.target).hasClass('dropdown-ignore')) return; //ignore elements or children with this class.
    event.preventDefault();
		event.stopPropagation();		
		hideDropdowns();		
		if( isOpen || trigger.hasClass('dropdown-disabled') ) return;		
		dropdown
			.css({
				left: dropdown.hasClass('anchor-right') ? 
					trigger.offset().left - (dropdown.outerWidth() - trigger.outerWidth()) : trigger.offset().left,
				top: trigger.offset().top + trigger.outerHeight ()
			})
			.show();	
		trigger.addClass('dropdown-open selected');	
	};	
	function hideDropdowns(event) {	
		var targetGroup = event ? $(event.target).parents().andSelf() : null;
		if( targetGroup && targetGroup.is('.dropdown-menu') && !targetGroup.is('A') ) return;
		
		$('BODY')
			.find('.dropdown-menu').hide().end()
			.find('[data-dropdown]').removeClass('dropdown-open selected');     
	};	
	$(function () {
		$('BODY').on('click.dropdown', '[data-dropdown]', showMenu);
		$('HTML').on('click.dropdown', hideDropdowns);
		// Hide on resize (IE7/8 trigger this when any element is resized...)
		if( !$.browser.msie || ($.browser.msie && $.browser.version >= 9) ) {
			$(window).on('resize.dropdown', hideDropdowns);
		}
	});
	
})(jQuery);

/*
* =Timeline
* Timeliner.js
* @version		1.0
* @copyright	Tarek Anandan (http://www.technotarek.com)
*/

;(function($){$.timeliner=function(options){settings=jQuery.extend({timelineContainer:'#timelineContainer',startState:'closed',baseSpeed:200},options);$(document).ready(function(){if(settings.startState=='closed'){$(".timelineEvent").hide()}else{$(".timelineMinor dt, .timelineMinor dt a").addClass('open').css("fontSize","1.2em");$(".timelineEvent").show()}$(".timelineMinor dt").toggle(function(){var currentId=$(this).attr('id');$("a",this).removeClass('closed').addClass('open').animate({fontSize:"1.2em"},settings.baseSpeed);$("#"+currentId+"EX").show(4*settings.baseSpeed)},function(){var currentId=$(this).attr('id');$("a",this).animate({fontSize:"1.0em"},0).removeClass('open').addClass('closed');$("#"+currentId+"EX").hide(4*settings.baseSpeed)});$(".timelineMajorMarker").toggle(function(){$(this).parents(".timelineMajor").find("dt a","dl.timelineMinor").animate({fontSize:"1.2em"},settings.baseSpeed).removeClass('closed').addClass('open');$(this).parents(".timelineMajor").find(".timelineEvent").show(4*settings.baseSpeed)},function(){$(this).parents(".timelineMajor").find("dl.timelineMinor a").animate({fontSize:"1.0em"},settings.baseSpeed).removeClass('open').addClass('closed');$(this).parents(".timelineMajor").find(".timelineEvent").hide(4*settings.baseSpeed)});$(".expandAll").toggle(function(){$(this).parents(settings.timelineContainer).find("dt a","dl.timelineMinor").animate({fontSize:"1.2em"},settings.baseSpeed).removeClass('closed').addClass('open');$(this).parents(settings.timelineContainer).find(".timelineEvent").show(4*settings.baseSpeed);$(this).html("[-]")},function(){$(this).parents(settings.timelineContainer).find("dl.timelineMinor a").animate({fontSize:"1.0em"},settings.baseSpeed).removeClass('open').addClass('closed');$(this).parents(settings.timelineContainer).find(".timelineEvent").hide(4*settings.baseSpeed);$(this).html("[+]")})})}})(jQuery);

/*
 * jQuery UI Multi Open Accordion Plugin
 * Author	: Anas Nakawa (http://anasnakawa.wordpress.com/)
 * Date		: 22-Jul-2011
 * Released Under MIT License
 * You are welcome to enhance this plugin at https://code.google.com/p/jquery-multi-open-accordion/
 */
(function($){
	
	$.widget('ui.multiOpenAccordion', {
		options: {
			active: 0,
			showAll: null,
			hideAll: null,
			_classes: {
				accordion: 'ui-accordion ui-widget ui-helper-reset ui-accordion-icons',
				h3: 'ui-accordion-header ui-helper-reset ui-state-default ui-corner-all',
				div: 'ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom',
				divActive: 'ui-accordion-content-active',
				span: 'ui-icon ui-icon-triangle-1-e',
				stateDefault: 'ui-state-default',
				stateHover: 'ui-state-hover'
			} 
		},

		_create: function() {
			var self = this,
			
			options  = self.options,
			
			$this = self.element,
			
			$h3 = $this.children('h3'),
			
			$div = $this.children('div');
			
			$this.addClass(options._classes.accordion);
			
			$h3.each(function(index){
				var $this = $(this);
				$this.addClass(options._classes.h3).prepend('<span class="{class}"></span>'.replace(/{class}/, options._classes.span));
				if(self._isActive(index)) {
					self._showTab($this)
				}
			}); // end h3 each
			
			$this.children('div').each(function(index){
				var $this = $(this);
				$this.addClass(options._classes.div);
			}); // end each
			
			$h3.bind('click', function(e){
				// preventing on click to navigate to the top of document
				e.preventDefault();
				var $this = $(this);
				var ui = {
					tab: $this,
					content: $this.next('div')
				};
				self._trigger('click', null, ui);
				if ($this.hasClass(options._classes.stateDefault)) {
					self._showTab($this);
				} else {
					self._hideTab($this);
				}
			});
			
			
			$h3.bind('mouseover', function(){
				$(this).addClass(options._classes.stateHover);
			});
			
			$h3.bind('mouseout', function(){
				$(this).removeClass(options._classes.stateHover);
			});
			
			// triggering initialized
			self._trigger('init', null, $this);
			
		},
		
		// destroying the whole multi open widget
		destroy: function() {
			var self = this;
			var $this = self.element;
			var $h3 = $this.children('h3');
			var $div = $this.children('div');
			var options = self.options;
			$this.children('h3').unbind('click mouseover mouseout');
			$this.removeClass(options._classes.accordion);
			$h3.removeClass(options._classes.h3).removeClass('ui-state-default ui-corner-all ui-state-active ui-corner-top').children('span').remove();
			$div.removeClass(options._classes.div + ' ' + options._classes.divActive).show();
		},
		
		// private helper method that used to show tabs
		_showTab: function($this) {
			var $span = $this.children('span.ui-icon');
			var $div = $this.next();
			var options = this.options;
			$this.removeClass('ui-state-default ui-corner-all').addClass('ui-state-active ui-corner-top');
			$span.removeClass('ui-icon-triangle-1-e').addClass('ui-icon-triangle-1-s');
			$div.slideDown('fast', function(){
				$div.addClass(options._classes.divActive);
			});
			var ui = {
				tab: $this,
				content: $this.next('div')
			}
			this._trigger('tabShown', null, ui);
		},
		
		// private helper method that used to show tabs 
		_hideTab: function($this) {
			var $span = $this.children('span.ui-icon');
			var $div = $this.next();
			var options = this.options;
			$this.removeClass('ui-state-active ui-corner-top').addClass('ui-state-default ui-corner-all');
			$span.removeClass('ui-icon-triangle-1-s').addClass('ui-icon-triangle-1-e');
			$div.slideUp('fast', function(){
				$div.removeClass(options._classes.divActive);
			});
			var ui = {
				tab: $this,
				content: $this.next('div')
			}
			this._trigger('tabHidden', null, ui);
		},
		
		// helper method to determine wether passed parameter is an index of an active tab or not
		_isActive: function(num) {
			var options = this.options;
			// if array
			if(typeof options.active == "boolean" && !options.active) {
				return false;
			} else {
				if(options.active.length != undefined) {
					for (var i = 0; i < options.active.length ; i++) {
						if(options.active[i] == num)
							return true;
					}
				} else {
					return options.active == num;
				}
			}
			return false;
		},
		
		// return object contain currently opened tabs
		_getActiveTabs: function() {
			var $this = this.element;
			var ui = [];
			$this.children('div').each(function(index){
				var $content = $(this);
				if($content.is(':visible')) {
					//ui = ui ? ui : [];
					ui.push({
						index: index,
						tab: $content.prev('h3'),
						content: $content
					});
				}
			});
			return (ui.length == 0 ? undefined : ui);
		},
		
		getActiveTabs: function() {
			var el = this.element;
			var tabs = [];
			el.children('div').each(function(index){
				if($(this).is(':visible')) {
					tabs.push(index);
				}
			});
			return (tabs.length == 0 ? [-1] : tabs);
		},
		
		// setting array of active tabs
		_setActiveTabs: function(tabs) {
			var self = this;
			var $this = this.element;
			if(typeof tabs != 'undefined') {
				$this.children('div').each(function(index){
					var $tab = $(this).prev('h3');
					if(tabs.hasObject(index)) {
						self._showTab($tab);
					} else {
						self._hideTab($tab);
					}
				});
			}
		},
		
		// active option passed by plugin, this method will read it and convert it into array of tab indexes
		_generateTabsArrayFromOptions: function(tabOption) {
			var tabs = [];
			var self = this;
			var $this = self.element;
			var size = $this.children('h3').size();
			if($.type(tabOption) === 'array') {
				return tabOption;
			} else if($.type(tabOption) === 'number') {
				return [tabOption];
			} else if($.type(tabOption) === 'string') {
				switch(tabOption.toLowerCase()) {
					case 'all':
						var size = $this.children('h3').size();
						for(var n = 0 ; n < size ; n++) {
							tabs.push(n);
						}
						return tabs;
						break;
					case 'none':
						tabs = [-1];
						return tabs;
						break;
					default:
						return undefined;
						break;
				}
			}
		},
		
		// required method by jquery ui widget framework, used to provide the ability to pass options
		// currently only active option is used here, may grow in the future
		_setOption: function(option, value){
			$.Widget.prototype._setOption.apply( this, arguments );
			var el = this.element;
			switch(option) {
				case 'active':
					this._setActiveTabs(this._generateTabsArrayFromOptions(value));
					break;
				case 'getActiveTabs':
					var el = this.element;
					var tabs;
					el.children('div').each(function(index){
						if($(this).is(':visible')) {
							tabs = tabs ? tabs : [];
							tabs.push(index);
						}
					});
					return (tabs.length == 0 ? [-1] : tabs);
					break;
			}
		}
		
	});
	
	// helper array has object function
	// thanks to @Vinko Vrsalovic
	// http://stackoverflow.com/questions/143847/best-way-to-find-an-item-in-a-javascript-array
	Array.prototype.hasObject = (!Array.indexOf ? function (o) {
	    var l = this.length + 1;
	    while (l -= 1) {
	        if (this[l - 1] === o) {
	            return true;
	        }
	    }
	    return false;
	  }: function (o) {
	    return (this.indexOf(o) !== -1);
	  }
	);
	
})(jQuery);
