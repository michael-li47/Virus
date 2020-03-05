import java.util.Random;

// Initializes global variables
int n = 100; // Number of cells
float blinksPerSecond = 10;
float padding = 50;

int[][] cells, cellsNext;
float cellSize;

Random r = new Random();

void setup(){
  size(1000,1000);  
  frameRate( blinksPerSecond );
  stroke(255,0,0);
  
  cellSize = (width-2*padding)/n;
  
  // Initializes cell arrays
  cells = new int[n][n];
  cellsNext = new int[n][n];
  
  // Assigns random integers from 0-3 to the cells 
  setCellValuesRandomly();
}

void draw() {
    background(0,0,255);
    noStroke();
    
    float y = padding;
    
    // for all cells in the grid...
    for(int i=0; i<n; i++) {
      for(int j=0; j<n; j++) {
        float x = padding + j*cellSize;
        
        if (cells[i][j] == 1) // Virions are black
          fill(0);
         
        else if (cells[i][j] == 2) // Healthy bacteria are orange
          fill(255,165,0);
          
        else if (cells[i][j] == 3) // Infected bacteria are purple
          fill(139,0,139);
          
        else // Empty cells are white
          fill(255);
          
        rect(x, y, cellSize, cellSize);
      }
      y += cellSize;
    }
    
    setNextGeneration();
    copyNextGenerationToCurrentGeneration();
}

void setNextGeneration() {
  int num = aliveCells(); // Number of active cells on the grid
  
  if(num <= 0) // If there are no active cells in the grid, end the program
    System.exit(0);
  
  //Procedures
  randomCellDeath();
  checkCellSurroundings();
  move();
  lyticCycle();
}

void randomCellDeath() {
  
  // for all cells in the grid...
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      
      if (cellsNext[i][j] > 0) { // if the cell is active
        int rand = r.nextInt(1000); // choose a random # between 0 and 1000
        
        // if rand comes out to be less than 5, the cell dies and is set to 0
        if (rand < 5) {
          cellsNext[i][j] = 0;
        }
      }
    }
  }
}

void checkCellSurroundings() {
  
  // for all cells in the grid...
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      
      if (cells[i][j] > 0) { // if the cell is active
        
        int emptyCells = countEmptySurroundingCells(i,j);
        int aliveNeighbours = countAliveNeighbours(i,j);
        
        // if the cell is a virus, check for any neighbouring bacteria
        if (cells[i][j] == 1)
          checkForBacteriaAroundVirus(i,j);
        
        // if the cell is surrounded with nowhere to move, it dies and is set to 0
        if (emptyCells == 0)
          cellsNext[i][j] = 0;
         
        // if the cell is has more than 3 neighbours, it dies and is set to 0
        if (aliveNeighbours > 3) 
          cellsNext[i][j] = 0;
      }
    }
  }
}

void checkForBacteriaAroundVirus(int i,int j) {
  
  // for all cells in a 3x3 grid around the original...
  for(int a = -1; a <= 1; a++) {
    for(int b = -1; b <= 1; b++) {
      
      // to catch index out of bounds error
      try {
        
        // if the neighbouring cell is a healthy bacteria and not itself
        if (cells[i+a][j+b] == 2 && !(a==0 && b==0)) {
          cellsNext[i+a][j+b] = 3; // the bacteria is now infected, so set it to 3
          cellsNext[i][j] = 0; // the virion dies and is set to 0
          break;
        }
      }
      catch( IndexOutOfBoundsException e ) {}
    }
  }
}

