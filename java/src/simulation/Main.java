package simulation;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import strategy.IMastermindStrategy;
import strategy.implementations.*;

/**
 * Alter the constants and run this file to see the results of the simulation. 
 */
public class Main {
	
	/** Time limit in seconds */
	private static final int TIME_LIMIT = 1000;
	/** Robot speed in mm/s */
	private static final double ROBOT_SPEED = 100;
	/** Number of buttons in the secret sequence */
	private static final int CODE_LENGTH = 3;
	/** The higher the value the greater the time penalty for calculations will be */
	private static final double CPU_SLOWNESS = 0;
	/** The higher the value the more precise the results will be */
	private static final int SIMULATIONS = 10;
	/** Strategy that will be used in the simulation */
	private static final IMastermindStrategy STRATEGY = new Knuth(CODE_LENGTH);

	public static void main(String[] args) {
		printTitle();
		printParameters();
		Simulation simulation;
		Statistics statistics;
		List<Statistics> statisticsList = new ArrayList<Statistics>();
		int progress = 0;
		for (int i = 0; i < SIMULATIONS; i++) {
			simulation = new Simulation(TIME_LIMIT, CPU_SLOWNESS, 
					ROBOT_SPEED, CODE_LENGTH, STRATEGY);
			statistics = simulation.run();
			statisticsList.add(statistics);
			// Print the progress
			double doneYet = 1.0 * i / SIMULATIONS;
			for (int j = 1; j <= 10; j++) {
				if (doneYet >= (1.0 * j / 10) && progress < j) {
					System.out.print("^");
					progress += 1;
				}
			}
		}
		printResults(statisticsList);
	}
	
	private static void printTitle() {
		String title = "Testing '" + STRATEGY + "'" + "\n";
		int length = title.length() - 1;
		for (int i = 0; i < length; i++) {
			title += "=";
		}
		System.out.println(title);
		System.out.println();
	}
	
	private static void printParameters() {
		System.out.println("Time Limit:   " + TIME_LIMIT + " [s]");
		System.out.println("Robot Speed:  " + ROBOT_SPEED + " [mm/s]");
		System.out.println("Code Length:  " + CODE_LENGTH);
		System.out.println("CPU Slowness: " + CPU_SLOWNESS);
		System.out.println("Simulations:  " + SIMULATIONS);
		System.out.println();
		// Print progress bar
		System.out.println("[..........]");
		System.out.print(" ");
	}

	private static void printResults(List<Statistics> statisticsList) {
		// Calculate the values for successes and expected
		int successesSum = 0;
		int expectedSum = 0;
		for (Statistics s : statisticsList) {
			Map<Integer, Integer> successesPerRound = s.getSuccessesPerRound();
			for (Entry<Integer, Integer> e : successesPerRound.entrySet()) {
				int round = e.getKey();
				int successes = e.getValue();
				successesSum += successes;
				expectedSum += round * successes;
			}
		}
		double expectedAverage = (successesSum != 0) ? 1.0 * expectedSum
				/ successesSum : Double.MAX_VALUE;
		double successesAverage = 1.0 * successesSum / SIMULATIONS;

		// Calculate percentages for the thinking and driving time
		double totalThinkingTime = 0;
		double totalDrivingTime = 0;
		for (Statistics s : statisticsList) {
			totalThinkingTime += s.getThinkingTime();
			totalDrivingTime += s.getDrivingTime();
		}
		double relativeThinkingTime = totalThinkingTime
				/ (totalThinkingTime + totalDrivingTime) * 100;
		double relativeDrivingTime = totalDrivingTime
				/ (totalThinkingTime + totalDrivingTime) * 100;

		// Calculate the values for the result table
		int maxRound = 8;
		double[] tableEntries = new double[maxRound];
		for(int i = 0; i < maxRound; i++) {
			tableEntries[i] = 0;
		}
		for (Statistics s : statisticsList) {
			Map<Integer, Integer> successesPerRound = s.getSuccessesPerRound();
			for(int i = 0; i < maxRound - 1; i++) {
				Integer successes = successesPerRound.get(i+1);
				if (successes != null) {
					tableEntries[i] += successes;
				}
			}
		}
		// Calclate rounds >= maxRound
		int sum = 0;
		for(int i = 0; i < maxRound - 1; i++) {
			sum += tableEntries[i];
		}
		tableEntries[maxRound-1] = successesSum - sum;
		// Transform into relative values
		for(int i = 0; i < maxRound; i++) {
			tableEntries[i] = (tableEntries[i] * 100) / successesSum;
		}

		// Print results
		System.out.println();
		System.out.println();
		System.out.println("Results");
		System.out.println("-------");
		System.out.println();
		System.out.printf("Successes: %.5f\n", successesAverage);
		System.out.printf("Expected:  %.5f [Guesses/Success]\n", expectedAverage);
		System.out.println();
		System.out.printf("Driving Time:  %.2f [%%]\n", relativeDrivingTime);
		System.out.printf("Thinking Time: %.2f [%%]\n", relativeThinkingTime);
		System.out.println();
		System.out.println("|   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]");
		System.out.println("|===============================================================|");
		System.out.print("| ");
		for(int i = 0; i < maxRound; i++) {
			double percentage = tableEntries[i];
			DecimalFormat df = new DecimalFormat( "00.00");
			String formatted = df.format(percentage);
			// To prevent weird characters when e.g. Dummy is tested
			if(new Double(percentage).equals(Double.NaN)) {
				formatted = " NaN ";
			}
			if (formatted.equals("100.00")) {
				formatted = "100.0";
			}
			System.out.printf("%s | ", formatted);
		}
		System.out.print("[%]");
	}

}