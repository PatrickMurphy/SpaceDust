class WaveManager extends ShipManager {
  int currentWave_id;
  int currentWave;
  boolean WavesInitalized;
  boolean waiting_for_timer;
  ArrayList<ArrayList<Ship>> waves;
  boolean debug;
  ArrayList<Integer> wave_delay_seconds;
  int last_wave_millis;
  
  WaveManager() {
    super();
    debug = false;
    waves = new ArrayList<ArrayList<Ship>>();
    wave_delay_seconds = new ArrayList<Integer>();
    WavesInitalized = false;
    waiting_for_timer = true;
    currentWave_id = 0;
    currentWave = currentWave_id-1;
    last_wave_millis = 25*1000;
  }

  void update() {
    int tempWave = currentWave_id;
    if (!WavesInitalized) {
      WavesInitalized = true;
      queueWave(generateWave(currentWave+3));
      deployWave(currentWave_id);
      currentWave_id = 1;
      currentWave = currentWave_id - 1; 
    } else {
      if (countAliveShips()==0) {
        waveComplete();
        tempWave++;
      }
      if (tempWave > currentWave_id && wave_delay_seconds.size()>0 && waiting_for_timer) {
        deployNextWave();
        currentWave_id = tempWave;
        currentWave = currentWave_id - 1;
      }
    }
  }

  boolean deployNextWave() {
    if (seconds_until_next_wave() <= 0) {
      deployWave(currentWave_id-1);
      waiting_for_timer = false;
      return true;
    }
    return false;
  }

  float seconds_until_next_wave() {
    if (waiting_for_timer) {
      float time_since_last_wave_end = (millis()-last_wave_millis);
      float millis_time_limit = 1000 * 25;
      return (millis_time_limit - time_since_last_wave_end)/1000;
    }
    return 0;
  }

  float seconds_wave_length() {
    if (waiting_for_timer) {
      float time_since_last_wave_end = (millis()-last_wave_millis);
      return time_since_last_wave_end/1000;
    }
    return 0;
  }

  void deployWave(int i) {
    if (waves.size()-1 > i) {
      addAll(waves.get(i));
    }
  }

  void waveComplete() {
    if (!waiting_for_timer) {
      last_wave_millis = millis();
      waiting_for_timer = true;
    }
    if (waves.size() <= currentWave_id)
      addAll(generateWave(currentWave+4));
  }

  void queueWave(ArrayList<Ship> wave) {
    wave_delay_seconds.add(25);
    waves.add(wave);
  }

  ArrayList<Ship> generateWave() {
    return generateWave(10);
  }
  ArrayList<Ship> generateWave(int count) {
    return generateWave(count, 0.0);
  }
  ArrayList<Ship> generateWave(int count, float strength) {
    ArrayList<Ship> wave = new ArrayList<Ship>();
    if (debug) println(wave);
    PVector RandomSpawn = new PVector(random(25, 90), random(0, height));
    for (int i = 0; i<count; i++) {     
      PVector rSpawn = copyVector(RandomSpawn);
      PVector randOffset = PVector.random2D();
      randOffset.setMag(random(250));
      rSpawn.add(randOffset);
      EnemyShip s = new EnemyShip(((Level)CurrentGameState).enemyPlayer, rSpawn, 1+(random(.05,.2)*currentWave));
      wave.add(s);
    }
    return wave;
  }

  int countAliveShips() {
    return ((Level)CurrentGameState).DisplayMap.get("EnemyShip").size()-1;
  }
}