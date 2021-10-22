class Pendulo {
  float dx, dy, dir, vel, largo, v;
  Pendulo() {
    tope = new FBox(5, 5);
    duend= new FBox(60,45);
    cadena= new FDistanceJoint(tope, duend);
    dx=width/2;
    dy=0;
    largo=250;
    v=100;
    
    
  }
  void Dibujar() {
    
    tope.setStatic(true);
    tope.setNoFill();
    tope.setNoStroke();
    tope.setPosition(width/2, 0);
    mundo.add(tope);
    duend.setPosition(dx, dy);
    duend.setRotatable(false);
    duend.attachImage(imagen_duende);
    //duend.setName("duende");
    mundo.add(duend);
    cadena.setLength(largo);
    mundo.add(cadena);
  }
  void Accion() {

    dx= duend.getX();
    dy= duend.getY();
    //if (mouseX<width/2) {
    //  v= - 100;
    //}
    //if (mouseX>width/2) {
    //  v= 100;
    //}
    duend.addForce(dx*v, dy);
    //if (mousePressed) {
    //  sosten=true;
    //} else {
    //  sosten=false;
    //}
  }
}
