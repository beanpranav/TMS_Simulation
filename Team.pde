enum TeamType { 
  CLIQUE, WHEEL, SUBGROUPS
}

class Team {
  private Graph teamStructure;

  public Team(int[][] memberSpecializations, TeamType type) {
    teamStructure = new GraphExtended(TEAM_SIZE);
      
    for (int i = 0; i < TEAM_SIZE; i++) {
      Member m = new Member(
        i+1,
        new float[] {i * ((MEMBER_BREADTH * NODE_SIZE * 2) + 120 + 25), 0},
        memberSpecializations[i]
        );
      teamStructure.addNode(m);
    }
    
    switch (type) {
      case WHEEL:  
        for (int i = 1; i < TEAM_SIZE; i++) {
          teamStructure.addEdge(1, i+1, MAX_EDGE_WT, MAX_EDGE_WT);
        }
        break;
      case SUBGROUPS:   
        for (int i = 1; i < TEAM_SIZE; i++) {
          teamStructure.addEdge(1, i+1, MAX_EDGE_WT, MAX_EDGE_WT);
        }
        int subgroupSize = (TEAM_SIZE - 1)/2;
        for (int i = 1; i <= subgroupSize; i++) {
          for (int j = i+1; j <= subgroupSize; j++) {
            if(i!=j) {
              teamStructure.addEdge(i+1, j+1, MAX_EDGE_WT, MAX_EDGE_WT);
            }
          }
        }
        for (int i = subgroupSize+1; i <= TEAM_SIZE; i++) {
          for (int j = i+1; j <= TEAM_SIZE; j++) {
            if(i!=j) {
              teamStructure.addEdge(i+1, j+1, MAX_EDGE_WT, MAX_EDGE_WT);
            }
          }
        }
        break;
      default: //CLIQUE
        for (int i = 0; i < TEAM_SIZE; i++) {
          for (int j = i; j < TEAM_SIZE; j++) {
            if(i!=j) {
              teamStructure.addEdge(i+1, j+1, MAX_EDGE_WT, MAX_EDGE_WT);
            }
          }
        }
        break;
      }
  }
  
  ArrayList<Member> getMyMembers(int memberID) {
    GraphEdge[] edges = teamStructure.getEdgeArray(memberID);
    ArrayList<Member> myMembers = new ArrayList<Member>(edges.length);
    
    for (GraphEdge e : edges) {
        myMembers.add((Member)e.to());
    }
    return myMembers;
  }
  
  ArrayList<Member> getCommonMembers(int memberID1, int memberID2) {
    GraphEdge[] edges1 = teamStructure.getEdgeArray(memberID1);
    GraphEdge[] edges2 = teamStructure.getEdgeArray(memberID2);
    ArrayList<Member> commonMembers = new ArrayList<Member>();
    
    for (GraphEdge e1 : edges1) {
      for (GraphEdge e2 : edges2) {
        if((Member)e1.to() == (Member)e2.to()) {
          commonMembers.add((Member)e1.to());
        }
      }
    }
    return commonMembers;
  }
  
  ArrayList<Member> getAllMembers() {
    GraphNode[] nodes = teamStructure.getNodeArray();
    ArrayList<Member> allMembers = new ArrayList<Member>(nodes.length);
    
    for (GraphNode n : nodes) {
      allMembers.add((Member)n);
    }
    return allMembers;
  }
  
  Member getLeader() {
    Member leader = new Member();
    for(Member m : getAllMembers()) {
      if (m.getID() == LEADER_ID) {
        leader = m;
      }
    }
    return leader;
  }

  void run() {
    ArrayList<Member> allMembers = getAllMembers();
    for (Member m : allMembers) {
      m.run();
    }
  }
  
  void drawTeam() {
    ArrayList<Member> allMembers = getAllMembers();
    for (Member m : allMembers) {
      m.drawMember();
    }
  }

}