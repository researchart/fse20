function {:existential true} b0(tagbuf_len:int,t:int): bool;
function {:existential true} b1(tagbuf_len:int,t:int): bool;

procedure main()
{
	var tagbuf_len,t: int;
	havoc tagbuf_len;
	if(tagbuf_len >= 1){
	}
	else{
		goto END;
	}
	t := 0;
	tagbuf_len := tagbuf_len - 1;
	while (true) 
	invariant b1(tagbuf_len,t);
	{
		if (t == tagbuf_len) {
			assert(0 <= t);
			assert(t <= tagbuf_len);
			goto END;
		}
		if (*) {
			break;
		}
		assert(0 <= t);
		assert(t <= tagbuf_len);
		t := t + 1;
  	}
	
	while (true) 
	invariant b1(tagbuf_len,t);
	{
		if (t == tagbuf_len) { 
		assert(0 <= t);
		assert(t <= tagbuf_len);
		goto END;
		}

		if (*) {
		if (*) {
			assert(0 <= t);
			assert(t <= tagbuf_len);
			t := t + 1;
			if (t == tagbuf_len) {
				assert(0 <= t);
				assert(t <= tagbuf_len);
				goto END;
			}
		}
		}
		else if (*) {
			break;
		}
			assert(0 <= t);
			assert(t <= tagbuf_len);
			t := t + 1;
	}
	assert(0 <= t);
	assert(t <= tagbuf_len);
	END:
}

