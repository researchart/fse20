package library;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import library.IntegerColumn;
import library.Predicate;
import library.StringColumn;
import library.Query;
import library.Table;
import library.Query.QueryType;

public class Table {

	private String name = "";

	List<Column<?>> columns = new ArrayList<Column<?>>();

	public Table() {
	}

	public Table(Table t) {
		this.columns = new ArrayList<Column<?>>();
		List<Column<?>> columns2 = t.getColumns();
		for (Column<?> column : columns2) {
			if (column instanceof StringColumn) {
				this.columns.add(new StringColumn((StringColumn) column));
			} else if (column instanceof IntegerColumn) {
				this.columns.add(new IntegerColumn((IntegerColumn) column));
			} else {
				this.columns.add(new Column(column));
			}
		}
	}

	public List<Column<?>> getColumns() {
		return columns;
	}

	public void addColumn(Column<?> c) {
		if (getColumn(c.getName(), "") == null) {
			columns.add(c);
		}
	}

	public int size() {
		return columns.size();
	}

	public int numberOfRows() {
		return columns.get(0).size();
	}

	public Column<?> getColumn(int i) {
		return columns.get(i);
	}

	public Column<?> getColumn(String name, String tableName) {

		for (Column<?> column : columns) {
			if (column.getName().equals(name)) {
				if (!tableName.isEmpty()) {
					if (column.getTablename().equals(tableName)) {
						return column;
					}
				} else {
					return column;
				}
			}
		}
		return null;
	}

	public Column<?> getColumn(String name) {

		for (Column<?> column : columns) {
			if (column.getName().equals(name)) {
				return column;
			}
		}
		return null;
	}

	public Column<?> getColumns(List<String> names) {
		for (Column<?> column : columns) {
			if (names.contains(column.getName())) {
				return column;
			}
		}
		return null;
	}

	public List<Column<?>> allButColumn(String name) {
		List<Column<?>> cs = new ArrayList<Column<?>>();
		for (Column<?> column : this.columns) {
			if (!column.getName().equals(name)) {
				cs.add(column);
			}
		}
		return cs;
	}

	public List<Column<?>> allButColumns(List<String> names) {
		List<Column<?>> columns = new ArrayList<Column<?>>();
		for (Column<?> column : columns) {
			if (!names.contains(column.getName())) {
				columns.add(column);
			}
		}
		return columns;
	}

	public List<String> getAllColumnNames() {
		List<String> names = new ArrayList<String>();
		for (Column<?> column : columns) {
			String name = column.getName();
			names.add(name);
		}
		return names;
	}

	public void deleteRow(int i) {
		List<Column<?>> columns2 = getColumns();

		for (Column<?> column : columns2) {
			column.deleteEntry(i);
		}
	}

