import java.util.Arrays;
import java.awt.Polygon;

class Point implements Comparable<Point> {
  int x, y;
 
  public int compareTo(Point p) {
    if (this.x == p.x) {
      return this.y - p.y;
    } else {
      return this.x - p.x;
    }
  } 
}
 
class ConvexHull {
 
  public long cross(Point O, Point A, Point B) {
    return (A.x - O.x) * (B.y - O.y) - (A.y - O.y) * (B.x - O.x);
  }
 
  public Point[] convex_hull(Point[] P) {
 
    if (P.length > 1) {
      int n = P.length, k = 0;
      Point[] H = new Point[2 * n];
 
      Arrays.sort(P);
 
      // Build lower hull
      for (int i = 0; i < n; ++i) {
        while (k >= 2 && cross(H[k - 2], H[k - 1], P[i]) <= 0)
          k--;
        H[k++] = P[i];
      }
 
      // Build upper hull
      for (int i = n - 2, t = k + 1; i >= 0; i--) {
        while (k >= t && cross(H[k - 2], H[k - 1], P[i]) <= 0)
          k--;
        H[k++] = P[i];
      }
      H[k-1]=null; // remove repetition
      return H;
    } else if (P.length <= 1) {
      return P;
    } else{
      return null;
    }
  }
 
  public Polygon myHull(List<Integer> parts) {
    if (parts.size() > 2) {   
      Point[] p = new Point[parts.size()];
      for (int i = 0; i < p.length; i++) {
        p[i] = new Point();
        p[i].x = round(flock.xs[parts.get(i)]);  
        p[i].y = round(flock.ys[parts.get(i)]);
      }
   
      Point[] hull = convex_hull(p).clone();
      
      //println(hull.length);
      int[] xs = new int[hull.length];
      int[] ys = new int[hull.length];
      for (int i = 0; i < hull.length; i++) {
        if (hull[i] != null) {
        xs[i] = hull[i].x;
        ys[i] = hull[i].y;
        } else {
          xs[i] = xs[i - 1];
          ys[i] = ys[i - 1];
        }
      }
      return new Polygon(xs,ys,hull.length);
    } else {
      return null;
    }
  }
 
}
