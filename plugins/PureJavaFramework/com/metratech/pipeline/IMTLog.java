package com.metratech.pipeline;

/**
 * COM Interface 'IMTLog'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTLog Interface</B>'
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
public interface IMTLog {
  /**
   * logString. Log a string
   *
   * @param     level A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0238_0001 constant (A  COM typedef)  (in)
   * @param     string The string (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void logString  (
              int level,
              String string) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * oKToLog. Ask if a message would be logged at this level
   *
   * @param     level A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0238_0001 constant (A  COM typedef)  (in)
   * @return    return value.  The wouldLog
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean oKToLog  (
              int level) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * init. Initialize the logging object
   *
   * @param     configPath The configPath (in)
   * @param     appTag The appTag (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void init  (
              String configPath,
              String appTag) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID2be32000_3eaf_11d2_a1c5_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTLogProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "2be32000-3eaf-11d2-a1c5-006008c0e24a";
  String DISPID_1_NAME = "logString";
  String DISPID_2_NAME = "oKToLog";
  String DISPID_3_NAME = "init";
}
