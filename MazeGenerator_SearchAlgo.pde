//global variables
int cols;
int rows;
int size = 20;
Block[][] blocks;

//global variables for maze
Block currentMazeBlock;
ArrayList<Block> mazeStack = new ArrayList<Block>();
boolean isMazeFinished = false;

//global variables for search algorithm
Block currentSearchBlock;
Block startSearchBlock;
Block finishSearchBlock;
ArrayList<Block> actualPath = new ArrayList<Block>();
ArrayList<Block> searchedPath = new ArrayList<Block>();
boolean searchNeighborsAdded = false;
ArrayList<Block> openSet = new ArrayList<Block>();
boolean pathFound = false;


void setup() {
  size(600, 600);
  rows = floor(height / size);
  cols = floor(width / size);
  blocks = new Block[rows][cols];

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      blocks[i][j] = new Block(i, j);
    }
  }

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      blocks[i][j].addNeighbors();
    }
  }

  currentMazeBlock = blocks[0][0];
  currentMazeBlock.visitedByMaze = true;

  startSearchBlock = blocks[0][0];
  finishSearchBlock = blocks[parseInt(random(0, rows - 1))][cols - 1];

  frameRate(60);
}


void draw() {

  if (!isMazeFinished) { //Maze Generator Here
    background(0, 255, 255);
    //background(0);
    strokeWeight(4);
    stroke(255, 255, 0);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        blocks[i][j].show();
      }
    }

    fill(193, 50, 193);
    rect(currentMazeBlock.x, currentMazeBlock.y, size, size);

    if (currentMazeBlock.hasUnvisitedNeightbors()) {
      Block nextCurrent = currentMazeBlock.pickRandomNeighbor();
      mazeStack.add(currentMazeBlock);
      removeWalls(currentMazeBlock, nextCurrent);
      currentMazeBlock = nextCurrent;
    } else if (mazeStack.size() > 0) {
      Block nextCurrent = mazeStack.get(mazeStack.size() - 1);
      mazeStack.remove(nextCurrent);
      currentMazeBlock = nextCurrent;
    } else {
      print("\n\n*************************\n");
      print("Maze Finsihed!");
      isMazeFinished = true;
    }
  } else {
    startSearchBlock.makeRect(255, 0, 0);
    finishSearchBlock.makeRect(255, 0, 0);
    //A* Search Algorithm Here
    if (!searchNeighborsAdded) { //Add neighbors only once
      print("\n\n\n************* Entring A* Search Algorithm *************\n");
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          print("\nAdding Neighbor for (" + i + ", " + j + ")\n");
          blocks[i][j].addMazeNeighbors();
        }
      }
      searchNeighborsAdded = true;
      //frameRate(1);
      print("All neighbors added\n\n");
      //Any inital setup before starting search algorithm.
      startSearchBlock.g = 0;
      startSearchBlock.f = heuristic(startSearchBlock, finishSearchBlock);
      openSet.add(startSearchBlock);
      print("Starting search\n");
    }
    if (openSet.size() > 0) { //runs until reaches a decision
      currentSearchBlock = lowestFinOpenSet();
      //currentSearchBlock.makeRect(255, 255, 255);
      if (currentSearchBlock == finishSearchBlock) {
        print("Path Found! Getting path.\n");
        pathFound = true;
        reconstructActualPath();
        for (int i = 0; i < actualPath.size() - 1; i++) {
          actualPath.get(i).makeLine(actualPath.get(i + 1), 255, 0, 0);
        }
        startSearchBlock.makeRect(0, 255, 0);
        finishSearchBlock.makeRect(0, 255, 0);
        print("Path printed. Stopping loop\n");
        noLoop();
      }
      if (!pathFound) {
        openSet.remove(currentSearchBlock);
        for (Block ngbr : currentSearchBlock.mazeNeighbors) {
          float tent_gScore = currentSearchBlock.g + 1;
          if (tent_gScore < ngbr.g) {
            ngbr.prev = currentSearchBlock;
            ngbr.g = tent_gScore;
            ngbr.f = ngbr.g + heuristic(ngbr, finishSearchBlock);
            if (!openSet.contains(ngbr)) {
              openSet.add(ngbr);
            }
          }
        }
        reconstructSearchPath();
        for (Block block : searchedPath) {
          block.makeRect(255, 255, 0);
        }
        startSearchBlock.makeRect(0, 255, 0);
        finishSearchBlock.makeRect(0, 255, 0);
      }
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          blocks[i][j].show();
        }
      }
    } else if (pathFound) {
      print("No Path Found");
      noLoop();
    }
  }
}


void removeWalls(Block current, Block next) {
  int xDistance = current.thisRow - next.thisRow;
  int yDistance = current.thisCol - next.thisCol;

  print("X Distance: " + xDistance + "\n");
  print("Y Distance: " + yDistance + "\n");

  if (xDistance == -1) {
    current.walls[1] = false;
    next.walls[3] = false;
  } else if (xDistance == 1) {
    current.walls[3] = false;
    next.walls[1] = false;
  }

  if (yDistance == -1) {
    current.walls[2] = false;
    next.walls[0] = false;
  } else if (yDistance == 1) {
    current.walls[0] = false;
    next.walls[2] = false;
  }
}


ArrayList reconstructSearchPath() {
  Block current = currentSearchBlock;
  searchedPath.add(current);
  while (current != startSearchBlock) {
    searchedPath.add(current);
    current = current.prev;
  }
  return searchedPath;
}

ArrayList reconstructActualPath() {
  Block current = currentSearchBlock;
  actualPath.add(current);
  while (current != startSearchBlock) {
    actualPath.add(current);
    current = current.prev;
  }
  print("Path reconstructed, returning path\n");
  return actualPath;
}

float heuristic(Block from, Block to) {
  float distance = 0.0;
  distance = dist(from.thisRow, from.thisCol, to.thisRow, to.thisCol);
  return distance;
}

Block lowestFinOpenSet() {
  Block lowestFScore = openSet.get(0);
  for (Block block : openSet) {
    if (block.f < lowestFScore.f) {
      lowestFScore = block;
    }
  }
  return lowestFScore;
}
