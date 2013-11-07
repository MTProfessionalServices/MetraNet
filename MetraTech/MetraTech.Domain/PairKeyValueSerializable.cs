// -----------------------------------------------------------------------
// <copyright file="PairKeyValueSerializable.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

using System.Collections;
using System.Xml.Serialization;

namespace MetraTech.Domain
{
    using System;

    /// <summary>
    /// Pair key value to use instead of Dictionary for Serialization
    /// </summary>
    [Serializable]
    public class PairKeyValueSerializable<TKey, TVal>
        where TKey :  IComparable, IConvertible
        where TVal : new()
    {
       [XmlElement(ElementName = "key")]
       public TKey Key;

       [XmlElement(ElementName = "value")]
       public TVal Value;

       public PairKeyValueSerializable()
       {
           Value = new TVal();
       }

       public PairKeyValueSerializable(TKey key, TVal value)
       {
          Key = key;
          Value = value;
       }
    }
}
