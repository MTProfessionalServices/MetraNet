using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// This class is comparator for dictionaries in DefaultObjectReferenceMapProvider
    /// </summary>
    internal class CaseInsensitiveStringComparer : IEqualityComparer<string>
    {
        #region IEqualityComparer<string> Members

        public bool Equals(string x, string y)
        {
            bool result = false;
            if (string.Compare(x.ToLowerInvariant(), y.ToLowerInvariant(), StringComparison.CurrentCultureIgnoreCase) == 0)
            {
                result = true;
            }
            return result;
        }

        public int GetHashCode(string obj)
        {
            return base.GetHashCode();
        }

        #endregion
    }


}
