package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTSystemContext'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTSystemContext Interface</B>'
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
public class IMTSystemContextProxy extends com.linar.jintegra.Dispatch implements IMTSystemContext, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTSystemContext.class;

  public IMTSystemContextProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTSystemContext.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTSystemContextProxy() {}

  public IMTSystemContextProxy(Object obj) throws java.io.IOException {
    super(obj, IMTSystemContext.IID);
  }

  protected IMTSystemContextProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTSystemContextProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTSystemContext.IID, host, null);
  }

  protected IMTSystemContextProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * getLog. method GetLog
   *
   * @return    return value.  An reference to a IMTLog
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTLog getLog  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTLog zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getLog", 7, zz_parameters);
        return (IMTLog)zz_retVal[0];
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
   * getNameID. method GetNameID
   *
   * @return    return value.  An reference to a IMTNameID
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTNameID getNameID  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTNameID zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getNameID", 8, zz_parameters);
        return (IMTNameID)zz_retVal[0];
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
   * getEffectiveConfig. property GetEffectiveConfig
   *
   * @return    return value.  An reference to a IMTConfigFile
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigFile getEffectiveConfig  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigFile zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getEffectiveConfig", 9, zz_parameters);
        return (IMTConfigFile)zz_retVal[0];
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
   * setEffectiveConfig. property GetEffectiveConfig
   *
   * @param     pEffectiveConfig An reference to a IMTConfigFile (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEffectiveConfig  (
              IMTConfigFile pEffectiveConfig) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { pEffectiveConfig, zz_retVal };
        vtblInvoke("setEffectiveConfig", 10, zz_parameters);
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
   * getEnumConfig. method GetEnumConfig
   *
   * @return    return value.  An reference to a IEnumConfig
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IEnumConfig getEnumConfig  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IEnumConfig zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getEnumConfig", 11, zz_parameters);
        return (IEnumConfig)zz_retVal[0];
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
    com.linar.jintegra.InterfaceDesc.add("16f737d0-3eaf-11d2-a1c5-006008c0e24a", IMTSystemContextProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("getLog",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("log", 29, 20, 4, IMTLog.IID, IMTLogProxy.class) }),
        new com.linar.jintegra.MemberDesc("getNameID",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("nameID", 29, 20, 4, IMTNameID.IID, IMTNameIDProxy.class) }),
        new com.linar.jintegra.MemberDesc("getEffectiveConfig",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pEffectiveConfig", 29, 20, 4, IMTConfigFile.IID, IMTConfigFileProxy.class) }),
        new com.linar.jintegra.MemberDesc("setEffectiveConfig",
            new Class[] { IMTConfigFile.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pEffectiveConfig", 29, 2, 4, IMTConfigFile.IID, IMTConfigFileProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEnumConfig",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_config", 29, 20, 4, IEnumConfig.IID, IEnumConfigProxy.class) }),
});  }
}
