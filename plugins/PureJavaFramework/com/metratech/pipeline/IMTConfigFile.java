package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfigFile'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigFile Interface</B>'
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
public interface IMTConfigFile {
  /**
   * getConfigData. property ConfigData
   *
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getConfigData  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setConfigData. property ConfigData
   *
   * @param     apVal An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setConfigData  (
              IMTConfigPropSet apVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEffectDate. property EffectDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getEffectDate  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEffectDate. property EffectDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEffectDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getExpireDate. property ExpireDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getExpireDate  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setExpireDate. property ExpireDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setExpireDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getDismissDate. property DismissDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getDismissDate  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setDismissDate. property DismissDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDismissDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getLingerDate. property LingerDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getLingerDate  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setLingerDate. property LingerDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setLingerDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getMainConfigData. property MainConfigData
   *
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getMainConfigData  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setMainConfigData. property MainConfigData
   *
   * @param     apVal An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setMainConfigData  (
              IMTConfigPropSet apVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getConfigFilename. property ConfigFilename
   *
   * @return    return value.  The apFilename
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getConfigFilename  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setConfigFilename. property ConfigFilename
   *
   * @param     apFilename The apFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setConfigFilename  (
              String apFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID20021548_741f_11d2_80fc_006008c0e8b7 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigFileProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "20021548-741f-11d2-80fc-006008c0e8b7";
  String DISPID_1_GET_NAME = "getConfigData";
  String DISPID_1_PUT_NAME = "setConfigData";
  String DISPID_2_GET_NAME = "getEffectDate";
  String DISPID_2_PUT_NAME = "setEffectDate";
  String DISPID_3_GET_NAME = "getExpireDate";
  String DISPID_3_PUT_NAME = "setExpireDate";
  String DISPID_4_GET_NAME = "getDismissDate";
  String DISPID_4_PUT_NAME = "setDismissDate";
  String DISPID_5_GET_NAME = "getLingerDate";
  String DISPID_5_PUT_NAME = "setLingerDate";
  String DISPID_6_GET_NAME = "getMainConfigData";
  String DISPID_6_PUT_NAME = "setMainConfigData";
  String DISPID_7_GET_NAME = "getConfigFilename";
  String DISPID_7_PUT_NAME = "setConfigFilename";
}
