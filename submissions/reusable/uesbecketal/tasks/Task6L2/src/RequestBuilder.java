package library;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class RequestBuilder {
	
	String query;
	private QueryType type = null;
	private String value;

	private List<String> columnnames = new ArrayList<String>();
	private Orderby orderby;

	private Predicate wherepred;

	private List<Object> insertvalues = new ArrayList<Object>();
	
	private List<Table> tables = new ArrayList<Table>();
	private HashMap<Table, String> joinCondition = new HashMap<Table, String> ();
	private List<Table> tablesToMerge = new ArrayList<Table> ();
	private RequestBuilder subrequest;
	
	enum QueryType {
		SELECT, UPDATE, INSERT
	}

	private void setToSelectQuery() {
		setType(QueryType.SELECT);
	}
	
	private void setToUpdateQuery() {
		setType(QueryType.UPDATE);
	}
	
	private void setToInsertQuery() {
		setType(QueryType.INSERT);
	}
	
	public QueryType getType() {
		return type;
	}

	public void setType(QueryType type) {
		this.type = type;
	}

	public void requestFields(String string) {
		setToSelectQuery();
		String[] split = string.split(",");
		getColumnnames().clear();
		for (String string2 : split) {
			String trim = string2.trim();
			if (!getColumnnames().contains(trim))
				getColumnnames().add(trim);
		}
	}

	public void setTable(Table table) {
		tables.clear();
		tables.add(table);
	}

	public void requestEntriesWhere(String string) throws Exception {
		
		String s = string.trim();
		String slower = s.toLowerCase();
		if (s.toLowerCase().contains("and")) {
			String substring2 = query.substring(slower.indexOf("where") + 5, slower.length()).trim();
			if (substring2.isEmpty()) {
				throw new Exception("There seem to be no conditions");
			}

			Predicate p = new Predicate();

			String[] split2 = substring2.split("AND");
			if (split2.length != 2) {
				throw new Exception("Wrong length of condition");
			}

			String[] split3 = split2[0].split("=");
			String[] split4 = split2[1].split("=");

			if (split3.length != 2 || split4.length != 2) {
				throw new Exception("Wrong length of condition");
			}

			setWherepred(p.And(p.Equals(split3[0].trim(), strip(split3[1])), p.Equals(split4[0].trim(), strip(split4[1]))));
		} else {
			int indexOfLessThan = s.indexOf("<");
			if (indexOfLessThan < 0) {
				throw new Exception("Query condition wrong for select statement");
			}

			String[] splitWhere = s.split("<");
			if (splitWhere.length > 2) {
				throw new Exception("Query condition formatting is wrong");
			}
			int parseInt = Integer.parseInt(splitWhere[1].trim());
			Predicate p = new Predicate();
			setWherepred(p.LessThan(splitWhere[0].trim(), parseInt));
		}
	}
	
	private String strip(String s) {
		String tmp = "";
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			if (c != ' ' && c != '\'') {
				tmp += c;
			}
		}

		return tmp;
	}
	
	private void setToAllColumns() {
		getColumnnames().clear();
		getColumnnames().add("~ALL~");
	}

	public Table result() throws Exception {
		
		if (tables != null && !tables.isEmpty()){
			Table table = tables.get(0);
			return table.fulfill(this);
		}
		else if (tablesToMerge != null) {
			Table result = new Table();
			return result.fulfill(this);
		}
		else if (subrequest != null) {
			Table result = subrequest.result();
			return result.fulfill(this);
		}
		else {
				throw new Exception ("Error! Did you set a datasource?");
		}
		
	}

	public void sortHighToLowBy(String string) {
		this.setOrderby(new Orderby(string, SortOrder.DESCENDING));		
	}

	public void requestAllFields() {
		setToSelectQuery();		
		setToAllColumns();
	}

	public void replaceField(String field, String value) {
		setToUpdateQuery();
		columnnames.clear();
		columnnames.add(field);
		this.setValue(value);
	}

	public void replaceEntriesWhere(String string) throws Exception {
		String s = string.trim();
		String slower = s.toLowerCase();
		if (slower.contains("and")) {
			String substring2 = s.substring(0, slower.length()).trim();
			if (substring2.isEmpty()) {
				throw new Exception("There seem to be no conditions");
			}

			Predicate p = new Predicate();

			String[] split2 = substring2.split("AND");
			if (split2.length != 2) {
				throw new Exception("Wrong length of condition");
			}

			String[] split3 = split2[0].split("=");
			String[] split4 = split2[1].split("=");

			if (split3.length != 2 || split4.length != 2) {
				throw new Exception("Wrong length of condition");
			}
			

			setWherepred(p.And(p.Equals(split3[0].trim(), strip(split3[1])), p.Equals(split4[0].trim(), strip(split4[1]))));
		} else {
			int indexOfLessThan = s.indexOf("<");
			if (indexOfLessThan < 0) {
				throw new Exception("Query condition wrong for select statement");
			}

			String[] splitWhere = s.split("<");
			if (splitWhere.length > 2) {
				throw new Exception("Query condition formatting is wrong");
			}
			int parseInt = Integer.parseInt(splitWhere[1].trim());
			Predicate p = new Predicate();
			setWherepred(p.LessThan(splitWhere[0].trim(), parseInt));
		}
	}

	public void addIntoFields(String string) {
		setToInsertQuery();
		getColumnnames().clear();
		
		String[] split = string.split(",");
		
		for (int i = 0; i < split.length; i++) {
			getColumnnames().add(split[i].trim());
		}
	}

	public void addValues(String string) {
		
		String[] split = string.split(",");
		
		for (int i = 0; i < split.length; i++) {
			getInsertvalues().add(strip(split[i].trim())); 
		}
	}

	public void setCombineKey(Table t, String field) {	
		joinCondition.put(t, field);
	}

	public void combine(Table left, Table right) {
		getTablesToMerge().add(left);
		getTablesToMerge().add(right);
	}

	public void addRequest(RequestBuilder q) {
		subrequest = q;
	}

	public List<String> getColumnnames() {
		return columnnames;
	}

	public void setColumnnames(List<String> columnnames) {
		this.columnnames = columnnames;
	}

	public Predicate getWherepred() {
		return wherepred;
	}

	public void setWherepred(Predicate wherepred) {
		this.wherepred = wherepred;
	}

	public Orderby getOrderby() {
		return orderby;
	}

	public void setOrderby(Orderby orderby) {
		this.orderby = orderby;
	}

	public List<Object> getInsertvalues() {
		return insertvalues;
	}

	public void setInsertvalues(List<Object> insertvalues) {
		this.insertvalues = insertvalues;
	}

	public HashMap<Table, String> getJoinCondition() {
		return joinCondition;
	}

	public void setJoinCondition(HashMap<Table, String> joinCondition) {
		this.joinCondition = joinCondition;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public List<Table> getTablesToMerge() {
		return tablesToMerge;
	}

	public void setTablesToMerge(List<Table> tablesToMerge) {
		this.tablesToMerge = tablesToMerge;
	}

}
