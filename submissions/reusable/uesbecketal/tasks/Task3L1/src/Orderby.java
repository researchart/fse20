package library;

public class Orderby {
	private String columnname;
	private SortOrder order;

	public Orderby(String columnname, SortOrder order) {
		this.setColumnname(columnname);
		this.setOrder(order);
	}

	public String getColumnname() {
		return columnname;
	}

	public void setColumnname(String columnname) {
		this.columnname = columnname;
	}

	public SortOrder getOrder() {
		return order;
	}

	public void setOrder(SortOrder order) {
		this.order = order;
	}
}