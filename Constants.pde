// simulation constants
public final int SIM_COUNT = 1;
public int TIME = 0;

public final int[] TMS_LEVEL = new int[]{0,1,2,3};
public int tmsl = 1; // 0 - 3
public final String[] TMS_STRUCTURE = new String[]{"HOMOGENEOUS","HETEROGENEOUS"};
public int tms = 0; // 0 - 1
public final String[] TEAM_STRUCTURE = new String[]{"CLIQUE","WHEEL","SUBGROUPS"};
public int tc = 0; // 0 - 2
public final String[] TEAM_MANAGEMENT = new String[]{"EGALITARIAN","AUTHORITARIAN"};
public int tm = 0; // 0 - 1
public final int[] COMPLEXITY_LEVEL = new int[] {1,2,5};   // 1 - NO_OF_DOMAINS 
                   //1=Divisible, 2=LowComplexity, 4=HighComplexity
public int cl = 1; // 0 - 2
public final String[] TASK_TYPE = new String[]{"Repeating", "Non-Repeating"};
public int tt = 1; // 0 - 1
public final int[][] DIFFICULTY_LEVEL = new int[][] {{1,1},{1,2},{3,4},{1,5}};
public int dl = 3; // 0 - 2, 3=all

public final int DOMAIN_HEIGHT = 5;
public final int NO_OF_DOMAINS = 5;
public IntList TASK_LEVELS = new IntList(1,2,3,4,5); //1 - upto no of domains
public final int JOB_SIZE = 5; // 5

public final boolean CREATE_ALLOCATION = false;
public final boolean ALLOW_TRANSACTIVE_PROCESS = true;

public final int TEAM_SIZE = 5; // 5
public final int INTRO_THRESHOLD = 3;
public final int LEADER_ID = 1;

public final int SIZE_OF_SHORT_TERM_MEMORY = 3;

// team specialization distributions
public final  int[][] specD_2 = new int[][] {{1,2,3},{4,5}};
public final  int[][] specD_3 = new int[][] {{1},{2,3},{4,5}};
public final  int[][] specD_4 = new int[][] {{1},{2},{3},{4,5}};
public final  int[][] specD_5 = new int[][] {{1},{2},{3},{4},{5}};
public final  int[][] specD_6 = new int[][] {{1},{2},{3},{4},{5},{3}};
public final  int[][] specD_7 = new int[][] {{1},{2},{3},{4,5},{2},{3},{4,5}};
public final  int[][] specD_9 = new int[][] {{1},{2},{3},{4},{5},{2},{3},{4},{5}};

// edge weights
public final int DEAD_EDGE_WT = 100;
public final int MAX_EDGE_WT = 10;
public final int MID_EDGE_WT = 35;  //25
public final int MIN_EDGE_WT = 50;
  
// visualization constants
public final int NODE_SIZE = 20;       // 20 - 30
public final int TASK_NODE_SIZE = 40;  // 40 - 50
public final int DEFAULT_STOKE_WT = 1;
public final int NODE_HEIGHT_OFFSET = DOMAIN_HEIGHT - 1;    // (domainHeight - 1) * NODE_SIZE * 2
public final float MEMBER_BREADTH = 3;   // (NO_OF_DOMAINS - 2) * NODE_SIZE * 2
public final int MEMBER_HEIGHT = NODE_HEIGHT_OFFSET + 4;    // (NODE_HEIGHT_OFFSET + 1 + 3) * NODE_SIZE * 2

// colors
public final int GREY = 167;
public final int LIGHT_GREY = 230;
public final int BG_COLOR = 255;
public final int[] BLUE = {176,224,230};  //{0,161,241};
public final int[] GREEN = {124,187,0};   //{52,168,83};
public final int[] YELLOW = {255,187,0};  //{251,188,5};
public final int[] RED = {246,83,20};     //{234,67,53};

// static functions

private static int FindSmallest (int[] memberCosts) {
  IntList indexes = new IntList();
  indexes.append(0);
  int min = memberCosts[0];
  for (int i = 1; i < memberCosts.length; i++) {
    if (memberCosts[i] < min ) {
      min = memberCosts[i];
      indexes = new IntList();
      indexes.append(i);
    } else if (memberCosts[i] == min ) {
      indexes.append(i);
    }
 }
 int rand = new Random().nextInt(indexes.size());
 return indexes.get(rand);
}

//private static float CalculateAverage(FloatList array) {
//  float sum = 0;
//  int count = 0;
//  for (float i : array) {
//    if (i >= 0) { 
//      sum += i;
//      count += 1;
//    }
//  }
//  return (count == 0) ? 0 : (sum / count);
//}

//private static FloatList MergeLists(FloatList f1, FloatList f2) {
//  for (float i : f2) {
//    f1.append(i); 
//  }
//  return f1;
//}
