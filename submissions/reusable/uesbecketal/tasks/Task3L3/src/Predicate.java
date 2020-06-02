package library;

import java.util.ArrayList;
import java.util.List;

public class Predicate {

	private String sValue;
	private int iValue;
	
	private String shortcut;

	private Predicate left;
	private Predicate right;
	
	private List<Predicate> predicateList = new ArrayList<Predicate>();

	private PredicateType predType;

	enum PredicateType {
		AND, OR, LESSTHAN, GREATERTHAN, EQUALS, NOTEQUALS, INTEGER, STRING, COLUMN
	}

	public Predicate LessThan(String string, int i) {
		Predicate p = new Predicate();
		p.predType = PredicateType.LESSTHAN;
		Predicate left = new Predicate();
		left.setPredType(PredicateType.COLUMN);
		left.setsValue(string);
		p.setLeft(left);
		Predicate right = new Predicate();
		right.setPredType(PredicateType.INTEGER);
		right.setiValue(i);
		p.setRight(right);
		return p;
	}
	
	public Predicate GreaterThan(String string, int i) {
		Predicate p = new Predicate();
		p.predType = PredicateType.GREATERTHAN;
		Predicate left = new Predicate();
		left.setPredType(PredicateType.COLUMN);
		left.setsValue(string);
		p.setLeft(left);
		Predicate right = new Predicate();
		right.setPredType(PredicateType.INTEGER);
		right.setiValue(i);
		p.setRight(right);
		return p;
	}

	public Predicate Equals(String string, String string2) {
		Predicate p = new Predicate();
		p.setPredType(PredicateType.EQUALS);

		Predicate left = new Predicate();
		left.setPredType(PredicateType.COLUMN);
		left.setsValue(string);
		p.setLeft(left);

		Predicate right = new Predicate();
		right.setPredType(PredicateType.STRING);
		right.setsValue(string2);
		p.setRight(right);

		return p;
	}

	public Predicate And(Predicate equals, Predicate equals2) {
		Predicate p = new Predicate();
		p.setPredType(PredicateType.AND);

		p.setLeft(equals);
		p.setRight(equals2);

		return p;
	}
	
	public PrePredicate And (String columnname) {
		
		PrePredicate prePredicate = new PrePredicate();
//		prePredicate.setColumnname(columnname);
//		
//		prePredicate.setP(this);
//		prePredicate.setType(PredicateType.AND);
		
		prePredicate.setShortcut(getShortcut() + " and " + columnname); 
		
		return prePredicate;
	}

	public PredicateType getPredType() {
		return predType;
	}

	public void setPredType(PredicateType predType) {
		this.predType = predType;
	}

	public String getsValue() {
		return sValue;
	}

	public void setsValue(String sValue) {
		this.sValue = sValue;
	}

	public int getiValue() {
		return iValue;
	}

	public void setiValue(int iValue) {
		this.iValue = iValue;
	}

	public Predicate getLeft() {
		return left;
	}

	public void setLeft(Predicate left) {
		this.left = left;
	}

	public Predicate getRight() {
		return right;
	}

	public void setRight(Predicate right) {
		this.right = right;
	}

	public Predicate Equals(String string, int i) {
		Predicate p = new Predicate();
		p.setPredType(PredicateType.EQUALS);

		Predicate left = new Predicate();
		left.setPredType(PredicateType.COLUMN);
		left.setsValue(string);
		p.setLeft(left);

		Predicate right = new Predicate();
		right.setPredType(PredicateType.INTEGER);
		right.setiValue(i);
		p.setRight(right);

		return p;
	}

	public Predicate greaterThan(Object count) {
		// TODO Auto-generated method stub
		return null;
	}

	public Predicate greaterThan(Object count, int i) {
		// TODO Auto-generated method stub
		return null;
	}

	public PrePredicate Or(String columnname) {

		PrePredicate prePredicate = new PrePredicate();
//		prePredicate.setColumnname(columnname);
//		prePredicate.setP(this);
//		prePredicate.setType(PredicateType.OR);
		
		prePredicate.setShortcut(getShortcut() + " or " + columnname); 
		
		return prePredicate;
	}

	public Predicate NotEquals(String columnname, String s) {
		Predicate p = new Predicate();
		p.setPredType(PredicateType.NOTEQUALS);

		Predicate left = new Predicate();
		left.setPredType(PredicateType.COLUMN);
		left.setsValue(columnname);
		p.setLeft(left);

		Predicate right = new Predicate();
		right.setPredType(PredicateType.STRING);
		right.setsValue(s);
		p.setRight(right);

		return p;
	}
	
	public String toString() {
		String t = getPredType().toString() + " , S: " + getsValue() + " , I: " + getiValue();
		return t;
	}

	public String getShortcut() {
		return shortcut;
	}

	public void setShortcut(String shortcut) {
		this.shortcut = shortcut;
	}

}
