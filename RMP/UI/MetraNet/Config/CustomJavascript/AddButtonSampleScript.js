Ext.onReady(function () {
  var panel = Ext.getCmp('formPanel_ctl00_ContentPlaceHolder1_ctl00');

  var tb = new Ext.Button({
    text: 'Click me',        
    handler: function() {
        alert('You clicked the button!');
    }
	});

  panel.add(tb);
  panel.doLayout();
});
