import 'package:flutter/material.dart';
import 'mycolor.dart';
import 'tile.dart';
import 'grid.dart';
import 'game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<List<int>> grid = [];
  List<List<int>> gridNew = [];
  SharedPreferences sharedPreferences;
  int score = 0;
  bool isgameOver = false;
  bool isgameWon = false;

  List<Widget> getGrid(double width, double height) {
    List<Widget> grids = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int num = grid[i][j];
        String number;
        int color;
        if (num == 0) {
          color = MyColor.emptyGridBackground;
          number = "";
        } 
        else if (num == 2) {
          color =MyColor.two1;
          number = "${num}";
        }
        else if (num == 4) {
          color = MyColor.four1;
          number = "${num}";
        }
        else if (num == 8) {
          color = MyColor.eight1;
          number = "${num}";
        }
        else if (num == 16) {
          color = MyColor.six1;
          number = "${num}";
        }
        else if (num == 32) {
          color = MyColor.three1;
          number = "${num}";
        }
        else if (num == 64) {
          color = MyColor.six4;
          number = "${num}";
        }
         else if (num == 256||num== 128) {
          color = MyColor.onetwo;
          number = "${num}";
        } else if (num == 1024) {
          color = MyColor.gridColorSixteenThirtyTwoOneZeroTwoFour;
          number = "${num}";
        } else if (num == 512) {
          color = MyColor.five1;
          number = "${num}";
        } else {
          color = MyColor.gridColorWin;
          number = "${num}";
        }
        double size;
        String n = "${number}";
        switch (n.length) {
          case 1:
          case 2:
            size = 40.0;
            break;
          case 3:
            size = 30.0;
            break;
          case 4:
            size = 20.0;
            break;
        }
        if(num==2||num==4)
        grids.add(Tile(number, width, height, color, size,0xFF766c62));
        else
        grids.add(Tile(number, width, height, color, size,0xFFFFFFFF));
      }
    }
    return grids;
  }

  void handleGesture(int direction) {
    /*
    
      0 = up
      1 = down
      2 = left
      3 = right

    */
    bool flipped = false;
    bool played = true;
    bool rotated = false;
    if (direction == 0) {
      setState(() {
        grid = transposeGrid(grid);
        grid = flipGrid(grid);
        rotated = true;
        flipped = true;
      });
    } else if (direction == 1) {
      setState(() {
        grid = transposeGrid(grid);
        rotated = true;
      });
    } else if (direction == 2) {
    } else if (direction == 3) {
      setState(() {
        grid = flipGrid(grid);
        flipped = true;
      });
    } else {
      played = false;
    }

    if (played) {
      print('playing');
      List<List<int>> past = copyGrid(grid);
      print('past ${past}');
      for (int i = 0; i < 4; i++) {
        setState(() {
          List result = operate(grid[i], score, sharedPreferences);
          score = result[0];
          print('score in set state ${score}');
          grid[i] = result[1];
        });
      }
      setState(() {
        grid = addNumber(grid, gridNew);
      });
      bool changed = compare(past, grid);
      print('changed ${changed}');
      if (flipped) {
        setState(() {
          grid = flipGrid(grid);
        });
      }

      if (rotated) {
        setState(() {
          grid = transposeGrid(grid);
        });
      }

      if (changed) {
        setState(() {
          grid = addNumber(grid, gridNew);
          print('is changed');
        });
      } else {
        print('not changed');
      }

      bool gameover = isGameOver(grid);
      if (gameover) {
        print('game over');
        setState(() {
          isgameOver = true;
        });
      }

      bool gamewon = isGameWon(grid);
      if (gamewon) {
        print("GAME WON");
        setState(() {
          isgameWon=true;          
        });
      }
      print(grid);
      print(score);
    }
  }

  @override
  void initState() {
    grid = blankGrid();
    gridNew = blankGrid();
    addNumber(grid, gridNew);
    addNumber(grid, gridNew);
    super.initState();
  }

  Future<String> getHighScore() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int score = sharedPreferences.getInt('high_score');
    if (score == null) {
      score = 0;
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double gridWidth = (width - 80) / 4;
    double gridHeight = gridWidth;
    double height = 30 + (gridHeight * 4) + 20;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '2048',
          style: TextStyle(fontSize: 45.0, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(MyColor.gridBackground),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.fromLTRB(15,20,15,20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0,60,0,40),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children:[
                  Text("2048",textAlign: TextAlign.left
                  ,style:TextStyle(color:Color(0xFFbbaba0),fontSize:55,fontWeight: FontWeight.w400)),
                  SizedBox(width:42),
                  Container(
                    width: 95,
                    height:60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(MyColor.gridBackground),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'High Score',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          FutureBuilder<String>(
                            future: getHighScore(),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                );
                              } else {
                                return Text(
                                  '0',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width:10),
                  Container(
                width: 90.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(MyColor.gridBackground),
                ),
                height: 60.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top:5.0, bottom: 5.0),
                      child: Text(
                        'Score',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '$score',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
                  ],
                  ) 
              
            ),
            Container(
              height: height,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(7.5),
                    child: GestureDetector(
                      child: GridView.count(
                        primary: false,
                        crossAxisSpacing: 7.5,
                        mainAxisSpacing: 7.5,
                        crossAxisCount: 4,
                        children: getGrid(gridWidth, gridHeight),
                      ),
                      onVerticalDragEnd: (DragEndDetails details) {
                        //primaryVelocity -ve up +ve down
                        if (details.primaryVelocity < 0) {
                          handleGesture(0);
                        } else if (details.primaryVelocity > 0) {
                          handleGesture(1);
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        //-ve right, +ve left
                        if (details.primaryVelocity > 0) {
                          handleGesture(2);
                        } else if (details.primaryVelocity < 0) {
                          handleGesture(3);
                        }
                      },
                    ),
                  ),
                  isgameOver
                      ? Container(
                          height: height,
                          color: Color(MyColor.transparentWhite),
                          child: Center(
                            child: Text(
                              'Game over!',
                              style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(MyColor.gridBackground)),
                            ),
                          ),
                        )
                      : SizedBox(),
                  isgameWon
                      ? Container(
                          height: height,
                          color: Color(MyColor.transparentWhite),
                          child: Center(
                            child: Text(
                              'You Won!',
                              style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(MyColor.gridBackground)),
                            ),
                          ),
                        )
                      : SizedBox(),    
                ],
              ),
              color: Color(MyColor.gridBackground),
            ),
                  SizedBox(height: 20,), 
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Color(MyColor.gridBackground),
                    ),
                    child: IconButton(
                        iconSize: 35.0,
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            grid = blankGrid();
                            gridNew = blankGrid();
                            grid = addNumber(grid, gridNew);
                            grid = addNumber(grid, gridNew);
                            score = 0;
                            isgameOver=false;
                            isgameWon=false;
                          });
                        },
                      ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
