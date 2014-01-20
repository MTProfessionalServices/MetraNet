Ext.namespace("Ext.ux.menu");
Ext.ux.menu.RangeMenu = function(){
	Ext.ux.menu.RangeMenu.superclass.constructor.apply(this, arguments);
	this.updateTask = new Ext.util.DelayedTask(this.fireUpdate, this);

	var cfg = this.fieldCfg;
	var cls = this.fieldCls;
	var fields = this.fields = Ext.applyIf(this.fields || {}, {
		'gt': new Ext.ux.menu.EditableItem({
			icon:  this.icons.gt,
			editor: new cls(typeof cfg == "object" ? cfg.gt || '' : cfg)}),
		'gte': new Ext.ux.menu.EditableItem({
			icon:  this.icons.gte,
			editor: new cls(typeof cfg == "object" ? cfg.gte || '' : cfg)}),			
		'lt': new Ext.ux.menu.EditableItem({
			icon:  this.icons.lt,
			editor: new cls(typeof cfg == "object" ? cfg.lt || '' : cfg)}),
		'lte': new Ext.ux.menu.EditableItem({
			icon:  this.icons.lte,
			editor: new cls(typeof cfg == "object" ? cfg.lte || '' : cfg)}),
		'eq': new Ext.ux.menu.EditableItem({
			icon:   this.icons.eq, 
			editor: new cls(typeof cfg == "object" ? cfg.gt || '' : cfg)}),
		'ne': new Ext.ux.menu.EditableItem({
			icon:   this.icons.ne, 
			editor: new cls(typeof cfg == "object" ? cfg.ne || '' : cfg)}),
		'lk': new Ext.ux.menu.EditableItem({
			icon:   this.icons.lk, 
			editor: new cls(typeof cfg == "object" ? cfg.ne || '' : cfg)})
			
	});
	this.add(fields.gt,fields.gte, fields.lt, '-', fields.eq);
	
	for(var key in fields)
		fields[key].on('keyup', function(event, input, notSure, field){
			if(event.getKey() == event.ENTER && field.isValid()){
				this.hide(true);
				return;
			}
			
			if(field == fields.eq){
				fields.gt.setValue(null);
				fields.gte.setValue(null);				
				fields.lt.setValue(null);
				fields.lte.setValue(null);				
				fields.ne.setValue(null);			
				
			} else {
				fields.eq.setValue(null);
			}
			
			this.updateTask.delay(this.updateBuffer);
		}.createDelegate(this, [fields[key]], true));

	this.addEvents({'update': true});
};
Ext.extend(Ext.ux.menu.RangeMenu, Ext.menu.Menu, {
	fieldCls:     Ext.ux.form.LargeNumberField,
	fieldCfg:     '',
	updateBuffer: 500,
	icons: {
		gt: '/Res/Images/icons/greater_then.png', 
		gte: '/Res/Images/icons/greater_equal.png',		
		lt: '/Res/Images/icons/less_then.png',
		lte: '/Res/Images/icons/less_then.png',		
		ne: '/Res/Images/icons/equals.png',
		eq: '/Res/Images/icons/equals.png',	
		lk: '/Res/Images/icons/equals.png'},
		
	fireUpdate: function(){
		this.fireEvent("update", this);
	},
	
	setValue: function(data){
		for(var key in this.fields)
			this.fields[key].setValue(data[key] !== undefined ? data[key] : '');
		
		this.fireEvent("update", this);
	},
	
	getValue: function(){
		var result = {};
		for(var key in this.fields){
			var field = this.fields[key];
			if(field.isValid() && (field.getValue() !== undefined) && String(field.getValue()).length > 0)
				result[key] = field.getValue();
		}
		
		return result;
	}
});