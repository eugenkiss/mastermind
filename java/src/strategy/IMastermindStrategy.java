package strategy;

/**
 * Interface for a mastermind strategy.
 */
public interface IMastermindStrategy {

	/**
	 * Reset the state of the strategy, e.g. refill the set of possible codes.
	 * Additionally, return the first guess (after the secret code has been
	 * found).
	 * 
	 * @return First guess
	 */
	Code reset();

	/**
	 * Return the next guess determined by the number of correct buttons on the
	 * correct positions and number of correct buttons on the wrong positions of
	 * the answer.
	 * 
	 * @param answer
	 *            Answer containing correct amount of buttons on correct
	 *            positions and Correct amount of buttons on wrong positions
	 * @return Next guess
	 */
	Code guess(Answer answer);

}
