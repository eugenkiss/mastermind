package simulation;

import java.util.HashMap;
import java.util.Map;

/**
 * Several statistics of a single simulation.
 */
public class Statistics {

	/** 
	 * Save how many correct guesses have been achieved in each round. The key
	 * is the respective round and the value is the number of successes in that
	 * round. 
	 */
	private Map<Integer, Integer> successesPerRound;
	/** Total time used for deciding for the next guess in milliseconds */
	private double thinkingTime;
	/** Total time used for driving in milliseconds */
	private double drivingTime;
	/** Keep track of the current round. Reset after a correct guess */
	private int roundCounter;

	public Statistics() {
		this.roundCounter = 1;
		this.thinkingTime = 0;
		this.drivingTime = 0;
		this.successesPerRound = new HashMap<Integer, Integer>();
	}

	/**
	 * Increment round counter.
	 */
	public void count() {
		this.roundCounter++;
	}

	/**
	 * Reset the round counter and increase the correct guesses by one for the 
	 * round in which the secret code guess has been found.
	 */
	public void reset() {
		Integer old = this.successesPerRound.get(this.roundCounter);
		if (old == null)
			old = 0;
		this.successesPerRound.put(this.roundCounter, old + 1);
		this.roundCounter = 1;
	}

	/**
	 * Increase the thinking time.
	 * 
	 * @param time
	 *            Time to be added in milliseconds
	 */
	public void addThinkingTime(double time) {
		this.thinkingTime += time;
	}
	
	/**
	 * Increase the driving time.
	 * 
	 * @param time
	 *            Time to be added in milliseconds
	 */
	public void addDrivingTime(double time) {
		this.drivingTime += time;
	}

	public double getThinkingTime() {
		return this.thinkingTime;
	}

	public double getDrivingTime() {
		return this.drivingTime;
	}

	public Map<Integer, Integer> getSuccessesPerRound() {
		return this.successesPerRound;
	}

}