using System;
using System.Collections;


namespace CubePrototype
{
	
	/// <summary>
	/// 
	/// </summary>

	class MTProperty : IComparer, IComparable
	{
		public MTProperty() {}
		public MTProperty(string aColumn,string aType) 
		{
			column = aColumn;
			type = aType;
		}	
	
		public string column {
			get { return mColumn; }
			set { mColumn = value; }
		}
		public string type {
			get { return mType; }
			set { mType = value; }
		}
		
		// XXX do more research on Compare.... the original 
		// implementation was off... probably should use 
		// reflection to verify the type
		public int Compare(object x,object y) 
		{
			//Less than zero: x is less than y. 
			//Zero: x equals y. 
			//Greater than zero: x is greater than y. 
			int retval = ((MTProperty)x).mColumn.CompareTo(y);
			return retval;
		}
		
		public int CompareTo(object obj)
		{
			if(obj is MTProperty) {
				return Compare(this,((MTProperty)obj).column);
			}
			else {
				throw new Exception("MTProperty: CompareTo called on object that is a MTProperty");
			}
		}
	
		protected string mColumn;
		protected string mType; 
	}
	
	class MTDBProperty : MTProperty
	{
		public MTDBProperty() {}
		public MTDBProperty(string aColumn,string aType) : base(aColumn,aType) 
		{
			mAlias = this.column;
		}
		
		public MTDBProperty(string aColumn,string aType,string aTableName,string alias)
		: base(aColumn,aType)
		{
			mTableName = aTableName;
			mAlias = alias;
		}
		
		public string TableName
		{
			get { return mTableName; }
			set { mTableName = value; }
		}
		
		public string alias {
			get { return mAlias; }
			set { mAlias = value; }
		}
		
		
		protected string mTableName;
		protected string mAlias;
	
	}
	
	/// <summary>
	/// 
	/// </summary>

	class PropertyException : System.Exception
	{
		public PropertyException(string szVal) : base(szVal) {}
	}
	
	/// <summary>
	/// 
	/// </summary>

	class MTProperties
	{
		public MTProperties()
		{
			mPropertyList = new ArrayList();
			sorted = false;
		}
	
		public void AddProperty(MTProperty InProp)
		{
			mPropertyList.Add(InProp);
			sorted = false;
		}

		public System.Collections.IEnumerator ListEnum()
		{
			return mPropertyList.GetEnumerator();
		}
		
		public bool InCollection(MTProperty aProp)
		{
			try {
				MTProperty temp  = find(aProp);
				return true;
			}
			catch(PropertyException) {
				return false;
			}
		}
		
		public MTProperty find(MTProperty aProp)
		{
			return findbyname(aProp.column);
		}
		
		public MTProperty find(string aColumnVal)
		{
			return findbyname(aColumnVal);
		}
		
		
		// protected methods
		protected MTProperty findbyname(string aColumnVal)
		{
			if(!sorted) 
			{
				mPropertyList.Sort();
				sorted = true;
			}
			int location = mPropertyList.BinarySearch(aColumnVal,new MTProperty());
			if(location < 0) 
			{
				throw new PropertyException("property not found");
			}
			return (MTProperty)this.mPropertyList[location];
		}

		protected ArrayList mPropertyList;
		protected bool sorted;
	}
	
	/// <summary>
	/// 
	/// </summary>

	class MTCubeTable : MTProperties
	{
		public MTCubeTable() {}
		public MTCubeTable(string aTableName) 
		{
			mTableName = aTableName;
		}
		public MTCubeTable(string aTableName,string aAlias)
		{
			mTableName = aTableName;
			mTableAlias = aAlias;
		}	
	
		public string TableName {
			get { return mTableName; }
			set { mTableName = value; }
		}
		public string TableAlias {
			get { return mTableAlias; }
			set { mTableAlias = value; }
		}
		
		public string TableQueryName 
		{
			get {
				if(this.AliasSet) {
					return this.TableAlias;
				}
				return this.TableName;
			}
		}
		
		public bool AliasSet 
		{
			get {
				if(mTableAlias == null) {
					return false;
				} 
				return true;
			}
		}
		
