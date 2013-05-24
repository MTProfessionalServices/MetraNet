//////////////////////////////////////////////////////////////////////////////
// This file was automatically generated using ICE.
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////

#region

using System;
using System.Runtime.InteropServices;

#endregion

namespace MetraTech.Tax.Plugins.BillSoft
{
  /// <summary>
  /// Thrown when a value is set to null
  /// </summary>
  [Serializable]
  public class InvalidValueException : COMException
  {
    private const int HRESULT = Constants.E_FAIL;

    public InvalidValueException()
    {
      HResult = HRESULT;
    }

    public InvalidValueException(string message) : base(message)
    {
      HResult = HRESULT;
    }

    public InvalidValueException(string message, Exception inner) : base(message, inner)
    {
      HResult = HRESULT;
    }

    protected InvalidValueException(
      System.Runtime.Serialization.SerializationInfo info,
      System.Runtime.Serialization.StreamingContext context)
      : base(info, context)
    {
      HResult = HRESULT;
    }
  }

  /// <summary>
  /// thrown when there's an unreadable enum attribute found while parsing enums
  /// </summary>
  [Serializable]
  public class InvalidEnumAttributeException : COMException
  {
    private const int HRESULT = Constants.E_FAIL;

    public InvalidEnumAttributeException()
    {
      HResult = HRESULT;
    }

    public InvalidEnumAttributeException(string message)
      : base(message)
    {
      HResult = HRESULT;
    }

    public InvalidEnumAttributeException(string message, Exception inner)
      : base(message, inner)
    {
      HResult = HRESULT;
    }

    public InvalidEnumAttributeException(string message, int errorCode)
      : base(message, errorCode)
    {
      HResult = HRESULT;
    }

    protected InvalidEnumAttributeException(
      System.Runtime.Serialization.SerializationInfo info,
      System.Runtime.Serialization.StreamingContext context)
      : base(info, context)
    {
      HResult = HRESULT;
    }
  }
}