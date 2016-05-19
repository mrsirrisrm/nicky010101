class MyPhysics {
  VPhysics physics;
  float z = 0;
  
  
  MyPhysics(Vec a, Vec b, float z) {
    physics = new VPhysics(a, b, true);
    this.z = z;
  }
  
}