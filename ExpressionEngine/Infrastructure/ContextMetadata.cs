using System;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.PropertyBags;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine
{
  /// <summary>
  /// Class represents context metadata.
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
  public class ContextMetadata
  {
    public ContextMetadata()
    {
    }

    public ContextMetadata(Context context)
    {
      if (context == null) throw new ArgumentNullException("context");

      PropertyBags = new List<PropertyBag>(context.PropertyBags);
      EnumCategories = new List<EnumCategory>(context.EnumCategories);
      Functions = new List<Function>(context.Functions);
      Expressions = new Dictionary<string, Expression>(context.Expressions);
    }

    [DataMember(EmitDefaultValue = false)]
    public IEnumerable<PropertyBag> PropertyBags { get; set; }

    [DataMember(EmitDefaultValue = false)]
    public IEnumerable<EnumCategory> EnumCategories { get; set; }

    [DataMember(EmitDefaultValue = false)]
    public IEnumerable<Function> Functions { get; set; }

    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly", Justification = "Setter should be public for serialization/deserialization.")]
    [DataMember(EmitDefaultValue = false)]
    public IDictionary<string, Expression> Expressions { get; set; }
  }
}
