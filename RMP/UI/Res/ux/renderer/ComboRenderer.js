Ext.ns("Ext.ux.renderer");

Ext.ux.renderer.ComboRenderer = function(options) {
    var value = options.value;
    var combo = options.combo;

    var returnValue = value;
    var valueField = combo.valueField;
        
    var idx = combo.store.findBy(function(record) {
        if(record.get(valueField) == value) {
            returnValue = record.get(combo.displayField);
            return true;
        }
    });
    
    // This is our application specific and might need to be removed for your apps
//    if(idx < 0 && value == 0) {
//        returnValue = '';
//    }
    
    return returnValue;
};

Ext.ux.renderer.ComboRendererEx = function(options) {
    var value = options.value;
    var combo = options.combo;
    var data = options.data

    var returnValue = value;
    var valueField = combo.valueField;

        var idx = combo.store.findBy(function(record) {
            
                if (record.get(valueField) == value) {
                    returnValue = record.get(combo.displayField);
                    return true;
                }
           
        });
    
    
    return returnValue;
};


Ext.ux.renderer.Combo = function(combo) {
    return function(value, meta, record) {
        return Ext.ux.renderer.ComboRenderer({value: value, meta: meta, record: record, combo: combo});
    };
}

Ext.ux.renderer.ComboEx = function(data) {
  var combo = new Ext.form.ComboBox({
    store:new Ext.data.SimpleStore(
    {
      fields:['value','text'],
      data:data            
    }
    ),
    displayField:'text',
    valueField:'value',
    mode:'local',
    triggerAction:'all',
    typeAhead:true    
  });

    return function(value, meta, record) {
        return Ext.ux.renderer.ComboRendererEx({value: value, meta: meta, record: record, combo: combo, data: data});
    };
}