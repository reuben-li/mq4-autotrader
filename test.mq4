//+------------------------------------------------------------------+
//|                                             UltimateTool.mq4 |
//|                                      Copyright � 2011, Reuben Li |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2011, Reuben Li"
#property link      ""


extern string _FixedDate = "2010.06.09 00:00";
extern int _RegressionDegree = 3;
extern double _kdev = 1.618;
extern double _kdev2 = 2.618;
extern double _kdev3 = 3.618;
extern color _StdChannelColor = Green;
extern color _RegressionColor1 = Aqua;
extern color _RegressionColor2 = Red;
extern color _RegressionColor3 = 0x0000a0;
extern color _FillColor1 = 0x300000;
extern color _FillColor2 = 0x000030;
extern bool _CenterLine = true;
extern bool _FutureCenterLine = false;
extern bool _UseFixedDate = false;
extern double lots = 0.01;
extern double TakeProfits=0.3;
extern double StopLoss=0.5;


//------------------------------------------
double fx,fx1,nfx,nfx1;
double a[10,10],b[10],x[10],sx[20];
double sum,sum1,sq, sq2,sq3; 
int p,nn,kt;
//---------------------
int i0,ip,pn,i0n,ipn;
int t0,tp,te,te1, strh;
string str;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
//----
   if(_UseFixedDate){
     datetime _time = StrToTime(_FixedDate);
 //   _Period = iBarShift(NULL, Period(), _time, false);
   }
   
   p = _Period;
   str = p+","+_RegressionDegree+","+DoubleToStr(_kdev,3);  //converts parameters to a string e.g. "250,3,3.618"
    

IndicatorShortName("X_NonLinearRegression_v2.0.1("+str+")");
//--- too small history
if(p>Bars) {
  Comment("\n\n                    ERROR - TOO SMALL HISTORY, RETURN NOW!"); // if period > number of bars in current chart
  return(-1); // then exit
}

