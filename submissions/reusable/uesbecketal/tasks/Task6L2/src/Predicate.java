package library;

public class Predicate {

	private String sValue;
	private int iValue;

	private Predicate left;
	private Predicate right;

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
	
	public Predicate NotEquals(String string, String string2) {
		Predicate p = new Predicate();
		p.setPredType(PredicateType.NOTEQUALS);

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

	public Predicate GreaterThan(Object count) {
		// TODO Auto-generated method stub
		return null;
	}

	public Predicate GreaterThan(Object count, int i) {
		// TODO Auto-generated method stub
		return null;
	}

}