		public string GenFromClause()
		{
			string retval;
			if(this.AliasSet) {
				retval = this.TableName + " " + this.TableAlias;
			}
			else {
				retval = this.TableName;
			}
			return retval;
		}
		
		public void ClonePropertiesFromCubeTable(MTCubeTable source)
		{
			this.mPropertyList = (ArrayList)source.mPropertyList.Clone();
		}
		
		protected string mTableName; 	
		protected string mTableAlias;
	}
	
	/// <summary>
	/// 
	/// </summary>
	
	class MTMeasure : MTDBProperty
	{
		public MTMeasure(MTCubeTable aFactTable,string aColumn,string aType) 
		: base(aColumn,aType) 
		{
			mFactTable = aFactTable;
		}		
		
		public MTMeasure(MTCubeTable aFactTable,MTProperty aFactProperty)
		: base(aFactProperty.column,aFactProperty.type)
		{
			mFactTable = aFactTable;
		}
		
		public MTProperty FactProperty {
			get { return (MTProperty)this; }
			set {
				this.column = value.column;
				this.type = value.type;
			}
		}
	
		public string AggregateFunc {
			get { return mAggFunc; }
			set { mAggFunc = value; }
		}
		
		public string GenerateSQLFragment()
		{
			// XXX fix this
			return mAggFunc + "(" + mFactTable.TableName + "." + this.column  + ") " + this.alias;
		}
	
		protected string mAggFunc;
		protected MTCubeTable mFactTable;
	}
	
	/// <summary>
	/// 
	/// </summary>
	
	interface ICubeAssociation {
		string JoinClause();
		string GenSelectList();
		string GenGroupBy();
		void Associate(MTProperty aFactProperty,MTProperty aDimensionProperty);
	}
	
	class MTCubeAssociation : ICubeAssociation
	{
		public MTCubeAssociation(MTCubeTable aFactTable,
			MTCubeTable aDimensionTable)
		{
			mFactTable = aFactTable;
			mDimensionTable = aDimensionTable;
			mAssociationSet = false;
		}
		
		public void Associate(MTProperty aFactProperty,
			MTProperty aDimensionProperty)
	{
		// step 1 : verify the the fact property exists in the
		// fact table
		if(!mFactTable.InCollection(aFactProperty)) {
			throw new Exception("Specified fact association not found in fact table");
		}
		// step 2: verify that the dimension property is part of the dimension table
		if(!mDimensionTable.InCollection(aDimensionProperty)) {
			throw new Exception("Specified dimension property not found in dimension table");
		}
		// step 3: verify that the type signatures match
		if(aFactProperty.type.CompareTo(aDimensionProperty.type) == 0) {
			mFactProperty = aFactProperty;
			mDimensionProperty = aDimensionProperty;
			mAssociationSet = true;
		}
		else {
			throw new Exception("column type mismatch");
		}
	}
		
		
		
		public MTProperty FactProperty {
			get { return mFactProperty; }
		}
	
		public MTProperty DimensionProperty {
			get { return mDimensionProperty; }
		}
		
		public string JoinClause()
		{
			string factTable;
			string dimensionTable;
			string joinString = "INNER JOIN ";
			
			if(!mAssociationSet) {
				throw new Exception("association not configured.");
			}
			
			factTable = mFactTable.AliasSet ? mFactTable.TableAlias : mFactTable.TableName;
			dimensionTable = mDimensionTable.AliasSet ? mDimensionTable.TableAlias : mDimensionTable.TableName;

			if(!mDimensionTable.AliasSet) {
				joinString += dimensionTable;
			}
			else {
				joinString += dimensionTable + " " + mDimensionTable.TableAlias;
			}
			joinString += " ON " + dimensionTable + "." + mDimensionProperty.column + 
			"= " + factTable + "." + mFactProperty.column;
			joinString += "\n";
			return joinString;
		}
		
		public string GenSelectList()
		{
			string retval = mDimensionTable.TableQueryName + "." + mDimensionProperty.column;
			return retval;
		}
		
		public string GenGroupBy()
		{
			string retval = mDimensionTable.TableQueryName + "." + mDimensionProperty.column;
			return retval;
		}
	
