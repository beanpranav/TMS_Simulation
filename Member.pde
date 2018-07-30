class Member extends GraphNode { //<>//
  private int id;
  private float x;
  private float y;
  private Memory myMemory;
  private int myMessagesSentCount = 0;
  private int myMessagesRecievedCount = 0;
  private ArrayList<Event> myMessageList;
  private ArrayList<Event> myInfoList;
  private ArrayList<Task> myTaskList;
  
  public Member() {}

  public Member(int id, float[] location, int[] specializationDomain) {
    super(id, 50 + location[0], 50 + location[1], 0);
    Memory myMemory = new Memory();
    myMemory.initializeMemory(id, specializationDomain);
    this.id = id;
    this.x = 50 + location[0];
    this.y = 50 + location[1];
    this.myMemory = myMemory;
    this.myMessageList = new ArrayList<Event>();
    this.myInfoList = new ArrayList<Event>();
    this.myTaskList = new ArrayList<Task>();
  }

  void run() {
    //println("");
    //println("Member <" + id + "> actions:");
    
    clearCurrentEvent();
    
    //STEP 1: Process all messages
    while(getMessageCount() > 0){
      Event currentMessage = getCurrentMessage();
      currentMessage.logTouchID(id);
      //println(".. working on DE (" + currentMessage.getEventID() + ")");
      processDirectoryEvent(currentMessage, t.getMyMembers(getID()));
      removeCurrentMessage();
    }
    
    //STEP 2: Process one info - if no info, get info
    if(getInfoCount() == 0 && jobIn.getInfoCount() > 0 && TIME > INTRO_THRESHOLD) {
      if(getID() == LEADER_ID || TEAM_MANAGEMENT[tm] == "EGALITARIAN") addInfo(jobIn.getCurrentInfo());
      //println(".. info added");
    }
    
    if(getInfoCount() > 0){
      Event currentInfo = getCurrentInfo();
      currentInfo.logTouchID(id);
      //println(".. working on AE (" + currentInfo.getEventID() + ")");
      processAllocationEvent(currentInfo, t.getMyMembers(getID()), t.getAllMembers());
      removeCurrentInfo();
    }
    
    //STEP 3: Process one task - if no task, get task based on MGMT type
    if(getTaskCount() == 0 && jobIn.getTaskCount() > 0 && TIME > INTRO_THRESHOLD) {
      if(getID() == LEADER_ID || TEAM_MANAGEMENT[tm] == "EGALITARIAN") addTask(jobIn.getCurrentTask());
      //println(".. task added");
    }
    
    if(getTaskCount() > 0) {
      Task currentTask = getCurrentTask();
      currentTask.logTouchID(id);
      //println(".. working on Task (" + currentTask.getTaskID() + ")");
      //println(".. Task<" + currentTask.getTaskID() + ">: " + Arrays.toString(currentTask.getSubtaskStatus()));
      
      int taskSize = currentTask.getTaskSize();
      int subtaskIndex = 0;
      boolean stillWorking = true;
      
      while(stillWorking && subtaskIndex < taskSize) {
        Event RE = currentTask.subtaskList.get(subtaskIndex);
        int recieverID = 0;
        if(RE.getCompletionStatus() == false) {
          RE.logTouchID(id);
          //println(".. working on RE (" + RE.getEventID() + ")");
          //println(".. (" + currentTask.getTaskID() + "-" + subtaskIndex + ") " + RE.touchIdLogs.toString());
          recieverID = processRetrievalEvent(RE, t.getMyMembers(getID()), t.getAllMembers());
        }
        if(recieverID > 0) {
          sendTask(currentTask, recieverID, t.getMyMembers(getID()));
          stillWorking = false;
        } else {
          subtaskIndex++;
        }
      }
      if(subtaskIndex == taskSize) {
        currentTask.markTaskAsComplete();
        jobTaskOut.add(currentTask);
      }
      removeCurrentTask();
    }
    
    // DRAW Memory
    drawLongTermMemory();
    //drawShortTermMemory();
  }

  int getID() {
    return id;
  }
  
  void updateMessageSentCount() {
    if(ALLOW_TRANSACTIVE_PROCESS || TIME < INTRO_THRESHOLD) {
      myMessagesSentCount++;
    }
  }
  
  void updateMessageRecievedCount() {
    if(ALLOW_TRANSACTIVE_PROCESS || TIME < INTRO_THRESHOLD) {
      myMessagesRecievedCount++;
    }
  }



  //----------------------------------------
  // directory event processing function 
  //----------------------------------------

  void processDirectoryEvent(Event currentMessage, ArrayList<Member> myMembers) {
    int recieverID = currentMessage.getEventScaffoldID();
    
    if (recieverID <= 10) { // Send Directory event
      KnowledgeNode myKnowledge = myMemory.sampleMyKnowlege(currentMessage.getEventIdentifierID());
      currentMessage.setEventScaffold(myKnowledge);
        
      if (recieverID == 0) { // send to all my connections
        for (Member m : myMembers) {
          if (m.getID() != currentMessage.getEventIdentifierID()) {
            m.addMessage(currentMessage);
            //println(".. SENT DE to Member <" + m.getID() + "|" + currentMessage.getEventIdentifierID() + "-" + currentMessage.getEventScaffoldID() + ">");
            updateMessageSentCount();
          }
        }
      } else { // send to only the person specified
        for (Member m : myMembers) {
          if (m.getID() == recieverID) {
            m.addMessage(currentMessage);
            //println(".. SENT DE to Member <" + m.getID() + "|" + currentMessage.getEventIdentifierID() + "-" + currentMessage.getEventScaffoldID() + ">");
            updateMessageSentCount();
          }
        }
      }
      
    } else { // Recieve Directory Event
    
      if(currentMessage.getEventID() > 0) { // Store edge
        myMemory.storeDirectoryEdge(currentMessage.getEventIdentifierID(), currentMessage.getEventScaffoldID(), false, false);
        //println(".. ENCODING memory with: (" + currentMessage.getEventIdentifierID() + "-" + currentMessage.getEventScaffoldID() + ")");
      } else { // destroy edge
        myMemory.storeDirectoryEdge(currentMessage.getEventIdentifierID(), currentMessage.getEventScaffoldID(), false, true);
        //println(".. DECODING memory with: (" + currentMessage.getEventIdentifierID() + "-" + currentMessage.getEventScaffoldID() + ")");
      }
      updateMessageRecievedCount();
    }
  }


  //----------------------------------------
  // allocation event processing functions 
  //----------------------------------------

  void processAllocationEvent(Event currentInfo, ArrayList<Member> myMembers, ArrayList<Member> allMembers) {
    // can I store it?
    if (currentEventViability(currentInfo)) { 
      //println(".. STORING (" + currentInfo.getEventScaffoldID() + ")");
      allocationEventEncoding(currentInfo);
      currentInfo.setEventScaffold(new KnowledgeNode(currentInfo.getEventScaffoldID(), 1, KnowledgeType.THEORY_K, 0));
      currentInfo.markEventAsComplete();
      for (Member m : myMembers) {
        m.addMessage(new Event(getID(), EventType.DIRECTORY, getID(), currentInfo.getEventScaffoldID()));
        updateMessageSentCount();
        //println(".. REMOVAL DE!");
      }
      jobInfoOut.add(currentInfo);
      
    } else {
      //println(".. .. can't store myself, checking touch logs for event (" + currentInfo.getEventID() + ")");

      // have I seen this before?
      if (currentInfo.searchTouchIdLogs(getID())) {
        // is this easy to store?
        if (allocationEventEase(currentInfo.getEventScaffoldID())) {
         //println(".. STORING (" + currentInfo.getEventScaffoldID() + "), easy!");
         allocationEventEncoding(currentInfo); // store
         currentInfo.setEventScaffold(new KnowledgeNode(currentInfo.getEventScaffoldID(), 1, KnowledgeType.THEORY_K, 0));
         currentInfo.markEventAsComplete();
         jobInfoOut.add(currentInfo);
         
        } else {       
          // NOT easy - Discarded
          // jobInfoOut.add(currentInfo);
          // NOT easy - send randomly to a team member
          randomlySendAllocationEvent(currentInfo, myMembers);
        }
      } else {
        //println(".. .. don't know (" + currentInfo.getEventID() + "), looking for someone who might");

        // who can store it?
        if (currentEventCandidacy(currentInfo, myMembers, allMembers) > 0) {
          // send and update (implemented in above function)
          
        } else {       
          // send randomly to a team member
          randomlySendAllocationEvent(currentInfo, myMembers);
        }
      }
    }
  }
  
  void allocationEventEncoding(Event currentEvent) {
    int knowledgeID = currentEvent.getEventScaffoldID();
    myMemory.storeTheoreticalNode(knowledgeID, 1);
    myMemory.storeTheoreticalEdge(knowledgeID);
    myMemory.storeDirectoryEdge(getID(), knowledgeID, true, false);
  }
  
  boolean allocationEventEase(int knowledgeID) {
    return (knowledgeID % 10 <= 1) ? true : false;
  }
  
  void randomlySendAllocationEvent(Event currentInfo, ArrayList<Member> myMembers) {
    int recieverID = getID();
    while (recieverID == getID()) {
      int rand = int(random(myMembers.size()));
      recieverID = myMembers.get(rand).getID();
    }
    for (Member m : myMembers) {
      if (m.getID() == recieverID) {
        m.addInfo(currentInfo);
        //println(".. RANDOMLY SENT INFO to Member <" + recieverID + ">");
      }
      m.addMessage(new Event(-1, EventType.DIRECTORY, getID(), currentInfo.getEventIdentifierID()));
      updateMessageSentCount();
      //println(".. REMOVAL DE!");
    }
    //println("sent to my members (-" + getID() + "-" + currentInfo.getEventIdentifierID() + ")");
  }

  //----------------------------------------
  // retrieval event processing functions
  //----------------------------------------

  int processRetrievalEvent(Event currentEvent, ArrayList<Member> myMembers, ArrayList<Member> allMembers) {
    // encode practical knowledge
    retrievalEventEncoding(currentEvent);

    // can I retrieve it?
    if (currentEventViability(currentEvent)) { 
      //println(".. RETRIEVING (" + currentEvent.getEventScaffoldID() + ")");
      currentEvent.setEventScaffold(new KnowledgeNode(currentEvent.getEventScaffoldID(), 1, KnowledgeType.THEORY_K, 1));
      currentEvent.markEventAsComplete();
      for (Member m : myMembers) {
        m.addMessage(new Event(getID(), EventType.DIRECTORY, getID(), currentEvent.getEventScaffoldID()));
        updateMessageSentCount();
        //println(".. REMOVAL DE!");
      }  
      return 0;
    } else {
      //println(".. .. can't retrieve myself, checking touch logs for event (" + currentEvent.getEventScaffoldID() + ")");

      // have I seen this before?
      if (currentEvent.searchTouchIdLogs(getID())) {
        // send randomly to a team member
        return randomlySelectMember(currentEvent.getEventScaffoldID(), myMembers);
        
      } else {
        //println(".. .. don't know (" + currentEvent.getEventScaffoldID() + "), looking for someone who might");

        // who can retrieve it?
        int recieverID = currentEventCandidacy(currentEvent, myMembers, allMembers);
        if (recieverID > 0) {
          // send and update (implemented in above function)
          return recieverID;
          
        } else {        
          // send randomly to a team member
          return randomlySelectMember(currentEvent.getEventScaffoldID(), myMembers);
        }
      }
    }
  }

  void retrievalEventEncoding(Event currentEvent) {
    int taskID = currentEvent.getEventIdentifierID();
    if (myMemory.searchInShortTermMemory(taskID) == false) {
      if (myMemory.searchInLongTermMemory(taskID) == false) {
        myMemory.storePracticalNode(taskID);
      }
    }
    int knowledgeID = currentEvent.getEventScaffoldID();
    if (myMemory.searchInShortTermMemory(knowledgeID) == false) {
      if (myMemory.searchInLongTermMemory(knowledgeID) == false) {
        myMemory.storeTheoreticalNode(knowledgeID, 0);
      }
    }
    myMemory.storePracticalEdge(taskID, knowledgeID);
  }
  
  int randomlySelectMember(int lastKnowledgeID, ArrayList<Member> myMembers) {
    int recieverID = getID();
    while (recieverID == getID()) {
      int rand = int(random(myMembers.size()));
      //int rand = new Random().nextInt(myMembers.size());
      recieverID = myMembers.get(rand).getID();
    }
    for (Member m : myMembers) {
      m.addMessage(new Event(-1, EventType.DIRECTORY, getID(), lastKnowledgeID));
      updateMessageSentCount();
      //println(".. REMOVAL DE!");
    }
    //println(".. .. Randomly Selected Member: <" + recieverID + ">");
    return recieverID;
  }
  
  void sendTask(Task currentTask, int recieverID, ArrayList<Member> myMembers) {
    for (Member m : myMembers) {
      if (m.getID() == recieverID) {
        m.addTask(currentTask);
        //println(".. SENT TASK to Member <" + recieverID + ">");
      }
    } 
  }



  //----------------------------------------
  // eventList functions 
  //----------------------------------------

  int getMessageCount() {
    return myMessageList.size();
  }
  int getInfoCount() {
    return myInfoList.size();
  }
  int getTaskCount() {
    return myTaskList.size();
  }

  Event getCurrentMessage() { 
    return myMessageList.get(0);
  }
  Event getCurrentInfo() { 
    return myInfoList.get(0);
  }
  Task getCurrentTask() { 
    return myTaskList.get(0);
  }

  void removeCurrentMessage() { 
    myMessageList.remove(0);
  }
  void removeCurrentInfo() { 
    myInfoList.remove(0);
  }
  void removeCurrentTask() { 
    myTaskList.remove(0);
  }

  void addMessage(Event event) { 
    myMessageList.add(event);
  }
  void addInfo(Event event) { 
    myInfoList.add(event);
  }
  void addTask(Task task) { 
    myTaskList.add(task);
  }
  
  boolean currentEventViability(Event currentEvent) {
    int knowledgeID = (currentEvent.getEventType() == EventType.RETRIEVAL) ? currentEvent.getEventScaffoldID() : currentEvent.getEventIdentifierID();
    if (myMemory.searchInShortTermMemory(knowledgeID) == false) {
      if (myMemory.searchInLongTermMemory(knowledgeID) == false) {
        //println(".. .. not aware of (" + knowledgeID + ")");
        return false;
      }
    }
    //println(".. .. aware of (" + knowledgeID + ")");
    return myMemory.hasKnowledgeContent(knowledgeID);
  }
  
  int currentEventCandidacy(Event currentEvent, ArrayList<Member> myMembers, ArrayList<Member> allMembers) {
    int knowledgeID = (currentEvent.getEventType() == EventType.RETRIEVAL) ? currentEvent.getEventScaffoldID() : currentEvent.getEventIdentifierID();
    int memberIndex = 0;
    int[] memberCost = new int[allMembers.size()];
    
    for (Member m : allMembers) {
      memberCost[memberIndex] = (m.getID() == getID()) ? DEAD_EDGE_WT : myMemory.getCostOfSearch(knowledgeID, m.getID());
      memberIndex += 1;
    }
    int bestMemberIndex = FindSmallest(memberCost);
    if (memberCost[bestMemberIndex] < DEAD_EDGE_WT) {
      Member bestMember = allMembers.get(bestMemberIndex);
      for(Member m : myMembers) {
        if(m == bestMember) {
          if(currentEvent.getEventType() == EventType.ALLOCATION) {
            m.addInfo(currentEvent);
          }
          myMemory.refreshSearchPath(knowledgeID, m.getID());
          //println(".. SENT event to Member <" + getID() + "-" + m.getID() + "> @" + memberCost[bestMemberIndex]);
          myMemory.storeDirectoryEdge(m.getID(), knowledgeID, false, false);
          // inform common members who is best
          for(Member cm : t.getCommonMembers(getID(), m.getID())) {
            cm.addMessage(new Event(m.getID(), EventType.DIRECTORY, m.getID(), knowledgeID));
            updateMessageSentCount();
          }
          //println(".. .. DEs sent to common members (" + m.getID() + "-" + getID() + ")");
          return m.getID();
        }
      }
      // if best member is not connected, send to first connected member
      if(currentEvent.getEventType() == EventType.ALLOCATION) {
        myMembers.get(0).addInfo(currentEvent);
      }
      myMemory.refreshSearchPath(knowledgeID, myMembers.get(0).getID());
      //println(".. SENT event to FIRST Member <" + getID() + "-" + myMembers.get(0).getID() + "> @unknown");
      myMemory.storeDirectoryEdge(myMembers.get(0).getID(), knowledgeID, false, false);
      // inform common members who is best
      for(Member cm : t.getCommonMembers(getID(), myMembers.get(0).getID())) {
        cm.addMessage(new Event(myMembers.get(0).getID(), EventType.DIRECTORY, myMembers.get(0).getID(), knowledgeID));
        updateMessageSentCount();
      }
      //println(".. .. DEs sent to common members (" + myMembers.get(0).getID() + "-" + getID() + ")");
      return myMembers.get(0).getID();
     
    } else {
      //println(".. .. suitable Member not found!");
      return 0;
    }
  }




  //----------------------------------------
  // reporting functions 
  //----------------------------------------

  boolean memberHasKnowledge(Member m, int knowledgeID) {
    return (m.myMemory.hasKnowledgeContent(knowledgeID));
  }
  
  ArrayList<GraphNode> membersTheoreticalKnowledge() {
    return myMemory.getTheoreticalKnowledge();
  }
  
  int calculateMetaKnowledgeCount(ArrayList<Member> allMembers) {
    int metaKnowledgeCount = 0;
    for(Member m : allMembers) {
      if(m.getID() != getID()) {
        GraphEdge[] metaKnowledge = myMemory.getPerceivedKnowledge(m.getID());
        for (GraphEdge e : metaKnowledge) {
          if (e.getCost() == MAX_EDGE_WT) metaKnowledgeCount++;
        }
      }
    }
    return metaKnowledgeCount;
  }
  
  float[] calculateDirectoryAccuracies(Member percieved) {
    GraphEdge[] perceivedKnowledge = myMemory.getPerceivedKnowledge(percieved.getID());
    float accuratePercievedCount = 0;
    float totalPercievedCount = 0;
    
    for (GraphEdge e : perceivedKnowledge) {
      if (e.getCost() == MAX_EDGE_WT) {
        totalPercievedCount += 1;
        if (memberHasKnowledge(percieved, e.to().id())) accuratePercievedCount += 1;
      }
    }
    
    ArrayList<GraphNode> theoreticalKnowledge = percieved.membersTheoreticalKnowledge();
    float totalTheoreticalCount = theoreticalKnowledge.size(); 
    
    //println("   " + getID() + "->" + percieved.getID() + ":   "
    //        + (int)accuratePercievedCount + "/" + (int)totalPercievedCount
    //        + "      "
    //        + (int)accuratePercievedCount + "/" + (int)totalTheoreticalCount);
    float type1 = (totalPercievedCount == 0) ? 0 : (accuratePercievedCount / totalPercievedCount);
    float type2 = (totalTheoreticalCount == 0) ? 0 : (accuratePercievedCount / totalTheoreticalCount);
    float[] accuracies = {type1, type2};
    return accuracies;
  }


  //----------------------------------------
  // draw functions 
  //----------------------------------------

  // render Member
  void drawMember() {
    noStroke();
    fill(GREY);
    rect(x, y, 20 + TASK_NODE_SIZE, 10 + TASK_NODE_SIZE);
    rect(x, y + 10 + TASK_NODE_SIZE, 120 + MEMBER_BREADTH * NODE_SIZE * 2, 120 + MEMBER_HEIGHT * NODE_SIZE * 2);

    fill(255);
    textAlign(CENTER);
    textSize(38);
    text(id, x + (20 + TASK_NODE_SIZE) / 2, y + 10 + (20 + TASK_NODE_SIZE) / 2);

    drawLongTermMemory();
    //drawShortTermMemory();
  }

  // render Long Term Memory
  void drawLongTermMemory() {
    pushMatrix();
    translate(x + 10, y + 20 + TASK_NODE_SIZE);
    fill(BG_COLOR);
    rect(0, 0, 100 + MEMBER_BREADTH * NODE_SIZE * 2, 100 + MEMBER_HEIGHT * NODE_SIZE * 2);
    myMemory.drawMemory();
    popMatrix();
  }

  // render Short Term Memory
  void drawShortTermMemory() {
    pushMatrix();
    translate(x + 25 + TASK_NODE_SIZE, y + 5);
    myMemory.drawShortTermMemory();
    popMatrix();
  }

  // render current Event
  void clearCurrentEvent() {
    pushMatrix();
    translate(x + 120 + MEMBER_BREADTH * NODE_SIZE * 2, y);
    noFill();
    rect(0, 0, -6 * TASK_NODE_SIZE - 2, TASK_NODE_SIZE + 5);
    translate(-1 * (2 * TASK_NODE_SIZE), 5);
    noStroke();
    fill(LIGHT_GREY);
    rect(0, 0, 2 * TASK_NODE_SIZE, TASK_NODE_SIZE);
    popMatrix();

    pushMatrix();
    translate(x + 118 + MEMBER_BREADTH * NODE_SIZE * 2, y + 5);
    fill(RED[0], RED[1], RED[2]);
    ellipse(0, 0, TASK_NODE_SIZE * 0.6, TASK_NODE_SIZE * 0.6);
    fill(255);
    textAlign(CENTER);
    textSize(15);
    text(getMessageCount() + getInfoCount() + getTaskCount(), 0, 5);    
    popMatrix();
  }
}
