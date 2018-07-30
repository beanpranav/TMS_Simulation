/*
 * Models of Transactive Memory System
 * by Pranav Gupta.  
 */

import pathfinder.*;
import java.util.Random;
import java.util.Arrays;

Team t;
TeamJob jobIn;
ArrayList<Event> jobInfoOut;
ArrayList<Task> jobTaskOut;

void setup() {
  size(1400, 560);
  background(BG_COLOR);
  simulationSetup();
}

void draw() {
  if (jobTaskOut.size() < JOB_SIZE && TIME < 100) {
    TIME += 1;
    //println(""); println("<---- TIME = " + TIME + " ---->");
    
    if(TIME < 3) {
      for(int i = 0; i < TMS_LEVEL[tmsl]; i++) { tmsSetup(); }
    }
    t.run();
    
    //if(TIME == INTRO_THRESHOLD) {
    //  calculateMessageCounts();
    //  calculateMetaKnowledgeDistribution();
    //}
    
    //delay(500);
  } else { 
    noLoop();
    simulationReporting(); // iteration reports
    println(""); println("#### SIM COMPLETE");
  }
}

void simulationSetup() {
  println("#### STARTING SETUPS");
  TIME = 0;
  // TEAM SETUP
  println(".. " + TEAM_STRUCTURE[tc]);
  switch (TEAM_STRUCTURE[tc]) {
    case "WHEEL":
      t = new Team(specD_5, TeamType.WHEEL);
      break;
    case "SUBGROUPS":
      t = new Team(specD_5, TeamType.SUBGROUPS);
      break;
    default: //CLIQUE
      t = new Team(specD_5, TeamType.CLIQUE);
      break;
  }
  t.drawTeam();
 
  // JOB SETUP 
  switch (TASK_TYPE[tt]) {
    case "Repeating":
      jobIn  = new TeamJob(JobType.REPEATING, DIFFICULTY_LEVEL[dl], COMPLEXITY_LEVEL[cl]);
      break;
    default: //"Non-Repeating"
      jobIn  = new TeamJob(JobType.NON_REPEATING, DIFFICULTY_LEVEL[dl], COMPLEXITY_LEVEL[cl]);
      break;
  }
  jobIn.initializeJob();
  jobInfoOut = new ArrayList<Event>();
  jobTaskOut = new ArrayList<Task>();
  
  println("");
  println("#### SETUPS COMPLETE, STARTING SIMULATION");
}

void tmsSetup() {
  // TMS SETUP
  switch (TMS_STRUCTURE[tms]) {
    case "HOMOGENEOUS": 
    //homo  - all to my connected, leader to all uncommon 
      if(TIME == 1) {
        for(Member m : t.getAllMembers()) { 
          m.addMessage(new Event(m.getID(), EventType.DIRECTORY, m.getID(), 0));
        }
      }
      if(TIME == 2) {
        Member leader = t.getLeader();
        for(Member m : t.getMyMembers(LEADER_ID)) { // for all connected
          
          for(Member reciever : t.getMyMembers(LEADER_ID)) { //leader to all uncommon
            boolean isPresent = false;
            for(Member cm : t.getCommonMembers(LEADER_ID,m.getID())) {
              if(reciever == cm) isPresent = true;
            }
            if(!isPresent && reciever != m) { // not a common connection
              leader.addMessage(new Event(LEADER_ID, EventType.DIRECTORY, m.getID(), reciever.getID()));
            }
          }
        }
      }
      break;
    default: //"HETEROGENEOUS"
      //hetero  - all to leader, leader to all
      if(TIME == 1) {
        Member leader = t.getLeader();
        leader.addMessage(new Event(LEADER_ID, EventType.DIRECTORY, LEADER_ID, 0));
        for(Member m : t.getMyMembers(LEADER_ID)) { // for all connected
          m.addMessage(new Event(m.getID(), EventType.DIRECTORY, m.getID(), LEADER_ID));
        }
      }
  }
  
}

void simulationReporting() {
  println("");
  println("#### SIMULATION COMPLETE, STARTING REPORTS");
  
  println("");
  println("Total Time Spent: " + (TIME - INTRO_THRESHOLD));
  calculateEffectiveness();
  //calculateDifficulty();
  calculateMessageCounts();
  calculateMetaKnowledgeDistribution();
}


