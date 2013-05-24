package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTEnumSpace'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTEnumSpace Interface</B>'
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
public class IMTEnumSpaceProxy extends com.linar.jintegra.Dispatch implements IMTEnumSpace, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTEnumSpace.class;

  public IMTEnumSpaceProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTEnumSpace.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTEnumSpaceProxy() {}

  public IMTEnumSpaceProxy(Object obj) throws java.io.IOException {
    super(obj, IMTEnumSpace.IID);
  }

  protected IMTEnumSpaceProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTEnumSpaceProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTEnumSpace.IID, host, null);
  }

  protected IMTEnumSpaceProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * getEnumTypes. method GetEnumTypes
   *
   * @return    return value.  An reference to a IMTEnumTypeCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumTypeCollection getEnumTypes  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTEnumTypeCollection zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getEnumTypes", 7, zz_parameters);
        return (IMTEnumTypeCollection)zz_retVal[0];
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
   * getEnumType. method GetEnumType
   *
   * @param     __MIDL_0020 The __MIDL_0020 (in)
   * @return    return value.  An reference to a IMTEnumType
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumType getEnumType  (
              String __MIDL_0020) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTEnumType zz_retVal[] = { null };
        Object zz_parameters[] = { __MIDL_0020, zz_retVal };
        vtblInvoke("getEnumType", 8, zz_parameters);
        return (IMTEnumType)zz_retVal[0];
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
        vtblInvoke("add", 9, zz_parameters);
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
   * getName. property Name
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getName", 10, zz_parameters);
        return (String)zz_retVal[0];
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
   * setName. property Name
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { pVal, zz_retVal };
        vtblInvoke("setName", 11, zz_parameters);
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
   * getDescription. property Description
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getDescription  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getDescription", 12, zz_parameters);
        return (String)zz_retVal[0];
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
   * setDescription. property Description
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDescription  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { pVal, zz_retVal };
        vtblInvoke("setDescription", 13, zz_parameters);
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
   * getLocation. property Location
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getLocation  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getLocation", 14, zz_parameters);
        return (String)zz_retVal[0];
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
   * setLocation. property Location
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setLocation  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { pVal, zz_retVal };
        vtblInvoke("setLocation", 15, zz_parameters);
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
   * writeSet. method WriteSet
   *
   * @param     __MIDL_0022 An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeSet  (
              IMTConfigPropSet __MIDL_0022) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { __MIDL_0022, zz_retVal };
        vtblInvoke("writeSet", 16, zz_parameters);
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

  /** Dummy reference from interface to proxy to make sure proxy gets compiled */
  static final int xxDummy = 0;

  static {
    com.linar.jintegra.InterfaceDesc.add("bc3e00f8-0665-11d4-95a1-00b0d025b121", IMTEnumSpaceProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("getEnumTypes",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("__MIDL_0019", 29, 20, 4, IMTEnumTypeCollection.IID, IMTEnumTypeCollectionProxy.class) }),
        new com.linar.jintegra.MemberDesc("getEnumType",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("__MIDL_0020", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("__MIDL_0021", 29, 20, 4, IMTEnumType.IID, IMTEnumTypeProxy.class) }),
        new com.linar.jintegra.MemberDesc("add",
            new Class[] { IMTEnumType.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_type", 29, 2, 4, IMTEnumType.IID, IMTEnumTypeProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getName",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setName",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getDescription",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setDescription",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getLocation",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setLocation",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("writeSet",
            new Class[] { IMTConfigPropSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("__MIDL_0022", 29, 2, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
});  }
}
