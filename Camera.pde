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
        rect(this.pos.x, this.pos.y, this.size.x, this.size.y);
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
        rect(this.pos.x, this.pos.y, this.size.x, this.size.y);
        for (int i = 0; i < Cam.rays.size(); ++i) {
            Camera.Ray r = Cam.rays.get(i);

        }
    }

    class Block {
        PVector pos, size;
        Block(PVector pos, PVector size) {
            this.pos = pos;
            this.size = size;
        }
        void render() {
            rectMode(CENTER);
            fill(255); stroke(255);
            rect(this.pos.x+this.size.x/2, this.pos.y, this.size.x, this.size.y);
        }
    }
}