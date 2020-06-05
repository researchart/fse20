package library;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class QueryT {

	String query;
	private QueryType type = null;
	private String value;

	private List<String> columnnames = new ArrayList<String>();
	private Orderby orderby;

	private Predicate wherepred;

	private List<Object> insertvalues = new ArrayList<Object>();

	private HashMap<String, Table> tables = new HashMap<String, Table>();
	private String firsttable;

	private HashMap<Table, String> joinCondition = new HashMap<Table, String>();
	private List<Table> tablesToMerge = new ArrayList<Table>();
	private QueryT subquery;

	enum QueryType {
		SELECT, UPDATE, INSERT
	}

	/**
	 * This method "parses" the query
	 * 
	 * @param string
	 * @throws Exception
	 */
	public void prepare(String string) throws Exception {
		this.query = string;
		String lowerquery = this.query.toLowerCase().trim();

		// if (lowerquery.contains("from")){
		// query.substring(lowerquery.indexOf(""))
		// }
		//
		if (lowerquery.startsWith("select")) {
			setToSelectQuery();

			int indexOfStar = lowerquery.indexOf("*");
			if (indexOfStar == -1) {
				String substring = lowerquery.substring(6, lowerquery.indexOf("from"));
				if (substring.trim().isEmpty() || substring.trim() == "") {
					throw new Exception("No columns specified for select statement");
				}
				String[] split = substring.split(",");
				getColumnnames().clear();
				for (int i = 0; i < split.length; i++) {
					getColumnnames().add(split[i].trim());
				}
			} else {
				setToAllColumns();
			}

			int indexOfFrom = lowerquery.indexOf("from");
			int indexOfJoin = lowerquery.indexOf("join");

			int indexOfWhere = lowerquery.indexOf("where");
			int indexOfOrderBy = lowerquery.indexOf("order by");

			if (indexOfJoin >= 0) {
				if (indexOfWhere >= 0) {
					parseJoin(lowerquery, indexOfFrom + 4, indexOfWhere);
				} else {
					parseJoin(lowerquery, indexOfFrom + 4, lowerquery.length());
				}
			}

			if (indexOfWhere >= 0) {
				if (indexOfOrderBy >= 0) {
					parseWhere(lowerquery, indexOfWhere + 5, indexOfOrderBy);
				} else {
					parseWhere(lowerquery, indexOfWhere + 5, lowerquery.length());
				}
			}

			if (indexOfOrderBy >= 0) {
				String substring = lowerquery.substring(indexOfOrderBy + 8, lowerquery.length()).trim();
				if (substring.isEmpty()) {
					throw new Exception("Order By syntax is faulty");
				}
				String[] split = substring.split(" ");
				if (split[1].equals("desc")) {
					orderby(split[0], SortOrder.DESCENDING);
				} else if (split[1].equals("asc")) {
					orderby(split[0], SortOrder.ASCENDING);
				} else {
					throw new Exception("Order By syntax is faulty");
				}
			}
		} else if (lowerquery.startsWith("update")) {
			setToUpdateQuery();
			String substring = query.substring(lowerquery.indexOf("set") + 3, lowerquery.indexOf("where")).trim();
			if (substring.isEmpty()) {
				throw new Exception("You are not setting anything");
			}

			String[] split = substring.split("=");
			if (split.length != 2) {
				throw new Exception("Wrong length of update argument");
			}
			set(strip(split[0]), strip(split[1]));

			String substring2 = query.substring(lowerquery.indexOf("where") + 5, lowerquery.length()).trim();
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

			where(p.and(p.equals(split3[0].trim(), strip(split3[1])), p.equals(split4[0].trim(), strip(split4[1]))));

		} else if (lowerquery.startsWith("insert")) {
			setToInsertQuery();
			String substring = query.substring(lowerquery.indexOf("("), lowerquery.indexOf("values"));
			if (substring.isEmpty()) {
				throw new Exception("You are not inserting anything");
			}

			String substring2 = substring.substring(substring.indexOf("(") + 1, substring.indexOf(")"));

			String[] split = substring2.split(", ");

			insert(split);
			// TODO: Error messages
			String substring3 = query.substring(lowerquery.indexOf("values"), lowerquery.length());
			String substring4 = substring3.substring(substring3.indexOf("(") + 1, substring3.indexOf(")"));
			if (substring3.isEmpty() || substring4.isEmpty()) {
				throw new Exception("Empty value list?");
			}

			String[] split2 = substring4.split(", ");
			if (split2.length < 2) {
				throw new Exception("wrong value list");
			}

			for (int i = 0; i < split2.length; i++) {
				split2[i] = strip(split2[i]);
			}

			// Type?
			values((Object[])split2);

		} else {
			throw new Exception("Query not starting with correct command");
		}
	}

	private void parseJoin(String lowerquery, int i, int endindex) throws Exception {
		String substring = lowerquery.substring(i, endindex);

		int joinindex = substring.indexOf("join");
		int onindex = substring.indexOf("on");
		String left = substring.substring(0, joinindex).trim();
		String right = substring.substring(joinindex + 4, onindex).trim();
		String oncondition = substring.substring(onindex + 2, substring.length());

		if (left.contains("as")) {
			left = left.substring(0, left.indexOf("as")).trim();
		}

		if (right.contains("as")) {
			right = right.substring(0, right.indexOf("as")).trim();
		}

		Table ltable = tables.get(left);

		if (ltable == null) {
			throw new Exception("Table name |" + left + "| not found. Did you forget to add this table?");
		}
		getTablesToMerge().add(ltable);
		Table rtable = tables.get(right);

		if (rtable == null) {
			throw new Exception("Table name " + right + " not found. Did you forget to add this table?");
		}
		getTablesToMerge().add(rtable);

		String[] condition = oncondition.split("=");
		if (condition.length < 2) {
			throw new Exception("On join condition incomplete or wrong");
		}

		String leftTableN = condition[0].trim().substring(0, condition[0].trim().indexOf('.'));
		String leftFieldN = condition[0].trim().substring(condition[0].trim().indexOf('.')+1, condition[0].trim().length());
		
		String rightTableN = condition[1].trim().substring(0, condition[1].trim().indexOf('.'));
		String rightFieldN = condition[1].trim().substring(condition[1].trim().indexOf('.')+1, condition[1].trim().length());
		
		
		Table condltable = tables.get(leftTableN);
		if (condltable == null) {
			throw new Exception(
					"Could not find table name " + leftTableN + " in condition. Did you spell the name right?");
		}

		String righthandfield = rightTableN;
		Table condrtable = tables.get(rightTableN);
		if (condrtable == null) {
			throw new Exception(
					"Could not find table name " + rightTableN + " in condition. Did you spell the name right?");
		}

		joinCondition.put(condltable, leftFieldN);

		joinCondition.put(condrtable, rightFieldN);

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

	private void parseWhere(String lowerquery, int indexOfWhere, int indexOfOrderBy) throws Exception {
		String whereclause = lowerquery.substring(indexOfWhere, indexOfOrderBy).trim();

		int indexOfLessThan = whereclause.indexOf("<");
		if (indexOfLessThan < 0) {
			throw new Exception("Query condition wrong for select statement");
		}

		String[] splitWhere = whereclause.split("<");
		if (splitWhere.length > 2) {
			throw new Exception("Query condition formatting is wrong");
		}
		int parseInt = Integer.parseInt(splitWhere[1].trim());
		Predicate p = new Predicate();
		this.where(p.lessThan(splitWhere[0].trim(), parseInt));
	}

	public String getQueryString() {
		return query;
	}

	public void columns(SelectArg selarg) throws Exception {
		setToSelectQuery();
		if (selarg == SelectArg.ALL) {
			setToAllColumns();
		} else {
			throw new Exception();
		}
	}

	private void setToAllColumns() {
		getColumnnames().clear();
		getColumnnames().add("~ALL~");
	}

	public void where(Predicate lessThan) {
		this.setWherepred(lessThan);
	}

	public void orderby(String string, SortOrder order) {
		this.setOrderby(new Orderby(string, order));
	}

	public void columns(String... string) {
//		setToSelectQuery();
		getColumnnames().clear();
		for (int i = 0; i < string.length; i++) {
			getColumnnames().add(string[i]);
		}
	}

	public void set(String string, String string2) {
		setToUpdateQuery();
		columnnames.clear();
		columnnames.add(string);
		value = string2;
	}

	public void insert(String... string) {
		setToInsertQuery();
		getColumnnames().clear();
		for (int i = 0; i < string.length; i++) {
			getColumnnames().add(string[i]);
		}
	}

	public void values(Object... o) {
		for (int i = 0; i < o.length; i++) {
			getInsertvalues().add(o[i]);
		}
	}

	/*
	 * missing errorhandling
	 * 
	 */
	private void setToUpdateQuery() {
		setType(QueryType.UPDATE);
	}

	/*
	 * missing errorhandling
	 * 
	 */
	private void setToInsertQuery() {
		setType(QueryType.INSERT);
	}

	/*
	 * missing errorhandling
	 * 
	 */
	private void setToSelectQuery() {
		setType(QueryType.SELECT);
	}

	public QueryType getType() {
		return type;
	}

	public void setType(QueryType type) {
		this.type = type;
	}

	public Predicate getWherepred() {
		return wherepred;
	}

	public void setWherepred(Predicate wherepred) {
		this.wherepred = wherepred;
	}

	public List<String> getColumnnames() {
		return columnnames;
	}

	public void setColumnnames(List<String> columnnames) {
		this.columnnames = columnnames;
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

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public void addData(String name, Table t) {
		tables.put(name, t);
		if (firsttable == null) {
			firsttable = name;
		}
	}

	public Table result() throws Exception {
		if (tables != null && !tables.isEmpty()) {
			Table table = tables.get(firsttable);
			return table.perform(this);
		} else {
			throw new Exception("Error! Did you set a datasource?");
		}
	}

	public HashMap<Table, String> getJoinCondition() {
		return joinCondition;
	}

	public void setJoinCondition(HashMap<Table, String> joinCondition) {
		this.joinCondition = joinCondition;
	}

	public List<Table> getTablesToMerge() {
		return tablesToMerge;
	}

	public void setTablesToMerge(List<Table> tablesToMerge) {
		this.tablesToMerge = tablesToMerge;
	}

	public QueryT AddField(String string) {
		getColumnnames().add(string);
		return this;
	}

	public void Filter(String string) {
		
	}

}
