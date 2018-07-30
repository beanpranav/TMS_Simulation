enum KnowledgeType { 
  THEORY_K, PRACTICAL_K, DIRECTORY_K
}

class KnowledgeNode extends GraphNode {
  private int[] location = new int[3]; // location(domainNo, domainBreadthLocation, domainHeightLocation)
  private KnowledgeType type;
  private int isAware = 0;
  private int hasKnowledge = 0;
  private int lastAccessed = 0;


  //----------------------------------------
  // Constructors
  //----------------------------------------
  
  // constructor for initializing long term memory with THEORY_K nodes
  public KnowledgeNode(int[] location) {
    super(location[0] * 100 + location[1] * 10 + location[2], 
      (location[0]-1) * (NODE_SIZE * 2) + (location[1]) * (NODE_SIZE * 2), 
      //(location[0]) % 2 * NODE_SIZE + (NODE_HEIGHT_OFFSET - location[2]) * (NODE_SIZE * 2), //staggered view
      (NODE_HEIGHT_OFFSET - (location[2]-1)) * (NODE_SIZE * 2), // overlapping view
      0);
    this.location = location;
    this.type = KnowledgeType.THEORY_K;
  }

  // constructor for creating PRACTICAL_K and DIRECTORY_K nodes
  public KnowledgeNode(int id, KnowledgeType type) {
    super(id, 
      (id % 10 - 1) * (NODE_SIZE * 2),
      (NODE_HEIGHT_OFFSET + 2 + id / 10) * (NODE_SIZE * 2), 
      0);
    this.location = new int[] {0, id / 10, id % 10};
    this.type = type;
    this.isAware = 1;
    this.hasKnowledge = 1;
    this.lastAccessed = TIME;
  }

  // constructor for creating event requirements
  public KnowledgeNode(int id, int location, KnowledgeType type, int knowledgeStatus) {
    super(id, location * TASK_NODE_SIZE, 0, 0);
    this.location = new int[] {location, 0, 0};
    this.type = type;
    this.isAware = 1;
    this.hasKnowledge = knowledgeStatus;
    this.lastAccessed = TIME;
  }


  //----------------------------------------
  // Getter and Setter functions 
  //----------------------------------------

  KnowledgeType getKnowledgeType() {
    return type;
  }

  int isAware() {
    return isAware;
  }

  void setAwareness() {
    this.isAware = 1;
  }

  int hasKnowledge() {
    return hasKnowledge;
  }

  void setKnowledge() {
    this.hasKnowledge = 1;
    this.lastAccessed = TIME;
  }
  
  void unsetKnowledge() {
    this.hasKnowledge = 0;
    this.lastAccessed = TIME;
  }
  
  int getLastAccessed() {
    return lastAccessed;
  }
  
  void resetLastAccessed() {
    this.lastAccessed = TIME;
  }
}