	public Table perform(QueryT q) throws Exception {
		Table newT = new Table();
		if (q.getType() == QueryT.QueryType.SELECT) {

			Table t = null;

			if (q.getTablesToMerge().size() == 2) {
				List<Table> tablesToMerge = q.getTablesToMerge();

				Table left = new Table(tablesToMerge.get(0));
				Table right = new Table(tablesToMerge.get(1));

				String leftMergeCol = q.getJoinCondition().get(tablesToMerge.get(0));
				String rightMergeCol = q.getJoinCondition().get(tablesToMerge.get(1));


				if (left.getColumn(leftMergeCol, "") == null || right.getColumn(rightMergeCol, "") == null) {
					throw new Exception("Mergecolumn not found in table");
				}

				Column<?> l = left.getColumn(leftMergeCol, "");
				Column<?> r = right.getColumn(rightMergeCol, "");

				Table result = new Table();

				for (Column col : left.getColumns()) {
					result.addColumnEmptyForMerge(col, left.getName());
				}

				for (Column col : right.getColumns()) {
					if (!col.getName().equals(rightMergeCol))
						result.addColumnEmptyForMerge(col, right.getName());
				}

				for (int i = 0; i < left.numberOfRows(); i++) {

					for (int j = 0; j < right.numberOfRows(); j++) {

						if (l.get(i).equals(r.get(j))) {
							for (int j2 = 0; j2 < left.size(); j2++) {
								Column<?> column = left.getColumn(j2);
								Column<?> column2 = result.getColumn(column.getName());
								Object c = column.get(i);
								if (c instanceof Integer) {
									Integer in = (Integer) c;
									column2.add(in);
								} else if (c instanceof String) {
									String s = (String) c;
									column2.add(s);
								}
							}

							for (int j3 = 0; j3 < right.size(); j3++) {
								Column<?> column = right.getColumn(j3);
								if (!(column.getName()).equals(r.getName())) {

									Column<?> column2 = result.getColumn(column.getName(), right.getName());
									Object c = column.get(j);
									if (c instanceof Integer) {
										Integer tmp = (Integer) c;
										column2.add(tmp);
									} else if (c instanceof String) {
										String s = (String) c;
										column2.add(s);
									}
								}
							}
						}
					}
				}

				t = result;


			} else if (q.getTablesToMerge().size() > 0) {
				throw new Exception("Wrong number of tables to merge");
			} else {
				t = this;
			}

			List<Integer> columnIndices = new ArrayList<Integer>();
			if (q.getWherepred() != null) {
				columnIndices = t.findRowNumbers(q.getWherepred());
			} else {
				columnIndices = t.allRowNumbers();
			}
			List<String> columnnames = q.getColumnnames();
			if (columnnames != null && columnnames.get(0) != null && columnnames.get(0).equals("~ALL~")) {
				columnnames = t.getAllColumnNames();
			}
			for (String string : columnnames) {
				Column<?> column = t.getColumn(string, "");
				if (column == null) {
					throw new Exception("Error! No such column '" + string + "'");
				}
				Column<?> filteredColumn = column.filterByIndices(columnIndices);
				newT.addColumn(filteredColumn);
			}

			if (q.getOrderby() != null) {
				Orderby orderby = q.getOrderby();
				String columnname = orderby.getColumnname();
				SortOrder order = orderby.getOrder();
				Column column = newT.getColumn(columnname, "");
				if (column == null) {
					throw new Exception("Error! No such column!");
				}

				List<Column<?>> allButColumn = newT.allButColumn(columnname);
				keySort(column, order, allButColumn);

			}
		} else if (q.getType() == QueryT.QueryType.UPDATE) {

			newT = new Table(this);

			List<Integer> rowNumbers = newT.findRowNumbers(q.getWherepred());
			String columnname = q.getColumnnames().get(0);
			StringColumn column = (StringColumn) newT.getColumn(columnname, ""); // little
																					// cheat
																					// for
																					// experiment
			for (Integer rownumber : rowNumbers) {
				column.replace(rownumber, q.getValue());
			}

		} else if (q.getType() == QueryT.QueryType.INSERT) {

			newT = new Table(this);

			List<String> columnnames = q.getColumnnames();
			List<Column<?>> allButColumns = newT.allButColumns(columnnames);
			List<Object> insertvalues = q.getInsertvalues();

			int i = 0;
			for (String string : columnnames) {
				Column column = newT.getColumn(string, "");
				if (column instanceof IntegerColumn) {
					Object c = insertvalues.get(i);
					if (c instanceof Integer) {
						Integer t = (Integer) c;
						column.add(t);
					} else if (c instanceof String) {
						String s = (String) c;
						int tmp = Integer.parseInt(s);
						column.add(tmp);
					}

				} else {
					column.add(insertvalues.get(i));
				}
				i++;

			}

			for (Column<?> column : allButColumns) {
				column.insertDefault();
			}

		}

		return newT;
	}