void calculateEffectiveness() {
  float completedAllocationEventsCount = 0;
  int allocationEventsPassesCount = 0;
  //float totalAllocationEventsCount = JOB_SIZE * COMPLEXITY_LEVEL[cl];
  
  float completedRetrievalEventsCount = 0;
  int retrievalEventsPassesCount = 0;
  int retrievalTime = 0;
  //float totalRetrievalEventsCount = JOB_SIZE;
  
  if(CREATE_ALLOCATION) {
    //println("");
    //println("<---- ALLOCATION EFFECTIVENESS ---->");
    //println("");
    for  (Event e : jobInfoOut) {
        if(e.getCompletionStatus()) completedAllocationEventsCount += 1;
        allocationEventsPassesCount += e.touchIdLogs.size();
        //print(".. .. A-" + e.getEventID() + ": (" + 
        //      e.getEventIdentifierID() + "|" + e.getEventScaffoldID() + ") is " + 
        //      e.getCompletionStatus());
        //print(": logs: ");
        //for (int l : e.touchIdLogs) print("-" + l);
        //println("-");
    }
    //println(".. completed Allocations: " + (int)completedAllocationEventsCount);
    //println(".. total Allocations: " + (int)totalAllocationEventsCount);
    //println("Allocation Effectiveness: " + completedAllocationEventsCount / totalAllocationEventsCount);
    //println(".. total Passes: " + allocationEventsPassesCount);
    println("Average Allocation Passes: " + allocationEventsPassesCount / completedAllocationEventsCount);
  }
  
  //println("");
  //println("<---- RETRIEVAL EFFECTIVENESS ---->");
  //println("");
  for  (Task t : jobTaskOut) {
      if(t.getCompletionStatus()) completedRetrievalEventsCount += 1;
      retrievalEventsPassesCount += t.touchIdLogs.size();
      retrievalTime += (t.touchTimeLogs.get(t.touchTimeLogs.size()-1) - t.touchTimeLogs.get(0) + 1);
     //print(".. .. R-" + t.getTaskID() + ": is " + t.getCompletionStatus() + " @" + t.touchIdLogs.size());
     //print(": logs: ");
     //for (int l : t.touchIdLogs) print("-" + l);
     //println("-");
  }
  //println(".. completed Retrievals: " + (int)completedRetrievalEventsCount);
  //println(".. total Retrievals: " + (int)totalRetrievalEventsCount);
  //println("Retrieval Effectiveness: " + completedRetrievalEventsCount / totalRetrievalEventsCount);
  //println(".. total Passes: " + retrievalEventsPassesCount);
  println("Average Retrieval Passes: " + retrievalEventsPassesCount / completedRetrievalEventsCount);
  println("Average Retrieval Time: " + retrievalTime / completedRetrievalEventsCount);
}

void calculateMessageCounts() {
  int[] messagesSentCountDistribution = new int[TEAM_SIZE];
  int[] messagesRecievedCountDistribution = new int[TEAM_SIZE];
  
  for(int i = 0; i < TEAM_SIZE; i++) {
    messagesSentCountDistribution[i] = t.getAllMembers().get(i).myMessagesSentCount;
    messagesRecievedCountDistribution[i] = t.getAllMembers().get(i).myMessagesRecievedCount;
  }
  println(""); 
  println(".. Messages Sent Distribution: " + Arrays.toString(messagesSentCountDistribution));
  println(".. Messages Reci Distribution: " + Arrays.toString(messagesRecievedCountDistribution));
    //println(".. " + m.getID() + "-" + m.myMessagesSentCount + "-" + m.myMessagesRecievedCount);
}

void calculateMetaKnowledgeDistribution() {
  ArrayList<Member> allMembers = t.getAllMembers();
  int[] metaKnowledgeDistribution = new int[TEAM_SIZE];
  for(int i = 0; i < TEAM_SIZE; i++) {
    metaKnowledgeDistribution[i] = allMembers.get(i).calculateMetaKnowledgeCount(allMembers);
  }
  println(".. MetaKnowledge Distribution: " + Arrays.toString(metaKnowledgeDistribution));
}
