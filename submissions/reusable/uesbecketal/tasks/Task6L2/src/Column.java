package library;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Column<T> {
	String name;

	private String tablename;
	
	public Column(Column<T> c) {
		this.name = c.getName();
		this.content = new ArrayList<T>();
		for (T t : content) {
			this.content.add(t);
		}
	}

	public Column() {
	}
	
	public void deleteEntry(int i) {
		content.remove(i);
	}
	
	// For empty copies
	public Column(Column<T> c, String tablename) {
		this.setTablename(tablename);
		this.name = c.getName();
		this.content = new ArrayList<T>();
	}

	List<T> content = new ArrayList<T>();

	public void setName(String name) {
		this.name = name;
	}

	public void setContent(List<Object> c) {
		this.content = (List<T>) c;
	}

	public String getName() {
		return this.name;
	}

	public int size() {
		return content.size();
	}

	public T get(int index) {
		return content.get(index);
	}

	public Column<T> filterByIndices(List<Integer> indices) {
		Column<T> column = new Column<T>();
		column.setName(name);
		for (Integer index : indices) {
			T t = get(index);
			column.add(t);
		}

		return column;
	}

	public List<T> getList() {
		return content;
	}

	public void add(Object t) {
		this.content.add((T) t);
	}

	public void insertDefault() {
		if (this instanceof IntegerColumn)
			this.add(-1);
		else if (this instanceof StringColumn)
			this.add("");
		else
			this.add(new Object());
	}

	public void print() {
		System.out.println("Print of column");
		System.out.print("" + this.getName() + ": ");
		for (T t : content) {
			System.out.print("" + t + ", ");
		}
		System.out.println();
	}

	public void swap(Integer key, Integer value) {
		Collections.swap(content, key, value);
	}

	public String getTablename() {
		return tablename;
	}

	public void setTablename(String tablename) {
		this.tablename = tablename;
	}

}
