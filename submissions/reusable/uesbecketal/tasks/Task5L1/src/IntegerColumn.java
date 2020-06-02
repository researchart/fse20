package library;

import java.util.ArrayList;

public class IntegerColumn extends Column<Integer> {

	public IntegerColumn() {
	}

	public IntegerColumn(IntegerColumn c) {
		this.name = c.getName();
		this.content = new ArrayList<Integer>();
		for (Integer t : c.getList()) {
			this.content.add(t);
		}
	}

	public void add(int newcont) {
		content.add(newcont);
	}

	public int size() {
		return content.size();
	}

}
