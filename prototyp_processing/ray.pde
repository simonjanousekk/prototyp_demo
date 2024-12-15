class Ray {
  PVector pos, dir;
  final int rayLength = 100;
  float originAngle;
  PVector intersection = null;

  Ray(PVector p, float angle) {
    pos = p.copy();
    originAngle = angle;
    dir = PVector.fromAngle(angle);
  }

  void update(PVector p, float a) {
    pos = p.copy();
    dir = PVector.fromAngle(originAngle + a);
  }

  void display() {
    
    if (intersection != null) {
      stroke(100, 100, 255);
      line(pos.x, pos.y, intersection.x, intersection.y);
      noStroke();
      fill(100, 100, 255);
      circle(intersection.x, intersection.y, 5);
    } else {
      stroke(100, 100, 255);
      line(
        pos.x,
        pos.y,
        pos.x + dir.x * rayLength,
        pos.y + dir.y * rayLength
        );
    }
  }

  ArrayList<PVector> cast(ArrayList<Wall> wls) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (Wall w : wls) {
      intersections.add(
        lineLineIntersection(
        pos,
        pos.copy().add(dir.copy().mult(rayLength)),
        w.pos1,
        w.pos2));
    }
    return intersections;
  }

  void findShortestIntersection(ArrayList<Wall> wls) {
    ArrayList<PVector> intersections = cast(wls); //<>//

    intersection = null;
    PVector shortestIntersection = null;

    for (PVector intersection : intersections) {
      if (intersection != null) {
        float dx = intersection.x - this.pos.x;
        float dy = intersection.y - this.pos.y;
        float distanceSquared = dx * dx + dy * dy;

        if (shortestIntersection == null || distanceSquared < (shortestIntersection.x - this.pos.x) * (shortestIntersection.x - this.pos.x) + (shortestIntersection.y - this.pos.y) * (shortestIntersection.y - this.pos.y)) {
          shortestIntersection = intersection;
        }
      }
    }

    intersection = shortestIntersection;
  }
}
