/*
This plugin adds the 'Insert Variable' button in the toolbar.
*/

(function(){
// Section 1 : Code to execute when the toolbar button is pressed
	var a = {
		/*exec:function(editor){
			var theSelectedText = editor.getSelection().getNative();
			CallCfWindow(theSelectedText);
		}*/
		$('#email-body').block({ message: null });
	},
	
// Section 2 : Create the button and add the functionality to it
	b = 'addvariable';
	CKEDITOR.plugins.add(b,{
		init:function(editor){
			editor.addCommand(b,a);
			editor.ui.addButton('addvariable',{
				label:'Add variable',
				icon: this.path + 'add_variable.png',
				command:b
			});
		}
	});
})();
