enum Level {
  D("Découverte", "#60C8B3"),
  B("Débutant", "#6EA1D4"),
  I("Intermédiaire", "#FFA74F"),
  E("Expert", "#1B5091");

  final String label;
  final String color;

  const Level(this.label, this.color);
}
