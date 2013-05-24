using System;
using System.Collections;
using System.Runtime.InteropServices;

namespace MetraTech.Pipeline
{
	[Guid("a1f59fa1-a3f0-46b0-b591-8716227ba661")]
		// TODO: should implement IEnumerable!
	public interface IPipelineSessionSet // : IEnumerable
	{
		void Add(PipelineSession session);
		IEnumerator GetEnumerator();
	}

	[Guid("02ea0044-83b4-4d24-900b-2f72e164e781")]
	[ClassInterface(ClassInterfaceType.None)]
	public class PipelineSessionSet : IPipelineSessionSet
	{
		public void Add(PipelineSession session)
		{
			mItems.Add(session);
		}

		public IEnumerator GetEnumerator()
		{
			return mItems.GetEnumerator();
		}

		private ArrayList mItems = new ArrayList();
	}

	[Guid("0490ee77-5b28-41fb-976f-5f291a5a0427")]
	public interface IPipelineSession
	{
		byte [] UID
		{ get; set; }

		int ServiceIndex
		{ get; set; }

		PipelineSession Parent
		{ get; set; }

		IEnumerable Children
		{ get; }

		void AddChild(PipelineSession session);

		void SetProperty(int index, int nameID, int value);
		void SetProperty(int index, int nameID, DateTime value);
		void SetProperty(int index, int nameID, string value);
		void SetProperty(int index, int nameID, decimal value);


		void Synchronize();

		void SetPropertyUnsync(int index, int value);
		void SetPropertyUnsync(int index, DateTime value);
		void SetPropertyUnsync(int index, string value);
		void SetPropertyUnsync(int index, decimal value);

		//PipelineProperty GetProperty(int index);
	}


	[Guid("ac36dc0a-3279-4dc9-b796-8f0e23c4ed66")]
	[ClassInterface(ClassInterfaceType.None)]
	public class PipelineSession : IPipelineSession
	{
		public PipelineSession()
		{
			mProperties = new PipelineProperty[0]; // new ArrayList();
			mNameIDs = null;
		}

		public byte [] UID
		{
			get { return mUID; }
			set { mUID = value; }
		}

		public int ServiceIndex
		{
			get { return mServiceIndex; }
			set
			{
				mServiceIndex = value;
				mNameIDs = null;
			}
		}

		public PipelineSession Parent
		{
			get { return mParent; }
			set { mParent = value; }
		}

		public IEnumerable Children
		{
			get { return mChildren; }
		}

		public void AddChild(PipelineSession session)
		{
			mChildren.Add(session);
		}

		/*
			public void AddProperty(int index, int nameID,
			PipelinePropType propType,
			object value)
			{
			mProperties[index] = new PipelineProperty(nameID, propType, value);
			}
		*/

		public void SetProperty(int index, int nameID,
														int value)
		{
			SynchronizeProps(index);

			mProperties[index].SetValue(value);
		}

		public void SetProperty(int index, int nameID,
														DateTime value)
		{
			SynchronizeProps(index);

			mProperties[index].SetValue(value);
		}

		public void SetProperty(int index, int nameID,
														string value)
		{
			SynchronizeProps(index);

			mProperties[index].SetValue(value);
		}

		public void SetProperty(int index, int nameID,
														decimal value)
		{
			SynchronizeProps(index);

			mProperties[index].SetValue(value);
		}



		public void SetPropertyUnsync(int index, int value)
		{
			mProperties[index].SetValue(value);
		}

		public void SetPropertyUnsync(int index, DateTime value)
		{
			mProperties[index].SetValue(value);
		}

		public void SetPropertyUnsync(int index, string value)
		{
			mProperties[index].SetValue(value);
		}

		public void SetPropertyUnsync(int index, decimal value)
		{
			mProperties[index].SetValue(value);
		}




		public PipelineProperty GetProperty(int index)
		{
			SynchronizeProps(index);

			return (PipelineProperty) mProperties[index];
		}

		public void Synchronize()
		{
			mNameIDs = PipelinePropIDManager.GetNameIDsForService(mServiceIndex);
			PipelineProperty [] newProps = new PipelineProperty[mNameIDs.Length];
			for (int i = 0; i < mNameIDs.Length; ++i)
				newProps[i].NameID = mNameIDs[i];

			mProperties = newProps;
		}

		private void SynchronizeProps(int index)
		{
			if (index >= mProperties.Length)
				GrowProps();
			// could check that index is in range of mProperties again..  for now let it throw
		}

		private void GrowProps()
		{
			mNameIDs = PipelinePropIDManager.GetNameIDsForService(mServiceIndex);
			//mProperties.Capacity = mNameIDs.Length;
			int current = mProperties.Length;
			PipelineProperty [] newProps = new PipelineProperty[mNameIDs.Length];
			mProperties.CopyTo(newProps, 0);
			while (current < mNameIDs.Length)
			{
				newProps[current].NameID = mNameIDs[current];
				++current;
			}

			mProperties = newProps;
		}

