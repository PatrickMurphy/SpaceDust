class ProjectileManager extends ArrayList<Projectile> {
  ArrayList<Projectile> newBullets;
  ArrayList<Projectile> removeList;
  ProjectileManager() {
    super();
    newBullets = new ArrayList<Projectile>();
  }

  void addNewBullets() {
    if (newBullets.size() >= 0) {
      ((Level)CurrentGameState).DisplayMap.get("Projectile").addAll(newBullets);
      this.addAll(newBullets);
      newBullets.clear();
    }
  }

  void addNew(Projectile P) {
    newBullets.add(P);
  }

  void removeAll(ArrayList<Projectile> l) {
    super.removeAll(l);
    ((Level)CurrentGameState).DisplayMap.get("Projectile").removeAll(l);
  }
}