package library;

import java.util.ArrayList;

public class StringColumn extends Column<String> {

	public StringColumn() {
	}

	public StringColumn(StringColumn c) {
		this.name = c.getName();
		this.content = new ArrayList<String>();
		for (String t : c.getList()) {
			this.content.add(t);
		}
	}

	public void add(String newcont) {
		content.add(newcont);
	}

	public void replace(int i, String s) {
		content.set(i, s);
	}

}
