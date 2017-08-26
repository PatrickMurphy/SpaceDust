import java.util.*;

class ResourceManager {
  Map<Resources, Float> resources;
  float resourceScale;
  
  ResourceManager(){
    this(0.0);
  }
  
  ResourceManager(float all){
    this(all,all,all,all,all);
    resourceScale = 1000;
  }
  
  ResourceManager(float l, float a, float i, float b, float r) {
    resources = new HashMap<Resources, Float>();
    resources.put(Resources.LYONDINE, l);
    resources.put(Resources.AZUTALITE, a);
    resources.put(Resources.ILLIUBISITE, i);
    resources.put(Resources.BYNTHITE, b);
    resources.put(Resources.REALINUM, r);
  }
  
  float getResource(Resources rKey){
    return resources.get(rKey);
  }
  
  void addResource(Resources resourceKey, float value){
    resources.put(resourceKey,(value*resourceScale)+resources.get(resourceKey));
  }
  boolean canAfford(float[] resources){
    boolean affordable = true;
    if(resources.length == 5){
      if(!canAfford(Resources.LYONDINE,resources[0])){
        affordable = false;
      }
      if(!canAfford(Resources.AZUTALITE,resources[1])){
        affordable = false;
      }
      if(!canAfford(Resources.ILLIUBISITE,resources[2])){
        affordable = false;
      }
      if(!canAfford(Resources.BYNTHITE,resources[3])){
        affordable = false;
      }
      if(!canAfford(Resources.REALINUM,resources[4])){
        affordable = false;
      }
    }else{
      affordable = false;
    }
    return affordable;
  }
  boolean canAfford(Resources resourceKey, float value){
    return resources.get(resourceKey) >= value;
  }
  
  boolean useResource(float[] cost){
    boolean bought = true;
    if(canAfford(cost)){
      useResource(Resources.LYONDINE, cost[0]);
      useResource(Resources.AZUTALITE, cost[1]);
      useResource(Resources.ILLIUBISITE, cost[2]);
      useResource(Resources.BYNTHITE, cost[3]);
      useResource(Resources.REALINUM, cost[4]);
    }else{
      bought = false;
    }
    return bought;
  }
  
  boolean useResource(Resources resourceKey, float value){
    if(canAfford(resourceKey, value)){
      resources.put(resourceKey, resources.get(resourceKey)-value);
      return true;
    }else{
      return false;
    }
  }
}