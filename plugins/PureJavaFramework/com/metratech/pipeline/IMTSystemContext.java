package com.metratech.pipeline;

/**
 * COM Interface 'IMTSystemContext'. Generated 7/24/00 5:03:12 PM
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
public interface IMTSystemContext {
  /**
   * getLog. method GetLog
   *
   * @return    return value.  An reference to a IMTLog
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTLog getLog  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getNameID. method GetNameID
   *
   * @return    return value.  An reference to a IMTNameID
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTNameID getNameID  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEffectiveConfig. property GetEffectiveConfig
   *
   * @return    return value.  An reference to a IMTConfigFile
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigFile getEffectiveConfig  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEffectiveConfig. property GetEffectiveConfig
   *
   * @param     pEffectiveConfig An reference to a IMTConfigFile (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEffectiveConfig  (
              IMTConfigFile pEffectiveConfig) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumConfig. method GetEnumConfig
   *
   * @return    return value.  An reference to a IEnumConfig
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IEnumConfig getEnumConfig  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID16f737d0_3eaf_11d2_a1c5_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTSystemContextProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "16f737d0-3eaf-11d2-a1c5-006008c0e24a";
  String DISPID_1_NAME = "getLog";
  String DISPID_2_NAME = "getNameID";
  String DISPID_3_GET_NAME = "getEffectiveConfig";
  String DISPID_3_PUT_NAME = "setEffectiveConfig";
  String DISPID_4_NAME = "getEnumConfig";
}
