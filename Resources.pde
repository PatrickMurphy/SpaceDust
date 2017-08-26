enum Resources {
  LYONDINE("lyine"), 
    AZUTALITE("azlite"), 
    ILLIUBISITE("illite"), 
    BYNTHITE("bythite"), 
    REALINUM("realum");

  final String text;

  private Resources(final String text) {
    this.text = text;
  }

  public String toString() {
    return text;
  }
}