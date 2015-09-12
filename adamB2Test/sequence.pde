class Sequence {
  ArrayList<SequenceAction> actions = new ArrayList<SequenceAction>();
  
  Sequence(String filename) {
    String[] inputLines = loadStrings(filename);
    for (String line : inputLines) {
      actions.add(new SequenceAction(line));
    }
    
    interpolateHomeForce();    
//    for (SequenceAction action : actions) {
//      if (action.action.equals("homeForce")) {
//        println(action.frame, action.action, action.chunkIndex, action.value, action.value2);
//      }
//    }
  }
  
  void checkForAction(int frame) {
    for (SequenceAction action : actions) {
      if (action.frame == frame) {
        action.runAction();
      }
    }
  }
  
  void interpolateHomeForce() {
    //get first home force point 
    SequenceAction oldAction = null;
    for (SequenceAction action: actions) {
      if (action.action.equals("homeForceLocation")) {
        oldAction = action; 
        break;
      }
    }
    ArrayList<SequenceAction> newActions = new ArrayList<SequenceAction>();
    for (SequenceAction action: actions) {
      if (action.action.equals("homeForceLocation")) {
        if (action.frame == oldAction.frame) {
          newActions.add(action);
        } else {
          int dFrame = action.frame - oldAction.frame;
          for (int i = 0; i < dFrame; i++) {
            SequenceAction newAction = new SequenceAction(action);
            newAction.frame = oldAction.frame + i;
            newAction.value  = int( round( float(oldAction.value ) + (float(action.value ) - float(oldAction.value )) * float(i) / float(dFrame)));
            newAction.value2 = int( round( float(oldAction.value2) + (float(action.value2) - float(oldAction.value2)) * float(i) / float(dFrame)));
            newActions.add(newAction);
          }        
          oldAction = action;
        }
      } else {
        newActions.add(action);
      }
    }
    this.actions = newActions;
  }
}

class SequenceAction {
  private static final float timeScaling = 1.0;
  
  String action = ""; 
  int chunkIndex = -1;
  int frame = -1;
  int value = 9999;
  int value2 = 9999;
  String comment = "";
  
  SequenceAction(SequenceAction sa) {
    this.action = sa.action;
    this.chunkIndex = sa.chunkIndex;
    this.frame = sa.frame;
    this.value = sa.value;
    this.value2 = sa.value2;
    this.comment = sa.comment;
  }
  
  SequenceAction(String line) {
    String[] list = split(line,",");
    if (list.length > 0) {
      try {this.frame = round(SequenceAction.timeScaling * Integer.parseInt(list[0]) );} catch(NumberFormatException e) {}
    }
         
    if (list.length > 1) {
      this.action = list[1];
    }
    
    //NB the file is 1-indexed
    if (list.length > 2) {
      try {this.chunkIndex = Integer.parseInt(list[2]) - 1;} catch(NumberFormatException e) {}
    }
    if (list.length > 3) {
      try {this.value = Integer.parseInt(list[3]);} catch(NumberFormatException e) {}
    }
    if (list.length > 4) {
      try {this.value2 = Integer.parseInt(list[4]);} catch(NumberFormatException e) {}
    }
    if (list.length > 5) {
      this.comment = list[5];
    }
  }
  
  void runAction() {
    if (this.frame == -1) return;
    
    //println(this.action, this.frame);
    
    if (this.action.equals("release")) { 
      flock.releaseChunk(this.chunkIndex);
    } else if (this.action.equals("dissolve")) {
      flock.explodeChunk(this.chunkIndex);
    } else if (this.action.equals("erosionRate")) {
      flock.setErosionRate(this.chunkIndex, this.value);
    } else if (this.action.equals("inverseDisorderRate")) {
      disorderingInverseRate = this.value;
    } else if (this.action.equals("homeForce")) {
      for (HomeForce homeForce: this.homeForcesForIndex(this.chunkIndex)) {
        homeForce.force = float(this.value) / 1000.0;
      } 
    } else if (this.action.equals("homeForceLocation")) {
      for (HomeForce homeForce: this.homeForcesForIndex(this.chunkIndex)) {
        homeForce.x = this.value;
        homeForce.y = this.value2;
      }     
    } else if (this.action.equals("inputPositionsMode")) {
      if (inputPositionsMode != 0 && this.value == 0) {
        //println("closing positions file");
        flock.closePositionsFile();
      }     
      inputPositionsMode = this.value;  
      println("inputPositionsMode",inputPositionsMode);
    } else if (this.action.equals("freeAllParticles")) {
      flock.freeAllParticles();
    } else if (this.action.equals("useMiniFlocks")) {
      useMiniFlocks = this.value == 1;
    } else if (this.action.equals("homeForceRadius")) {
      for (HomeForce homeForce: this.homeForcesForIndex(this.chunkIndex)) {
        homeForce.radius = float(this.value);
      } 
    } else if (this.action.equals("separationForce")) {
      separationForce = float(this.value) / 1000.0; //*******  NB val / 1000.0
    } else if (this.action.equals("cohesionForce")) {
      cohesionForce = float(this.value) / 1000.0; //*******  NB val / 1000.0
    } else if (this.action.equals("alignmentForce")) {
      alignmentForce = float(this.value) / 1000.0; //*******  NB val / 1000.0
    } else if (this.action.equals("assignHomeForceIndexWithProbability")) {
      flock.assignHomeForceIndexWithProbability(float(this.value) / 1000.0, float(this.value2) / 1000.0); //*******  NB val / 1000.0
    } else if (this.action.equals("assignHomeForceIndexWithLocation")) {
      flock.assignHomeForceIndexWithLocation(this.chunkIndex, this.value, this.value2); 
    } else if (this.action.equals("stragglers")) {
      flock.stragglers(this.chunkIndex, this.value, float(this.value2) / 1000.0);
    }
  }
  
  ArrayList<HomeForce> homeForcesForIndex(int index) {    
    if (this.chunkIndex == -1) {
        //apply to all homeForces
        return homeForces;
      } else {
        ArrayList<HomeForce> list = new ArrayList<HomeForce>();
        list.add(homeForces.get(index));
        return list;
      }      
  }
}
