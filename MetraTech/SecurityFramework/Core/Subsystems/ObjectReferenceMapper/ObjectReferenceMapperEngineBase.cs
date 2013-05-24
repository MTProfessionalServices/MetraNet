/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Viktor Grytsay <VGrytsay@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;

namespace MetraTech.SecurityFramework
{
    public abstract class ObjectReferenceMapperEngineBase : EngineBase
    {
        #region Nested classes

        /// <summary>
        /// This class is comparator for dictionaries in DefaultObjectReferenceMapProvider
        /// </summary>
        protected class ObjectComparer : IEqualityComparer<object>
        {
            #region IEqualityComparer<string> Members

            public new bool Equals(object x, object y)
            {
                bool rezult = false;
                if (string.Compare(x.ToString(), y.ToString(), true, CultureInfo.InvariantCulture) == 0)
                {
                    rezult = true; ;
                }

                return rezult;
            }

            public int GetHashCode(object obj)
            {
                return base.GetHashCode();
            }

            #endregion
        }

        #endregion

        /// <summary>
        /// Gets or sets an engine's category.
        /// </summary>
        protected virtual ObjectReferenceMapperEngineCategory Category
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or internally sets a collection of "Object-to-ID" mappings.
        /// </summary>
        protected Dictionary<object, string> Object2IdMap
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or internally sets a collection of "ID-to-Object" mappings.
        /// </summary>
        protected Dictionary<string, object> Id2ObjectMap
        {
            get;
            private set;
        }

        #region Constructors

        protected ObjectReferenceMapperEngineBase(ObjectReferenceMapperEngineCategory category)
        {
            Category = category;
            this.CategoryName = Convert.ToString(Category);

            Id2ObjectMap = new Dictionary<string, object>(new CaseInsensitiveStringComparer());
            Object2IdMap = new Dictionary<object, string>(new ObjectComparer());
        }

        #endregion

        protected override Type SubsystemType
        {
            get
            {
                return typeof(MetraTech.SecurityFramework.ObjectReferenceMapper);
            }
        }

        protected sealed override ApiOutput ExecuteInternal(ApiInput input)
        {
            if (input == null || string.IsNullOrEmpty(input.ToString()))
            {
                throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
            }

            return ProtectInternal(input);
        }

        protected abstract ApiOutput ProtectInternal(ApiInput input);

        protected bool HasReference(object obj)
        {
            if (null == obj)
                throw new ArgumentNullException("HasRecordWithObject");

            return Object2IdMap.ContainsKey(obj);
        }

        protected object GetObject(string id)
        {
            if (string.IsNullOrEmpty(id))
                throw new ArgumentNullException("GetRecordObject");

            object obj = null;
            if (!Id2ObjectMap.TryGetValue(id, out obj))
                throw new ObjectReferenceMapperException(string.Format("Can not find object with ID=\"{0}\"", id));

            return obj;
        }

        protected string GetReference(object obj)
        {
            if (null == obj)
                throw new ArgumentNullException("GetRecordId");

            string id = string.Empty;
            if (!Object2IdMap.TryGetValue(obj, out id))
                throw new ObjectReferenceMapperException(string.Format("Can not find ID for object \"{0}\"", obj));

            return id;
        }

        protected void AddRecord(string id, object obj)
        {
            if (string.IsNullOrEmpty(id) || (null == obj))
                throw new ArgumentNullException("DefaultObjectReferenceMapProvider.AddRecord");

            if (HasRecordWithId(id) || HasReference(obj))
                throw new ArgumentException("DefaultObjectReferenceMapProvider.AddRecord.DuplicateArgs");

            Id2ObjectMap[id] = obj;
            Object2IdMap[obj] = id;
        }

        protected bool HasRecordWithId(string id)
        {
            if (string.IsNullOrEmpty(id))
                throw new ArgumentNullException("HasRecordWithId");

            return Id2ObjectMap.ContainsKey(id);
        }

        private void DestroyReferenceWithObject(object obj)
        {
            if (null == obj)
                throw new ArgumentNullException("DefaultObjectReferenceMapProvider.RemoveRecordWithObject");

            if (!HasReference(obj))
                throw new ArgumentException("DefaultObjectReferenceMapProvider.RemoveRecordWithObject.NoRecord");

            string id = Object2IdMap[obj];
            if (string.IsNullOrEmpty(id))
                throw new ArgumentException("DefaultObjectReferenceMapProvider.RemoveRecordWithObject.NoRecord");

            Id2ObjectMap.Remove(id);
            Object2IdMap.Remove(obj);
        }

        private void DestroyReferenceWithId(string id)
        {
            if (string.IsNullOrEmpty(id))
                throw new ArgumentNullException("DefaultObjectReferenceMapProvider.RemoveRecordWithId");

            if (!HasRecordWithId(id))
                throw new ArgumentException("DefaultObjectReferenceMapProvider.RemoveRecordWithId.NoRecord");

            object obj = Id2ObjectMap[id];
            if (null == obj)
                throw new ArgumentException("DefaultObjectReferenceMapProvider.RemoveRecordWithId.NoRecord");

            Id2ObjectMap.Remove(id);
            Object2IdMap.Remove(obj);
        }
    }
}
