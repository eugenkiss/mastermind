package strategy.implementations;

import strategy.Answer;
import strategy.Code;

/**
 * In contrast to Knuth this strategy does *not* try to minimize the travel
 * distance.
 */
public class Knuth2 extends BasicStrategy {

	public Knuth2(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code guess(Answer answer) {
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		this.lastGuess = consistentCodes.get(0);
		int maxMinimum = 0;
		for (Code code : this.allCodes) {
			int minimum = Integer.MAX_VALUE;
			for (Answer a : this.allAnswers) {
				int removedCodesSize = getConsistentCodes(
						this.consistentCodes, code, a).size();
				minimum = Math.min(removedCodesSize, minimum);
			}
			if (minimum > maxMinimum) {
				maxMinimum = minimum;
				this.lastGuess = code;
			}
		}
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}

	@Override
	public String toString() {
		return "Knuth";
	}

}