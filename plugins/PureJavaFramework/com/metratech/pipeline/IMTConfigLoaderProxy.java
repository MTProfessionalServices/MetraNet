package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTConfigLoader'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigLoader Interface</B>'
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
public class IMTConfigLoaderProxy extends com.linar.jintegra.Dispatch implements IMTConfigLoader, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTConfigLoader.class;

  public IMTConfigLoaderProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfigLoader.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTConfigLoaderProxy() {}

  public IMTConfigLoaderProxy(Object obj) throws java.io.IOException {
    super(obj, IMTConfigLoader.IID);
  }

  protected IMTConfigLoaderProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTConfigLoaderProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfigLoader.IID, host, null);
  }

  protected IMTConfigLoaderProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * init. method Init
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void init  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("init", 7, zz_parameters);
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
   * initWithPath. method InitWithPath
   *
   * @param     aRootPath The aRootPath (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initWithPath  (
              String aRootPath) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { aRootPath, zz_retVal };
        vtblInvoke("initWithPath", 8, zz_parameters);
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
   * getAllFiles. method GetAllFiles
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @return    return value.  An reference to a IMTConfigFileList
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigFileList getAllFiles  (
              String aCompName,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigFileList zz_retVal[] = { null };
        Object zz_parameters[] = { aCompName, aFilename, zz_retVal };
        vtblInvoke("getAllFiles", 9, zz_parameters);
        return (IMTConfigFileList)zz_retVal[0];
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
   * getActiveFiles. method GetActiveFiles
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @return    return value.  An reference to a IMTConfigFileList
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigFileList getActiveFiles  (
              String aCompName,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigFileList zz_retVal[] = { null };
        Object zz_parameters[] = { aCompName, aFilename, zz_retVal };
        vtblInvoke("getActiveFiles", 10, zz_parameters);
        return (IMTConfigFileList)zz_retVal[0];
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
   * getEffectiveFile. method GetEffectFile
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getEffectiveFile  (
              String aCompName,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aCompName, aFilename, zz_retVal };
        vtblInvoke("getEffectiveFile", 11, zz_parameters);
        return (IMTConfigPropSet)zz_retVal[0];
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
   * getEffectiveFileWithDate. method GetEffectFileWithDate
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @param     aDate A Variant (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getEffectiveFileWithDate  (
              String aCompName,
              String aFilename,
              Object aDate) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aCompName, aFilename, aDate, zz_retVal };
        vtblInvoke("getEffectiveFileWithDate", 12, zz_parameters);
        return (IMTConfigPropSet)zz_retVal[0];
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
   * getPath. method GetPath
   *
   * @param     aCompName The aCompName (in)
   * @return    return value.  The apRetVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getPath  (
              String aCompName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { aCompName, zz_retVal };
        vtblInvoke("getPath", 13, zz_parameters);
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

  /** Dummy reference from interface to proxy to make sure proxy gets compiled */
  static final int xxDummy = 0;

  static {
    com.linar.jintegra.InterfaceDesc.add("20021541-741f-11d2-80fc-006008c0e8b7", IMTConfigLoaderProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("init",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("initWithPath",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aRootPath", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getAllFiles",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aCompName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apConfigFileList", 29, 20, 4, IMTConfigFileList.IID, IMTConfigFileListProxy.class) }),
        new com.linar.jintegra.MemberDesc("getActiveFiles",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aCompName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apConfigFileList", 29, 20, 4, IMTConfigFileList.IID, IMTConfigFileListProxy.class) }),
        new com.linar.jintegra.MemberDesc("getEffectiveFile",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aCompName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apConfigPropSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("getEffectiveFileWithDate",
            new Class[] { String.class, String.class, Object.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aCompName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aDate", 12, 2, 8, null, null), 
              new com.linar.jintegra.Param("apConfigPropSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("getPath",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aCompName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apRetVal", 8, 20, 8, null, null) }),
});  }
}
