#ifndef __USAGELOADER_H__
#define __USAGELOADER_H__

#include "MetraFlowConfig.h"
#include <string>
#include <boost/cstdint.hpp>

METRAFLOW_DECL std::string GenerateLoader(const std::string& inputFilename,
                                          const std::string& productViewName,
                                          boost::int32_t commitSize,
                                          boost::int32_t batchSize,
                                          bool useMerge);

/**
 * If one wants a composite operator definition to be generated, then pass a non-empty compositeOperatorName.  
 * If one is generating a composite operator definition, then the inputFilename will be ignored.
 */
METRAFLOW_DECL std::string GenerateLoaderEx(const std::string& inputFilename,
                                            const std::string& productViewName,
                                            boost::int32_t commitSize,
                                            boost::int32_t batchSize,
                                            bool useMerge,
                                            const std::string& compositeOperatorName);

#endif