		protected MTCubeTable mFactTable;
		protected MTCubeTable mDimensionTable;
		protected MTProperty mFactProperty;
		protected MTProperty mDimensionProperty;
		protected bool mAssociationSet;
	}



class MTParentChildAssociation : ICubeAssociation
{
	public MTParentChildAssociation(MTCubeTable aFactTable,
		MTCubeTable aParentTable,MTCubeTable aChildTable)
		{
			if(!aParentTable.AliasSet) {
				throw new Exception("Parent table must have an alias");
			}
			if(!aChildTable.AliasSet) {
				throw new Exception("Child table must have an alias");
			}
		mFactTable = aFactTable;
		mParentTable = aParentTable;
		mChildTable = aChildTable;
		
		mParentConstraints = new Hashtable();
		mChildConstraints = new Hashtable();
	}

	public void Associate(MTProperty parent,MTProperty child)
	{
		// XXX more robust checking here
		parentProperty = parent;
		childProperty = child;
	}
	
	public MTDimension AddParentConstraint(string name,MTProperty constrainedProp)
	{
		MTDimension retval = new MTDimension(mParentTable,constrainedProp);
		mParentConstraints.Add(name,retval);
		return retval;
	}
	
	public MTDimension AddChildConstraint(string name,MTProperty constrainedProp)
	{
		MTDimension retval = new MTDimension(mChildTable,constrainedProp);
		mChildConstraints.Add(name,retval);
		return retval;
	}

	public string JoinClause()
	{
		// XXX missing proper handling if no constraints are specified
		string parentJoin = "INNER JOIN " + mParentTable.TableName + " as " +
		mParentTable.TableQueryName + " ON " + 
		GenerateJoinList(mParentConstraints);
		
		string childJoin = "INNER JOIN " + mChildTable.TableName + " as " +
			mChildTable.TableQueryName + " ON "  +
			mChildTable.TableQueryName + "." + parentProperty.column + " = " + 
			mParentTable.TableQueryName + "." + childProperty.column + " AND " + 
			GenerateJoinList(mChildConstraints);
		
		
		return parentJoin + "\n" + childJoin + "\n";
	}
	
	protected string GenerateJoinList(Hashtable constraintList)
	{
		string retval = "";
		string AndStr = " AND ";

		IDictionaryEnumerator it = constraintList.GetEnumerator();
		while(it.MoveNext()) 
		{
			retval += ((MTDimension)it.Value).GenWhereClause() + AndStr;
		}
		if(retval.Length > 0) {
			retval = retval.Remove(retval.Length-AndStr.Length,AndStr.Length);
		}
		return retval;
	}
	
	public string GenSelectList()
	{
		string retval = "";
		return retval;
	}
	
	public string GenGroupBy()
	{
		string groupby = "";
		return groupby;
	}
	
	
	// data	
	protected MTCubeTable mFactTable;
	protected MTCubeTable mParentTable;
	protected MTCubeTable mChildTable;
	protected MTProperty parentProperty;
	protected MTProperty childProperty;
	protected Hashtable mParentConstraints;
	protected Hashtable mChildConstraints;
}


class MTAssociation : ICubeAssociation
{
	public MTAssociation(MTCubeTable aSourceTable,MTCubeTable aMatchTable)
	{
		mSourceTable = aSourceTable;
		mMatchTable = aMatchTable;
	}
	
	public string JoinClause()
	{
	
		string retval = "INNER JOIN " + mSourceTable.TableName;
		if(mSourceTable.AliasSet) {
			retval += " as " + mSourceTable.TableQueryName;
		}
		retval += " ON " + mSourceTable.TableQueryName + "." + mSourceProp.column + 
		" = " + mMatchTable.TableQueryName + "." + mMatchProp.column + "\n";
		return retval;
	}
	
	public string GenSelectList()
	{
		string retval = "";
		return retval;
	}
	
	public string GenGroupBy()
	{
		string retval = "";
		return retval;
	}

	public void Associate(MTProperty aSourceProp,MTProperty aMatchProp)
	{
		mSourceProp = aSourceProp;
		mMatchProp = aMatchProp;
	}
	
	protected MTCubeTable mSourceTable;
	protected MTCubeTable mMatchTable;
	protected MTProperty mSourceProp;
	protected MTProperty mMatchProp;
	
}

