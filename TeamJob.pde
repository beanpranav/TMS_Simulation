enum JobType { 
  REPEATING, NON_REPEATING
}

class TeamJob {
  //private int jobID;
  private JobType type;
  private int[] difficulty_level;
  private int complexity_level;
  private ArrayList<Task> taskList;
  private ArrayList<Event> infoList;

  public TeamJob(JobType type, int[] difficulty_level, int complexity_level) {
    //this.jobID = jobID;
    this.type = type;
    this.difficulty_level = difficulty_level;
    this.complexity_level = complexity_level;
    this.taskList = new ArrayList<Task>(JOB_SIZE);
    this.infoList = new ArrayList<Event>(JOB_SIZE * complexity_level);
  }
  
  void initializeJob() {
    Graph allKnowledge = initializeAllKnowledge();
    Task task = new Task(11, allKnowledge, difficulty_level, complexity_level);
    taskList.add(task);
    
    // add tasks to job based on task-type
    for (int i = 1; i < JOB_SIZE; i++) {
      if (type == JobType.NON_REPEATING) {
        Task distinctTask = new Task((i/5)*10 + (i%5) + 11, allKnowledge, difficulty_level, complexity_level);
        taskList.add(distinctTask);
      } else {
        taskList.add(task);
      }
    }
    
    // create allocation events
    if(CREATE_ALLOCATION) {
      int subtaskID = 1;
      for (int i = 0; i < JOB_SIZE; i++) {
        int[] knowledgeIDs = taskList.get(i).getKnowledgeIDs();
        for (int j = 0; j < complexity_level; j++) {
          infoList.add(new Event(subtaskID, EventType.ALLOCATION, getKnowledgeScoffold(allKnowledge, knowledgeIDs[j]), knowledgeIDs[j]));
          subtaskID++;
        }
      }
    }
  }
  
  int getTaskCount() {
    return taskList.size();
  }
  
  int getInfoCount() {
    return infoList.size();
  }
  
  Task getCurrentTask() {
    Task currentTask = taskList.get(0);
    taskList.remove(0);
    return currentTask; 
  }
  
  Event getCurrentInfo() {
    Event currentInfo = infoList.get(0);
    infoList.remove(0);
    return currentInfo; 
  }
  
  JobType getJobType() {
    return type;
  }



  //----------------------------------------
  // Knowledge graph functions 
  //----------------------------------------
    
  Graph initializeAllKnowledge() {
    Graph allKnowledge = new GraphExtended(NO_OF_DOMAINS * DOMAIN_HEIGHT);
    // initialize all THEORY_K nodes
    for (int i = 1; i <= NO_OF_DOMAINS; i++) {
      for (int k = 1; k <= DOMAIN_HEIGHT; k++) {
        GraphNode n = new KnowledgeNode(new int[] {i, 0, k}); 
        allKnowledge.addNode(n);
        ((KnowledgeNode)n).setAwareness();
        ((KnowledgeNode)n).setKnowledge();
      }
    }

    // initialize THEORY_K graph structure
    for (int i = 1; i <= NO_OF_DOMAINS; i++) {
      for (int k = 1; k <= DOMAIN_HEIGHT; k++) {
        int fromN = i * 100 + k;
        // all THEORY_K are connected to the next higher node
        if (k < DOMAIN_HEIGHT) { 
          int toNk = i * 100 + (k+1);
          allKnowledge.addEdge(fromN, toNk, MAX_EDGE_WT, MAX_EDGE_WT);
        }
        // first level THEORY_K nodes have inter-domain connections
        if(k == 1) {
          if (i < NO_OF_DOMAINS) {
            int toNi = (i+1) * 100 + 1;
            allKnowledge.addEdge(fromN, toNi, MAX_EDGE_WT, MAX_EDGE_WT);
          } else {
            int toNi = 100 + 1;
            allKnowledge.addEdge(fromN, toNi, MAX_EDGE_WT, MAX_EDGE_WT);
          }
        }
      }
    }
    return allKnowledge;
  }

  int getKnowledgeScoffold(Graph allKnowledge, int knowledgeID) {
    GraphEdge[] knowledgeArray = allKnowledge.getEdgeArray(knowledgeID);
    int scaffoldKnowledgeID = knowledgeID+1;
    while (scaffoldKnowledgeID == (knowledgeID+1)) {
      int rand = int(random(knowledgeArray.length));
      scaffoldKnowledgeID = knowledgeArray[rand].to().id();
    }
    //println(scaffoldKnowledgeID + " --> " + knowledgeID);
    return scaffoldKnowledgeID;
  }
}