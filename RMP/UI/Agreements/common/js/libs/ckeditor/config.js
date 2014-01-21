/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function(config)
{
	// Define changes to default configuration here.
	
	config.resize_enabled = false;
	config.resize_maxWidth = '';
	config.uiColor = '#ddd';
	config.toolbar_Full =
	[
		{ name: 'basicstyles', items : [ 'Bold','Italic','Strike','Subscript','Superscript' ] },
		{ name: 'paragraph', items : [ 'NumberedList','BulletedList','Outdent','Indent','Blockquote','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock' ] },
		{ name: 'links', items : [ 'Link','Unlink','Anchor' ] },
		{ name: 'insert', items : [ 'Image','Table','HorizontalRule' ] },
		{ name: 'clipboard', items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','Undo','Redo' ] },
		{ name: 'styles', items : [ 'Format','FontSize' ] },
		{ name: 'document', items : [ 'Source' ] }
	];
	//config.extraPlugins = 'addvariable';
};
