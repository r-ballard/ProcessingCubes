import ddf.minim.*;
import ddf.minim.analysis.*;
 
Minim minim;
AudioPlayer song;
FFT fft;


String song_path = 'SONG PATH';

// Variables qui définissent les "zones" du spectre
// Variables which define the "zones" of the spectrum
// Par exemple, pour les basses, on prend seulement les premières 4% du spectre total
// For example, for bass, we only take the first 4% of the total spectrum
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

// Il reste donc 64% du spectre possible qui ne sera pas utilisé. 
// So 64% of the possible spectrum remains that will not be used.
// Ces valeurs sont généralement trop hautes pour l'oreille humaine de toute facon.
// These values ​​are generally too high for the human ear anyway.

// Valeurs de score pour chaque zone
// Score values ​​for each zone
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

// Valeur précédentes, pour adoucir la reduction
// Previous value, to soften the reduction
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

// Valeur d'adoucissement
// Softening value
float scoreDecreaseRate = 25;

// Cubes qui apparaissent dans l'espace
// Cubes that appear in space
int nbCubes;
Cube[] cubes;

//Lignes qui apparaissent sur les cotés
// Lines that appear on the sides
int nbMurs = 500;
Mur[] murs;
 
void setup()
{
  //Faire afficher en 3D sur tout l'écran
  // Display in 3D on the whole screen
  fullScreen(P3D);
 
  //Charger la librairie minim
  // Load the minim library
  minim = new Minim(this);
 
  //Charger la chanson
  // Load the song
  song = minim.loadFile(song_path);
  
  //Créer l'objet FFT pour analyser la chanson
  // Create the FFT object to analyze the song
  fft = new FFT(song.bufferSize(), song.sampleRate());
  
  //Un cube par bande de fréquence
  // One cube per frequency band
  nbCubes = (int)(fft.specSize()*specHi);
  cubes = new Cube[nbCubes];
  
  //Autant de murs qu'on veux
  // As many walls as we want
  murs = new Mur[nbMurs];

  //Créer tous les objets
  // Create all the objects
  //Créer les objets cubes
  // Create the cube objects
  for (int i = 0; i < nbCubes; i++) {
   cubes[i] = new Cube(); 
  }
  
  //Créer les objets murs
  // Create the wall objects
  //Murs gauches
  // Left walls
  for (int i = 0; i < nbMurs; i+=4) {
   murs[i] = new Mur(0, height/2, 10, height); 
  }
  
  //Murs droits
  // Straight walls
  for (int i = 1; i < nbMurs; i+=4) {
   murs[i] = new Mur(width, height/2, 10, height); 
  }
  
  //Murs bas
  // Low walls
  for (int i = 2; i < nbMurs; i+=4) {
   murs[i] = new Mur(width/2, height, width, 10); 
  }
  
  //Murs haut
  // High walls
  for (int i = 3; i < nbMurs; i+=4) {
   murs[i] = new Mur(width/2, 0, width, 10); 
  }
  
  //Fond noir
  //Black background
  background(0);
  
  //Commencer la chanson
  // Start the song
  song.play(0);
}
 
