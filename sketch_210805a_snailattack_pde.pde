import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import TUIO.*;
import fisica.*;

Minim minim;
AudioPlayer sMusica;
AudioPlayer sPerdiste;
AudioPlayer sGanaste;
AudioSample chew;
AudioSample hop;
AudioSample sonidoCajas;

FWorld mundo;
FCircle duende, caracol;
FMouseJoint cursor;
FBox piso;
FBox [] cajas = new FBox[2];
FCircle [] limite = new FCircle[2];
FBox duend;
FBox tope;
FDistanceJoint cadena;
Pendulo p;
TuioProcessing tuioClient;
float vidaArbol = 5;
Caracol[] caracoles = new Caracol[80];
FMouseJoint[] caracolesJoint = new FMouseJoint[80];
Float[] posEnY = new Float [80];
int identificacion;
int id = 0;
int esteId;

PImage fondo;
PImage imagen_caracol;
PImage imagen_duende;
PImage ganaste;
PImage perdiste;

int mil;
int seg = 0;
int min = 1;
boolean fiducial, hayContacto;

String estado = "";

float altura = 0;
float trans = 300;
int tiempo;

boolean musica = true;

float largoBarra = 330;
float valor = 66;
float f, x, y;
int cont = 0;
float speed = 1;

void setup() {
  size(520, 700);

  minim = new Minim( this );
  sMusica = minim.loadFile("groove1.mp3", 2048);
  sPerdiste = minim.loadFile("smash.mp3", 2048);
  sGanaste = minim.loadFile("sparkles.mp3", 2048);
  chew = minim.loadSample("chew.mp3", 512);
  hop = minim.loadSample("hop.mp3", 512);
  sonidoCajas = minim.loadSample("sonidocajas.mp3", 512);
  if (musica) {
    sMusica.loop();
  } else {
    sMusica.pause();
  }

  estado = "titulo";
  tiempo = 0;

  Fisica.init(this);
  mundo = new FWorld();
  p= new Pendulo();
  rectMode(CENTER);
  fondo = loadImage("bg.jpg");
  imagen_caracol = loadImage("caracolcolcol.png");
  imagen_duende = loadImage("spriteduende.png");
  ganaste = loadImage("ganaste.jpg");
  perdiste = loadImage("perdiste-01.jpg");

  for (int i = 0; i < caracoles.length; i++) {

    caracoles[i] = new Caracol(50);

  }

  mundo.setEdges();
  mundo.setGravity (0, 800);



  for (int i = 0; i < 2; i++ ) {
    cajas[i] = new FBox(80, 60);
    cajas[i].setNoFill();
    cajas[i].setNoStroke();
    cajas[i].setSensor(true);
    cajas[i].setName("caja");
    cajas[i].setStatic(true);

    mundo.add(cajas[i]);
  }
  cajas[0].setPosition(55, height-70);
  cajas[1].setPosition(width-55, height-70);

  for (int i = 0; i < 2; i++ ) {
    limite[i] = new FCircle(300);
    limite[i].setNoFill();
    limite[i].setNoStroke();

    limite[i].setName("limite");
    limite[i].setStatic(true);

    mundo.add(limite[i]);
  }
  limite[0].setPosition(0, 0);
  limite[1].setPosition(width, 0);

  piso = new FBox(330, 20);
  piso.setPosition(width/2, 680);
  piso.setStatic(true);
  piso.setNoFill();
  piso.setNoStroke();
  piso.setName("piso");

  mundo.add(piso);

  

  FBox borde = new FBox(width, 10);
  borde.setPosition(width/2, 0);
  borde.setNoFill();
  borde.setNoStroke();
  borde.setName("borde");
  borde.setStatic(true);
  borde.setGrabbable(false);
  mundo.add(borde);
  tuioClient  = new TuioProcessing(this);
}

