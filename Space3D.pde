//Space grid setup
PVector pos = new PVector(0, 0, 0);
PVector gridPos = new PVector(0, 0, 0);

final int GRID_SIZE = 10;
final int SPACE_DEPTH = 80;
int zoomFactor = 5;

boolean enable = true;
boolean shading = true;
boolean lighting = true;

final int MAX_ZOOM = 10;
final int MIN_ZOOM = 1;
//End space grid setup

//Camera stuff
float camYAng;
float camXAng = PI;
float camYAngV;
float camXAngV;

void keyboardControls() {
  if (keyPressed) {
    //3D space rotation
    if (key == 'a' || key == 'A') {
      camYAng += radians(1);
    } else  if (key == 'd' || key == 'D') {
      camYAng -= radians(1);
    }
    //Enable and disable gird
    if (key == 'g' || key == 'G') {
      enable = !enable;
    }
    //Shade or frame
    if (key == 'f' || key == 'F') {
      shading = !shading;
    }
    //Turn light on or off
    if (key == 'l' || key == 'L') {
      lighting = !lighting;
    }
  }
  camXAng= map(mouseY, 0, height, -HALF_PI, HALF_PI);
}
//End camera

//Create grid
void createGrid(int size, int tilesize) {
  if (enable) {
    strokeWeight(0.5 * zoomFactor);
    //+x axis
    stroke(255, 0, 0);
    line(0, 0, 0, size/2*tilesize, 0, 0);
    stroke(200, 0, 200);
    //+y axis
    line(0, 0, 0, 0, size/2*tilesize, 0);
    //+z axis
    stroke(0, 200, 200);
    line(0, 0, 0, 0, 0, size/2*tilesize);

    //-x axis
    stroke(255, 0, 0, 100);
    line(0, 0, 0, -size/2*tilesize, 0, 0);
    //-y axis
    stroke(200, 0, 200, 100);
    line(0, 0, 0, 0, -size/2*tilesize, 0);
    //-z axis
    stroke(0, 200, 200, 100);
    line(0, 0, 0, 0, 0, -size/2*tilesize);

    //Verical grid
    noFill();
    for (float x = -size/2; x <= size/2; x++) {
      for (float z = -size/2; z <= size/2; z++) {
        pushMatrix();
        translate(x*tilesize, 0, z*tilesize);
        rotateX(HALF_PI);
        strokeWeight(0.1 * zoomFactor);
        stroke(0, 255, 0, map(dist(-gridPos.x, -gridPos.z, x*tilesize, z*tilesize), 0, size/2*tilesize, 255, 0));
        rect(0, 0, tilesize, tilesize);
        popMatrix();
      }
    }

    //Horizontal grid
    noFill();
    for (float y = -size/2; y <= size/2; y++) {
      for (float z = -size/2; z <= size/2; z++) {
        pushMatrix();
        translate(0, y*tilesize, z*tilesize);
        rotateY(HALF_PI);
        strokeWeight(0.1 * zoomFactor);
        stroke(0, 255, 0, map(dist(-gridPos.x, -gridPos.z, y*tilesize, z*tilesize), 0, size/2*tilesize, 255, 0));
        rect(0, 0, tilesize, tilesize);
        popMatrix();
      }
    }
  }
}

float clamp(float val, float min, float max) {
  return val < min ? min : val > max ? max : val;
}

void mouseWheel(MouseEvent event) {
  zoomFactor = (int)clamp(zoomFactor - event.getCount(), MIN_ZOOM, MAX_ZOOM);
}
//End create grid