	/// <summary>
	/// 
	/// </summary>
	
	class MTDimension : MTDBProperty
	{
		public MTDimension(MTCubeTable aCubeTable,MTProperty aMatchProperty) 
		: base(aMatchProperty.column,aMatchProperty.type) 
		{
			mTable = aCubeTable;
			mEnum = ConditionEnum.Operator;
		}
		public MTCubeTable AssociatedTable {
			get { return this.mTable; }
		}
		public MTProperty AssociatedProperty {
			get { return (MTProperty)this; }
		}
		
		public string conditionvalue
		{	
			get { return mConditionValue; }
			set { 
				mConditionValue = value; 
			}
		}
		public string conditionoperator
		{
			get { return mConditionOperator; }
			set { mConditionOperator = value; }
		}
		
		public string[] ConditionIn
		{
			get { 
				if(mEnum == ConditionEnum.In) {
					return mConditionArray;
				}
				else {
					return new string[1]{""};
				}
			}
			set {
				mConditionArray = value;
				mEnum = ConditionEnum.In;
			} 
		}
		
		public string[] Between
		{
			get {
				return this.ConditionIn;			
			}
			set {
				this.ConditionIn = value;
				mEnum = ConditionEnum.Between;
			}
		}
		
		public bool ConditionSpecified 
		{
			get { 
				if(mEnum == ConditionEnum.Operator && 
				conditionvalue != null && conditionoperator != null
				|| (mEnum == ConditionEnum.Between && mConditionArray.Length == 2) 
				|| (mEnum == ConditionEnum.In && mConditionArray.Length >= 1))
				 {
					return conditionvalue.Length != 0 && conditionoperator.Length != 0; 
				}
				return false;			
			}
		}
		
		public string GenWhereClause()
		{
			string retval = "";
			switch(mEnum) {
				case ConditionEnum.Between:
					// XXX error checking
					retval = mTable.TableQueryName + "." + this.column 
					+ " BETWEEN " + 
					mConditionArray[0] + " AND " + mConditionArray[1];
					break;
				case ConditionEnum.In:
					// XXX error checking
					retval = mTable.TableQueryName + "." + this.column + " in (";
					for(int i=0;i < mConditionArray.Length;i++) {
						retval += mConditionArray[i] + ",";
					}
					// remove the trailing ,
					retval = retval.Remove(retval.Length-1,1);
					retval += ")";
					break;
				case ConditionEnum.Operator:
				retval = mTable.TableQueryName + "." + this.column
			+ " " + mConditionOperator + " " + mConditionValue;
				break;
			}
			return retval;
		}
		
		public string GroupByClause()
		{
			string retval = mTable.TableQueryName + "." + this.column;
			return retval;
		}
		
		public string SelectClause()
		{
			string retval = mTable.TableQueryName + "." + this.column;
			return retval;
		}

		// enumerations
		protected enum ConditionEnum {none,Operator,Between,In };
		
		// data
		protected ConditionEnum mEnum;
		protected MTCubeTable mTable;
		protected string[] mConditionArray;
		protected string mConditionValue;
		protected string mConditionOperator;
	}
	
	/// <summary>
	/// 
	/// </summary>
	
	class MTCube
	{
		public MTCube() 
		{
			mAssocTable = new Hashtable();
			mDimensionTable = new ArrayList();
		}
		
		/// <summary>
		/// Creates a MTCubeSlice object populated with the current cube.  The
		/// second argument is used to control the generation of dimensions
		/// from the dimension tables in the cube.
		/// </summary>
		/// <param name="bDimensionTablesInSelectList"></param>
		/// <returns></returns>
			
		public MTCubeSlice CreateCubeSlice(bool bDimensionTablesInSelectList)
		{
			MTCubeSlice retval = new MTCubeSlice(this,bDimensionTablesInSelectList);
			return retval;
		}
		
		public MTAssociation CreateAssociation(string name,MTCubeTable aSource,
		MTCubeTable aMatch)
		{
			MTAssociation assoc = new MTAssociation(aSource,aMatch);
			mAssocTable.Add(name,assoc);
			return assoc;
		}
		