void draw() {



  //Diagrama de estados//-----------------------

  if (estado.equals("inicio")) {
    fill(255, trans);
    trans = trans -3;
    image(fondo, 0, altura, width, height*2);
    rect(width/2, height/2, width, height);
    tiempo++;
    if (tiempo >120) {
      estado = "titulo";
      tiempo = 0;
    }
  } else if (estado.equals("titulo")) {
    image(fondo, 0, altura, width, height*2);
    altura= altura -3;
    tiempo++;
    if (tiempo >230) {
      estado = "gameplay";
      tiempo = 0;
    }
  } else if (estado.equals("gameplay")) {


   musica = true;

    pushStyle();

    rectMode(CORNER);
    image(fondo, 0, altura, width, height*2);
    noStroke();
    fill(255, 90);
    rect(100, 25, 350, 30);
    if (vidaArbol >= 4) {
      fill(#FCFC82, 190);
      // fill(255, 0, 0);
    } else if (vidaArbol <=3 && vidaArbol >=2 ) {
      fill(#FCC682, 190);
    } else if (vidaArbol == 1 ) {
      fill(#FC8C82, 190);
    }
    rect(110, 30, largoBarra, 20);

    popStyle();

    if (frameCount == 250) {
      p.Dibujar();
      duend.setName("duende");
    }

    if (frameCount % 300 == 0) {


      x = random( width/2 - 110, width/2 + 120);
      y = height - 60;
      id = id+1;

      caracoles[id].inicializar(x, y);
      caracoles[id].setName ("caracol_"+id);

      caracoles[id].attachImage(imagen_caracol);
      mundo.add(caracoles[id]);

      caracolesJoint[id] = new FMouseJoint(caracoles[id], x, y );
      //caracolesJoint[id].setName ("cadena_"+id);
      mundo.add(caracolesJoint[id]);

      posEnY[id] = y;
    }


    for (int i=0; i<caracolesJoint.length; i++) {

      if (caracolesJoint[i] != null) {

        float xc = caracoles[i].getX();

        posEnY[i]= posEnY[i] - speed;                            // ACÁ SE SETEA LA VELOCIDAD DE SUBIDA DE CARACOLES


        if (hayContacto) {

          
          caracoles[esteId].setDensity(0.000001);
           caracoles[esteId].setRestitution(0.0);


          caracolesJoint[esteId].setTarget(duend.getX()+20, duend.getY()+20);
          caracolesJoint[i].setTarget(xc, posEnY[i] );
        } else {

          mundo.remove(caracolesJoint[esteId]);
          //caracoles[esteId].setVelocity(-0, 90);
          caracoles[esteId].setDensity(100.0);
          // caracoles[esteId].addForce(0, -100);
          caracolesJoint[i].setTarget(xc, posEnY[i] );
          caracoles[i].setRotatable(true);
        }
      }
    }
    


    if ( min != 0 || seg != 0 ) {
      timer();
    } else {
      estado = "ganaste";
      tiempo = 0;
    }
    if (vidaArbol<=0) {
      estado = "perdiste";
      tiempo = 0;
    }
  } else if (estado.equals("ganaste")) {
    //Condicion de victoria
    sGanaste.play();
    //mundo.remove(duend);
    /*for (int i=0; i<40; i++) {
     
     mundo.remove(caracoles[i]);
     mundo.remove(caracolesJoint[i]);
     }*/
    //mundo.remove(cadena);
    pushStyle();
    image(ganaste, 0, 0, width, height);
    popStyle();
    tiempo++;
    if (tiempo >120) {
      estado = "gameplay";
      tiempo = 0;
      reiniciar();
    }
  } else if (estado.equals("perdiste")) {
    musica = false;
    sPerdiste.play();
    mundo.remove(duend);
    mundo.remove(cadena);


    pushStyle();
    image(perdiste, 0, 0, width, height);
    popStyle();

    tiempo++;
    if (tiempo >120) {
      estado = "gameplay";
      tiempo = 0;
      reiniciar();
    }
  }




  p.Accion();
  mundo.step();
  mundo.draw();
}


void timer() {
  int tiempoAnterior = 0;
  int tiempo = millis()/1000;

  if (tiempoAnterior != tiempo) {
    if (mil <= 0) {

      if ( seg <= 0 ) {
        seg = 60;
        min --;
        mil = 60;
      } else {
        seg --;
        mil = 60;
      }

      tiempoAnterior = tiempo;
    } else {
      mil --;
      tiempoAnterior = tiempo;
    }
  }

  pushStyle();
  textSize(28);
  text(min + " : " + seg, 20, 50);
  popStyle();
}

String darNombre (FBody cuerpo ) {
  String nombre = "nada";

  if (cuerpo != null) {
    String esteNombre = cuerpo.getName();
    if (esteNombre != null) {
      nombre = esteNombre;
    }
  }

  return nombre;
}

void contactStarted(FContact datosColision) {
  FBody cuerpo1 = datosColision.getBody1();
  FBody cuerpo2 = datosColision.getBody2();



  for (int i=0; i<caracolesJoint.length; i++) {

    if ( darNombre( cuerpo1 ).equals("caja") && darNombre( cuerpo2 ).equals("caracol_"+i)
      || darNombre (cuerpo1).equals("caja") && darNombre (cuerpo2).equals("cBox"+i) ) {
      mundo.remove(cuerpo2);
      sonidoCajas.trigger();
    } else
      if (darNombre( cuerpo2 ).equals("caja") && darNombre( cuerpo1 ).equals("caracol_"+i)
        || darNombre (cuerpo2).equals("caja") && darNombre (cuerpo1).equals("cBox"+i) ) {
        mundo.remove(cuerpo1);
        sonidoCajas.trigger();
      }
  }

  for (int i=0; i<caracolesJoint.length; i++) {
    if ( darNombre (cuerpo1).equals("piso") && darNombre (cuerpo2).equals("caracol_"+i)) {
      mundo.remove(cuerpo2);
      
      x = random( width/2 - 110, width/2 + 120);
      y = height - 120;

      id = id+ 1;

      caracoles[id].inicializar(x, y);
      caracoles[id].setName ("caracol_"+id);
      caracoles[id].attachImage(imagen_caracol);
      mundo.add(caracoles[id]);

      caracolesJoint[id] = new FMouseJoint(caracoles[id], x, y );
      //caracolesJoint[id].setName ("cadena_"+id);
      mundo.add(caracolesJoint[id]);

      posEnY[id] = y;
      
    } else if (darNombre( cuerpo2 ).equals("piso") && darNombre( cuerpo1 ).equals("caracol_"+i)) {
      mundo.remove(cuerpo1);
  
      x = random( width/2 - 110, width/2 + 120);
      y = height - 120;

      
      id = id+ 1;

      caracoles[id].inicializar(x, y);
      caracoles[id].setName ("caracol_"+id);
      caracoles[id].attachImage(imagen_caracol);
      mundo.add(caracoles[id]);

      caracolesJoint[id] = new FMouseJoint(caracoles[id], x, y );
      //caracolesJoint[id].setName ("cadena_"+id);
      mundo.add(caracolesJoint[id]);

      posEnY[id] = y;
    
    }
  }

  for (int i=0; i<caracolesJoint.length; i++) {

    if ( darNombre( cuerpo1 ).equals("borde") &&
      darNombre( cuerpo2 ).equals("caracol_"+i) ) {
      mundo.remove(cuerpo2);
      vidaArbol= vidaArbol-1;
      chew.trigger();
      largoBarra = largoBarra - valor;

      
    }
  }
  
  for (int i=0; i<caracolesJoint.length; i++) {


    if (fiducial && darNombre( cuerpo1 ).equals("duende") &&
      darNombre( cuerpo2 ).equals("caracol_"+i) || fiducial &&
      darNombre( cuerpo1 ).equals("caracol_"+i) &&
      darNombre( cuerpo2 ).equals("duende")) {

      
      hayContacto = true;
      esteId = i;
      hop.trigger();



      if (hayContacto) {


        caracolesJoint[i].setTarget(duend.getX(), duend.getY());
       
      }
    }


    else if (fiducial == false  && darNombre( cuerpo1 ).equals("duende") &&
      darNombre( cuerpo2 ).equals("caracol_"+i) || fiducial == false &&
      darNombre( cuerpo1 ).equals("caracol_"+i) &&
      darNombre( cuerpo2 ).equals("duende")) {

      hayContacto = false;

      
    }
  }
  println("hayContacto_"+ hayContacto);
}

void reiniciar() {
  vidaArbol = 5;
  seg = 0;
  min = 1;
  largoBarra = 330;
  id= 0;

  mundo.add(duend);
  mundo.add(cadena);
  for (int i=0; i<caracolesJoint.length; i++) {
    posEnY[i] = y;
  }
}


//-------------------------------------------
void addTuioObject(TuioObject objetoTuio) {
  //if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  identificacion= objetoTuio.getSymbolID();
  //println(objetoTuio.getSymbolID());
}
//-------------------------------------------
void updateTuioObject (TuioObject objetoTuio) {
  //if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
  //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
  identificacion= objetoTuio.getSymbolID();
  //println(objetoTuio.getSymbolID());

  if (identificacion==7) {
    
      if (objetoTuio.getX()*width<width/2) {
        p.v= - 10;
      }
      if (objetoTuio.getX()*width>width/2) {
        p.v= 10;
      }
    

  }
  if (identificacion==8) {
    fiducial=true;
  }
}
//-------------------------------------------
void removeTuioObject(TuioObject objetoTuio) {
  //if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  identificacion= objetoTuio.getSymbolID();
  println(objetoTuio.getSymbolID());
  if (identificacion==8) {
    fiducial=false;
    hayContacto=false;

    /*   for (int i=0; i<caracolesJoint.length; i++) {
     caracoles[i].setRotatable(true);
     }*/
  }
}
// --------------------------------------------------------------
void addTuioCursor(TuioCursor tcur) {
  //if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}
//-------------------------------------------
void updateTuioCursor (TuioCursor tcur) {
  //if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
  //        +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}
//-------------------------------------------
void removeTuioCursor(TuioCursor tcur) {
  //if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}
// --------------------------------------------------------------
void addTuioBlob(TuioBlob tblb) {
  //if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}
//-------------------------------------------
void updateTuioBlob (TuioBlob tblb) {
  //if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
  //        +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}
//-------------------------------------------
void removeTuioBlob(TuioBlob tblb) {
  //if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}
// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  //if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  //if (callback) redraw();
}
