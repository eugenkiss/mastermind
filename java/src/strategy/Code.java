package strategy;

import java.util.LinkedList;
import java.util.List;

/**
 * A sequence of buttons representing a code in the mastermind game.
 * 
 * Used as a guess by a mastermind strategy.
 */
public class Code {

	private final T[] code;

	public Code(T... t) {
		this.code = t.clone();
	}

	@Override
	public boolean equals(Object other) {
		if (other instanceof Code) {
			Code that = (Code) other;
			if (this.code.length != that.code.length) {
				return false;
			}
			for (int i = 0; i < code.length; i++) {
				if (this.code[i] != that.code[i]) {
					return false;
				}
			}
			return true;
		}
		return false;
	}

	@Override
	public String toString() {
		String result = "";
		for (T t : code) {
			result += "T[" + t.i + "]";
		}
		return result;
	}

	/**
	 * Return true if t is a button in this code.
	 * 
	 * @param t
	 *            Element to test
	 * @return True, if t is an element
	 */
	public boolean contains(T t) {
		for (T x : this.code) {
			if (x == t) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Compare this code with other's code and return the respective answer
	 * consisting of the number of correct buttons on the correct positions and
	 * the number of correct buttons on the wrong positions.
	 * 
	 * If used to provide the mastermind answer for a guess 'other' should be
	 * the secret code and not the other way around.
	 * 
	 * @param other
	 *            Code to be compared to
	 * @return Answer
	 */
	public Answer compare(Code other) {
		int blacks = 0;
		int whites = 0;
		for (int i = 0; i < this.code.length; i++) {
			if (code[i] == other.code[i]) {
				blacks++;
			} else if (this.contains(other.code[i])) {
				whites++;
			}
		}
		return new Answer(blacks, whites);
	}

	/**
	 * Return the i-th button.
	 * 
	 * @param i
	 *            Index
	 * @return i-th button
	 */
	public T get(int i) {
		return this.code[i];
	}
	
	/**
	 * Return the number of buttons in this code.
	 * 
	 * @return Number of buttons
	 */
	public int getLength() {
		return this.code.length;
	}

	/**
	 * Create a set of all possible codes of a specific length consisting of the
	 * buttons T[0],...,T[7].
	 * 
	 * Assume that the parameter length is between 1-8. Use a linked list
	 * because it is fast to remove an element and we don't need direct acces to
	 * elements.
	 */
	public static List<Code> createAllCodes(int length) {
		final List<Code> result = new LinkedList<Code>();
		_createAllCodes(result, length, new T[length]);
		return result;
	}

	private static void _createAllCodes(List<Code> codes, int length, T[] ts) {
		if (length == 0) {
			codes.add(new Code(ts));
		} else {
			for (T t : T.values()) {
				ts[length-1] = t;
				_createAllCodes(codes, length - 1, ts);
			}
		}
	}

}