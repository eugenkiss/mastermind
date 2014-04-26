package strategy.implementations;

import java.util.ArrayList;
import java.util.List;

import strategy.Answer;
import strategy.Code;

/**
 * Strategy that uses the worst case algorithm also known as the "Knuth
 * Algorithm" after its creator Donald Knuth.
 * 
 * In addition this strategy tries to minimize the travel distance.
 */
public class Knuth extends BasicStrategy {

	public Knuth(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code guess(Answer answer) {
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		List<Code> bestGuesses = new ArrayList<Code>();
		bestGuesses.add(this.consistentCodes.get(0));
		int maxMinimum = 0;
		for (Code code : this.allCodes) {
			int minimum = Integer.MAX_VALUE;
			for (Answer a : this.allAnswers) {
				int removedCodesSize = getConsistentCodes(
						this.consistentCodes, code, a).size();
				minimum = Math.min(removedCodesSize, minimum);
			}
			if (minimum == maxMinimum && minimum > 0) {
				bestGuesses.add(code);
			}
			if (minimum > maxMinimum) {
				maxMinimum = minimum;
				bestGuesses.clear();
				bestGuesses.add(code);
			}
		}
		// Use, if possible, consistent codes
		List<Code> consistentBestGuesses = getConsistentCodes(
				bestGuesses, this.lastGuess, answer);
		if(!consistentBestGuesses.isEmpty()) {
			bestGuesses = consistentBestGuesses;
		}
		// Use a code with the shortest travel distance
		this.lastGuess = this.getShortestCode(bestGuesses);
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}

	@Override
	public String toString() {
		return "Knuth2";
	}

}