//----------------------ar------------------------------
  kt=Period()*60; // Period = amount of minutes. Conversion to seconds. e.g. 5min = 300 seconds
  nn=_RegressionDegree+1; 
  //----------------------
  t0=Time[0];    // Array containing opentime in seconds. current bar = Time[0]
  i0=iBarShift(Symbol(),Period(),t0);  //search for bar that with time specified. i0 = 0
  ip=i0+p;    //shift time back by period number
  tp=Time[ip]; // look for open time 250 bars ago
  pn=p;  //duplicate variable
  
  
  //----------------------ar------------------------------
  
  ObjectCreate("_stdDev("+str+")",6,0,Time[0],0,Time[0],0); //creates window object, typ 6 = stdev channel
  ObjectSet("_stdDev("+str+")",OBJPROP_RAY,0);  
 
  
  for (int j=-p/2; j<p; j++)  // -125 all the way to 249. ~375 points => Time = 250 days ago to 125 days into the future
  {
    ObjectCreate("_ar("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_ar("+str+")"+j,OBJPROP_RAY,0);  
    ObjectSet("_ar("+str+")"+j,OBJPROP_STYLE,STYLE_DOT);  
    ObjectCreate("_arH("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_arH("+str+")"+j,OBJPROP_RAY,0);
    ObjectCreate("_arL("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_arL("+str+")"+j,OBJPROP_RAY,0);  
    
    ObjectCreate("_arL2("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_arL2("+str+")"+j,OBJPROP_RAY,0); 
    ObjectCreate("_arH2("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_arH2("+str+")"+j,OBJPROP_RAY,0); 
    ObjectCreate("_arL3("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_arL3("+str+")"+j,OBJPROP_RAY,0); 
    ObjectCreate("_arH3("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
    ObjectSet("_arH3("+str+")"+j,OBJPROP_RAY,0); 

    ObjectCreate("_arLF1_1("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arLF1_1("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arLF1_1("+str+")"+j,OBJPROP_BACK,true);
    ObjectCreate("_arHF1_1("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arHF1_1("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arHF1_1("+str+")"+j,OBJPROP_BACK,true);
    ObjectCreate("_arLF1_2("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arLF1_2("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arLF1_2("+str+")"+j,OBJPROP_BACK,true);
    ObjectCreate("_arHF1_2("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arHF1_2("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arHF1_2("+str+")"+j,OBJPROP_BACK,true);
    
    ObjectCreate("_arLF2_1("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arLF2_1("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arLF2_1("+str+")"+j,OBJPROP_BACK,true);
    ObjectCreate("_arHF2_1("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arHF2_1("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arHF2_1("+str+")"+j,OBJPROP_BACK,true);
    ObjectCreate("_arLF2_2("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arLF2_2("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arLF2_2("+str+")"+j,OBJPROP_BACK,true);
    ObjectCreate("_arHF2_2("+str+")"+j,OBJ_TRIANGLE,0,Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
    ObjectSet("_arHF2_2("+str+")"+j,OBJPROP_RAY,0); 
    ObjectSet("_arHF2_2("+str+")"+j,OBJPROP_BACK,true);
    
   
    
  }
//----

return(0);
}

int deinit() {


ObjectDelete("_stdDev("+str+")"); 
  for (int j=p; j>=-p/2; j--)
  { 
    ObjectDelete("_ar("+str+")"+j);
    ObjectDelete("_arH("+str+")"+j);
    ObjectDelete("_arL("+str+")"+j);
    ObjectDelete("_arL2("+str+")"+j);
    ObjectDelete("_arH2("+str+")"+j);
    ObjectDelete("_arL3("+str+")"+j);
    ObjectDelete("_arH3("+str+")"+j);
        
    ObjectDelete("_arLF1_1("+str+")"+j);
    ObjectDelete("_arHF1_1("+str+")"+j);
    ObjectDelete("_arLF1_2("+str+")"+j);
    ObjectDelete("_arHF1_2("+str+")"+j);
    
    ObjectDelete("_arLF2_1("+str+")"+j);
    ObjectDelete("_arHF2_1("+str+")"+j);
    ObjectDelete("_arLF2_2("+str+")"+j);
    ObjectDelete("_arHF2_2("+str+")"+j);

  }
  Comment("");
return(0);
}

//+------------------------------------------------------------------+

int start() {
   
int counted_bars = IndicatorCounted();  //number of bars at start
if ( Bars - counted_bars > 1) {
  ObjectDelete("_stdDev("+str+")");
  for (int jj=p; jj>=-p/2; jj--)
  { 
    ObjectDelete("_ar("+str+")"+jj);
    ObjectDelete("_arH("+str+")"+jj);
    ObjectDelete("_arL("+str+")"+jj);
    ObjectDelete("_arL2("+str+")"+jj);
    ObjectDelete("_arH2("+str+")"+jj);
    ObjectDelete("_arL3("+str+")"+jj);
    ObjectDelete("_arH3("+str+")"+jj);

    ObjectDelete("_arLF1_1("+str+")"+jj);
    ObjectDelete("_arHF1_1("+str+")"+jj);
    ObjectDelete("_arLF1_2("+str+")"+jj);
    ObjectDelete("_arHF1_2("+str+")"+jj);
    
    ObjectDelete("_arLF2_1("+str+")"+jj);
    ObjectDelete("_arHF2_1("+str+")"+jj);
    ObjectDelete("_arLF2_2("+str+")"+jj);
    ObjectDelete("_arHF2_2("+str+")"+jj);
    
  }
  Sleep(5000);
  init();
}

//=================================================================
  int i,n,k,ticket;
  //---- 
 
    if (i0n!=i0 || ipn!=ip)
    {
      p=ip-i0;
      i0n=ip;
      ipn=ip;
      //--------------------------------------------------------
      if (pn<p)
      {
        ObjectCreate("_stdDev("+str+")",6,0,Time[0],0,Time[0],0);
        ObjectSet("_stdDev("+str+")",OBJPROP_RAY,0);
        for(int j=pn; j<=p; j++) {
          ObjectCreate("_ar("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_ar("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_ar("+str+")"+j,OBJPROP_STYLE,STYLE_DOT);  
          ObjectCreate("_arH("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_arH("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arL("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_arL("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arL2("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_arL2("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arH2("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_arH2("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arL3("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_arL3("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arH3("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0);
          ObjectSet("_arH3("+str+")"+j,OBJPROP_RAY,0);

          
          ObjectCreate("_arLF1_1("+str+")"+j,OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arLF1_1("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arLF1_1("+str+")"+j, OBJPROP_BACK,true);
          ObjectCreate("_arHF1_1("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arHF1_1("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arHF1_1("+str+")"+j,OBJPROP_BACK,true);  
          
          ObjectCreate("_arLF1_2("+str+")"+j,OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arLF1_2("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arLF1_2("+str+")"+j, OBJPROP_BACK,true);
          ObjectCreate("_arHF1_2("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arHF1_2("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arHF1_2("+str+")"+j,OBJPROP_BACK,true);  

          ObjectCreate("_arLF2_1("+str+")"+j,OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arLF2_1("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arLF2_1("+str+")"+j, OBJPROP_BACK,true);
          ObjectCreate("_arHF2_1("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arHF2_1("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arHF2_1("+str+")"+j,OBJPROP_BACK,true);  
          
          ObjectCreate("_arLF2_2("+str+")"+j,OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arLF2_2("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arLF2_2("+str+")"+j, OBJPROP_BACK,true);
          ObjectCreate("_arHF2_2("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0);
          ObjectSet("_arHF2_2("+str+")"+j, OBJPROP_RAY,0);
          ObjectSet("_arHF2_2("+str+")"+j,OBJPROP_BACK,true);  

        }  
        
        for (j=-pn/2; j>=-p/2; j--) {
          ObjectCreate("_ar("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_ar("+str+")"+j,OBJPROP_RAY,0); 
          ObjectSet("_ar("+str+")"+j,OBJPROP_STYLE,STYLE_DOT);  
          ObjectCreate("_arH("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_arH("+str+")"+j,OBJPROP_RAY,0); 
          ObjectCreate("_arL("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_arL("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arL2("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_arL2("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arH2("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_arH2("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arL3("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_arL3("+str+")"+j,OBJPROP_RAY,0);
          ObjectCreate("_arH3("+str+")"+j,2,0,Time[i0+1+j],0,Time[i0+j],0); 
          ObjectSet("_arH3("+str+")"+j,OBJPROP_RAY,0);

          ObjectCreate("_arLF1_1("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arLF1_1("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arLF1_1("+str+")"+j,OBJPROP_BACK,true);
          ObjectCreate("_arHF1_1("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arHF1_1("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arHF1_1("+str+")"+j,OBJPROP_BACK,true);
          ObjectCreate("_arLF1_2("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arLF1_2("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arLF1_2("+str+")"+j,OBJPROP_BACK,true);
          ObjectCreate("_arHF1_2("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arHF1_2("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arHF1_2("+str+")"+j,OBJPROP_BACK,true);

          ObjectCreate("_arLF2_1("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arLF2_1("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arLF2_1("+str+")"+j,OBJPROP_BACK,true);
          ObjectCreate("_arHF2_1("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arHF2_1("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arHF2_1("+str+")"+j,OBJPROP_BACK,true);
          ObjectCreate("_arLF2_2("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arLF2_2("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arLF2_2("+str+")"+j,OBJPROP_BACK,true);
          ObjectCreate("_arHF2_2("+str+")"+j, OBJ_TRIANGLE,0, Time[i0+1+j],0, Time[i0+j],0, Time[i0+j],0); 
          ObjectSet("_arHF2_2("+str+")"+j,OBJPROP_RAY,0);
          ObjectSet("_arHF2_2("+str+")"+j,OBJPROP_BACK,true);
          
        } 
        pn=p;    
      }
      if (pn>p)
      {
        ObjectDelete("_stdDev("+str+")");
        for(j=pn; j>=p; j--) {
          ObjectDelete("_ar("+str+")"+j); 
          ObjectDelete("_arH("+str+")"+j); 
          ObjectDelete("_arL("+str+")"+j);
          ObjectDelete("_arL2("+str+")"+j);
          ObjectDelete("_arH2("+str+")"+j);
          ObjectDelete("_arL3("+str+")"+j);
          ObjectDelete("_arH3("+str+")"+j);
          
          ObjectDelete("_arLF1_1("+str+")"+j);
          ObjectDelete("_arHF1_1("+str+")"+j);
          ObjectDelete("_arLF1_2("+str+")"+j);
          ObjectDelete("_arHF1_2("+str+")"+j);
          ObjectDelete("_arLF2_1("+str+")"+j);
          ObjectDelete("_arHF2_1("+str+")"+j);
          ObjectDelete("_arLF2_2("+str+")"+j);
          ObjectDelete("_arHF2_2("+str+")"+j);
        }
        
        for (j=-p/2; j>=-pn/2; j--) {
          ObjectDelete("_ar("+str+")"+j); 
          ObjectDelete("_arH("+str+")"+j); 
          ObjectDelete("_arL("+str+")"+j);
          ObjectDelete("_arL2("+str+")"+j);
          ObjectDelete("_arH2("+str+")"+j);
          ObjectDelete("_arL3("+str+")"+j);
          ObjectDelete("_arH3("+str+")"+j);
          
          ObjectDelete("_arLF1_1("+str+")"+j);
          ObjectDelete("_arHF1_1("+str+")"+j);
          ObjectDelete("_arLF1_2("+str+")"+j);
          ObjectDelete("_arHF1_2("+str+")"+j);
          ObjectDelete("_arLF2_1("+str+")"+j);
          ObjectDelete("_arHF2_1("+str+")"+j);
          ObjectDelete("_arLF2_2("+str+")"+j);
          ObjectDelete("_arHF2_2("+str+")"+j);
          
        }   
        pn=p;
      }
    }
    //======================PR================================================
    sx[1]=p+1;
    //----------------------sx------------------------------------------------
    for(i=1; i<=nn*2-2; i++) 
    {
      sum=0.0; 
      for(n=i0; n<=i0+p; n++) sum+=MathPow(n,i); 
      sx[i+1]=sum;
    }  
    //----------------------syx-----------------------------------------------
    for(i=1; i<=nn; i++) 
    {
      sum=0.0; 
      for(n=i0; n<=i0+p; n++) 
      {
        if (i==1) sum+=Close[n]; 
        else 
        sum+=Close[n]*MathPow(n,i-1);
      } 
      b[i]=sum;
    } 
    //===============Matrix==================================================
    for(j=1; j<=nn; j++) 
    {
      for(i=1; i<=nn; i++) {k=i+j-1; a[i,j]=sx[k];}
    }  
    //===============Gauss===================================================
    af_Gauss(nn,a,b,x);
    //=======================SQ==============================================
    sq=0.0;
    for (n=p; n>=0; n--)
    {
      sum=0.0;
      for(k=1; k<=_RegressionDegree; k++) {
        sum+=x[k+1]*MathPow(i0+n,k); 
        sum1+=x[k+1]*MathPow(i0+n+1,k);
      }
      fx=x[1]+sum;
      sq+=MathPow(Close[n+i0]-fx,2);
    }
    sq3 = _kdev3 * MathSqrt(sq/(p+1));
    sq2 = _kdev2 * MathSqrt(sq/(p+1));
    sq = _kdev * MathSqrt(sq/(p+1)); 
   //---
//=======================================================================

   ObjectMove("_stdDev("+str+")",0,Time[i0],0);
   ObjectMove("_stdDev("+str+")",1,Time[0],0);
    
    //CURRENT VALUE EDIT
    for (n=p; n>=i0; n--) 
    {
      sum=0.0; 
      sum1=0.0; 
      for(k=1; k<=_RegressionDegree; k++) {
        sum+=x[k+1]*MathPow(i0+n,k); 
        sum1+=x[k+1]*MathPow(i0+n+1,k);
      }  
    
    nfx=x[1]+sum;
    nfx1=x[1]+sum1;
    
    }
    
    
    for (n=p; n>=-p/2; n--) 
    {
      sum=0.0; 
      sum1=0.0; 
      for(k=1; k<=_RegressionDegree; k++) {
        sum+=x[k+1]*MathPow(i0+n,k); 
        sum1+=x[k+1]*MathPow(i0+n+1,k);
      }  
     
      fx=x[1]+sum;
      fx1=x[1]+sum1;
      
      
      if (n>=0 && n<p)
      {
		  //CENTRELINE DEFINED ar = centreline arH = high line arL = low line
         if(_CenterLine){              
            ObjectMove("_ar("+str+")"+n,0,Time[n+i0+1],fx1); 
            ObjectMove("_ar("+str+")"+n,1,Time[n+i0],fx);
            
        }
        ObjectMove("_arH("+str+")"+n,0,Time[n+i0+1],fx1+sq); 
        ObjectMove("_arH("+str+")"+n,1,Time[n+i0],fx+sq);
        ObjectMove("_arL("+str+")"+n,0,Time[n+i0+1],fx1-sq); 
        ObjectMove("_arL("+str+")"+n,1,Time[n+i0],fx-sq);
        ObjectMove("_arL2("+str+")"+n,0,Time[n+i0+1],fx1-sq2); 
        ObjectMove("_arL2("+str+")"+n,1,Time[n+i0],fx-sq2);
        ObjectMove("_arH2("+str+")"+n,0,Time[n+i0+1],fx1+sq2); 
        ObjectMove("_arH2("+str+")"+n,1,Time[n+i0],fx+sq2);
        ObjectMove("_arL3("+str+")"+n,0,Time[n+i0+1],fx1-sq3); 
        ObjectMove("_arL3("+str+")"+n,1,Time[n+i0],fx-sq3);
        ObjectMove("_arH3("+str+")"+n,0,Time[n+i0+1],fx1+sq3); 
        ObjectMove("_arH3("+str+")"+n,1,Time[n+i0],fx+sq3);

        
        //Filling
        ObjectMove("_arLF1_1("+str+")"+n,0, Time[n+i0+1],fx1-sq); 
        ObjectMove("_arLF1_1("+str+")"+n,1, Time[n+i0],fx-sq);
        ObjectMove("_arLF1_1("+str+")"+n,2, Time[n+i0+1],fx1-sq2);
        ObjectMove("_arLF1_2("+str+")"+n,0, Time[n+i0+1],fx1-sq2); 
        ObjectMove("_arLF1_2("+str+")"+n,1, Time[n+i0],fx-sq2);
        ObjectMove("_arLF1_2("+str+")"+n,2, Time[n+i0],fx-sq);
        
        ObjectMove("_arHF1_1("+str+")"+n,0, Time[n+i0+1],fx1+sq); 
        ObjectMove("_arHF1_1("+str+")"+n,1, Time[n+i0],fx+sq);
        ObjectMove("_arHF1_1("+str+")"+n,2, Time[n+i0+1],fx1+sq2);
        ObjectMove("_arHF1_2("+str+")"+n,0, Time[n+i0+1],fx1+sq2); 
        ObjectMove("_arHF1_2("+str+")"+n,1, Time[n+i0],fx+sq2);
        ObjectMove("_arHF1_2("+str+")"+n,2, Time[n+i0],fx+sq);


        ObjectMove("_arLF2_1("+str+")"+n,0, Time[n+i0+1],fx1-sq2); 
        ObjectMove("_arLF2_1("+str+")"+n,1, Time[n+i0],fx-sq2);
        ObjectMove("_arLF2_1("+str+")"+n,2, Time[n+i0+1],fx1-sq3);
        ObjectMove("_arLF2_2("+str+")"+n,0, Time[n+i0+1],fx1-sq3); 
        ObjectMove("_arLF2_2("+str+")"+n,1, Time[n+i0],fx-sq3);
        ObjectMove("_arLF2_2("+str+")"+n,2, Time[n+i0],fx-sq2);
        
        ObjectMove("_arHF2_1("+str+")"+n,0, Time[n+i0+1],fx1+sq2); 
        ObjectMove("_arHF2_1("+str+")"+n,1, Time[n+i0],fx+sq2);
        ObjectMove("_arHF2_1("+str+")"+n,2, Time[n+i0+1],fx1+sq3);
        ObjectMove("_arHF2_2("+str+")"+n,0, Time[n+i0+1],fx1+sq3); 
        ObjectMove("_arHF2_2("+str+")"+n,1, Time[n+i0],fx+sq3);
        ObjectMove("_arHF2_2("+str+")"+n,2, Time[n+i0],fx+sq2);
     

        if(_CenterLine){
          ObjectSet("_ar("+str+")"+n,OBJPROP_COLOR,_RegressionColor1); 
        }
        ObjectSet("_arH("+str+")"+n,OBJPROP_COLOR,_RegressionColor1); 
        ObjectSet("_arL("+str+")"+n,OBJPROP_COLOR,_RegressionColor1);
        ObjectSet("_arL2("+str+")"+n,OBJPROP_COLOR,_RegressionColor2);
        ObjectSet("_arH2("+str+")"+n,OBJPROP_COLOR,_RegressionColor2);
        ObjectSet("_arL3("+str+")"+n,OBJPROP_COLOR,_RegressionColor3);
        ObjectSet("_arH3("+str+")"+n,OBJPROP_COLOR,_RegressionColor3);                  

        ObjectSet("_arLF1_1("+str+")"+n,OBJPROP_COLOR, _FillColor1);
        ObjectSet("_arLF1_2("+str+")"+n,OBJPROP_COLOR, _FillColor1);
        ObjectSet("_arHF1_1("+str+")"+n,OBJPROP_COLOR, _FillColor1);
        ObjectSet("_arHF1_2("+str+")"+n,OBJPROP_COLOR, _FillColor1);  
        ObjectSet("_arLF2_1("+str+")"+n,OBJPROP_COLOR, _FillColor2);
        ObjectSet("_arLF2_2("+str+")"+n,OBJPROP_COLOR, _FillColor2);
        ObjectSet("_arHF2_1("+str+")"+n,OBJPROP_COLOR, _FillColor2);
        ObjectSet("_arHF2_2("+str+")"+n,OBJPROP_COLOR, _FillColor2);  

        
      }
        
      if (n<0)
      {
        if ((n+i0)>=0) 
        {
          if(_CenterLine){           
               ObjectMove("_ar("+str+")"+n,0,Time[n+i0+1],fx1); 
               ObjectMove("_ar("+str+")"+n,1,Time[n+i0],fx);
          }
          ObjectMove("_arH("+str+")"+n,0,Time[n+i0+1],fx1+sq); 
          ObjectMove("_arH("+str+")"+n,1,Time[n+i0],fx+sq);
          ObjectMove("_arL("+str+")"+n,0,Time[n+i0+1],fx1-sq); 
          ObjectMove("_arL("+str+")"+n,1,Time[n+i0],fx-sq);
          ObjectMove("_arL2("+str+")"+n,0,Time[n+i0+1],fx1-sq2); 
          ObjectMove("_arL2("+str+")"+n,1,Time[n+i0],fx-sq2);
          ObjectMove("_arH2("+str+")"+n,0,Time[n+i0+1],fx1+sq2); 
          ObjectMove("_arH2("+str+")"+n,1,Time[n+i0],fx+sq2);
          ObjectMove("_arL3("+str+")"+n,0,Time[n+i0+1],fx1-sq3); 
          ObjectMove("_arL3("+str+")"+n,1,Time[n+i0],fx-sq3);
          ObjectMove("_arH3("+str+")"+n,0,Time[n+i0+1],fx1+sq3); 
          ObjectMove("_arH3("+str+")"+n,1,Time[n+i0],fx+sq3);
        }
        if ((n+i0)<0) 
        {
          te=Time[0]-(n+i0)*kt; 
          te1=Time[0]-(n+i0+1)*kt;
          if(_FutureCenterLine){          
               ObjectMove("_ar("+str+")"+n,0,te1,fx1); 
               ObjectMove("_ar("+str+")"+n,1,te,fx);       
          }
          ObjectMove("_arH("+str+")"+n,0,te1,fx1+sq); 
          ObjectMove("_arH("+str+")"+n,1,te,fx+sq);
          ObjectMove("_arL("+str+")"+n,0,te1,fx1-sq); 
          ObjectMove("_arL("+str+")"+n,1,te,fx-sq);
          ObjectMove("_arL2("+str+")"+n,0,te1,fx1-sq2); 
          ObjectMove("_arL2("+str+")"+n,1,te,fx-sq2);
          ObjectMove("_arH2("+str+")"+n,0,te1,fx1+sq2); 
          ObjectMove("_arH2("+str+")"+n,1,te,fx+sq2);
          ObjectMove("_arL3("+str+")"+n,0,te1,fx1-sq3); 
          ObjectMove("_arL3("+str+")"+n,1,te,fx-sq3);
          ObjectMove("_arH3("+str+")"+n,0,te1,fx1+sq3); 
          ObjectMove("_arH3("+str+")"+n,1,te,fx+sq3);

        } 
          ObjectMove("_arLF1_1("+str+")"+n,0, te1, fx1-sq); 
          ObjectMove("_arLF1_1("+str+")"+n,1, te, fx-sq);
          ObjectMove("_arLF1_1("+str+")"+n,2, te1, fx1-sq2);
          ObjectMove("_arLF1_2("+str+")"+n,0, te1, fx1-sq2); 
          ObjectMove("_arLF1_2("+str+")"+n,1, te, fx-sq2);
          ObjectMove("_arLF1_2("+str+")"+n,2, te, fx-sq);
          
          ObjectMove("_arHF1_1("+str+")"+n,0, te1,fx1+sq); 
          ObjectMove("_arHF1_1("+str+")"+n,1, te,fx+sq);
          ObjectMove("_arHF1_1("+str+")"+n,2, te1,fx1+sq2);
          ObjectMove("_arHF1_2("+str+")"+n,0, te1,fx1+sq2); 
          ObjectMove("_arHF1_2("+str+")"+n,1, te,fx+sq2);
          ObjectMove("_arHF1_2("+str+")"+n,2, te,fx+sq);

          ObjectMove("_arLF2_1("+str+")"+n,0, te1, fx1-sq2); 
          ObjectMove("_arLF2_1("+str+")"+n,1, te, fx-sq2);
          ObjectMove("_arLF2_1("+str+")"+n,2, te1, fx1-sq3);
          ObjectMove("_arLF2_2("+str+")"+n,0, te1, fx1-sq3); 
          ObjectMove("_arLF2_2("+str+")"+n,1, te, fx-sq3);
          ObjectMove("_arLF2_2("+str+")"+n,2, te, fx-sq2);
          
          ObjectMove("_arHF2_1("+str+")"+n,0, te1,fx1+sq2); 
          ObjectMove("_arHF2_1("+str+")"+n,1, te,fx+sq2);
          ObjectMove("_arHF2_1("+str+")"+n,2, te1,fx1+sq3);
          ObjectMove("_arHF2_2("+str+")"+n,0, te1,fx1+sq3); 
          ObjectMove("_arHF2_2("+str+")"+n,1, te,fx+sq3);
          ObjectMove("_arHF2_2("+str+")"+n,2, te,fx+sq2);


        
          if(_FutureCenterLine){
            ObjectSet("_ar("+str+")"+n,OBJPROP_COLOR,_RegressionColor1); 
          }
          ObjectSet("_arH("+str+")"+n,OBJPROP_COLOR,_RegressionColor1); 
          ObjectSet("_arL("+str+")"+n,OBJPROP_COLOR,_RegressionColor1);
          ObjectSet("_arL2("+str+")"+n,OBJPROP_COLOR,_RegressionColor2);
          ObjectSet("_arH2("+str+")"+n,OBJPROP_COLOR,_RegressionColor2);         
          ObjectSet("_arL3("+str+")"+n,OBJPROP_COLOR,_RegressionColor3);
          ObjectSet("_arH3("+str+")"+n,OBJPROP_COLOR,_RegressionColor3);         
                  
          ObjectSet("_arLF1_1("+str+")"+n,OBJPROP_COLOR, _FillColor1);
          ObjectSet("_arHF1_1("+str+")"+n,OBJPROP_COLOR, _FillColor1);
          ObjectSet("_arLF1_2("+str+")"+n,OBJPROP_COLOR, _FillColor1);
          ObjectSet("_arHF1_2("+str+")"+n,OBJPROP_COLOR, _FillColor1);
          ObjectSet("_arLF2_1("+str+")"+n,OBJPROP_COLOR, _FillColor2);
          ObjectSet("_arHF2_1("+str+")"+n,OBJPROP_COLOR, _FillColor2);
          ObjectSet("_arLF2_2("+str+")"+n,OBJPROP_COLOR, _FillColor2);
          ObjectSet("_arHF2_2("+str+")"+n,OBJPROP_COLOR, _FillColor2);

        
      }
      

      
      
      
      //LIMITER
   int total;
            
     total=OrdersTotal();
   if(total<1) 
     {
      // no opened orders identified
      if(AccountFreeMargin()<((1000*lots)))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
        }
     } 
        

      //BUY
      
      
   double SignalCurrent, SignalPrevious, MacdCurrent, MacdPrevious;
    MacdCurrent=iMACD(NULL,0,12,26,7,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,7,PRICE_CLOSE,MODE_MAIN,1);  
   SignalCurrent=iMACD(NULL,0,12,26,7,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,7,PRICE_CLOSE,MODE_SIGNAL,1);
      
	if ( Ask < nfx-sq && nfx > nfx1  )  
		{
		ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,3,Ask-StopLoss*sq,Ask+TakeProfits*sq,"UltimateTool",16384,0,Green)
		;
		if(ticket>0)
			{
			if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
			}
		else Print("Error opening BUY order : ",GetLastError()); 
		return(0);
		}
		
		
	//SELL
	 if( Bid > nfx+sq && nfx < nfx1 )
     {
      ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,3,Bid+StopLoss*sq,Bid-TakeProfits*sq,"macd sample",16384,0,Red);
      if(ticket>0)
        {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
        }
      else Print("Error opening SELL order : ",GetLastError()); 
      return(0); 
     }
  
	
      
  int cnt;

 
   for(cnt=0;cnt<total;cnt++)
  {
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   if(OrderType()<=OP_SELL &&   // check for opened position 
      OrderSymbol()==Symbol())  // check for symbol
     {
      if(OrderType()==OP_BUY)   // long position is opened
        {
         // should it be closed?
         if(
            
           Bid >= nfx 
            
                        
            )
             {
              OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
              return(0); // exit
             }
         // check for trailing stop
         
        
        
        }
      else // go to short position
        {
         // should it be closed?
         if(
           
            Ask <= nfx 
          
            )
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
            return(0); // exit
           }
         // check for trailing stop
        
        }
     }
  }


    }
//=================================================================
Sleep(5000);
return(0);
}//end of program





//+------------------------------------------------------------------+

void af_Gauss(int n, double& a[][],double& b[], double& x[]) {
  int i,j,k,l;
  double q,m,t;

  for(k=1; k<=n-1; k++) 
  {
    l=0; 
    m=0; 
    for(i=k; i<=n; i++) 
    {
      if (MathAbs(a[i,k])>m) {m=MathAbs(a[i,k]); l=i;}
    } 
    if (l==0) return(0);   

    if (l!=k) 
    {
      for(j=1; j<=n; j++) 
      {
        t=a[k,j]; 
        a[k,j]=a[l,j]; 
        a[l,j]=t;
      } 
      t=b[k]; 
      b[k]=b[l]; 
      b[l]=t;
    }  

    for(i=k+1;i<=n;i++) 
    {
      q=a[i,k]/a[k,k]; 
      for(j=1;j<=n;j++) 
      {
        if (j==k) a[i,j]=0; 
        else 
        a[i,j]=a[i,j]-q*a[k,j];
      } 
      b[i]=b[i]-q*b[k];
    }
  }  
  
  x[n]=b[n]/a[n,n]; 
  
  for(i=n-1;i>=1;i--) 
  {
    t=0; 
    for(j=1;j<=n-i;j++) 
    {
      t=t+a[i,i+j]*x[i+j]; 
      x[i]=(1/a[i,i])*(b[i]-t);
    }
  }
}
//===========================================================================

