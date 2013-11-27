
CREATE FUNCTION CheckEBCRCycleTypeCompatibility
  (@EBCRCycleType INT, @OtherCycleType INT)
RETURNS INT 
BEGIN
  -- checks weekly based cycle types
  IF (((@EBCRCycleType = 4) OR (@EBCRCycleType = 5)) AND
      ((@OtherCycleType = 4) OR (@OtherCycleType = 5)))
    RETURN 1   -- success

  -- checks monthly based cycle types
  IF ((@EBCRCycleType in (1,7,8,9)) AND
      (@OtherCycleType  in (1,7,8,9)))
    RETURN 1   -- success

  RETURN 0     -- failure
END
		