		public MTCubeAssociation CreateCubeAssociation(string name,string aDimensionName)
		{
			// step 1: find the associated dimension table object
			IEnumerator it = mDimensionTable.GetEnumerator();
			while(it.MoveNext()) 
			{
				MTCubeTable aCubeRef = (MTCubeTable)it.Current;
				if((aCubeRef.AliasSet && 
					aCubeRef.TableAlias.CompareTo(aDimensionName) == 0)
					|| aCubeRef.TableName.CompareTo(aDimensionName) == 0) {
						// step 2: create the cube association
						MTCubeAssociation retval = new MTCubeAssociation(mFactTable,aCubeRef);
						// step 3: add the association to the collection
						mAssocTable.Add(name,retval);
						return retval;
					}
			}			
			throw new Exception("failed to find dimension table in collection");		
		
		}
		
		public MTCubeAssociation CreateCubeAssociation(string name,MTCubeTable aDimensionTable)
		{
			// step 1: find the associated dimension table object
			IEnumerator it = mDimensionTable.GetEnumerator();
			while(it.MoveNext()) {
				MTCubeTable aCubeRef = (MTCubeTable)it.Current;
				if(aCubeRef.Equals(aDimensionTable)) {
					// step 2: create the cube association
					MTCubeAssociation retval = new MTCubeAssociation(mFactTable,aCubeRef);
					// step 3: add the association to the collection
					mAssocTable.Add(name,retval);
					return retval;
				}
			}
			throw new Exception("failed to find dimension table in collection");		
		}
		
		public MTParentChildAssociation CreateParentChildAssociation(string name,
		MTCubeTable aParent,
		MTCubeTable aChild)
		{
			// XXX verify that these tables are already associated or not
			MTParentChildAssociation assoc = new MTParentChildAssociation(mFactTable,
			aParent,aChild);
			mAssocTable.Add(name,assoc);
			return assoc;
		}
		
		public void DropCubeAssociation(string name)
		{
			mAssocTable.Remove(name);
		}
		
		public void DropCubeAssociation(MTCubeAssociation aAssociation)
		{
			System.Collections.IDictionaryEnumerator it = mAssocTable.GetEnumerator();
			MTCubeAssociation tempval;
			while(it.MoveNext()) {
				// XXX I am not sure if I should be use .value or .Current
				if(it.Value is MTCubeAssociation) {
				
					tempval = (MTCubeAssociation)it.Value;
					if(tempval.Equals(aAssociation)) {
						mAssocTable.Remove(it.Current);
					}
				}
			}
		}
		
		public MTCubeTable FactTable
		{
			get { return mFactTable; }
			set { mFactTable = value; }
		}
		
		public void AddDimensionTable(MTCubeTable aDimTable)
		{
			mDimensionTable.Add(aDimTable);
		}
		
		// const??
		public IEnumerator DimensionIterator
		{
			get { return mDimensionTable.GetEnumerator(); }
		}
		
		public IDictionaryEnumerator AssociationIter
		{
			get { return mAssocTable.GetEnumerator(); }
		}
		
		public string GenJoinClause()
		{
			string retval = "";
			
			IDictionaryEnumerator it = mAssocTable.GetEnumerator();
			while(it.MoveNext()) {
				retval += ((ICubeAssociation)it.Value).JoinClause();
			}
			return retval;
		}
		
		
		// data
		protected Hashtable mAssocTable;
		protected MTCubeTable mFactTable;
		protected ArrayList mDimensionTable;
	}
	
	/// <summary>
	/// 
	/// </summary>
	
	class MTCubeSlice
	{
		public MTCubeSlice(MTCube aCube,bool InsertDimensionsFromDimensionTable) 
		{
			mDimList = new Hashtable();
			mMeasureList = new ArrayList();
			mCube = aCube;
			
			if(InsertDimensionsFromDimensionTable) {
				GenerateDimensions();
			}
		}
		
		public MTCube sliceCube {
			get { return mCube; }
		}
		