	/**
	 * from
	 * http://stackoverflow.com/questions/15400514/syncronized-sorting-between-two-arraylists
	 * 
	 * @param key
	 * @param lists
	 */
	public static <T extends Comparable<T>> void keySort(final Column<T> key, SortOrder order, List<Column<?>> lists) {
		// Create a List of indices
		List<Integer> indices = new ArrayList<Integer>();
		for (int i = 0; i < key.size(); i++)
			indices.add(i);

		if (order == SortOrder.ASCENDING) {
			// Sort the indices list based on the key
			Collections.sort(indices, new Comparator<Integer>() {
				@Override
				public int compare(Integer i, Integer j) {
					return key.get(i).compareTo(key.get(j));
				}
			});
		} else {
			Collections.sort(indices, new Comparator<Integer>() {
				@Override
				public int compare(Integer i, Integer j) {
					return key.get(j).compareTo(key.get(i));
				}
			});
		}

		// Create a mapping that allows sorting of the List by N swaps.
		Map<Integer, Integer> swapMap = new HashMap<Integer, Integer>(indices.size());

		// Only swaps can be used b/c we cannot create a new List of type <?>
		for (int i = 0; i < indices.size(); i++) {
			int k = indices.get(i);
			while (swapMap.containsKey(k))
				k = swapMap.get(k);

			swapMap.put(i, k);
		}

		// for each list, swap elements to sort according to key list
		for (Map.Entry<Integer, Integer> e : swapMap.entrySet()) {
			for (Column<?> list : lists) {
				list.swap(e.getKey(), e.getValue());
			}
			key.swap(e.getKey(), e.getValue());
		}

	}

	private static void printMapDebug(Map<Integer, Integer> swapMap) {
		StringBuilder sb = new StringBuilder();
		Iterator<Entry<Integer, Integer>> iter = swapMap.entrySet().iterator();
		while (iter.hasNext()) {
			Entry<Integer, Integer> entry = iter.next();
			sb.append(entry.getKey());
			sb.append('=').append('"');
			sb.append(entry.getValue());
			sb.append('"');
			if (iter.hasNext()) {
				sb.append(',').append(' ');
			}
		}
		System.out.println(sb.toString());
	}

	private static void printlistDebug(Column<?> key) {
		key.print();
	}

	private static void printlistDebug(List<Integer> indices) {
		System.out.println("Listprint for debug:");
		for (Integer integer : indices) {
			System.out.print("" + integer + ", ");
		}
		System.out.println();
	}

	private List<Integer> allRowNumbers() {
		List<Integer> indices = new ArrayList<Integer>();
		Column<?> column = getColumn(0);
		List<?> content = column.content;
		for (int i = 0; i < content.size(); i++) {
			indices.add(i);
		}

		return indices;
	}

	private List<Integer> findRowNumbers(Predicate pred) throws Exception {
		List<Integer> list = new ArrayList<Integer>();

		if (pred.getPredType() == Predicate.PredicateType.LESSTHAN) {
			Predicate left = pred.getLeft();
			String columnName = left.getsValue();
			IntegerColumn column = (IntegerColumn) getColumn(columnName, "");

			int iValue = pred.getRight().getiValue();
			if (column == null) {
				throw new Exception("Error! No such column!");
			}
			int size = column.size();
			for (int i = 0; i < size; i++) {
				int j = column.get(i);
				if (j < iValue) {
					list.add(i);
				}
			}

		} else if (pred.getPredType() == Predicate.PredicateType.GREATERTHAN) {
			Predicate left = pred.getLeft();
			String columnName = left.getsValue();
			IntegerColumn column = (IntegerColumn) getColumn(columnName, "");

			int iValue = pred.getRight().getiValue();
			if (column == null) {
				throw new Exception("Error! No such column!");
			}
			int size = column.size();
			for (int i = 0; i < size; i++) {
				int j = column.get(i);
				if (j > iValue) {
					list.add(i);
				}
			}

		} else if (pred.getPredType() == Predicate.PredicateType.AND) {
			Predicate left = pred.getLeft();
			List<Integer> indicesleft = findRowNumbers(left);
			Predicate right = pred.getRight();
			List<Integer> indicesright = findRowNumbers(right);

			for (int i =0; i < indicesleft.size(); i++) {
				if (indicesright.contains(indicesleft.get(i))) {
					list.add(indicesleft.get(i));
				}
			}
//			list.addAll(indicesleft);
//			list.addAll(indicesright);

		} else if (pred.getPredType() == Predicate.PredicateType.OR) {
			Predicate left = pred.getLeft();
			List<Integer> indicesleft = findRowNumbers(left);

			Predicate right = pred.getRight();
			List<Integer> indicesright = findRowNumbers(right);

			for (Integer integer : indicesleft) {
				if (!list.contains(integer)) {
					list.add(integer);
				}
			}
			for (Integer integer : indicesright) {
				if (!list.contains(integer)) {
					list.add(integer);
				}
			}
//			list.addAll(indicesleft);
//			list.addAll(indicesright);
		}
		else if (pred.getPredType() == Predicate.PredicateType.EQUALS) {

			Predicate left = pred.getLeft();
			Predicate right = pred.getRight();

			String columnName = left.getsValue();
			StringColumn column = (StringColumn) getColumn(columnName, "");
			if (column == null) {
				throw new Exception("Error! No such column!");
			}

			String sValue = right.getsValue();

			int size = column.size();
			for (int i = 0; i < size; i++) {
				String j = column.get(i);
				if (j.equalsIgnoreCase(sValue)) {
					list.add(i);
				}
			}
		} else if (pred.getPredType() == Predicate.PredicateType.NOTEQUALS) {
			Predicate left = pred.getLeft();
			Predicate right = pred.getRight();

			String columnName = left.getsValue();
			StringColumn column = (StringColumn) getColumn(columnName, "");
			if (column == null) {
				throw new Exception("Error! No such column!");
			}

			String sValue = right.getsValue();

			int size = column.size();
			for (int i = 0; i < size; i++) {
				String j = column.get(i);
				if (!j.equalsIgnoreCase(sValue)) {
					list.add(i);
				}
			}
		}
			
		return list;
	}

