package strategy.implementations;

import strategy.Answer;
import strategy.Code;

/**
 * In contrast to Simple this strategy does *not* try to minimize the travel
 * distance.
 */
public class Simple2 extends BasicStrategy {

	public Simple2(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code reset() {
		// Refill consistent codes
		this.consistentCodes.clear();
		this.consistentCodes.addAll(this.allCodes);
		
		this.lastGuess = this.consistentCodes.get(0);
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}

	@Override
	public Code guess(Answer answer) {		
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		this.lastGuess = this.consistentCodes.get(0);
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}

	@Override
	public String toString() {
		return "Simple";
	}

}