		public MTMeasure AddMeasure(MTProperty aFactProperty,string aggregate)
		{
			MTMeasure measure = new MTMeasure(mCube.FactTable,aFactProperty);
			measure.AggregateFunc = aggregate;
			mMeasureList.Add(measure);
			return measure;
		}
		public MTDimension AddDimension(string DimensionName,
			MTCubeTable aTable,MTProperty aProperty)
		{
			// XXX verify that the table is part of the cube
			
			// XXX verify that the property is from the cubetable
			MTDimension mydim = new MTDimension(aTable,aProperty);
			mDimList.Add(DimensionName,mydim);
			return mydim;
		}
		
		public IDictionaryEnumerator dimensionIterator
		{
			get { return mDimList.GetEnumerator(); }
		}
		
		public MTDimension this [string index]
		{
			get {
				return (MTDimension)mDimList[index];
			}
		}
		
		public MTDimension this [int index]
		{
			get {
				int i = 0;
				IDictionaryEnumerator it= this.dimensionIterator;
				while(it.MoveNext()) {
					if(i==index) {
						return (MTDimension)it.Value;
					}
					i++;
				}
				throw new Exception("index out of range");
			}
		}
	
		public void FetchData()
		{
			throw new Exception("not implemented");
		
		}

		// XXX this really should be protected
		public string GenerateQuery()
		{
			string aGenString = "SELECT ";
			// add in the aggregates.  XXX what do we do if there are none?
			aGenString += AggSelectList() + " ";
			string groupby = mGroupByList;
			string dimselectlist = mSelectList;
			DimensionSelectList(ref dimselectlist,ref groupby);
			// add in the dimension select values
			if(dimselectlist.Length != 0) {
				aGenString += "," + dimselectlist;
			}
			
			aGenString += "\nFROM " + mCube.FactTable.GenFromClause() + "\n";
			// add in the dimension tables (via the table Assocition)
			aGenString += mCube.GenJoinClause();
			// add in the where clause if necessary
			string dimwhereclause = GenDimWhereClause();
			if(dimwhereclause.Length > 0) {
				aGenString += "WHERE\n" + dimwhereclause + "\n";
			}
			if(groupby.Length > 0) {
				aGenString += "GROUP BY " + groupby;
			}
			return aGenString;
		}

		////////////////////////////////////////////////////
		// protected methods
		////////////////////////////////////////////////////
		
		protected string GenDimWhereClause()
		{
			const string AndClause = " AND ";
			string retval = "";
			IDictionaryEnumerator it = mDimList.GetEnumerator();
			while(it.MoveNext()) {
				MTDimension tempdim = (MTDimension)it.Value;
				if(tempdim.ConditionSpecified) {
					
					retval += tempdim.GenWhereClause() + AndClause;
				}
			}
			if(retval.Length > 0) {
				retval = retval.Remove(retval.Length-AndClause.Length,AndClause.Length);
			}
			return retval;
		}
		
		protected string AggSelectList()
		{
			string retval = "";
			IEnumerator it = mMeasureList.GetEnumerator();
			while(it.MoveNext()) {
				MTMeasure tempMeasure = (MTMeasure)it.Current;
				retval += tempMeasure.GenerateSQLFragment() + ",";
			}
			// trim the last ,
			if(retval.Length > 0) {
				retval = retval.Remove(retval.Length-1,1);
			}
			return retval;
		}
		

		/// <summary>
		/// 
		/// </summary>
		/// <param name="selectlist"></param>
		/// <param name="groupbylist"></param>
		
		protected void DimensionSelectList(ref string selectlist,ref string groupbylist)
		{
			IDictionaryEnumerator it = mDimList.GetEnumerator();
			while(it.MoveNext()) {
				MTDimension tempdim = (MTDimension)it.Value;
				// XXX this is broken because we do not support aliases properly
				selectlist += tempdim.SelectClause() + ",";
				groupbylist += tempdim.GroupByClause() + ",";
			}
			if(selectlist.Length > 0) {
				selectlist = selectlist.Remove(selectlist.Length-1,1);
				groupbylist = groupbylist.Remove(groupbylist.Length-1,1);
			}
		}
		
		protected void GenerateDimensions()
		{
			IDictionaryEnumerator myEnumerator = mCube.AssociationIter;
			while(myEnumerator.MoveNext()) {
				
				ICubeAssociation tempassoc = (ICubeAssociation)myEnumerator.Value;
				mSelectList += tempassoc.GenSelectList() + ",";
				mGroupByList += tempassoc.GenGroupBy() + ",";
			}
		}
		


