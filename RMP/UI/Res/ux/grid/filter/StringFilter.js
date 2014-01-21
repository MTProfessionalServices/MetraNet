Ext.ux.grid.filter.StringFilter = Ext.extend(Ext.ux.grid.filter.Filter, {
	updateBuffer: 500,
	icon: '/Res/Images/icons/find.png',
	
	init: function(){
		this.menu = new Ext.ux.menu.RangeMenu(
		  {fieldCls:     Ext.form.TextField}
		);
		
		this.menu.on("update", this.fireUpdate, this);
	/*
		var value = this.value = new Ext.ux.menu.EditableItem({icon: this.icon});
		value.on('keyup', this.onKeyUp, this);
		this.menu.add(value);
		
		this.updateTask = new Ext.util.DelayedTask(this.fireUpdate, this);
	*/
	},
	
	onKeyUp: function(event){
		if(event.getKey() == event.ENTER){
			this.menu.hide(true);
			return;
		}
			
		this.updateTask.delay(this.updateBuffer);
	},
	
	isActivatable: function(){
	
    var value = this.menu.getValue();
		return value.lk !== undefined || value.eq !== undefined || value.gt !== undefined || value.gte !== undefined ||value.lt !== undefined || value.lte !== undefined || value.ne !== undefined;

		//return this.value.getValue().length > 0;
	},
	
	fireUpdate: function(){		
	  /*
		if(this.active)
			this.fireEvent("update", this);
			*/
		this.setActive(this.isActivatable());
	},
	
	setValue: function(value){
		//this.value.setValue(value);
		
		this.menu.setValue(value);
	},
	
	getValue: function(){
		//return this.value.getValue();
		
		return this.menu.getValue();
	},
	
	serialize: function(){
		//var args = {type: 'string', value: this.getValue()};
    var args = [];
		var values = this.menu.getValue();
		for(var key in values)
			args.push({type: 'string', comparison: key, value: values[key]});
	
		
		
		this.fireEvent('serialize', args, this);
		return args;
	},
	
	validateRecord: function(record){
	return true; ///
	
		var val = record.get(this.dataIndex);
		
		if(typeof val != "string")
			return this.getValue().length == 0;
			
		return val.toLowerCase().indexOf(this.getValue().toLowerCase()) > -1;
	}
});