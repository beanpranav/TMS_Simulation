class GraphExtended extends Graph {
  HashMap<String,Integer> timeMap = new HashMap<String,Integer>();
  
  public GraphExtended() {
    super();
  }
  
  public GraphExtended(int nbrNodes) {
    super(nbrNodes);
  }

  @Override
  public boolean addEdge(int fromID, int toID, double costOutward, double costInward) {
    boolean result = super.addEdge(fromID, toID, costOutward, costInward);
    if (result) {
      timeMap.put("" + fromID + toID, TIME);
      timeMap.put("" + toID + fromID, TIME);
      return true;
    } else {
      return false;
    }
  }
  
  public synchronized int getEdgeTime(int fromID, int toID) {
    return timeMap.get("" + fromID + toID);
  }
  
  public synchronized void resetEdgeTime(int fromID, int toID) {
    timeMap.put("" + fromID + toID, TIME);
  }

}