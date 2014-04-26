package strategy;

/**
 * Enumeration of the buttons including their position in the area.
 * 
 * Allows calculation of the distance between two buttons. 
 */
public enum T {
	
	T0(0, -460, 982),
	T1(1, 460, 982),
	T2(2, 982, 460),
	T3(3, 982, -460),
	T4(4, 460, -982),
	T5(5, -460, -982),
	T6(6, -982, -460),
	T7(7, -982, 460);
	
	public final int i;
	public final int x;
	public final int y;
	
	T(int i, int x, int y) {
		this.i = i;
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Return the distance between this button and buttonx.
	 * 
	 * @param t 
	 *            Other button
	 * @return Distance
	 */
	public double calculateDistance(T t) {
		return Math.sqrt(Math.pow(this.x - t.x, 2) + Math.pow(this.y - t.y, 2));
	}

}