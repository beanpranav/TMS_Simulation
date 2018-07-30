class Memory { //<>//
  private Graph longTermMemory;
  private ArrayList<KnowledgeNode> shortTermMemory; 

  public Memory() {
    longTermMemory = new GraphExtended(NO_OF_DOMAINS * DOMAIN_HEIGHT);

    // initialize all DIRECTORY_K nodes
    for (int i = 0; i < TEAM_SIZE; i++) {
      GraphNode n = new KnowledgeNode(i+1, KnowledgeType.DIRECTORY_K);
      longTermMemory.addNode(n);
    }

    // initialize all THEORY_K nodes
    for (int i = 1; i <= NO_OF_DOMAINS; i++) {
      for (int k = 1; k <= DOMAIN_HEIGHT; k++) {
        GraphNode n = new KnowledgeNode(new int[] {i, 0, k}); 
        longTermMemory.addNode(n);
      }
    }

    // initialize THEORY_K graph structure
    for (int i = 1; i <= NO_OF_DOMAINS; i++) {
      for (int k = 1; k <= DOMAIN_HEIGHT; k++) {
        int fromN = i*100 + k;

        // all THEORY_K are connected to the next higher node
        if (k < DOMAIN_HEIGHT) { 
          int toNk = i*100 + (k+1);
          longTermMemory.addEdge(fromN, toNk, DEAD_EDGE_WT, DEAD_EDGE_WT);
        }

        // first level THEORY_K nodes have inter-domain connections
        if(k == 1) {
          if (i < NO_OF_DOMAINS) {
            int toNi = (i+1)*100 + 1;
            longTermMemory.addEdge(fromN, toNi, DEAD_EDGE_WT, DEAD_EDGE_WT);
          } else {
            int toNi = 100 + 1;
            longTermMemory.addEdge(fromN, toNi, DEAD_EDGE_WT, DEAD_EDGE_WT);
          }
        }
      }
    }
  }


  // set awareness and edges for basic THEORY_K nodes
  // set knowledge for specializationDomain
  void initializeMemory(int memberID, int[] specializationDomains) {
    //println(".. .. initializing member's memory");
    shortTermMemory = new ArrayList<KnowledgeNode>();

    for (int i = 1; i <= NO_OF_DOMAINS; i++) {
      // add awareness of all first level
      GraphNode node1 = longTermMemory.getNode(i*100 + 1);
      ((KnowledgeNode)node1).setAwareness();
      if (i < NO_OF_DOMAINS) { 
        setEdgeWeight(i*100 + 1, (i+1)*100 + 1, MID_EDGE_WT);
      } else {
        setEdgeWeight(i*100 + 1, 100 + 1, MID_EDGE_WT);
      }

      // add to short term memory
      if (shortTermMemory.size() < SIZE_OF_SHORT_TERM_MEMORY) {
        shortTermMemory.add((KnowledgeNode)node1);
      }
    }

    for (int sd : specializationDomains) { 
      switch (sd) {
        case 0: // generalist
          for (int i = 1; i <= NO_OF_DOMAINS; i++) {  
            // add knowledge of all first level
            GraphNode node1 = longTermMemory.getNode(i*100 + 1);
            ((KnowledgeNode)node1).setKnowledge();
            storeDirectoryEdge(memberID, i*100 + 1, true, false);
            if (i < NO_OF_DOMAINS) { 
              setEdgeWeight(i*100 + 1, (i+1)*100 + 1, MAX_EDGE_WT);
            } else {
              setEdgeWeight(i*100 + 1, 100 + 1, MAX_EDGE_WT);
            }
            // add awareness of all first level
            GraphNode node2 = longTermMemory.getNode(i * 100 + 2);
            ((KnowledgeNode)node2).setAwareness();
            setEdgeWeight(i*100 + 1, i*100 + 2, MAX_EDGE_WT);
          }
          break; 
        default:  // domain specialist
          // add knowledge to first level specialist domain
          GraphNode sdNode = longTermMemory.getNode(sd*100 + 1);
          ((KnowledgeNode)sdNode).setKnowledge();
          storeDirectoryEdge(memberID, sd*100 + 1, true, false);
            
          // add knowledge of all levels for specialist domain
          for (int k = 2; k <= DOMAIN_HEIGHT; k++) {
            GraphNode node1 = longTermMemory.getNode(sd*100 + k);
            ((KnowledgeNode)node1).setKnowledge();
            storeDirectoryEdge(memberID, sd*100 + k, true, false);
            setEdgeWeight(sd*100 + k-1, sd*100 + k, MAX_EDGE_WT);
          }
          
          //// add knowledge to first level of domain next to specialist domain
          //if(sd == NO_OF_DOMAINS) {
          //  GraphNode sdNextNode = longTermMemory.getNode(100 + 1);
          //  ((KnowledgeNode)sdNextNode).setKnowledge();
          //  setEdgeWeight(sd*100 + 1, 100 + 1, MAX_EDGE_WT);
          //  storeDirectoryEdge(memberID, 100 + 1, true, false);
          //  GraphNode sdNextNode2 = longTermMemory.getNode(100 + 2);
          //  ((KnowledgeNode)sdNextNode2).setAwareness();
          //  setEdgeWeight(100 + 1, 100 + 2, MAX_EDGE_WT);
          //} else {
          //  GraphNode sdNextNode = longTermMemory.getNode((sd+1)*100 + 1);
          //  ((KnowledgeNode)sdNextNode).setKnowledge();
          //  setEdgeWeight(sd*100 + 1, (sd+1)*100 + 1, MAX_EDGE_WT);
          //  storeDirectoryEdge(memberID, (sd+1)*100 + 1, true, false);
          //  GraphNode sdNextNode2 = longTermMemory.getNode((sd+1)*100 + 2);
          //  ((KnowledgeNode)sdNextNode2).setAwareness();
          //  setEdgeWeight((sd+1)*100 + 1, (sd+1)*100 + 2, MAX_EDGE_WT);
          //}
          
          //// add knowledge to first level of domain previous to specialist domain
          //if(sd <= 1) {
          //  GraphNode sdPreviousNode = longTermMemory.getNode(NO_OF_DOMAINS*100 + 1);
          //  ((KnowledgeNode)sdPreviousNode).setKnowledge();
          //  setEdgeWeight(sd*100 + 1, NO_OF_DOMAINS*100 + 1, MAX_EDGE_WT);
          //  storeDirectoryEdge(memberID, NO_OF_DOMAINS*100 + 1, true);
          //  GraphNode sdNextNode2 = longTermMemory.getNode(NO_OF_DOMAINS*100 + 2);
          //  ((KnowledgeNode)sdNextNode2).setAwareness();
          //  setEdgeWeight(NO_OF_DOMAINS*100 + 1, NO_OF_DOMAINS*100 + 2, MAX_EDGE_WT);
          //} else {
          //  GraphNode sdPreviousNode = longTermMemory.getNode((sd-1)*100 + 1);
          //  ((KnowledgeNode)sdPreviousNode).setKnowledge();
          //  setEdgeWeight(sd*100 + 1, (sd-1)*100 + 1, MAX_EDGE_WT);
          //  storeDirectoryEdge(memberID, (sd-1)*100 + 1, true);
          //  GraphNode sdNextNode2 = longTermMemory.getNode((sd-1)*100 + 2);
          //  ((KnowledgeNode)sdNextNode2).setAwareness();
          //  setEdgeWeight((sd-1)*100 + 1, (sd-1)*100 + 2, MAX_EDGE_WT);
          //}
      }
    }
  }

  // set weight for both bidirectional edges
  void setEdgeWeight(int fromID, int toID, double wt) {
    if (longTermMemory.getEdge(fromID, toID) == null) {
      //println("** skipped NULL pointer exception!");
    } else {
      GraphEdge edge1 = longTermMemory.getEdge(fromID, toID);
      edge1.setCost(wt);
      ((GraphExtended)longTermMemory).resetEdgeTime(fromID, toID);
    }
    if (longTermMemory.getEdge(toID, fromID) == null) {
      //println("** skipped NULL pointer exception!");
    } else {
      GraphEdge edge2 = longTermMemory.getEdge(toID, fromID);
      edge2.setCost(wt);
      ((GraphExtended)longTermMemory).resetEdgeTime(toID, fromID);
    }
  }


  //----------------------------------------
  // Short Term Memory functions 
  //----------------------------------------

  boolean searchInShortTermMemory(int knowledgeID) {
    boolean seachResult = false;
    for (int i = 0; i < shortTermMemory.size(); i++) {
      KnowledgeNode node = shortTermMemory.get(i);
      if (node.id() == knowledgeID) {
        shortTermMemory.remove(i);
        shortTermMemory.add(node);
          
        GraphNode n = longTermMemory.getNode(knowledgeID);
        ((KnowledgeNode)n).resetLastAccessed();
        
        seachResult = true;
        break;
      }
    }
    //println(".. .. .. (" + knowledgeID + ") found in SM: " + seachResult);
    return seachResult;
  }

  void addToShortTermMemory(int knowledgeID) {
    GraphNode node = longTermMemory.getNode(knowledgeID);
    shortTermMemory.remove(0);
    shortTermMemory.add((KnowledgeNode)node);
    ((KnowledgeNode)node).resetLastAccessed();
    //println(".. .. .. (" + knowledgeID + ") added to SM");
  }


  //----------------------------------------
  // Long Term Memory functions 
  //----------------------------------------

  boolean searchInLongTermMemory(int id) {
    if (longTermMemory.hasNode(id)) {                                //if found in LM traverse
      IGraphSearch pf = new GraphSearch_Dijkstra(longTermMemory);    //  traverse
      int rand = int(random(SIZE_OF_SHORT_TERM_MEMORY - 1));
      pf.search(shortTermMemory.get(rand).id(), id);                 //  randomly from top of SM
      GraphNode[] path = pf.getRoute();                              //  identify shortest path
      int pathCost = 0;
      for (int i = 0; i < path.length - 1; i++) {
        pathCost += longTermMemory.getEdgeCost(path[i].id(), path[i+1].id());
      }
      if (pathCost > 0 && pathCost < DEAD_EDGE_WT) {
        //  update path's edge weights
        for (int i = 0; i < path.length - 1; i++) {
          setEdgeWeight(path[i+1].id(), path[i].id(), MAX_EDGE_WT);
          ((GraphExtended)longTermMemory).resetEdgeTime(path[i].id(), path[i+1].id());
          ((GraphExtended)longTermMemory).resetEdgeTime(path[i+1].id(), path[i].id());
        }
        //println(".. .. .. (" + id + ") found in LM: from " + shortTermMemory.get(SIZE_OF_SHORT_TERM_MEMORY - 1).id() + " in " + (path.length - 1) + " steps, costing @" + pathCost);
        addToShortTermMemory(id);                                      //  add found node to SM
        return true;                                                   //  say found
      }
    }
    //println(".. .. .. (" + id + ") found in LM: false");
    return false;                                                  //  say not found
  }

  void storeTheoreticalNode(int knowledgeID, int knowledgeStatus) {
    GraphNode n = longTermMemory.getNode(knowledgeID);
    ((KnowledgeNode)n).setAwareness();                                               //set task A
    if (knowledgeStatus == 1) ((KnowledgeNode)n).setKnowledge();
    addToShortTermMemory(n.id());                                                    //add task to SM
    //println(".. .. .. theoretical knowledge (" + knowledgeID + ") added to LM!");
  }
  
  void storeTheoreticalEdge(int knowledgeID) {
    GraphEdge[] knowledgeArray = longTermMemory.getEdgeArray(knowledgeID);
    for (GraphEdge e : knowledgeArray) {
      if (((KnowledgeNode)e.to()).getKnowledgeType() == KnowledgeType.THEORY_K) {
        setEdgeWeight(knowledgeID, e.to().id(), MAX_EDGE_WT);
        ((KnowledgeNode)e.to()).setAwareness();
        //println(".. .. .. theoretical knowledge edge (" + knowledgeID + "-" + e.to().id() + ") refreshed!");
      }
    }
  }

  void storePracticalNode(int knowledgeID) {
    GraphNode n = new KnowledgeNode(knowledgeID, KnowledgeType.PRACTICAL_K);  
    longTermMemory.addNode(n);                                                       //create task in LM
    addToShortTermMemory(n.id());                                                    //add task to SM
    //println(".. .. .. practical knowledge (" + knowledgeID + ") added to LM!");
  }

  void storePracticalEdge(int taskID, int knowledgeID) {
    if (longTermMemory.hasEdge(knowledgeID, taskID)) {
      setEdgeWeight(taskID, knowledgeID, MAX_EDGE_WT);
      //println(".. .. .. practical knowledge edge (" + taskID + "-" + knowledgeID + ") refreshed!");
    } else {
      longTermMemory.addEdge(taskID, knowledgeID, MAX_EDGE_WT, MAX_EDGE_WT);
      ((KnowledgeNode)longTermMemory.getNode(knowledgeID)).setAwareness();
      //println(".. .. .. practical knowledge edge (" + taskID + "-" + knowledgeID + ") added to LM!");
    }
  }

  void storeDirectoryEdge(int memberID, int knowledgeID, boolean isSelf, boolean removeEdge) {
    
    if (!searchInShortTermMemory(memberID)) addToShortTermMemory(memberID);
    if (!searchInShortTermMemory(knowledgeID)) addToShortTermMemory(knowledgeID);
    
    if(ALLOW_TRANSACTIVE_PROCESS || TIME < INTRO_THRESHOLD) {
      if (longTermMemory.hasEdge(knowledgeID, memberID)) {
        if(!removeEdge) {
          longTermMemory.getEdge(memberID, knowledgeID).setCost(MAX_EDGE_WT);
          ((GraphExtended)longTermMemory).resetEdgeTime(memberID, knowledgeID);
          if (!isSelf) {
            longTermMemory.getEdge(knowledgeID, memberID).setCost(MAX_EDGE_WT);
            ((GraphExtended)longTermMemory).resetEdgeTime(knowledgeID, memberID);
          }
          //println(".. .. .. directory knowledge edge (" + memberID + "-" + knowledgeID + ") refreshed!");
        } else {
          //println(".. .. .. REMOVED directory knowledge edge (" + memberID + "-" + knowledgeID + ")!");
          longTermMemory.getEdge(memberID, knowledgeID).setCost(MIN_EDGE_WT);
          if (!isSelf) {
            longTermMemory.getEdge(knowledgeID, memberID).setCost(MIN_EDGE_WT);
          }
        }
      } else {
        if(!removeEdge) {
          if (isSelf) {
            longTermMemory.addEdge(memberID, knowledgeID, MAX_EDGE_WT, DEAD_EDGE_WT);
          } else {
            longTermMemory.addEdge(memberID, knowledgeID, MAX_EDGE_WT, MAX_EDGE_WT);
          }
          ((KnowledgeNode)longTermMemory.getNode(knowledgeID)).setAwareness();
          //println(".. .. .. directory knowledge edge (" + memberID + "-" + knowledgeID + ") added to LM!");
        }
      }
    }
  }

  KnowledgeNode sampleMyKnowlege(int memberID) {
    GraphEdge[] myKnowledgeArray = longTermMemory.getEdgeArray(memberID);
    double wt = MIN_EDGE_WT;
    int breakCount = 5;
    int myKnowledgeID = 0;
    while (wt == MIN_EDGE_WT && breakCount > 0) { 
      // IMP: not checking if infact I have the knowledge content: arrogance!
      int rand = int(random(myKnowledgeArray.length));
      myKnowledgeID = myKnowledgeArray[rand].to().id();
      wt = myKnowledgeArray[rand].getCost();
      breakCount -= 1;
    }
    addToShortTermMemory(myKnowledgeID);
    if (longTermMemory.getEdge(memberID, myKnowledgeID) == null) {
      //println("** skipped NULL pointer exception!"); //<>// //<>//
    } else {
      longTermMemory.getEdge(memberID, myKnowledgeID).setCost(MAX_EDGE_WT);
    }
    ((GraphExtended)longTermMemory).resetEdgeTime(memberID, myKnowledgeID);
    
    //println(".. .. .. knows contents of (" + myKnowledgeID + ")");
    return (new KnowledgeNode(myKnowledgeID, 1, KnowledgeType.THEORY_K, 1));
  }
  
  void refreshSearchPath(int fromID, int toID) {
    IGraphSearch pf = new GraphSearch_Dijkstra(longTermMemory);
    pf.search(fromID, toID);
    GraphNode[] path = pf.getRoute();                              //  identify shortest path
    for (int i = 0; i < path.length - 1; i++) {
      if(path[i].id() != toID) {
        if (longTermMemory.getEdge(path[i+1].id(), path[i].id()) == null) {
          //println("** skipped NULL pointer exception!");
        } else {
          longTermMemory.getEdge(path[i+1].id(), path[i].id()).setCost(MAX_EDGE_WT);
        }
        ((GraphExtended)longTermMemory).resetEdgeTime(path[i+1].id(), path[i].id());
      }
      if(path[i+1].id() != toID) {
        if (longTermMemory.getEdge(path[i].id(), path[i+1].id()) == null) {
          //println("** skipped NULL pointer exception!");
        } else {
          longTermMemory.getEdge(path[i].id(), path[i+1].id()).setCost(MAX_EDGE_WT);
        }
        ((GraphExtended)longTermMemory).resetEdgeTime(path[i].id(), path[i+1].id());
      }
    }
  }
  
  


  //----------------------------------------
  // reporting functions 
  //----------------------------------------
  
  int getCostOfSearch(int fromID, int toID) {
    IGraphSearch pf = new GraphSearch_Dijkstra(longTermMemory);
    pf.search(fromID, toID);
    GraphNode[] path = pf.getRoute();                              //  identify shortest path
    int pathCost = 0;
    for (int i = 0; i < path.length - 1; i++) {
      pathCost += longTermMemory.getEdgeCost(path[i].id(), path[i+1].id());
      ((GraphExtended)longTermMemory).resetEdgeTime(path[i].id(), path[i+1].id());
      ((GraphExtended)longTermMemory).resetEdgeTime(path[i+1].id(), path[i].id());
    }
    //println(".. .. .. search cost of " + fromID + " -> " + toID + " is @" + pathCost);
    return (pathCost == 0) ? DEAD_EDGE_WT : pathCost;
  }
  
  boolean hasKnowledgeContent(int knowledgeID) {
    GraphNode node = longTermMemory.getNode(knowledgeID);
    return (((KnowledgeNode)node).hasKnowledge() == 1) ? true : false;
  }
  
  GraphEdge[] getPerceivedKnowledge(int memberID) {
    return longTermMemory.getEdgeArray(memberID);
  }
  
  ArrayList<GraphNode> getTheoreticalKnowledge() {
    GraphNode[] allKnowledge = longTermMemory.getNodeArray();
    ArrayList<GraphNode> theoreticalKnowledgeList = new ArrayList<GraphNode>();
    
    for (GraphNode node : allKnowledge) {
      if (((KnowledgeNode)node).hasKnowledge() == 1 && ((KnowledgeNode)node).getKnowledgeType() == KnowledgeType.THEORY_K) {
        theoreticalKnowledgeList.add(node);
      }
    }
    return theoreticalKnowledgeList;
  }
  
  
  

  //----------------------------------------
  // draw functions 
  //----------------------------------------

  void drawMemory() {
    pushMatrix();
    translate(30,30);
    drawEdges(longTermMemory.getAllEdgeArray());
    drawNodes(longTermMemory.getNodeArray());
    popMatrix();
  }

  void drawNodes(GraphNode[] gNodes) {
    pushStyle();
    for (GraphNode node : gNodes) {
      if (((KnowledgeNode)node).isAware() == 0) {
        strokeWeight(DEFAULT_STOKE_WT);
        stroke(GREY);
        fill(BG_COLOR);
        //noStroke();
        //noFill();
      } else {
        int r, g, b;
        // set color based on knowledgeNode type
        switch (((KnowledgeNode)node).getKnowledgeType()) {
        case DIRECTORY_K:
          r = BLUE[0];
          g = BLUE[1];
          b = BLUE[2];
          break; 
        case PRACTICAL_K:
          r = YELLOW[0];
          g = YELLOW[1];
          b = YELLOW[2];
          break;
        case THEORY_K:
          r = GREEN[0];
          g = GREEN[1];
          b = GREEN[2];
          break;
        default:
          r = 167;
          g = 167;
          b = 167;
        }

        if (((KnowledgeNode)node).hasKnowledge() == 0) {
          strokeWeight(DEFAULT_STOKE_WT + 1);
          stroke(r, g, b);
          fill(BG_COLOR);
        } else {
          stroke(r, g, b);
          fill(r, g, b);
        }
      }
      rectMode(CENTER);
      rect(node.xf(), node.yf(), NODE_SIZE, NODE_SIZE);
      if (NODE_SIZE >= 20 && ((KnowledgeNode)node).isAware() != 0) {
        fill(0);
        textSize(8);
        textAlign(CENTER);
        text((node.id()), node.xf(), node.yf()+4);
        //text(((KnowledgeNode)node).getLastAccessed()-TIME, node.xf(), node.yf()+4);
      }
    }
    popStyle();
  }

  void drawEdges(GraphEdge[] edges) {
    if (edges != null) {
      pushStyle();
      noFill();
      for (GraphEdge ge : edges) {
        // set thickness based on edge weight
        int wt = (int)ge.getCost();
        //int edgeTime = TIME - ((GraphExtended)longTermMemory).getEdgeTime(ge.from().id(), ge.to().id());
        //int x = (edgeTime > 1) ? LIGHT_GREY : GREY;
        switch (wt) {
          case MIN_EDGE_WT:  
            strokeWeight(DEFAULT_STOKE_WT);
            stroke(LIGHT_GREY);
            break;
          case MID_EDGE_WT:  
            strokeWeight(DEFAULT_STOKE_WT);
            stroke(GREY);
            break;
          case MAX_EDGE_WT:  
            strokeWeight(DEFAULT_STOKE_WT);
            stroke(GREY);
            break;
          default:
            //strokeWeight(DEFAULT_STOKE_WT);
            //stroke(LIGHT_GREY);
            noStroke();
        }
        line(ge.from().xf(), ge.from().yf(), ge.to().xf(), ge.to().yf());
      }
      popStyle();
    }
  }

  void drawShortTermMemory() {
    pushStyle();
    noStroke();
    fill(GREY);
    rect(0, 0, shortTermMemory.size() * TASK_NODE_SIZE + 4, TASK_NODE_SIZE); 
    fill(0);

    translate(TASK_NODE_SIZE * 0.5 + 2, TASK_NODE_SIZE * 0.5);
    for (int i = 0; i < shortTermMemory.size(); i ++) {
      KnowledgeNode node = shortTermMemory.get(i);

      pushMatrix();
      translate(50 - 17 - TASK_NODE_SIZE * 1.5, 50 + 20 + TASK_NODE_SIZE * 0.5 - 5); // ?? simplify red square visual!
      strokeWeight(DEFAULT_STOKE_WT + 2);
      stroke(RED[0], RED[1], RED[2]);
      noFill();
      rectMode(CENTER);
      rect(node.xf(), node.yf(), NODE_SIZE, NODE_SIZE);
      popMatrix();

      noStroke();
      fill(BG_COLOR);
      rectMode(CENTER);
      rect(i * TASK_NODE_SIZE, 0, TASK_NODE_SIZE * 0.8, TASK_NODE_SIZE * 0.8);
      int r, g, b;
      // set color based on knowledgeNode type
      switch (node.getKnowledgeType()) {
      case DIRECTORY_K:
        r = BLUE[0];
        g = BLUE[1];
        b = BLUE[2];
        break; 
      case PRACTICAL_K:
        r = YELLOW[0];
        g = YELLOW[1];
        b = YELLOW[2];
        break;
      case THEORY_K:
        r = GREEN[0];
        g = GREEN[1];
        b = GREEN[2];
        break;
      default:
        r = 255;
        g = 255;
        b = 255;
      }

      if (node.hasKnowledge() == 0) {
        fill(r, g, b);
        rectMode(CENTER);
        rect(i * TASK_NODE_SIZE, 0, TASK_NODE_SIZE * 0.7, TASK_NODE_SIZE * 0.7);
        fill(BG_COLOR);
        rect(i * TASK_NODE_SIZE, 0, TASK_NODE_SIZE * 0.6, TASK_NODE_SIZE * 0.6);
      } else {
        noStroke();
        fill(r, g, b);
        rectMode(CENTER);
        rect(i * TASK_NODE_SIZE, 0, TASK_NODE_SIZE * 0.7, TASK_NODE_SIZE * 0.7);
      }
      if (TASK_NODE_SIZE >= 30) {
        fill(0);
        textSize(11);
        textAlign(CENTER);
        //text(((KnowledgeNode)node).getLastAccessed(), i * TASK_NODE_SIZE - 1, 4);
        text((node.id()), i * TASK_NODE_SIZE - 1, 4);
      }
    }
    popStyle();
  }
}
