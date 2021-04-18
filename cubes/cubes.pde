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
