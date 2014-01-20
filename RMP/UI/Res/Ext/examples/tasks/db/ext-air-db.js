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
 Ext.data.AirDB = Ext.extend(Ext.data.SqlDB, {
	open : function(db, cb, scope){
		this.conn = new air.SQLConnection();

		var file = air.File.applicationResourceDirectory.resolve(db);

		this.conn.addEventListener(air.SQLEvent.OPEN, this.onOpen.createDelegate(this, [cb, scope]));
		this.conn.addEventListener(air.SQLEvent.CLOSE, this.onClose.createDelegate(this));
		this.conn.open(file, true);
	},

	close : function(){
		this.conn.close();
	},

	onOpen : function(cb, scope){
		this.openState = true;
		Ext.callback(cb, scope, [this]);
		this.fireEvent('open', this);
	},

	onClose : function(){
		this.fireEvent('close', this);
	},

	onError : function(e, stmt, type, cb, scope){
		Ext.callback(cb, scope, [false, e, stmt]);
	},

	onResult : function(e, stmt, type, cb, scope){
		if(type == 'exec'){
			Ext.callback(cb, scope, [true, e, stmt]);
		}else{
			var r = [];
			var result = stmt.getResult();
			if(result && result.data){
		        var len = result.data.length;
		        for(var i = 0; i < len; i++) {
		            r[r.length] = result.data[i];
		        }
		    }
			Ext.callback(cb, scope, [r, e, stmt]);
		}
	},

	createStatement : function(type, cb, scope){

		var stmt = new air.SQLStatement();

		stmt.addEventListener(air.SQLErrorEvent.ERROR, this.onError.createDelegate(this, [stmt, type, cb, scope], true));
		stmt.addEventListener(air.SQLEvent.RESULT, this.onResult.createDelegate(this, [stmt, type, cb, scope], true));

		stmt.sqlConnection = this.conn;

		return stmt;
	},

	exec : function(sql, cb, scope){
		var stmt = this.createStatement('exec', cb, scope);
		stmt.text = sql;
		stmt.execute();
	},

	execBy : function(sql, args, cb, scope){
		var stmt = this.createStatement('exec', cb, scope);
		stmt.text = sql;
		this.addParams(stmt, args);
		stmt.execute();
	},

	query : function(sql, cb, scope){
		var stmt = this.createStatement('query', cb, scope);
		stmt.text = sql;
		stmt.execute(this.maxResults);
	},

	queryBy : function(sql, args, cb, scope){
		var stmt = this.createStatement('query', cb, scope);
		stmt.text = sql;
		this.addParams(stmt, args);
		stmt.execute(this.maxResults);
	},

    addParams : function(stmt, args){
		if(!args){ return; }
		for(var key in args){
			if(args.hasOwnProperty(key)){
				if(!isNaN(key)){
					stmt.parameters[parseInt(key)+1] = args[key];
				}else{
					stmt.parameters[':' + key] = args[key];
				}
			}
		}
		return stmt;
	}
});