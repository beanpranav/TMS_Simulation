enum EventType { 
  ALLOCATION, RETRIEVAL, DIRECTORY
}

class Event {
  private int eventID;
  private EventType type;
  private IntList touchIdLogs = new IntList();
  private IntList touchTimeLogs = new IntList();
  private KnowledgeNode eventIdentifier;
  private KnowledgeNode eventScaffold;
  private boolean complete = false;

  public Event(int eventID, EventType type, int identifier, int scaffold) {
    this.eventID = eventID;
    this.type = type;
    switch (type) {
    case DIRECTORY:
      this.eventIdentifier = new KnowledgeNode(identifier, 0, KnowledgeType.DIRECTORY_K, 0);
      this.eventScaffold = new KnowledgeNode(scaffold, 1, KnowledgeType.THEORY_K, 0);
      break; 
    case RETRIEVAL:
      this.eventIdentifier = new KnowledgeNode(identifier, 0, KnowledgeType.PRACTICAL_K, 1);
      this.eventScaffold = new KnowledgeNode(scaffold, 1, KnowledgeType.THEORY_K, 0);
      break;
    default: //ALLOCATION
      this.eventIdentifier = new KnowledgeNode(identifier, 0, KnowledgeType.THEORY_K, 1);
      this.eventScaffold = new KnowledgeNode(scaffold, 1, KnowledgeType.THEORY_K, 1);
    }
  }

  int getEventID() {
    return eventID;
  }
  
  EventType getEventType() {
    return type;
  }

  int getEventIdentifierID() {
    return eventIdentifier.id();
  }
  
  void setEventIdentifier(KnowledgeNode identifier) {
    eventIdentifier = identifier;
  }
  
  int getEventScaffoldID() {
    return eventScaffold.id();
  }
  
  void setEventScaffold(KnowledgeNode scaffold) {
    eventScaffold = scaffold;
  }
  
  boolean getCompletionStatus() {
    return complete;
  }
  
  void markEventAsComplete() {
    complete = true;
  }
  

  //----------------------------------------
  // Logging functions
  //----------------------------------------

  void logTouchID(int memberID) {
    touchIdLogs.append(memberID);
    touchTimeLogs.append(TIME);
  }
  
  boolean searchTouchIdLogs(int memberID) {
    int count = 0;
    for (Integer mID : touchIdLogs) {
      if (mID == memberID) {
        count += 1;
      }
    }
    if (count > 1) {
      //println(".. .. .. have worked on event (" + getEventID() + ") before");
      return true;
    } else {
      //println(".. .. .. seeing event (" + getEventID() + ") for the first time");
      return false;
    }
  }
  

  //----------------------------------------
  // Draw function 
  //----------------------------------------

  public void drawEvent() {
    pushStyle();
    pushMatrix();
    translate(-1 * (2 * TASK_NODE_SIZE), 5);
    noStroke();
    int r, g, b;
    // set color based on EventType
    switch (type) {
    case DIRECTORY:
      r = BLUE[0];
      g = BLUE[1];
      b = BLUE[2];
      break; 
    case RETRIEVAL:
      r = YELLOW[0];
      g = YELLOW[1];
      b = YELLOW[2];
      break;
    case ALLOCATION:
      r = GREEN[0];
      g = GREEN[1];
      b = GREEN[2];
      break;
    default:
      r = 167;
      g = 167;
      b = 167;
    }
    fill(r,g,b);
    rect(0, 0, 2 * TASK_NODE_SIZE, TASK_NODE_SIZE); 
    fill(0);
    textSize(11);
    textAlign(CENTER);
    text(eventIdentifier.id(), TASK_NODE_SIZE * 0.5, TASK_NODE_SIZE * 0.5 + 5);

    translate(TASK_NODE_SIZE * 0.4, TASK_NODE_SIZE * 0.5);
    noStroke();
    fill(BG_COLOR);
    ellipse(eventScaffold.xf(), eventScaffold.yf(), TASK_NODE_SIZE * 0.75, TASK_NODE_SIZE * 0.75);
    if (eventScaffold.hasKnowledge() == 0) {
      fill(BG_COLOR);
    } else {
      fill(GREEN[0], GREEN[1], GREEN[2]);
    }
    ellipse(eventScaffold.xf(), eventScaffold.yf(), TASK_NODE_SIZE * 0.65, TASK_NODE_SIZE * 0.65);
    if (TASK_NODE_SIZE >= 30) {
      fill(0);
      textSize(11);
      textAlign(CENTER);
      text((eventScaffold.id()), eventScaffold.xf() - 1, eventScaffold.yf() + 4);
    }
    popMatrix();
    popStyle();
  }
}