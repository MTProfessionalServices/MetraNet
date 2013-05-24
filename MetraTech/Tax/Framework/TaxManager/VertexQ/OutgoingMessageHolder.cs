using System;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class OutgoingMessageHolder
  /// </summary>
  class OutgoingMessageHolder
  {
    /// <summary>
    /// 
    /// </summary>
    internal string[] vertexTaxParamsXMLArray;

    /// <summary>
    /// Initializes a new instance of the <see cref="OutgoingMessageHolder"/> class.
    /// </summary>
    /// <param name="theArrayOfMessages">The array of messages.</param>
    /// <remarks></remarks>
    public OutgoingMessageHolder(string[] theArrayOfMessages)
    {
      this.vertexTaxParamsXMLArray = theArrayOfMessages;
    }
  }
}