void move() {
  int num = aliveCells();
  int d = num; // d will be used to find the cell that will divide this generation
  
  if(num <= 0) // If there are no active cells in the grid, end the program
    System.exit(0);
    
  int randIndex = r.nextInt(num); // generate random index of the cell that will divide this generation
  
  // for all cells in the grid...
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      
      if (cellsNext[i][j] > 0) {
        boolean foundEmptyCell = false;
          d--; // decrease d everytime an active cell is found
          
          // while an empty cell has not been found where the active cell can move, repeat the process
          while (!foundEmptyCell) {
            
            // generate random position in a one cell radius of the active cell
            int x = (r.nextInt(1 + 1 + 1) - 1) + i;
            int y = (r.nextInt(1 + 1 + 1) - 1) + j;
            
            // if the new position is within the bounds of the grid and empty, continue
            if (0 <= x && x < n && 0 <= y && y < n  && cellsNext[x][y] == 0) {
              
              //if the 
              //if (cells[x][y] == 0 && !(x==0 && y==0)); {
              cellsNext[x][y] = cellsNext[i][j]; // set the new cell equal to the value of the original (1,2, or 3)
              
              if (randIndex == d && cellsNext[i][j] != 1){} // if the cell is a bacteria and it coresponds
                                                            // to the chosen bacteria index, don't kill the original
              
              else {
                cellsNext[i][j] = 0; // otherwise, kill the original
              }
              
              foundEmptyCell = true; // break the loop
            
          }
        }
      }
    }
  }
}
    
void lyticCycle() {
  
  // for all cells in the grid...
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      
      // if the cell is an infected bacterium
      if(cellsNext[i][j] == 3) {
        int x = r.nextInt(100); // set x to a random number between 0 and 100
        
        // if x == 1, kill the bacterium and draw the new virions around it
        if(x == 1) {
          cellsNext[i][j] = 0;
          drawProgenyVirions(i,j);
        }
      }
    }
  }
}

void drawProgenyVirions(int i, int j) {
  int emptyCells = countEmptySurroundingCells(i,j);
  int numVirions = r.nextInt(emptyCells);
  
  // for all cells in a 3x3 grid around the original...
  for(int a = -1; a <= 1; a++) {
    for(int b = -1; b <= 1; b++) {
      
      try {
        // if the new cell is empty...
        if (cells[i+a][j+b] == 0 && !(a==0 && b==0)) {
          cellsNext[i+a][j+b] = 1; // set the chosen cell to 1, to turn it into a virus
          numVirions--; // decrease number of virions left to draw
          
          if(numVirions <= 0) // if all virions have been drawn, break the loop
            break;
        }
      }
      
      catch( IndexOutOfBoundsException e ) {
      }
    }
  }
}

// Copies cellsNext to cells
void copyNextGenerationToCurrentGeneration() {
    for(int i=0; i<n; i++) {
      for(int j=0; j<n; j++) 
        cells[i][j] = cellsNext[i][j];
    }
}

//Sets random values for every cell
void setCellValuesRandomly() {
  
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {      
      int x = r.nextInt(10000); // x is a random number between 0 and 10000
      
      // if x is between 1 and 5, set the cell to be a virus(1)
      if (1 <= x && x <= 5) {
        cells[i][j] = 1;
        cellsNext[i][j] = 1;
      }
      
      // if x is between 50 and 100, set the cell to be a bacterium(2)
      else if (50 <= x && x <= 100) {
        cells[i][j] = 2;
        cellsNext[i][j] = 2;
      }
      
      // otherwise, set the cell to be empty(0)
      else {
        cells[i][j] = 0;
        cellsNext[i][j] = 0;
      }
    }
  }
}

// COUNTING PROCEDURES
// Number of empty neighbouring cells
int countEmptySurroundingCells(int i,int j) {
  int count = 0;
  
  for(int a = -1; a <= 1; a++) {
    for(int b = -1; b <= 1; b++) {
      try {
        if (cells[i+a][j+b] == 0 && !(a==0 && b==0))
          count++;              
      }   
      catch( IndexOutOfBoundsException e ) {
      }
    }
  }
  return count;
}

// Number of active neighbouring cells
int countAliveNeighbours(int i,int j) {
  int count = 0;
  
  for(int a = -1; a <= 1; a++) {
    for(int b = -1; b <= 1; b++) {
      
      try {
        if (cells[i+a][j+b] > 0 && !(a==0 && b==0))
          count++;               
      }
      
      catch( IndexOutOfBoundsException e ) {
      }
    }
  }
  return count;
}

// Total number of active cells
int aliveCells() {
  int count = 0;
  
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {
      if(cellsNext[i][j] > 0)
        count++;
    }
  }
  return count;
}

// Number of virions
int countViruses() {
  int count = 0;
  for(int i=0; i<n; i++) {
    for(int j=0; j<n; j++) {     
      if (cells[i][j] == 1)
       count++;
    }
  }
  return count;
}