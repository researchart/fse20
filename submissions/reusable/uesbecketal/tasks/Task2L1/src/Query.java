package library;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.swing.plaf.metal.MetalIconFactory.FolderIcon16;

import library.Predicate.PredicateType;
import library.Predicate;

public class Query {

	String query;
	private QueryType type = null;
	private String value;

	private List<String> columnnames = new ArrayList<String>();
	private Orderby orderby;

	private Predicate wherepred;

	private List<Object> insertvalues = new ArrayList<Object>();

	private List<Table> tables = new ArrayList<Table>();
	private HashMap<Table, String> joinCondition = new HashMap<Table, String>();
	private List<Table> tablesToMerge = new ArrayList<Table>();
	private Query subrequest;

	public Query() {
		setToAllColumns();
	}

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

			setWherepred(
					p.and(p.equals(split3[0].trim(), strip(split3[1])), p.equals(split4[0].trim(), strip(split4[1]))));
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
			setWherepred(p.lessThan(splitWhere[0].trim(), parseInt));
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

		if (tables != null && !tables.isEmpty()) {
			Table table = tables.get(0);
			return table.fulfill(this);
		} else if (tablesToMerge != null) {
			Table result = new Table();
			return result.fulfill(this);
		} else if (subrequest != null) {
			Table result = subrequest.result();
			return result.fulfill(this);
		} else {
			throw new Exception("Error! Did you set a datasource?");
		}

	}

	public void SortHighToLow(String string) {
		this.setOrderby(new Orderby(string, SortOrder.DESCENDING));
	}

	public void SortLowToHigh(String string) {
		this.setOrderby(new Orderby(string, SortOrder.ASCENDING));
	}

	public void requestAllFields() {
		// setToSelectQuery();
		setToAllColumns();
	}

	public void Replace(String field, String value) {
		setToUpdateQuery();
		columnnames.clear();
		columnnames.add(field);
		this.setValue(value);
	}

	public void setFilter(String string) throws Exception {
		Predicate p = new Predicate();

		p = replaceEntriesWhere(string);

		setWherepred(p);
	}

	private boolean containsIgnoreCase (String initial , String stringtomatch) {
		if (initial.toLowerCase().contains(stringtomatch.toLowerCase())) {
			return true;
		}
		return false;
	}
	
	private String[] split(String initial, String regex) {
		String[] split = initial.split(regex, 2);
		String[] split2 = initial.split(regex.toUpperCase(), 2);
		if (split.length > split2.length) {
			return split;
		} 
		return split2;
	}
	
	public Predicate replaceEntriesWhere(String string) throws Exception {
		String s = string.trim();
		String slower = s.toLowerCase();
		String substring2 = s.substring(0, slower.length()).trim();
		Predicate p = new Predicate();
		if (substring2.isEmpty()) {
			throw new Exception("There seem to be no conditions");
		}
		
		if (substring2.contains("(")) {
			int indexOfFirstOpen = substring2.indexOf('(');
			int parenthesesCounter = 0;
			int indexOfCorrespondingClose = -1;
			for (int i = indexOfFirstOpen; i < substring2.length(); i++) {
				char c = substring2.charAt(i);
				if (c == '(' ) {
					parenthesesCounter++;
				} else if (c == ')') {
					parenthesesCounter--;
					if (parenthesesCounter == 0) {
						indexOfCorrespondingClose = i;
					} else if (parenthesesCounter == -1) {
						throw new Exception("Parenthesis mismatch. Too many closing parentheses!");
					}
				}
			}
			if (parenthesesCounter > 0) {
				throw new Exception ("Parenthesis mismatch. Too many opening parentheses!");
			}
			if (indexOfFirstOpen == 0 ) {
				// parentheses just enclosing entire string
				if (indexOfCorrespondingClose == substring2.length()-1) {
					p = replaceEntriesWhere(substring2.substring(1, substring2.length()-1));
				} else {
					// create dummy on one side and let build two tree parts. Join tree parts after
					String substring3 =substring2.substring(indexOfFirstOpen+1, indexOfCorrespondingClose);
					Predicate temp1 = replaceEntriesWhere(substring3);
					Predicate tempDominant = replaceEntriesWhere("$#placeholder#$" + substring2.substring(indexOfCorrespondingClose+1, substring2.length()));
					tempDominant.setLeft(replacePlaceholderLeft(tempDominant.getLeft(), temp1));
					p = tempDominant;
					
				}
				
			} else if(indexOfCorrespondingClose == substring2.length()-1) {
				// create dummy on one side and let build two tree parts. Join tree parts after
				Predicate temp1 = replaceEntriesWhere(substring2.substring(indexOfFirstOpen+1, indexOfCorrespondingClose-1));
				Predicate tempDominant = replaceEntriesWhere(substring2.substring(0, indexOfFirstOpen) + "$#placeholder#$ ");
				tempDominant.setRight(replacePlaceholderRight(tempDominant.getRight(), temp1));
				p = tempDominant;
			}
		} else if (containsIgnoreCase(substring2, " or ")) {

			String[] split = split(substring2, " or ");
			p.setPredType(PredicateType.OR);

			p.setLeft(replaceEntriesWhere(split[0]));
			p.setRight(replaceEntriesWhere(split[1]));

		} else if (slower.contains("and")) {

			String[] split = split(substring2, " and ");
			if (split.length != 2) {
				throw new Exception("Wrong length of condition");
			}

			p.setPredType(PredicateType.AND);

			p.setLeft(replaceEntriesWhere(split[0]));
			p.setRight(replaceEntriesWhere(split[1]));

		} else if (slower.contains("$#placeholder#$")) {
			Predicate bob = new Predicate();
			bob.setPredType(PredicateType.COLUMN);
			bob.setsValue("$#placeholder#$");
			
			p = bob;
		} else if (slower.contains("!=")) {
			String[] split = substring2.split("!=");
			p = p.notEquals(split[0].trim(), strip(split[1]));

		} else if (slower.contains("=")) {
			String[] split = substring2.split("=");
			p = p.equals(split[0].trim(), strip(split[1]));
		} else if (slower.contains("<")) {

			String[] split = substring2.split("<");
			int parseInt = Integer.parseInt(split[1].trim());
			p = p.lessThan(split[0].trim(), parseInt);

		} else if (slower.contains(">")) {
			String[] split = substring2.split(">");
			int parseInt = Integer.parseInt(split[1].trim());
			p = p.greaterThan(split[0].trim(), parseInt);
		}
		return p;
	}
	
	private Predicate replacePlaceholderLeft(Predicate tree, Predicate replacement) {
		if (tree.getPredType() == PredicateType.COLUMN && tree.getsValue().equals("$#placeholder#$")) {
			tree = replacement;
		} else {
			tree.setLeft(replacePlaceholderLeft(tree.getLeft(), replacement));
		}
		return tree;
	}
	
	private Predicate replacePlaceholderRight(Predicate tree, Predicate replacement) {
		if (tree.getPredType() == PredicateType.COLUMN && tree.getsValue().equals("$#placeholder#$")) {
			tree = replacement;
		} else {
			tree.setRight(replacePlaceholderRight(tree.getRight(), replacement));
		}
		return tree;
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

	}

	public void addRequest(Query q) {
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

	public Query AddField(String string) {
		if (getColumnnames().get(0).equals("~ALL~")) {
			getColumnnames().clear();
		}

		getColumnnames().add(string);
		return this;
	}

	public Query AddValue(String name, String value) {
		if (getColumnnames().get(0).equals("~ALL~")) {
			getColumnnames().clear();
		}
		getColumnnames().add(name);
		getInsertvalues().add(value);

		return this;
	}

	public Query AddValue(String name, int value) {
		if (getColumnnames().get(0).equals("~ALL~")) {
			getColumnnames().clear();
		}
		getColumnnames().add(name);
		getInsertvalues().add(value);

		return this;
	}

	public void Filter(String string) throws Exception {
		// requestEntriesWhere(string);
		setFilter(string);
	}

	public void Combine(Table left, String string, Table right, String string2) {
		getTablesToMerge().add(left);
		getTablesToMerge().add(right);
		setCombineKey(left, string);
		setCombineKey(right, string2);
	}

	public void AddFields(String fields) {
		addIntoFields(fields);
	}

	public void IntoFields(String string) {
		addIntoFields(string);
		
	}

	public void SetValues(String string) {
		addValues(string);
		
	}

	public void Replace(String field, int i) {
		setToUpdateQuery();
		columnnames.clear();
		columnnames.add(field);
		this.setValue(value);
	}

}
