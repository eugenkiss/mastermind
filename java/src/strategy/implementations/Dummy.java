package strategy.implementations;

import strategy.Answer;
import strategy.Code;
import strategy.IMastermindStrategy;
import strategy.T;

/**
 * A dummy strategy that always returns the same code.
 * 
 * E.g. CODE_LENGTH = 4 then the returned guess is always T0,T1,T2,T3.
 */
public class Dummy implements IMastermindStrategy {

	private final int CODE_LENGTH;
	
	public Dummy(int codeLength) {
		this.CODE_LENGTH = codeLength;
	}
	
	@Override
	public Code guess(Answer answer) {
		T[] t = new T[this.CODE_LENGTH];
		for(int i = 0; i < this.CODE_LENGTH; i++) {
			t[i] = T.values()[i];
		}
		return new Code(t);
	}

	@Override
	public Code reset() {
		T[] t = new T[this.CODE_LENGTH];
		for(int i = 0; i < this.CODE_LENGTH; i++) {
			t[i] = T.values()[i];
		}
		return new Code(t);
	}
	
	@Override
	public String toString() {
		return "Dummy";
	}

}
