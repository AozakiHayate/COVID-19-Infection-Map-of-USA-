//米国の地図にマルを描画
//マウスによるインタラクション機能を追加します

PImage mapImage;
Table locationTable;
int rowCount;


Table dataTable;
Table nameTable;

float dataMin = MAX_FLOAT; 
float dataMax = MIN_FLOAT; 

boolean DataBase = false;
boolean MyGithub = false;


void setup(){
  size(640,600); 
 

  mapImage = loadImage("map.png");
  locationTable = new Table("locations.tsv");
  rowCount = locationTable.getRowCount();

  //米国の各州の正式名称の書かれたファイルをロード
  nameTable = new Table("names.tsv");
  
  //２０２１年６月９日現時点米国の各州の感染者人数
  dataTable = new Table("infected.tsv");
  
  for(int row = 0; row < rowCount; row++){
    
    float value = dataTable.getFloat(row, 1);
    
    if(value > dataMax){
      dataMax = value;
    }
 
    if(value < dataMin){
      dataMin = value;
    }
  }
  
}


//ここからメインループ
void draw(){
  
  background(255);
  image(mapImage, 0, 0);
  
  smooth();
  noStroke();
  
  
  
  
  for(int row=0; row < rowCount; row++){
   String abbrev = dataTable.getRowName(row);
   float x = locationTable.getFloat(row,1);
   float y = locationTable.getFloat(row,2);
   drawData(x, y, abbrev); 
  }
  
}

//マルの描画のための関数
//正負を区別して描画
void drawData(float x, float y, String abbrev){

  float value = dataTable.getFloat(abbrev, 1);
  float radius = 0;
  

//円のサイズがmap関数使って、各州の感染者数データから
//見やすいサイズ5-50に写像する。
  radius = map(value, 0, dataMax, 5, 50);
//円の透明度と色を感染者データより人に見やすくように設定した
  fill(180+radius,0,0,30+radius*3);
  

  ellipseMode(RADIUS);
  ellipse(x, y, radius, radius);
  
  
  if(dist(x,y,mouseX, mouseY) < radius+2){
    fill(0);
    textAlign(CENTER);
    //各州の正式名称を表示するように変更
    String name = nameTable.getString(abbrev, 1);
    text(name + " " + value, x, y-radius-4);
  }


if(DataBase == true) {
    
    fill(100,0,0,150);
  } else {
    fill(0,0,100,50);
  }
  rect(40, 500, 80, 80);

  
  // MyGithub
  if(MyGithub == true) {
    fill(255,0,0,50);
  } else {
    fill(100,200,0,50);
  }
  rect(180, 500, 80, 80);
beginShape();
vertex(180+100, 82+450);
vertex(207+100, 36+450);
vertex(214+100, 63+450);
vertex(407+100, 11+450);
vertex(412+100, 30+450);
vertex(219+100, 82+450);
vertex(226+100, 109+450);
fill(255, 255, 255);
textSize(15);
text("COVID-19", 80, 530);
text("DATA", 80, 560);
fill(1, 1, 1);
text("My", 220, 530);
text("GitHub", 220, 560);
fill(1, 1, 1);
textSize(30);
text("To Visit My GitHub", 250, 440);
endShape(CLOSE); 

textSize(15);

}



class Table {
  String[][] data;
  int rowCount;
  
  
  Table() {
    data = new String[10][10];
  }

  
  Table(String filename) {
    String[] rows = loadStrings(filename);
    data = new String[rows.length][];
    
    for (int i = 0; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }
      
      // split the row on the tabs
      String[] pieces = split(rows[i], TAB);
      // copy to the table array
      data[rowCount] = pieces;
      rowCount++;
      
      // this could be done in one fell swoop via:
      //data[rowCount++] = split(rows[i], TAB);
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
  }


  int getRowCount() {
    return rowCount;
  }
  
  
  // find a row by its name, returns -1 if no row found
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (data[i][0].equals(name)) {
        return i;
      }
    }
    println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  String getRowName(int row) {
    return getString(row, 0);
  }


  String getString(int rowIndex, int column) {
    return data[rowIndex][column];
  }

  
  String getString(String rowName, int column) {
    return getString(getRowIndex(rowName), column);
  }

  
  int getInt(String rowName, int column) {
    return parseInt(getString(rowName, column));
  }

  
  int getInt(int rowIndex, int column) {
    return parseInt(getString(rowIndex, column));
  }

  
  float getFloat(String rowName, int column) {
    return parseFloat(getString(rowName, column));
  }

  
  float getFloat(int rowIndex, int column) {
    return parseFloat(getString(rowIndex, column));
  }
  
  
  void setRowName(int row, String what) {
    data[row][0] = what;
  }


  void setString(int rowIndex, int column, String what) {
    data[rowIndex][column] = what;
  }

  
  void setString(String rowName, int column, String what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = what;
  }

  
  void setInt(int rowIndex, int column, int what) {
    data[rowIndex][column] = str(what);
  }

  
  void setInt(String rowName, int column, int what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }

  
  void setFloat(int rowIndex, int column, float what) {
    data[rowIndex][column] = str(what);
  }


  void setFloat(String rowName, int column, float what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }
  
  
  // Write this table as a TSV file
  void write(PrintWriter writer) {
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < data[i].length; j++) {
        if (j != 0) {
          writer.print(TAB);
        }
        if (data[i][j] != null) {
          writer.print(data[i][j]);
        }
      }
      writer.println();
    }
    writer.flush();
  }
}


void mousePressed() 
{
  if(DataBase) { 
    link("https://www.worldometers.info/coronavirus/country/us/");
  } else if (MyGithub) {
    link("https://github.com/AozakiHayate");
  }
}

void mouseMoved() { 
  checkButtons(); 
}
  
void mouseDragged() {
  checkButtons(); 
}

void checkButtons() {
  if(mouseX > 40 && mouseX < 120 &&
     mouseY > 500 && mouseY <580) {
    DataBase = true;   
  }  else if (mouseX > 180 && mouseX < 260 &&
     mouseY > 500 && mouseY <580) {
    MyGithub = true; 
  } else {
    DataBase = MyGithub = false;
  }

}

