	SELECT count (1) as num
	FROM 
		%%TABLE%%
	WHERE 
		c__CollectionID in (%%BATCHIDS%%)

	