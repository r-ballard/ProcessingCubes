//Classe pour les cubes qui flottent dans l'espace
// Class for cubes that float in space
class Cube {
  //Position Z de "spawn" et position Z maximale
  // Z position of "spawn" and maximum Z position
  float startingZ = -10000;
  float maxZ = 1000;
  
  //Valeurs de positions
  // Position values
  float x, y, z;
  float rotX, rotY, rotZ;
  float sumRotX, sumRotY, sumRotZ;
  
  //Constructeur
  // Constructor
  Cube() {
    //Faire apparaitre le cube à un endroit aléatoire
    // Make the cube appear at a random location
    x = random(0, width);
    y = random(0, height);
    z = random(startingZ, maxZ);
    
    //Donner au cube une rotation aléatoire
    // Give the cube a random rotation
    rotX = random(0, 1);
    rotY = random(0, 1);
    rotZ = random(0, 1);
  }
  
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    //Sélection de la couleur, opacité déterminée par l'intensité (volume de la bande)
    // Selection of the color, opacity determined by the intensity (volume of the band)
    color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, intensity*5);
    fill(displayColor, 255);
    
    //Couleur lignes, elles disparaissent avec l'intensité individuelle du cube
    // Color lines, they disappear with the individual intensity of the cube
    color strokeColor = color(255, 150-(20*intensity));
    stroke(strokeColor);
    strokeWeight(1 + (scoreGlobal/300));
    
    //Création d'une matrice de transformation pour effectuer des rotations, agrandissements
    // Creation of a transformation matrix to perform rotations, enlargements
    pushMatrix();
    
    //Déplacement
    //Shifting
    translate(x, y, z);
    
    //Calcul de la rotation en fonction de l'intensité pour le cube
    // Calculate the rotation according to the intensity for the cube
    sumRotX += intensity*(rotX/1000);
    sumRotY += intensity*(rotY/1000);
    sumRotZ += intensity*(rotZ/1000);
    
    //Application de la rotation
    // Apply rotation
    rotateX(sumRotX);
    rotateY(sumRotY);
    rotateZ(sumRotZ);
    
    //Création de la boite, taille variable en fonction de l'intensité pour le cube
    // Creation of the box, variable size according to the intensity for the cube
    box(100+(intensity/2));
    
    //Application de la matrice
    // Apply the matrix
    popMatrix();
    
    //Déplacement Z
    // Displacement Z
    z+= (1+(intensity/5)+(pow((scoreGlobal/150), 2)));
    
    //Replacer la boite à l'arrière lorsqu'elle n'est plus visible
    // Replace the box at the back when it is no longer visible
    if (z >= maxZ) {
      x = random(0, width);
      y = random(0, height);
      z = startingZ;
    }
  }
}


//Classe pour afficher les lignes sur les cotés
// Class to display the lines on the sides
class Mur {
  //Position minimale et maximale Z
  // Minimum and maximum position Z
  float startingZ = -10000;
  float maxZ = 50;
  
  //Valeurs de position
  // Position values
  float x, y, z;
  float sizeX, sizeY;
  
  //Constructeur
  // Constructor
  Mur(float x, float y, float sizeX, float sizeY) {
    //Faire apparaitre la ligne à l'endroit spécifié
    // Make the line appear at the specified location
    this.x = x;
    this.y = y;
    //Profondeur aléatoire
    // Random depth
    this.z = random(startingZ, maxZ);  
    
    //On détermine la taille car les murs au planchers ont une taille différente que ceux sur les côtés
    // We determine the size because the walls on the floors have a different size than those on the sides
    this.sizeX = sizeX;
    this.sizeY = sizeY;
  }
  
  //Fonction d'affichage
  // Display function
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    //Couleur déterminée par les sons bas, moyens et élevé
    // Color determined by low, medium and high sounds
    //Opacité déterminé par le volume global
    // Opacity determined by the overall volume
    color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, scoreGlobal);
    
    //Faire disparaitre les lignes au loin pour donner une illusion de brouillard
    // Make the lines disappear in the distance to give an illusion of fog
    fill(displayColor, ((scoreGlobal-5)/1000)*(255+(z/25)));
    noStroke();
    
    //Première bande, celle qui bouge en fonction de la force
    // First band, the one that moves according to the force
    //Matrice de transformation
    // Transformation matrix
    pushMatrix();
    
    //Déplacement
    //Shifting
    translate(x, y, z);
    
    //Agrandissement
    // Expansion
    if (intensity > 100) intensity = 100;
    scale(sizeX*(intensity/100), sizeY*(intensity/100), 20);
    
    //Création de la "boite"
    // Create the "box"
    box(1);
    popMatrix();
    
    //Deuxième bande, celle qui est toujours de la même taille
    // Second band, the one that is always the same size
    displayColor = color(scoreLow*0.5, scoreMid*0.5, scoreHi*0.5, scoreGlobal);
    fill(displayColor, (scoreGlobal/5000)*(255+(z/25)));
    //Matrice de transformation
    // Transformation matrix
    pushMatrix();
    
    //Déplacement
    //Shifting
    translate(x, y, z);
    
    //Agrandissement
    // Expansion
    scale(sizeX, sizeY, 10);
    
    //Création de la "boite"
    // Create the "box"
    box(1);
    popMatrix();
    
    //Déplacement Z
    // Z displacement
    z+= (pow((scoreGlobal/150), 2));
    if (z >= maxZ) {
      z = startingZ;  
    }
  }
}