void draw()
{
  //Faire avancer la chanson. On draw() pour chaque "frame" de la chanson...
  // Advance the song. We draw () for each "frame" of the song
  fft.forward(song.mix);
  
  //Calcul des "scores" (puissance) pour trois catégories de son
  // Calculation of the "scores" (power) for three categories of sound
  //D'abord, sauvgarder les anciennes valeurs
  // First, save the old values
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
  //Réinitialiser les valeurs
  // Reset the values
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
 
  //Calculer les nouveaux "scores"
  // Calculate the new "scores"
  for(int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }
  
  //Faire ralentir la descente.
  // Slow down the descent.
  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }
  
  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }
  
  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }
  
  //Volume pour toutes les fréquences à ce moment, avec les sons plus haut plus importants.
  // Volume for all frequencies at this time, with higher sounds more prominent.
  //Cela permet à l'animation d'aller plus vite pour les sons plus aigus, qu'on remarque plus
  // This allows the animation to go faster for higher pitched sounds, which are more noticeable
  float scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;
  
  //Couleur subtile de background
  // Subtle background color
  background(scoreLow/100, scoreMid/100, scoreHi/100);
   
  //Cube pour chaque bande de fréquence
  // Cube for each frequency band
  for(int i = 0; i < nbCubes; i++)
  {
    //Valeur de la bande de fréquence
    // Value of the frequency band
    float bandValue = fft.getBand(i);
    
    //La couleur est représentée ainsi: rouge pour les basses, vert pour les sons moyens et bleu pour les hautes. 
    // The color is represented as: red for bass, green for mid-range and blue for high.
    //L'opacité est déterminée par le volume de la bande et le volume global.
    // The opacity is determined by the tape volume and the overall volume.
    cubes[i].display(scoreLow, scoreMid, scoreHi, bandValue, scoreGlobal);
  }
  
  //Murs lignes, ici il faut garder la valeur de la bande précédent et la suivante pour les connecter ensemble
  // Line walls, here you have to keep the value of the previous strip and the next one to connect them together
  float previousBandValue = fft.getBand(0);
  
  //Distance entre chaque point de ligne, négatif car sur la dimension z
  // Distance between each line point, negative because on dimension z
  float dist = -25;
  
  //Multiplier la hauteur par cette constante
  // Multiply the height by this constant
  float heightMult = 2;
  
  //Pour chaque bande
  // For each band
  for(int i = 1; i < fft.specSize(); i++)
  {
    //Valeur de la bande de fréquence, on multiplie les bandes plus loins pour qu'elles soient plus visibles.
    // Value of the frequency band, we multiply the bands further away so that they are more visible.
    float bandValue = fft.getBand(i)*(1 + (i/50));
    
    //Selection de la couleur en fonction des forces des différents types de sons
    // Selection of the color according to the strengths of the different types of sounds
    stroke(100+scoreLow, 100+scoreMid, 100+scoreHi, 255-i);
    strokeWeight(1 + (scoreGlobal/100));
    
    //ligne inferieure gauche
    // lower left line
    line(0, height-(previousBandValue*heightMult), dist*(i-1), 0, height-(bandValue*heightMult), dist*i);
    line((previousBandValue*heightMult), height, dist*(i-1), (bandValue*heightMult), height, dist*i);
    line(0, height-(previousBandValue*heightMult), dist*(i-1), (bandValue*heightMult), height, dist*i);
    
    //ligne superieure gauche
    // top left line
    line(0, (previousBandValue*heightMult), dist*(i-1), 0, (bandValue*heightMult), dist*i);
    line((previousBandValue*heightMult), 0, dist*(i-1), (bandValue*heightMult), 0, dist*i);
    line(0, (previousBandValue*heightMult), dist*(i-1), (bandValue*heightMult), 0, dist*i);
    
    //ligne inferieure droite
    // lower right line
    line(width, height-(previousBandValue*heightMult), dist*(i-1), width, height-(bandValue*heightMult), dist*i);
    line(width-(previousBandValue*heightMult), height, dist*(i-1), width-(bandValue*heightMult), height, dist*i);
    line(width, height-(previousBandValue*heightMult), dist*(i-1), width-(bandValue*heightMult), height, dist*i);
    
    //ligne superieure droite
    // upper right line
    line(width, (previousBandValue*heightMult), dist*(i-1), width, (bandValue*heightMult), dist*i);
    line(width-(previousBandValue*heightMult), 0, dist*(i-1), width-(bandValue*heightMult), 0, dist*i);
    line(width, (previousBandValue*heightMult), dist*(i-1), width-(bandValue*heightMult), 0, dist*i);
    
    //Sauvegarder la valeur pour le prochain tour de boucle
    // Save the value for the next loop round
    previousBandValue = bandValue;
  }
  
  //Murs rectangles
  // Rectangular walls
  for(int i = 0; i < nbMurs; i++)
  {
    //On assigne à chaque mur une bande, et on lui envoie sa force.
    // We assign each wall a band, and we send its strength to it.
    float intensity = fft.getBand(i%((int)(fft.specSize()*specHi)));
    murs[i].display(scoreLow, scoreMid, scoreHi, intensity, scoreGlobal);
  }
}

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