		private int [] mNameIDs = null;
		private byte [] mUID = null;
		private int mServiceIndex;
		private PipelineSession mParent = null;
		private ArrayList mChildren = new ArrayList();

		//private Hashtable mProperties = new Hashtable();
		//private ArrayList mProperties;
		private PipelineProperty [] mProperties;
	}

	[Guid("500ce2bb-a49a-4747-b83e-f7f6acb84752")]
	public enum PipelinePropType
	{
		Date,
		Time,
		String,
		Int32,
		Double,
		Bool,
		Enum,
		Decimal,
		Object,
		Undefined
	}


	[ComVisible(false)]
	public interface IPipelineProperty
	{
		PipelinePropType Type
		{ get; set; }
	}

	[ComVisible(false)]
	public struct PipelineProperty : IPipelineProperty
	{
		/*
		public PipelineProperty(int nameID)
		{
			mNameID = nameID;
			mType = PipelinePropType.Undefined;
			mStringValue = null;
			mValues = new ValueUnion();
		}
		*/

		public int NameID
		{
			get { return mNameID; }
			set { mNameID = value; }
		}

		/*
		public object Value
		{
			get { return mValue; }
			set { mValue = value; }
		}
		*/

		public PipelinePropType Type
		{
			get { return mType; }
			set { mType = value; }
		}

		public void SetValue(int value)
		{
			mType = PipelinePropType.Int32;
			mValues.mIntValue = value;
		}

		public void SetValue(decimal value)
		{
			mType = PipelinePropType.Decimal;
			mValues.mDecimalValue = value;
		}

		public void SetValue(DateTime value)
		{
			mType = PipelinePropType.Date;
			mValues.mDateTimeValue = value;
		}

		public void SetValue(string value)
		{
			mType = PipelinePropType.String;
			mStringValue = value;
		}

		public int Int32Value
		{
			get { return mValues.mIntValue; }
		}

		public DateTime DateTimeValue
		{
			get { return mValues.mDateTimeValue; }
		}

		public decimal DecimalValue
		{
			get { return mValues.mDecimalValue; }
		}

		public string StringValue
		{
			get { return mStringValue; }
		}

		[StructLayout(LayoutKind.Explicit)]
		private struct ValueUnion
		{
			[FieldOffset(0)]
			public int mIntValue;
			[FieldOffset(0)]
			public DateTime mDateTimeValue;
			[FieldOffset(0)]
			public decimal mDecimalValue;
		}

		private int mNameID;
		private PipelinePropType mType;

		private string mStringValue;
		private ValueUnion mValues;
	}

	[ComVisible(false)]
	public class PipelinePropIDManager
	{
		public static int GetIndexForService(int serviceID)
		{
			lock(mServiceIDs)
			{
				object value = mServiceIDs[serviceID];
				int index;
				if (value != null)
					index = (int) value;
				else
				{
					index = AddService(serviceID);
				}
				return index;
			}
		}

		public static int [] GetNameIDsForService(int serviceIndex)
		{
			lock (mNameIDArrays)
			{
				int [] lst = (int []) mNameIDArrays[serviceIndex];
				if (lst == null)
				{
					Hashtable nameIDs = (Hashtable) mNameIDs[serviceIndex];
					lst = new int[nameIDs.Count];
					// figure out the current mapping
					foreach (DictionaryEntry entry in nameIDs)
						lst[(int) entry.Value] = (int) entry.Key;

					mNameIDArrays[serviceIndex] = lst;
					return lst;
				}
				else
					return lst;
			}
		}

		public static int GetIndexForNameID(int serviceIndex, int nameID)
		{
			lock (mNameIDArrays)
			{
				Hashtable lookup = (Hashtable) mNameIDs[serviceIndex];
				object val = lookup[nameID];
				int index;
				if (val == null)
				{
					index = (int) mNextPropertyIndex[serviceIndex];
					mNextPropertyIndex[serviceIndex] = index + 1;
					lookup[nameID] = index;

					// invalidate the current name ID -> index mappings for
					// this service.
					mNameIDArrays[serviceIndex] = null;
				}
				else
					index = (int) val;

				return index;
			}
		}

		private static int AddService(int serviceID)
		{
			lock (mNameIDArrays)
			{
				int index = mNextServiceIndex++;
				mServiceIDs[serviceID] = index;

				mNameIDArrays.Add(null);
				mNameIDs.Add(new Hashtable());
				mNextPropertyIndex.Add(0);
				return index;
			}
		}

		// external service ID->service index
		private static Hashtable mServiceIDs = new Hashtable();

		// next service index assigned
		private static int mNextServiceIndex = 0;

		// array indexed by service index
		//  each element is an array index by property index
		//   each value is the name ID
		private static ArrayList mNameIDArrays = new ArrayList();

		// array of Hashtables that map name ID to index for each service def
		private static ArrayList mNameIDs = new ArrayList();

		// next property index for each service def
		private static ArrayList mNextPropertyIndex = new ArrayList();
	}

}

