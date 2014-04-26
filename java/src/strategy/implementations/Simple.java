package strategy.implementations;

import strategy.Answer;
import strategy.Code;

/**
 * A simple strategy that removes inconsistent codes from all possible codes
 * until the secret code is narrowed down.
 * 
 * In addition this strategy tries to minimize the travel distance for the
 * robot.
 */
public class Simple extends BasicStrategy {

	public Simple(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code guess(Answer answer) {
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		this.lastGuess = this.getShortestCode(this.consistentCodes);
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}
	
	@Override
	public String toString() {
		return "Simple2";
	}

}