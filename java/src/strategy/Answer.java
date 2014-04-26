package strategy;

import java.util.ArrayList;
import java.util.List;

/**
 * A mastermind answer to an entered guess consisting of the number of correct
 * buttons on the correct positions and the number of correct buttons on the
 * wrong positions.
 */
public class Answer {

	/** Number of correct buttons on the correct positions */
	public final int blacks;
	/** Number of correct buttons on the wrong positions */
	public final int whites;

	public Answer(int blacks, int whites) {
		this.blacks = blacks;
		this.whites = whites;
	}

	@Override
	public boolean equals(Object other) {
		boolean result = false;
		if (other instanceof Answer) {
			Answer that = (Answer) other;
			result = (this.blacks == that.blacks && this.whites == that.whites);
		}
		return result;
	}
	
	@Override
	public String toString() {
		return "b:" + this.blacks + " w:" + this.whites;
	}

	/**
	 * Create all possible anwers for a specific length.
	 * 
	 * @param length
	 *            Code length
	 * @return List of all possible answers
	 */
	public static List<Answer> createAllAnswers(int length) {
		List<Answer> result = new ArrayList<Answer>();
		for (int blacks = 0; blacks < length; blacks++) {
			for (int whites = 0; whites < length; whites++) {
				int sum = whites + blacks;
				if (sum <= length && !(blacks == length - 1 && whites == 1)) {
					result.add(new Answer(blacks, whites));
				}
			}
		}
		return result;
	}

}