//Object loader
class Vertex {
  float x, y, z;
  Vertex(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Color {
  int r, g, b;
  float a;
  Color(int r, int g, int b, float a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  Color(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

ArrayList<Vertex> vbo = new ArrayList<Vertex>();
ArrayList<int[]> vib = new ArrayList<int[]>();

void drawModel(ArrayList<Vertex> vbo, ArrayList<int[]> vib, Color shade) {
  fill(shade.r, shade.g, shade. b, shade.a);
  for (int[] face : vib) {
    Vertex a = vbo.get(face[0]);
    Vertex b = vbo.get(face[1]);
    Vertex c = vbo.get(face[2]);
    if (shading) {
      drawFace(a, b, c);
    } else {
      drawFrame(a, b, c);
    }
  }
}

void drawFace(Vertex a, Vertex b, Vertex c) {
  beginShape(TRIANGLE);
  vertex(a.x * zoomFactor * GRID_SIZE, a.y * zoomFactor * GRID_SIZE, a.z * zoomFactor * GRID_SIZE);
  vertex(b.x * zoomFactor * GRID_SIZE, b.y * zoomFactor * GRID_SIZE, b.z * zoomFactor * GRID_SIZE);
  vertex(c.x * zoomFactor * GRID_SIZE, c.y * zoomFactor * GRID_SIZE, c.z * zoomFactor * GRID_SIZE);
  endShape(CLOSE);
}

void drawFrame(Vertex a, Vertex b, Vertex c) {
  stroke(255);
  line(a, b);
  line(b, c);
  line(c, a);
}

void line(Vertex v1, Vertex v2) {
  line(
    v1.x * zoomFactor * GRID_SIZE, v1.y * zoomFactor * GRID_SIZE, v1.z * zoomFactor * GRID_SIZE, 
    v2.x * zoomFactor * GRID_SIZE, v2.y * zoomFactor * GRID_SIZE, v2.z * zoomFactor * GRID_SIZE
    );
}

void loadFiles(String inFileName) {
  String[] lines = loadStrings(inFileName);
  for (String line : lines) {
    String[] currentLine = line.split(" ");
    if (currentLine.length != 0) {
      if (currentLine[0].equals("v")) {
        float z = Float.parseFloat(currentLine[1]);
        float y = Float.parseFloat(currentLine[2]);
        float x = Float.parseFloat(currentLine[3]);
        vbo.add(new Vertex(x, y, z));
      } else if (currentLine[0].equals("f")) {
        String[] faceA = currentLine[1].split("/");
        String[] faceB = currentLine[2].split("/");
        String[] faceC = currentLine[3].split("/");
        int a = Integer.parseInt(faceA[0]) - 1;
        int b = Integer.parseInt(faceB[0]) - 1;
        int c = Integer.parseInt(faceC[0]) - 1;
        vib.add(new int[]{a, b, c});
      }
    }
  }
}
//End object loader

//Ligthing
void pointLight(Color clr, float x, float y, float z) {
  if (lighting) {
    pushMatrix();
    scale(-1, -1, -1);
    pointLight(
      clr.r, clr.g, clr. b, 
      x * zoomFactor * GRID_SIZE, y * zoomFactor * GRID_SIZE, z * zoomFactor * GRID_SIZE
      );
    popMatrix();
  }
}

void ambientLight(Color clr) {
  if (lighting) {
    ambientLight(clr.r, clr.g, clr. b);
  }
}

void directionalLight(Color clr, int nx, int ny, int nz) {
  if (lighting) {
    directionalLight(
      clr.r, clr.g, clr. b, 
      nx, ny, nz
      );
  }
}
//End lighting

//3D transformation
ArrayList<Vertex> translate3D(ArrayList<Vertex> vbo, float x, float y, float z) {
  ArrayList<Vertex> result = new ArrayList();
  for(Vertex point : vbo) {
    result.add(new Vertex(
      point.x + x,
      point.y + y,
      point.z + z
    ));
  }
  return result;
}

ArrayList<Vertex> scale3D(ArrayList<Vertex> vbo, float scaleFactor) {
  ArrayList<Vertex> result = new ArrayList();
  for(Vertex point : vbo) {
    result.add(new Vertex(
      point.x * scaleFactor,
      point.y * scaleFactor,
      point.z * scaleFactor
    ));
  }
  return result;
}
//End 3D transformation

void setup() {
  size(1270, 720, P3D);
  loadFiles("cube.obj");
  smooth(2); //Lower this into 8, 4, 2 or even disable this instruction if you have performance issue
}

void draw() {
  print("FPS: ");
  println(frameRate);
  background(50);
  translate(width/2, height/2, 0);
  rotateX(camXAng);
  rotateY(camYAng);
  //Put your operation inside this push block
  pushMatrix();
  translate(gridPos.x, gridPos.y, gridPos.z);
  scale(1, -1, 1);
  createGrid(SPACE_DEPTH / zoomFactor, GRID_SIZE * zoomFactor);
  //pointLight(new Color(255, 255, 255), 10, 10, 20);
  drawModel(vbo, vib, new Color(255, 255, 255, 10));
  //drawModel(scale3D(2), vib, new Color(255, 0, 0, 100));
  drawModel(translate3D(scale3D(vbo, 2), 1, 1, 1), vib, new Color(255, 0, 0, 100));
  //---//
  popMatrix();
  translate(pos.x, pos.y, pos.z);
  keyboardControls();
}