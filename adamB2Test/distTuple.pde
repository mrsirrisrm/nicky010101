class DistTuple {
  int ind;
  float dist;
  DistTuple(int i, float d) {
    ind = i;
    dist = d;
  }
}

class DistTupleComparator implements Comparator {
  int compare(Object o1, Object o2) {
    float d1 = ((DistTuple) o1).dist;
    float d2 = ((DistTuple) o2).dist;
    if (d1 == d2) {
      return 0; 
    } else if (d1 > d2) {
      return 1;
    } else return -1;
  }
}
