package fr.yasemin.movem8.enums;

public enum Level {
    D("Discovery", "#60C8B3"), 
    B("Beginner", "#6EA1D4"),
    I("Intermediate", "#FFA74F"),
    E("Expert", "#1B5091");
	
	
	private final String label;
	private final String color;
	
	Level(String label, String color){
		this.label = label;
		this.color = color;
	}
	
	 public String getColor() {
	        return color;
	    }

	    public String getLabel() {
	        return label;
	    }
}
