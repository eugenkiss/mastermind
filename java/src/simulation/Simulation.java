package simulation;

import java.util.Random;

import strategy.Answer;
import strategy.Code;
import strategy.IMastermindStrategy;
import strategy.T;

/**
 * A simulation of the specific mastermind alteration in an enclosed area with
 * robots trying to guess a secret code by pushing buttons without repetitions
 * in the correct order.
 */
public class Simulation {

	/** Strategy that will be used in the simulation */
	private IMastermindStrategy strategy;
	/** Secret button sequence to be found by the robot */
	private Code secretCode;
	/** Time limit in milliseconds */
	private int timeLimit;
	/** Multiplied with the thinking time to simulate a slower cpu */
	private double CPUSlowness;
	/** Speed in mm/second */
	private double robotSpeed;
	/** Number of buttons in the secret sequence */
	private int codeLength;
	/** Last position of the robot */
	private T lastButton;

	/**
	 * Create a simulation with the specified configuration.
	 * 
	 * @param timeLimit
	 *            Time limit in seconds
	 * @param CPUSlowness
	 *            Multiplied with the thinking time to simulate a slower cpu
	 * @param robotSpeed
	 *            Speed in mm/second
	 * @param codeLength
	 *            Code length
	 * @param strategy
	 *            Used strategy
	 */
	public Simulation(int timeLimit, double CPUSlowness,
			double robotSpeed, int codeLength, IMastermindStrategy strategy) {
		// Convert from seconds to milliseconds
		this.timeLimit = timeLimit * 1000;
		this.CPUSlowness = CPUSlowness;
		this.robotSpeed = robotSpeed;
		this.codeLength = codeLength;
		this.strategy = strategy;
		this.secretCode = createRandomCode(this.codeLength);
	}

	/**
	 * Start the simulation and let it run until the time limit is exceeded.
	 * 
	 * @return Round statistics
	 */
	public Statistics run() {
		Statistics statistics = new Statistics();
		double thinkingTime = 0; // milliseconds
		double drivingTime = 0; // milliseconds
		long timer;
		Code guess;
		this.lastButton = null;
		timer = System.currentTimeMillis();
		guess = this.strategy.reset();
		thinkingTime += (System.currentTimeMillis() - timer)
				* this.CPUSlowness;
		drivingTime += this.calculateDrivingTime(guess);

		while (drivingTime + thinkingTime < this.timeLimit) {
			Answer answer = guess.compare(this.secretCode);
			if (answer.blacks == this.codeLength) {
				this.secretCode = createRandomCode(this.codeLength);
				timer = System.currentTimeMillis();
				guess = this.strategy.reset();
				thinkingTime += (System.currentTimeMillis() - timer)
						* this.CPUSlowness;
				statistics.reset();
			} else {
				timer = System.currentTimeMillis();
				guess = this.strategy.guess(answer);
				thinkingTime += (System.currentTimeMillis() - timer)
						* this.CPUSlowness;
				statistics.count();
			}
			drivingTime += this.calculateDrivingTime(guess);
			this.lastButton = guess.get(this.codeLength - 1);
		}

		statistics.addDrivingTime(drivingTime);
		statistics.addThinkingTime(thinkingTime);
		return statistics;
	}

	/**
	 * Create and return a random code of specified length.
	 * 
	 * @param length
	 *            Length of the code
	 * @return Random code
	 */
	public static Code createRandomCode(int length) {
		Random rnd = new Random();
		T[] ts = new T[length];
		for (int i = 0; i < length; i++) {
			ts[i] = T.values()[rnd.nextInt(8)];
		}
		return new Code(ts);
	}

	/**
	 * Calculate the driving time for a specific guess by dividing the distance
	 * from the current button (i.e. where the robot stands) to the next one
	 * with the robot speed and of course summing up.
	 * 
	 * @param guess
	 *            Sequence to be entered
	 * @return Calculated driving time
	 */
	private double calculateDrivingTime(Code guess) {
		return (calculateDrivingDistance(this.lastButton, guess) / this.robotSpeed) * 1000;
	}

	/**
	 * Calculate the driving distance for a specific guess by summing up the
	 * distance from one button to the next.
	 * 
	 * @param lastButton
	 *            Last pushed button. If null means that robot is in the center.
	 * @param guess
	 *            Sequence to be entered
	 * @return Calculated driving distance
	 */
	public static double calculateDrivingDistance(T lastButton, Code guess) {
		double distance = 0;
		if (lastButton != null) {
			distance += lastButton.calculateDistance(guess.get(0));
		} else { // I.e. The robot is in the middle of the field (start)
			// Distance from the center to each button is 1084.4
			distance += 1084.4;
		}
		for (int i = 0; i < guess.getLength() - 1; i++) {
			distance += guess.get(i).calculateDistance(guess.get(i + 1));
		}
		return distance;
	}

}