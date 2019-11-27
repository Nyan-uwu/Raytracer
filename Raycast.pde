Scene Scene;
View  View;

Camera Cam;

void setup() {
    size(801, 401);
    frameRate(120);

    // Setup Views
    Scene = new Scene(new PVector(0, 0),
                      new PVector(floor((width-1)/2), height-1));
    View  = new View(new PVector(floor((width-1)/2), 0),
                     new PVector(floor((width-1)/2), height-1));


    println("Scene.pos: " + Scene.pos);
    println("Scene.size: " + Scene.size);
    println("View.pos: " + View.pos);
    println("View.size: " + View.size);

    Cam = new Camera(new PVector(floor(Scene.size.x/2), floor(Scene.size.y/2)));
}

void draw() {
    background(0);

    // Render View Boundries
    Scene.render();

    Cam.update_pos();
    Cam.render();

    // Render All Scenes Info Onto View :( help this is gonna be hard
    View.render();
}

class Camera
{
    int fov = 70,
        rad = 10,
        ang = -35,
        rotation = 0,
        move = 0;

    Ray[] rays = new Ray[this.fov];
    ArrayList<PVector> rays_hit = new ArrayList<PVector>();
    ArrayList<Boundry> bounds = new ArrayList<Boundry>();

    PVector pos, move_angle;

    Camera(PVector _pos) {
        this.pos = _pos;

        for (int i = 0; i < 1; ++i) {
            this.bounds.add(
                new Boundry(
                    new PVector(
                        floor(random(Scene.pos.x, Scene.pos.x+Scene.size.x)),
                        floor(random(Scene.pos.y, Scene.pos.y+Scene.size.y))
                    ),
                    new PVector(
                        floor(random(Scene.pos.x, Scene.pos.x+Scene.size.x)),
                        floor(random(Scene.pos.y, Scene.pos.y+Scene.size.y))
                    )
                )
            );
        }

        // Walls //
        this.bounds.add(
            new Boundry(new PVector(Scene.pos.x, Scene.pos.y),
                        new PVector(Scene.pos.x+Scene.size.x, Scene.pos.y))
        );
        this.bounds.add(
            new Boundry(new PVector(Scene.pos.x, Scene.pos.y),
                        new PVector(Scene.pos.x, Scene.pos.y+Scene.size.y))
        );
        this.bounds.add(
            new Boundry(new PVector(Scene.pos.x+Scene.size.x, Scene.pos.y),
                        new PVector(Scene.pos.x+Scene.size.x, Scene.pos.y+Scene.size.y))
        );
        this.bounds.add(
            new Boundry(new PVector(Scene.pos.x, Scene.pos.y+Scene.size.y),
                        new PVector(Scene.pos.x+Scene.size.x, Scene.pos.y+Scene.size.y))
        );

        int index = 0;
        for (int a = this.ang; a < this.fov+this.ang; ++a) {
            // println(index + " : " + PVector.fromAngle(radians(a)));
            this.rays[index] = new Ray(PVector.fromAngle(radians(a)));
            if (index == floor(this.fov/2)) {
                this.move_angle = PVector.fromAngle(radians(a));
                // println(this.move_angle);
            }
            ++index;
        }

    }

    void rotate(int dir) {
        this.rays = new Ray[this.fov];
        this.ang += dir;
        int index = 0;
        for (int a = this.ang; a < this.fov+this.ang; ++a) {
            // println(index + " : " + PVector.fromAngle(radians(a)));
            this.rays[index] = new Ray(PVector.fromAngle(radians(a)));
            if (index == floor(this.fov/2)) {
                this.move_angle = PVector.fromAngle(radians(a));
                // println(this.move_angle);
            }
            ++index;
        }
    }

    void move_f() {
        this.pos.x += this.move_angle.x;
        this.pos.y += this.move_angle.y;
    }
    void move_b() {
        this.pos.x -= this.move_angle.x;
        this.pos.y -= this.move_angle.y;
    }

    void render() {
        fill(255); stroke(255);
        ellipseMode(CENTER);
        ellipse(this.pos.x, this.pos.y, this.rad, this.rad);

        if (this.rotation != 0) {
            this.rotate(this.rotation);
        }
        if (this.move != 0) {
            if (this.move == 1) {
                this.move_f();
            } else if(this.move == -1) {
                this.move_b();
            }
        }

        this.cast_all();
        for (Ray r : this.rays) { if (r != null) {
            r.render();
        } }
        for (Boundry b : this.bounds) { if (b != null) {
            b.render();
        } }
    }