	public void printSummary() {
		System.out.println(" ________ ");
		for (Column<?> column : columns) {
			System.out.println(column.getName() + ", Size: " + column.size());
		}
		System.out.println(" ________ ");
	}

	public void outputTable() {
		System.out.println(" ________ ");
		System.out.println("Table Content");
		System.out.println("Columns: ");
		for (int j = 0; j < columns.size(); j++) {
			System.out.print("" + columns.get(j).getName() + " (" + columns.get(j).size() + "),  ");
		}
		System.out.println();
		for (int i = 0; i < columns.get(0).size(); i++) {
			for (int j = 0; j < columns.size(); j++) {
				System.out.print("" + columns.get(j).get(i) + ",  ");
			}
			System.out.println();
		}
	}

	public Table fulfill(Query request) throws Exception {
		Table newT = new Table();
		if (request.getType() == Query.QueryType.SELECT) {

			Table t = null;

			if (request.getTablesToMerge().size() == 2) {
				List<Table> tablesToMerge = request.getTablesToMerge();

				Table left = new Table(tablesToMerge.get(0));
				Table right = new Table(tablesToMerge.get(1));

				String leftMergeCol = request.getJoinCondition().get(tablesToMerge.get(0));
				String rightMergeCol = request.getJoinCondition().get(tablesToMerge.get(1));

				if (left.getColumn(leftMergeCol, "") == null || right.getColumn(rightMergeCol, "") == null) {
					throw new Exception("Mergecolumn not found in table");
				}

				Column<?> l = left.getColumn(leftMergeCol, "");
				Column<?> r = right.getColumn(rightMergeCol, "");

				Table result = new Table();

				for (Column col : left.getColumns()) {
					result.addColumnEmptyForMerge(col, left.getName());
				}

				for (Column col : right.getColumns()) {
					if (!col.getName().equals(rightMergeCol))
						result.addColumnEmptyForMerge(col, right.getName());
				}

				for (int i = 0; i < left.numberOfRows(); i++) {

					for (int j = 0; j < right.numberOfRows(); j++) {

						if (l.get(i).equals(r.get(j))) {
							for (int j2 = 0; j2 < left.size(); j2++) {
								Column<?> column = left.getColumn(j2);
								Column<?> column2 = result.getColumn(column.getName());
								Object c = column.get(i);
								if (c instanceof Integer) {
									Integer in = (Integer) c;
									column2.add(in);
								} else if (c instanceof String) {
									String s = (String) c;
									column2.add(s);
								}
							}

							for (int j3 = 0; j3 < right.size(); j3++) {
								Column<?> column = right.getColumn(j3);
								if (!(column.getName()).equals(r.getName())) {

									Column<?> column2 = result.getColumn(column.getName(), right.getName());
									Object c = column.get(j);
									if (c instanceof Integer) {
										Integer tmp = (Integer) c;
										column2.add(tmp);
									} else if (c instanceof String) {
										String s = (String) c;
										column2.add(s);
									}
								}
							}
						}
					}
				}

				t = result;

			} else if (request.getTablesToMerge().size() > 0) {
				throw new Exception("Wrong number of tables to merge");
			} else {
				t = this;
			}
			
//			System.out.println("After merge:");
//			t.printFull();

			List<Integer> columnIndices = new ArrayList<Integer>();
			if (request.getWherepred() != null) {
				columnIndices = t.findRowNumbers(request.getWherepred());
			} else {
				columnIndices = t.allRowNumbers();
			}
			List<String> columnnames = request.getColumnnames();
			if (columnnames != null && columnnames.get(0) != null && columnnames.get(0).equals("~ALL~")) {
				columnnames = t.getAllColumnNames();
			}
			for (String string : columnnames) {
				Column<?> column = t.getColumn(string);
				if (column == null) {
					throw new Exception("Error! No such column '" + string + "'");
				}
				Column<?> filteredColumn = column.filterByIndices(columnIndices);
				newT.addColumn(filteredColumn);
			}
			
//			System.out.println("After Projection:");
//			newT.printFull();

			if (request.getOrderby() != null) {
				Orderby orderby = request.getOrderby();
				String columnname = orderby.getColumnname();
				SortOrder order = orderby.getOrder();
				Column column = newT.getColumn(columnname);
				if (column == null) {
					throw new Exception("Error! No such column!");
				}

				List<Column<?>> allButColumn = newT.allButColumn(columnname);
				keySort(column, order, allButColumn);

			}
//			System.out.println("After sort:");
//			newT.printFull();
		} else if (request.getType() == Query.QueryType.UPDATE) {

			newT = new Table(this);

			List<Integer> rowNumbers = newT.findRowNumbers(request.getWherepred());
			String columnname = request.getColumnnames().get(0);
			StringColumn column = (StringColumn) newT.getColumn(columnname); // little
																				// cheat
																				// for
																				// experiment
			for (Integer rownumber : rowNumbers) {
				column.replace(rownumber, request.getValue());
			}

		} else if (request.getType() == Query.QueryType.INSERT) {

			newT = new Table(this);

			List<String> columnnames = request.getColumnnames();
			List<Column<?>> allButColumns = newT.allButColumns(columnnames);
			List<Object> insertvalues = request.getInsertvalues();

			int i = 0;
			for (String string : columnnames) {
				Column column = newT.getColumn(string);
				if (column instanceof IntegerColumn) {
					Object c = insertvalues.get(i);
					if (c instanceof Integer) {
						Integer t = (Integer) c;
						column.add(t);
					} else if (c instanceof String) {
						String s = (String) c;
						int tmp = Integer.parseInt(s);
						column.add(tmp);
					}

				} else {
					column.add(insertvalues.get(i));
				}
				i++;

			}

			for (Column<?> column : allButColumns) {
				column.insertDefault();
			}

		}

		return newT;
	}

	private void addColumnEmptyForMerge(Column col, String tablename) {
		if (getColumn(col.getName()) == null) {
			columns.add(new Column(col, tablename));
		} else {
			columns.add(new Column(col, tablename));
		}
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Table Search(Query q) throws Exception {
		q.setType(QueryType.SELECT);
		Table t = fulfill(q);
		return t;
	}

	public Table Update(Query q) throws Exception {
		q.setType(QueryType.UPDATE);
		Table t = fulfill(q);
		return t;
	}

	public Table Insert(Query q) throws Exception {
		q.setType(QueryType.INSERT);
		Table t = fulfill(q);
		return t;
	}
}
