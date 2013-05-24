using System;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;

[assembly: Guid("ce050242-808d-419e-bb3e-250141e2bbe0")]

namespace MetraTech.Auth.Capabilities
{
	/// <summary>
	/// Base class for all C# capabilities
	/// </summary>
	/// 

  [Guid("c0e44a07-5ce0-4d3b-8707-40d1bfb44184")]
  [ClassInterface(ClassInterfaceType.None)]
	public class MTCompositeCapability : IMTCompositeCapability
	{
		public MTCompositeCapability()
		{
			mCC = new MTCompositeCapabilityBase();
		}
		/// <summary>
		/// 
		/// </summary>

		public void AddAtomicCapability(MTAtomicCapability aAtomicCap)
		{
			mCC.AddAtomicCapability(aAtomicCap);
			return;
		}
		/// <summary>
		/// 
		/// </summary>

		public MetraTech.Interop.MTAuth.IMTCollection AtomicCapabilities
		{
			get
			{
				return mCC.AtomicCapabilities;
			}
			
		}
		/// <summary>
		/// 
		/// </summary>

		public MTCompositeCapabilityType CapabilityType
		{
			get
			{
				return mCC.GetCapabilityType(this);
			}
			set
			{
				mCC.SetCapabilityType(value);
			}
		}
		/// <summary>
		/// 
		/// </summary>

		public int ID
		{
			get
			{
				return mCC.ID;
			}
			set
			{
				mCC.ID = value;
			}
		}

        /// <summary>
        /// 
        /// </summary>

        public int ActorAccountID
        {
            get
            {
                return mCC.ActorAccountID;
            }
            set
            {
                mCC.ActorAccountID = value;
            }
        }

		/// <summary>
		/// 
		/// </summary>

		public virtual MTAtomicCapability GetAtomicCapabilityByName(string aCapName)
		{
			return mCC.GetAtomicCapabilityByName(this, aCapName);
		}
		/// <summary>
		/// 
		/// </summary>

		public virtual MTDecimalCapability GetAtomicDecimalCapability()
		{
			return mCC.GetAtomicDecimalCapability(this);
		}
		/// <summary>
		/// 
		/// </summary>

		public virtual MTEnumTypeCapability GetAtomicEnumCapability()
		{
			return mCC.GetAtomicEnumCapability(this);
		}
		/// <summary>
		/// 
		/// </summary>

		public virtual MTPathCapability GetAtomicPathCapability()
		{
			return mCC.GetAtomicPathCapability(this);
		}
		/// <summary>
		/// 
		/// </summary>

        public virtual MTStringCollectionCapability GetAtomicCollectionCapability()
        {
            return mCC.GetAtomicCollectionCapability(this);
        }
        
      
        public virtual bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
		{
			return mCC.Implies(this, aCap, aCheckParams);
		}
		/// <summary>
		/// 
		/// </summary>

		public virtual void Remove(MTPrincipalPolicy aPolicy)
		{
			mCC.Remove(this, aPolicy);
			return;
		}
		/// <summary>
		/// 
		/// </summary>

		public virtual void Save(MTPrincipalPolicy aPolicy)
		{
			mCC.Save(this, aPolicy);
			return;
		}
		/// <summary>
		/// 
		/// </summary>

		public override string ToString()
		{
			return mCC.ToString(this);
		}
		/// <summary>
		/// 
		/// </summary>

		public virtual void FromXML(object aDomNode)
		{
			mCC.FromXML(this, aDomNode);
			return;
		}
		/// <summary>
		/// 
		/// </summary> 

		public virtual string ToXML()
		{
			return mCC.ToXML(this);
		}

    protected MetraTech.Interop.MTAuth.IMTCompositeCapabilityBase mCC;
	}
	
}
