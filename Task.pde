class Task {
  private int taskID;
  private ArrayList<Event> subtaskList;
  private int difficulty_level;
  private int complexity_level;
  private int[] knowledgeIDs;
  private IntList touchIdLogs = new IntList();
  private IntList touchTimeLogs = new IntList();
  private boolean complete = false;
  
  public Task(int taskID, Graph allKnowledge, int[] difficulty_level, int complexity_level) {
    this.taskID = taskID;
    this.subtaskList = new ArrayList<Event>(complexity_level);
    this.difficulty_level = difficulty_level[1];
    this.complexity_level = complexity_level;
    this.knowledgeIDs = getTaskRequirements(allKnowledge, difficulty_level, complexity_level);
    for (int j = 0; j < complexity_level; j++) { 
      subtaskList.add(new Event(j+1, EventType.RETRIEVAL, taskID, knowledgeIDs[j]));
    }
    println(".. Task<" + taskID + ">: " + Arrays.toString(knowledgeIDs));
  }
  
  int getTaskID() {
    return taskID;
  }
  
  int[] getKnowledgeIDs() {
    return knowledgeIDs;
  }
  
  float getTaskDifficulty() {
    return difficulty_level;
  }
  
  int getTaskSize() {
    return complexity_level;
  }
  
  boolean getCompletionStatus() {
    return complete;
  }
  
  void markTaskAsComplete() {
    complete = true;
  }
  
  int[] getSubtaskStatus() {
    int[] status = new int[complexity_level*2];
    for(int i = 0; i < complexity_level; i++) {
      status[2*i] = subtaskList.get(i).getEventScaffoldID();
      status[2*i+1] = subtaskList.get(i).getCompletionStatus() ? 1 : 0;
    }
    return status;
  }

  //----------------------------------------
  // Logging functions
  //----------------------------------------

  void logTouchID(int memberID) {
    touchIdLogs.append(memberID);
    touchTimeLogs.append(TIME);
  }
  
  //----------------------------------------
  // Knowledge graph functions 
  //----------------------------------------
  
  int[] getTaskRequirements(Graph allKnowledge, int[] difficulty_level, int complexity_level) {
    IntList knowledgeIDs = new IntList();
    for (GraphNode n : allKnowledge.getNodeArray()) {
      knowledgeIDs.append(n.id());
    }
    
    int[] answer = new int[complexity_level];
    TASK_LEVELS.shuffle();
    
    for (int i = 0; i < complexity_level; i++) {
      while(answer[i]%10 < difficulty_level[0] || answer[i]%10 > difficulty_level[1] || answer[i]/100 != TASK_LEVELS.get(i)) {
        knowledgeIDs.shuffle();
        answer[i] = knowledgeIDs.get(0);
      }
    }
    return answer;
  }
  
}