    void update_pos() {
        if     (this.pos.x < 0) this.pos.x = 0;
        else if(this.pos.x >= Scene.size.x) this.pos.x = Scene.size.x-1;

        if     (this.pos.y < 0) this.pos.y = 0;
        else if(this.pos.y >= Scene.size.y) this.pos.y = Scene.size.y-1;
    }

    void cast_all() {
        for (Ray r : this.rays) { if(r != null) {
            ArrayList<PVector> vPoints = r.cast(this.bounds);
            if (vPoints.size() > 0) {
                if (vPoints.size() == 1) {
                    r.show = true;
                    r.closest_point = vPoints.get(0);
                } else {
                    final float x1 = Cam.pos.x,
                                y1 = Cam.pos.y;

                    PVector closest = null;
                    float dist_float = 99999999;

                    for (PVector pv : vPoints) {
                        // println("VALID POINT: " + pv);
                        float dist = PVector.dist(Cam.pos, pv);
                        // println("DISTANCE: " + dist);
                        if (closest != null) {
                            if (dist < dist_float) {
                                closest = pv;
                                dist_float = dist;
                            }
                        } else {
                            closest = pv;
                            dist_float = dist;
                        }
                    }

                    // println("CLOSEST POINT: " + closest);
                    r.show = true;
                    r.closest_point = closest;
                }
            } else {
                r.show = false;
                r.closest_point = null;
            }
            // println("----------");
        } }
    }

    class Ray {
        PVector dir, closest_point = null;
        Boolean show = true;
        Ray(PVector dir) { this.dir = dir; }

        ArrayList<PVector> cast(ArrayList<Boundry> walls) {
            

            ArrayList<PVector> validPoints = new ArrayList<PVector>();
            for (Boundry wall : walls) {
                
                float x1 = wall.posa.x;
                float y1 = wall.posa.y;
                float x2 = wall.posb.x;
                float y2 = wall.posb.y;

                float x3 = Cam.pos.x;
                float y3 = Cam.pos.y;
                float x4 = Cam.pos.x + this.dir.x;
                float y4 = Cam.pos.y + this.dir.y;
                
                final float den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
                if (den == 0) {
                    continue;
                } else {
                    final float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
                    final float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den;

                    if (t >= 0 && t <= 1 && u >= 0) {
                        PVector pt = new PVector();
                        pt.x = x1 + t * (x2 - x1);
                        pt.y = y1 + t * (y2 - y1);
                        validPoints.add(pt);
                    }
                }
            }
            for (int i = 0; i < validPoints.size(); ++i) {
                // println("VALID POINTS: " + validPoints.get(i));
            }
            return validPoints;
        }

        void render() {
            stroke(255); fill(255);
            // Testing
            // line(Cam.pos.x, Cam.pos.y, Cam.pos.x+this.dir.x*50, Cam.pos.y+this.dir.y*50);
            if (this.show && this.closest_point != null) {
                line(Cam.pos.x, Cam.pos.y, this.closest_point.x, this.closest_point.y);
            }
        }
    }
}

class Boundry {
    PVector posa, posb;
    Boundry(PVector a, PVector b) {
        this.posa = a;
        this.posb = b;
    }

    void render() {
        stroke(255);
        line(this.posa.x, this.posa.y, this.posb.x, this.posb.y);
    }
}

void keyPressed() {
    if (key == 'a') {
        Cam.rotation = -1;
        // println("You Pressed: " + key);
    }
    if (key == 'd') {
        Cam.rotation = 1;
        // println("You Pressed: " + key);
    }
    if (key == 'w') {
        Cam.move = 1;
        // println("You Pressed: " + key);
    }
    if (key == 's') {
        Cam.move = -1;
        // println("You Pressed: " + key);
    }
}

void keyReleased() {
    if (key == 'w' && Cam.move == 1) {
        Cam.move = 0;
    } else if (key == 's' && Cam.move == -1) {
        Cam.move = 0;
    }
    if (key == 'a' && Cam.rotation == -1) {
        Cam.rotation = 0;
    }
    else if (key == 'd' && Cam.rotation == 1) {
        Cam.rotation = 0;
    }
}