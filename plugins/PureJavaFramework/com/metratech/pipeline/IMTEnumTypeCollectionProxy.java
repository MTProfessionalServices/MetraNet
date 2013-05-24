package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTEnumTypeCollection'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTEnumTypeCollection Interface</B>'
 *
 * Generator Options:
 * PromptForTypeLibraries = True
 * AttemptNonDual = True
 * ClashPrefix = zz_
 * LowerCaseMemberNames = True
 * IDispatchOnly = False
 * RetryOnReject = True
 * GenerateDeprecatedConstructors = True
 * ArraysAsObjects = False
 * DontGenerateDisp = False
 * DontRenameSameMethods = False
 * IgnoreConflictingInterfaces = True
 */
public class IMTEnumTypeCollectionProxy extends com.linar.jintegra.Dispatch implements IMTEnumTypeCollection, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTEnumTypeCollection.class;

  public IMTEnumTypeCollectionProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTEnumTypeCollection.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTEnumTypeCollectionProxy() {}

  public IMTEnumTypeCollectionProxy(Object obj) throws java.io.IOException {
    super(obj, IMTEnumTypeCollection.IID);
  }

  protected IMTEnumTypeCollectionProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTEnumTypeCollectionProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTEnumTypeCollection.IID, host, null);
  }

  protected IMTEnumTypeCollectionProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
    super(CLSID, iid, host, authInfo);
  }

  public void addListener(String iidStr, Object theListener, Object theSource) throws java.io.IOException {
    super.addListener(iidStr, theListener, theSource);
  }

  public void removeListener(String iidStr, Object theListener) throws java.io.IOException {
    super.removeListener(iidStr, theListener);
  }

  /**
   * getPropertyByName. Get the value of a property dynamically at run-time, based on its name
   *
   * @return    return value.  The value of the property.
   * @param     name. The name of the property to get.
   * @exception java.lang.NoSuchFieldException If the property does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropertyByName(String name) throws NoSuchFieldException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant parameters[] = {};
    return super.invoke(name, super.getDispatchIdOfName(name), 2, parameters).getVARIANT();
  }

  /**
   * getPropertyByName. Get the value of a property dynamically at run-time, based on its name and a parameter value
   *
   * @return    return value.  The value of the property.
   * @param     name. The name of the property to get.
   * @param     rhs. Parameter used when getting the property.
   * @exception java.lang.NoSuchFieldException If the property does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropertyByName(String name, Object rhs) throws NoSuchFieldException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant parameters[] = {rhs == null ? new Variant("rhs", 10, 0x80020004L) : new Variant("rhs", 12, rhs)};
    return super.invoke(name, super.getDispatchIdOfName(name), 2, parameters).getVARIANT();
  }

  /**
   * invokeMethodByName. Invoke a method dynamically at run-time
   *
   * @return    return value.  The value returned by the method (null if none).
   * @param     name. The name of the method to be invoked
   * @param     parameters.  One element for each parameter.  Use primitive type wrappers
   *            to pass primitive types (eg Integer to pass an int).
   * @exception java.lang.NoSuchMethodException If the method does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object invokeMethodByName(String name, Object[] parameters) throws NoSuchMethodException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant variantParameters[] = new com.linar.jintegra.Variant[parameters.length];
    for(int i = 0; i < parameters.length; i++) {
      variantParameters[i] = parameters[i] == null ? new Variant("p" + i, 10, 0x80020004L) :
	                                                   new Variant("p" + i, 12, parameters[i]);
    }
    try {
      return super.invoke(name, super.getDispatchIdOfName(name), 1, variantParameters).getVARIANT();
    } catch(NoSuchFieldException nsfe) {
      throw new NoSuchMethodException("There is no method called " + name);
    }
  }

  /**
   * get_NewEnum. property _NewEnum
   *
   * @return    return value.  An enumeration.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Enumeration get_NewEnum  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        java.util.Enumeration zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("get_NewEnum", 7, zz_parameters);
        return (java.util.Enumeration)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * add. method Add
   *
   * @param     enum_type An reference to a IMTEnumType (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void add  (
              IMTEnumType enum_type) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { enum_type, zz_retVal };
        vtblInvoke("add", 8, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getSize. property Size
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getSize  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getSize", 9, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getCount. property Count
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getCount  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getCount", 10, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getItem. property Item
   *
   * @param     aIndex The aIndex (in)
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getItem  (
              int aIndex) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(aIndex), zz_retVal };
        vtblInvoke("getItem", 11, zz_parameters);
        return (Object)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /** Dummy reference from interface to proxy to make sure proxy gets compiled */
  static final int xxDummy = 0;

  static {
    com.linar.jintegra.InterfaceDesc.add("bc3e00f1-0665-11d4-95a1-00b0d025b121", IMTEnumTypeCollectionProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("get_NewEnum",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 13, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("add",
            new Class[] { IMTEnumType.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_type", 29, 2, 4, IMTEnumType.IID, IMTEnumTypeProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getSize",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getCount",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getItem",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aIndex", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("pVal", 12, 20, 8, null, null) }),
});  }
}
