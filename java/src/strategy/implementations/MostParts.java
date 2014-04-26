package strategy.implementations;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import strategy.Answer;
import strategy.Code;

/**
 * A strategy that seeks the guess with the maximum entropy.
 * 
 * In addition this strategy tries to minimize the travel distance.
 */
public class MostParts extends BasicStrategy {

	public MostParts(int codeLength) {
		super(codeLength);
	}

	@Override
	public Code guess(Answer answer) {
		this.removeInconsistentCodes(this.consistentCodes, this.lastGuess,
				answer);
		List<Code> bestGuesses = new ArrayList<Code>();
		bestGuesses.add(this.consistentCodes.get(0));
		int mostParts = 1;
		for (Code code : this.allCodes) {
			Map<EncodedPart, Boolean> parts = new HashMap<EncodedPart, Boolean>();
			for (Answer a : this.allAnswers) {
				List<Code> partition = getConsistentCodes(this.consistentCodes, code, a);
				if(!partition.isEmpty()) {
					int size = partition.size();
					Code firstCode = partition.get(0);
					parts.put(new EncodedPart(size, firstCode), true);
				}
			}
			int numberOfParts = parts.size();
			if (numberOfParts == mostParts && numberOfParts > 1) {
				bestGuesses.add(code);
			}
			if (numberOfParts > mostParts) {
				mostParts = numberOfParts;
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
		return "Most Parts";
	}

}

/**
 * A partition is new if its cardinality was not encountered before and its
 * first element was not encountered either. This distinction is sufficient to
 * distinguish partitions because the filterCandidates function does not alter
 * the order of the guesses in the list it returns.
 */
// TODO: Writing a hashCode function for this class would be useful for performance (I guess)
class EncodedPart {
	
	private int size;
	private Code firstCode;
	
	public EncodedPart(int size, Code firstCode) {
		this.size = size;
		this.firstCode = firstCode;
	}
	
	public Boolean equals(EncodedPart other) {
		return this.size == other.size && this.firstCode.equals(other.firstCode);
	}
	
}