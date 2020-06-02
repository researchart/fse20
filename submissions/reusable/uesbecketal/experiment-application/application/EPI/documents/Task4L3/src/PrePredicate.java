package library;

import library.Predicate.PredicateType;

public class PrePredicate {

	private String columnname;
	private Predicate p;
	private PredicateType type;
	private String shortcut;
	
	public Predicate LessThan(int i) {
		
		Predicate p2 = new Predicate();
		
//		Predicate lt = p2.LessThan(getColumnname(), i);
//		
//		if (p != null) {
//			p2.setLeft(p);
//			p2.setPredType(type);
//			p2.setRight(lt);
//			return p2;
//		}
		p2.setShortcut(getShortcut() + " < " + i);
		return p2;
	}
	
	public Predicate GreaterThan(int i) {
		Predicate p2 = new Predicate();
//		Predicate gt = p2.GreaterThan(getColumnname(), i);
//		
//		if (p != null) {
//			p2.setLeft(p);
//			p2.setPredType(type);
//			p2.setRight(gt);
//			return p2;
//		}
		p2.setShortcut(getShortcut() + " > " + i);
		return p2;
	}
	
	public Predicate Equals(String s) {
		Predicate p2 = new Predicate();
//		Predicate eq = p2.Equals(getColumnname(), s);
//		
//
//		if (p != null) {
//			p2.setLeft(p);
//			p2.setPredType(type);
//			p2.setRight(eq);
//			return p2;
//		}
		p2.setShortcut(getShortcut() + " = " + s);
		return p2;
	}

	public Predicate getP() {
		return p;
	}

	public void setP(Predicate p) {
		this.p = p;
	}

	public String getColumnname() {
		return columnname;
	}

	public void setColumnname(String columnname) {
		this.columnname = columnname;
	}

	public PredicateType getType() {
		return type;
	}

	public void setType(PredicateType type) {
		this.type = type;
	}

	public Predicate NotEquals(String s) {
		Predicate p2 = new Predicate();
//		Predicate eq = p2.NotEquals(getColumnname(), s);
//		
//		
//		if (p != null) {
//			p2.setLeft(p);
//			p2.setPredType(type);
//			p2.setRight(eq);
//			return p2;
//		}
		p2.setShortcut(getShortcut() + " != " + s);
		return p2;
	}

	public String getShortcut() {
		return shortcut;
	}

	public void setShortcut(String shortcut) {
		this.shortcut = shortcut;
	}
	
	
	
}
