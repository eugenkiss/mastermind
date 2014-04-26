package strategy.implementations;

import java.util.ArrayList;
import java.util.List;

import strategy.Answer;
import strategy.Code;

/**
 * A strategy that seeks the guess with the maximum entropy.
 * 
 * In addition this strategy tries to minimize the travel distance.
 */
public class Entropy extends BasicStrategy {

	public Entropy(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code guess(Answer answer) {
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		List<Code> bestGuesses = new ArrayList<Code>();
		bestGuesses.add(this.consistentCodes.get(0));
		double maxEntropy = 0;
		int totalSize = this.consistentCodes.size();
		for (Code code : this.allCodes) {
			double entropy = 0;
			for (Answer a : this.allAnswers) {
				int partSize = getConsistentCodes(this.consistentCodes, code, a)
						.size();
				if (partSize != 0) {
					double I = Math.log(1.0 * totalSize / partSize) / Math.log(2);
					double P = 1.0 * partSize / totalSize;
					entropy += entropy + I * P;
				}
			}
			if (entropy == maxEntropy && entropy > 0) {
				bestGuesses.add(code);
			}
			if (entropy > maxEntropy) {
				maxEntropy = entropy;
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
		this.lastGuess = this.getShortestCode(bestGuesses);
		this.lastButton = this.lastGuess.get(this.CODE_LENGTH - 1);
		return this.lastGuess;
	}

	@Override
	public String toString() {
		return "Entropy";
	}

}