		// data		
		protected Hashtable mDimList;
		protected ArrayList mMeasureList;
		protected MTCube mCube;
		string mSelectList;
		string mGroupByList;
		
	}





	/// <summary>
	/// Summary description for Class1.``
	/// </summary>
	class TestCube
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			TestCube.RealTableTest();
		}
		
		public static string DbTimeStr
		{
			get {
				string retval = "'" + System.DateTime.Now.ToString() + "'";
				return retval;
			}
		}
		
		public static void RealTableTest()
		{
			MTCubeTable usage = new MTCubeTable("t_acc_usage_test");
			MTCubeTable parent = new MTCubeTable("t_account_ancestor","parent");
			MTCubeTable child = new MTCubeTable("t_account_ancestor","child");
			MTCubeTable mapper = new MTCubeTable("t_account_mapper_test");

			// all the properties for t_acc_usage_test
			usage.AddProperty(new MTProperty("id_sess","int"));
			usage.AddProperty(new MTProperty("tx_UID","varbinary"));
			usage.AddProperty(new MTProperty("id_acc","int"));
			usage.AddProperty(new MTProperty("id_view","int"));
			usage.AddProperty(new MTProperty("id_usage_interval","int"));
			usage.AddProperty(new MTProperty("id_parent_sess","int"));
			usage.AddProperty(new MTProperty("id_prod","int"));
			usage.AddProperty(new MTProperty("id_svc","int"));
			usage.AddProperty(new MTProperty("dt_session","datetime"));
			usage.AddProperty(new MTProperty("amount","numeric"));
			usage.AddProperty(new MTProperty("am_currency","varchar"));
			usage.AddProperty(new MTProperty("dt_crt","datetime"));
			usage.AddProperty(new MTProperty("tx_batch","varbinary"));
			usage.AddProperty(new MTProperty("tax_federal","numeric"));
			usage.AddProperty(new MTProperty("tax_state","numeric"));
			usage.AddProperty(new MTProperty("tax_county","numeric"));
			usage.AddProperty(new MTProperty("tax_local","numeric"));
			usage.AddProperty(new MTProperty("tax_other","numeric"));
			usage.AddProperty(new MTProperty("id_pi_instance","int"));
			usage.AddProperty(new MTProperty("id_pi_template","int"));

			// all the properties for t_account_ancestor
			parent.AddProperty(new MTProperty("id_ancestor","int"));
			parent.AddProperty(new MTProperty("id_descendent","int"));
			parent.AddProperty(new MTProperty("num_generations","int"));
			parent.AddProperty(new MTProperty("b_children","char(1)"));
			parent.AddProperty(new MTProperty("vt_start","datetime"));
			parent.AddProperty(new MTProperty("vt_end","datetime"));
			
			child.ClonePropertiesFromCubeTable(parent);
			
			// all the properties for t_account_mapper_test
			mapper.AddProperty(new MTProperty("nm_login","nvarchar"));
			mapper.AddProperty(new MTProperty("nm_space","nvarchar"));
			mapper.AddProperty(new MTProperty("id_acc","int"));
		
			MTCube mycube = new MTCube();
			mycube.FactTable = usage;
			mycube.AddDimensionTable(parent);
			mycube.AddDimensionTable(child);
			mycube.AddDimensionTable(mapper);
			MTParentChildAssociation dimensionAssoc= mycube.CreateParentChildAssociation("ancestor",
				parent,child);
			MTAssociation mapperAssoc = 
				mycube.CreateAssociation("mapper association",mapper,parent);
				
				dimensionAssoc.Associate(parent.find("id_ancestor"),child.find("id_descendent"));
				
				MTDimension childstartdate = dimensionAssoc.AddChildConstraint("childstartdate",child.find("vt_start"));
				childstartdate.conditionoperator = "<=";
				childstartdate.conditionvalue = TestCube.DbTimeStr;
				
			MTDimension childenddate = dimensionAssoc.AddChildConstraint("childenddate",child.find("vt_end"));
			childenddate.conditionoperator = ">";
			childenddate.conditionvalue = TestCube.DbTimeStr;
			
			MTDimension childUsage = dimensionAssoc.AddChildConstraint("childusage",child.find("id_descendent"));
			childUsage.conditionoperator = "=";
			childUsage.conditionvalue = "t_acc_usage_test.id_acc";
			
			MTDimension parentstartdate = dimensionAssoc.AddParentConstraint("parentstart",parent.find("vt_start"));
			parentstartdate.conditionoperator = "<=";
			parentstartdate.conditionvalue = TestCube.DbTimeStr;
			
			MTDimension parentenddate = dimensionAssoc.AddParentConstraint("parentend",parent.find("vt_end"));
			parentenddate.conditionoperator = ">";
			parentenddate.conditionvalue = TestCube.DbTimeStr;
			
			MTDimension parentAncestor = dimensionAssoc.AddParentConstraint("parentAncestor",parent.find("id_ancestor"));
			parentAncestor.conditionoperator = "=";
			parentAncestor.conditionvalue = "1";

			MTDimension parentGenerations = dimensionAssoc.AddParentConstraint("parentGenerations",parent.find("num_generations"));
			parentGenerations.conditionoperator = "=";
			parentGenerations.conditionvalue = "1";

			mapperAssoc.Associate(mapper.find("id_acc"),
			parent.find("id_descendent"));
			
			MTCubeSlice myslice = mycube.CreateCubeSlice(false);
			myslice.AddMeasure(myslice.sliceCube.FactTable.find("amount"),"SUM");
			MTDimension mydim = myslice.AddDimension("Interval",usage,
				usage.find("id_usage_interval"));
			myslice["Interval"].conditionoperator = "=";
			myslice["Interval"].conditionvalue = "1000";
			
			MTDimension name = myslice.AddDimension("name",mapper,
			mapper.find("nm_login"));
			System.Console.WriteLine(myslice.GenerateQuery());
			
			
		}
		
		
		public static void Oldtest()
		{
			// create our tables
			MTCubeTable usage = new MTCubeTable("usage_test");
			MTCubeTable acc = new MTCubeTable("acc_test");
			
			usage.AddProperty(new MTProperty("id_acc","int"));
			usage.AddProperty(new MTProperty("amount","decimal"));
			usage.AddProperty(new MTProperty("tax","decimal"));
			usage.AddProperty(new MTProperty("id_prod","decimal"));
			usage.AddProperty(new MTProperty("id_pi","int"));

			acc.AddProperty(new MTProperty("id_acc","int"));
			acc.AddProperty(new MTProperty("id_parent","int"));
			acc.AddProperty(new MTProperty("nm_name","varchar(256"));

			// create a cube with the fact table and one dimension table
			MTCube mycube = new MTCube();
			mycube.FactTable = usage;
			mycube.AddDimensionTable(acc);
			MTCubeAssociation association = 
				mycube.CreateCubeAssociation("account association","acc_test");
				
			association.Associate(mycube.FactTable.find("id_acc"),acc.find("id_acc"));
		
			// create a measure
			
			MTCubeSlice myslice = mycube.CreateCubeSlice(true);
			myslice.AddMeasure(myslice.sliceCube.FactTable.find("amount"),"SUM");
			System.Console.WriteLine(myslice.GenerateQuery());
			
			MTDimension mydim = myslice.AddDimension("product",usage,usage.find("id_prod"));
			System.Console.WriteLine("\r\n" + myslice.GenerateQuery());
			
			myslice["product"].conditionoperator = "=";
			myslice["product"].conditionvalue = "1";
			System.Console.WriteLine("\r\n" + myslice.GenerateQuery());
			myslice[0].conditionvalue = "2";
			System.Console.WriteLine("\r\n" + myslice.GenerateQuery());
			myslice.AddMeasure(usage.find("amount"),"AVG");
			System.Console.WriteLine("\r\n" + myslice.GenerateQuery());
			
			myslice["product"].Between = new String[2] {"1","2"};
			System.Console.WriteLine("\r\n" + myslice.GenerateQuery());
			myslice["product"].ConditionIn = new String[2] {"1","2"};
			System.Console.WriteLine("\r\n" + myslice.GenerateQuery());

			System.Console.Write(System.DateTime.Now);
		}
	}
}
