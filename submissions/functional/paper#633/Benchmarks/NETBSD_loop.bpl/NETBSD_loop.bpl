function {:existential true} b0(MAXPATHLEN:int,pathbuf_off:int,bound_off:int,glob2_p_off:int,glob2_pathbuf_off:int,glob2_pathlim_off:int): bool;


procedure main()
{

	var MAXPATHLEN,pathbuf_off,bound_off,glob2_p_off,glob2_pathbuf_off,glob2_pathlim_off: int;
	
	havoc MAXPATHLEN;

	if(MAXPATHLEN > 0 && MAXPATHLEN < 2147483647)
	{
	}
	else
	{
		goto END;
	}
	pathbuf_off := 0;
	bound_off := pathbuf_off + (MAXPATHLEN + 1) - 1;
	
	glob2_pathbuf_off := pathbuf_off;
	glob2_pathlim_off := bound_off;
	
	glob2_p_off := glob2_pathbuf_off;
	while (glob2_p_off <= glob2_pathlim_off)
	invariant b0(MAXPATHLEN,pathbuf_off,bound_off,glob2_p_off,glob2_pathbuf_off,glob2_pathlim_off);
	{
		assert (0 <= glob2_p_off );
		assert (glob2_p_off < MAXPATHLEN + 1);
		glob2_p_off := glob2_p_off + 1;
	}
	END:
	exit:
}

