class Caracol extends FCircle {

  float x, y, dir, vel, cx, cy, v;


  Caracol(float ancho_) {

    super(ancho_);
    

    vel = 2;
    dir = 30;
    
    cx=duend.getX();
    cy=duend.getY();
    v=100;
  }

  void inicializar(float x_, float y_) {

    x = x_;
    y = y_;
    
    
    setPosition(x, y);
    setName("caracol");
    //setStatic(true);
    setGrabbable(false);
    setRotatable(false);
    setDensity(100.0);
    setRestitution(0.5);
    
  }

  void Accion() {

    cx= duend.getX();
    cy= duend.getY();
    //if (mouseX<width/2) {
    //  v= - 100;
    //}
    //if (mouseX>width/2) {
    //  v= 100;
    //}
    duend.addForce(cx*v, cy);
    //if (mousePressed) {
    //  sosten=true;
    //} else {
    //  sosten=false;
    //}
  }
}
