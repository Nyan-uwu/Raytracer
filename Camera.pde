class Scene
{
    PVector pos,
           size;

    Scene(PVector pos, PVector size) {
        this.pos = pos;
        this.size = size;
    }

    void render() {
        noFill(); stroke(255);
        // rect(this.pos.x, this.pos.y, this.size.x, this.size.y);
    }
}

class View
{
    PVector pos,
           size;

    View(PVector pos, PVector size) {
        this.pos = pos;
        this.size = size;
    }

    void render() {
        noFill(); stroke(255);
        //rect(this.pos.x, this.pos.y, this.size.x, this.size.y);

        float[] distances = new float[Cam.rays.length];

        // println(Cam.rays.length);
        for (int i = 0; i < Cam.rays.length; ++i) {
            Camera.Ray r = Cam.rays[i];
            if (r.closest_point != null) {
                float d = PVector.dist(Cam.pos, r.closest_point);
                float a = PVector.angleBetween(r.dir, Cam.move_angle);
                distances[i] = d*cos(a);
            }
            else {
                distances[i] = 999999;
            }
        }

        int col_width = floor(View.size.x/Cam.rays.length);
        int col_offset = 0;

        float wSq = Scene.size.x*Scene.size.y;
        for (float d : distances) {
            if (d != 999999) {
                float b = map(d*d, 0, wSq, 255, 0);
                float h = map(d, 0, Scene.size.x, View.size.y, 0);

                fill(b); stroke(0); rectMode(CENTER);
                rect(View.pos.x+col_offset+col_width/2, View.size.y/2, col_width, h);
                col_offset+=col_width;
            }
        }
    }
}