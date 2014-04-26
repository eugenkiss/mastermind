package strategy.implementations;

import java.util.ArrayList;
import java.util.List;

import strategy.Answer;
import strategy.Code;

/**
 * A strategy that seeks to maximize the expected payoff.
 * 
 * In addition this strategy tries to minimize the travel distance.
 */
// TODO: There seems to be a misunderstanding on my side. I needed to fix
// the weird behaviour of this strategy so that it yielded good results.
public class ExpectedSize extends BasicStrategy {
	
	private int lastSize; // Needed to fix strance behaviour of this strategy

	public ExpectedSize(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code guess(Answer answer) {
		lastSize = this.consistentCodes.size();
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		// Fix strange behaviour
		if(lastSize == this.consistentCodes.size()) {
			this.lastGuess = this.getShortestCode(this.consistentCodes);
			this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
			return this.lastGuess;
		}
		List<Code> bestGuesses = new ArrayList<Code>();
		bestGuesses.add(this.consistentCodes.get(0));
		double minExpectedSize = Double.MAX_VALUE;
		int totalSize = this.consistentCodes.size();
		for (Code code : this.allCodes) {
			double expectedSize = 0;
			for (Answer a : this.allAnswers) {
				int partSize = getConsistentCodes(this.consistentCodes, code, a)
						.size();
				expectedSize += 1.0 * Math.pow(partSize, 2) / totalSize;
			}
			if (expectedSize == minExpectedSize) {
				bestGuesses.add(code);
			}
			if (expectedSize < minExpectedSize) {
				minExpectedSize = expectedSize;
				bestGuesses.clear();
				bestGuesses.add(code);
			}
		}
		// Use, if possible, consistent codes
		List<Code> consistentBestGuesses = getConsistentCodes(bestGuesses,
				this.lastGuess, answer);
		if (!consistentBestGuesses.isEmpty()) {
			bestGuesses = consistentBestGuesses;
		}
		// Use a code with the shortest travel distance
		Code guess = this.getShortestCode(bestGuesses);
		if (guess.equals(lastGuess)) {
			lastGuess = this.consistentCodes.get(0);
		}
		else {
			lastGuess = guess;
		}
		this.lastGuess = this.getShortestCode(bestGuesses);
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}

	@Override
	public String toString() {
		return "Expected Size";
	}

}